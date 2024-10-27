const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const conf = @import("config.zig");
const CsvConfig = conf.CsvConfig;

const tok = @import("token.zig");
const Token = tok.Token;
const TokenType = tok.TokenType;

const Crawler = struct {
    start: usize,
    end: usize,

    const Self = @This();

    pub fn init() Self {
        return .{ .start = 0, .end = 0 };
    }

    pub fn crawl(self: *Self) void {
        self.end += 1;
    }

    pub fn pull(self: *Self) void {
        self.start = self.end;
    }

    pub fn drop(self: *Self) void {
        self.start = 0;
        self.end = 0;
    }

    pub fn jump(self: *Self, steps: usize) void {
        self.end += steps;
        self.pull();
    }
};

const State = enum { INT, FLOAT, STRING, QUOTED_STRING, COL_SEP, ROW_SEP, NEW_TOKEN, COMPLETE_TOKEN };

pub fn CsvReaderTokenizer(comptime config: CsvConfig) type {
    return struct {
        allocator: *mem.Allocator,
        reader: fs.File.Reader,
        buffer: []u8,
        bytes_read: ?usize,
        tokenizer: Tokenizer(config),

        const Self = @This();

        pub fn init(allocator: *mem.Allocator, reader: fs.File.Reader, buffer_size: usize) !Self {
            const buffer = try allocator.alloc(u8, buffer_size);
            return .{
                .allocator = allocator,
                .reader = reader,
                .buffer = buffer,
                .bytes_read = null,
                .tokenizer = Tokenizer(config).init(allocator, buffer),
            };
        }

        pub fn deinit(self: *Self) void {
            self.tokenizer.deinit();
            self.allocator.free(self.buffer);
        }

        pub fn tokenize(self: *Self) !void {
            self.bytes_read = try self.reader.read(self.buffer);
            while (true) {
                if (self.bytes_read == 0) break;
                try self.tokenizer.tokenize(self.bytes_read.?);
                self.bytes_read = try self.reader.read(self.buffer);
            }
        }

        pub fn next(self: *Self) !?Token {
            self.bytes_read = try self.reader.read(self.buffer);
            while (true) {
                if (self.bytes_read == 0) return null;
                const next_token = self.tokenizer.next(self.bytes_read.?);
                return next_token catch return null; // TODO: improve error handling
            }
        }
    };
}

pub fn CsvSliceTokenizer(comptime config: CsvConfig) type {
    return struct {
        allocator: *mem.Allocator,
        slice: []const u8,
        tokenizer: Tokenizer(config),

        const Self = @This();

        pub fn init(allocator: *mem.Allocator, slice: []const u8) Self {
            return .{
                .allocator = allocator,
                .slice = slice,
                .tokenizer = Tokenizer(config).init(allocator, slice),
            };
        }

        pub fn deinit(self: *Self) void {
            self.tokenizer.deinit();
        }

        pub fn tokenize(self: *Self) !void {
            try self.tokenizer.tokenize(self.slice.len);
        }

        pub fn next(self: *Self) !?Token {
            return try self.tokenizer.next(self.slice.len);
        }
    };
}

pub fn Tokenizer(comptime config: CsvConfig) type {
    return struct {
        allocator: *mem.Allocator,
        slice: []const u8,
        carryover_buffer: std.ArrayList(u8),
        crawler: Crawler,
        tokens: std.ArrayList(Token),
        state: State,

        const Self = @This();

        pub fn init(allocator: *mem.Allocator, slice: []const u8) Self {
            const tokens = std.ArrayList(Token).init(allocator.*);
            const carryover_buffer = std.ArrayList(u8).init(allocator.*);
            return .{
                .allocator = allocator,
                .slice = slice,
                .carryover_buffer = carryover_buffer,
                .crawler = Crawler.init(),
                .tokens = tokens,
                .state = State.NEW_TOKEN,
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.tokens.items) |*token| {
                token.deinit();
            }
            self.tokens.deinit();
            self.carryover_buffer.deinit();
        }

        pub fn tokenize(self: *Self, len: usize) !void {
            while (self.crawler.end < len) {
                try self.nextChar();
            } else {
                try self.setCarryover();
                self.crawler.drop();
            }
        }

        pub fn next(self: *Self, len: usize) !?Token {
            while (self.crawler.end < len) {
                try self.nextChar();
                if (self.state == State.COMPLETE_TOKEN) {
                    return self.tokens.pop();
                } else {
                    continue;
                }
            } else {
                if (self.state != State.COMPLETE_TOKEN) {
                    try self.setCarryover();
                }
                self.crawler.drop();
                return null;
            }
            return error.StopIteration;
        }

        fn setCarryover(self: *Self) !void {
            try self.carryover_buffer.appendSlice(self.slice[self.crawler.start..self.crawler.end]);
        }

        fn nextChar(self: *Self) !void {
            const char: u8 = self.slice[self.crawler.end];
            switch (self.state) {
                State.NEW_TOKEN => self.stateNewToken(char),
                State.INT => try self.stateInt(char),
                State.FLOAT => try self.stateFloat(char),
                State.STRING => try self.stateString(char),
                State.QUOTED_STRING => try self.stateQuotedString(char),
                State.COL_SEP => try self.stateComma(),
                State.ROW_SEP => try self.stateLineBreak(),
                State.COMPLETE_TOKEN => self.stateCompleteToken(),
            }
        }

        fn stateNewToken(self: *Self, char: u8) void {
            switch (char) {
                '0'...'9' => self.state = State.INT,
                config.delimiter => self.state = State.COL_SEP,
                config.terminator => self.state = State.ROW_SEP,
                config.text_qualifier => {
                    self.state = State.QUOTED_STRING;
                    self.crawler.jump(1);
                },
                '.' => self.state = State.FLOAT,
                '\r' => if (config.ignore_slash_r) self.crawler.jump(1),
                else => self.state = State.STRING,
            }
        }

        fn stateInt(self: *Self, char: u8) !void {
            switch (char) {
                '0'...'9' => self.crawler.crawl(),
                '.' => self.state = State.FLOAT,
                config.delimiter, config.terminator => try self.addToken(TokenType.INT),
                else => self.state = State.STRING,
            }
        }

        fn stateFloat(self: *Self, char: u8) !void {
            switch (char) {
                '0'...'9' => self.crawler.crawl(),
                config.delimiter, config.terminator => try self.addToken(TokenType.FLOAT),
                else => self.state = State.STRING,
            }
        }

        fn stateString(self: *Self, char: u8) !void {
            switch (char) {
                config.delimiter, config.terminator => try self.addToken(TokenType.STRING),
                else => self.crawler.crawl(),
            }
        }

        fn stateQuotedString(self: *Self, char: u8) !void {
            switch (char) {
                config.text_qualifier => {
                    try self.addToken(TokenType.STRING);
                    self.crawler.crawl();
                },
                else => self.crawler.crawl(),
            }
        }

        fn stateComma(self: *Self) !void {
            self.crawler.crawl();
            try self.addToken(TokenType.COL_SEP);
        }

        fn stateLineBreak(self: *Self) !void {
            self.crawler.crawl();
            try self.addToken(TokenType.ROW_SEP);
        }

        fn stateCompleteToken(self: *Self) void {
            self.crawler.pull();
            self.state = State.NEW_TOKEN;
        }

        fn addToken(self: *Self, token_type: TokenType) !void {
            var slice: []u8 = undefined;
            const carryover_buffer_len = self.carryover_buffer.items.len;
            const token_len: usize = carryover_buffer_len + self.crawler.end - self.crawler.start;

            slice = try self.allocator.alloc(u8, token_len);
            defer self.allocator.free(slice);

            if (carryover_buffer_len > 0) {
                mem.copyForwards(u8, slice[0..carryover_buffer_len], self.carryover_buffer.items);
                self.carryover_buffer.clearAndFree();
            }

            mem.copyForwards(u8, slice[carryover_buffer_len..], self.slice[self.crawler.start..self.crawler.end]);

            const token = try Token.init(self.allocator, slice, token_type);
            try self.tokens.append(token);
            self.state = State.COMPLETE_TOKEN;
        }
    };
}
