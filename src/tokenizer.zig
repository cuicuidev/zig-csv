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

/// Reads a file and tokenizes the contents following the CsvConfig rules.
/// CsvConfig must be comptime known value.
/// Does not currently support lazy loading, so the buffer size must be big enough to hold the entire csv in memory.
pub fn CsvReaderTokenizer(comptime config: CsvConfig) type {
    return struct {
        allocator: *mem.Allocator,
        reader: fs.File.Reader,
        buffer: []u8,
        bytes_read: usize,
        carryover_buffer: std.ArrayList(u8),
        crawler: Crawler,
        tokens: std.ArrayList(Token),
        state: State,

        const Self = @This();

        /// Constructor.
        /// Takes a ptr to an allocator, a reader and a buffer size as arguments.
        pub fn read(allocator: *mem.Allocator, reader: fs.File.Reader, buffer_size: usize) !Self {
            const buffer = allocator.alloc(u8, buffer_size) catch @panic("Unable to allocate buffer");
            const bytes_read = try reader.read(buffer);
            return .{ .allocator = allocator, .reader = reader, .buffer = buffer, .bytes_read = bytes_read, .carryover_buffer = std.ArrayList(u8).init(allocator.*), .crawler = Crawler.init(), .tokens = std.ArrayList(Token).init(allocator.*), .state = State.NEW_TOKEN };
        }

        /// Destructor.
        /// Deinits all dynamic structs and frees the buffer.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
            self.carryover_buffer.deinit();
            for (self.tokens.items) |*token| {
                token.deinit();
            }
            self.tokens.deinit();
        }

        /// Tokenizes the whole file and stores all the tokens in the .tokens attribute
        pub fn tokenize(self: *Self) !void {
            while (true) {
                if (self.bytes_read == 0) break;
                try self.tokenizeBuffer();
            }
        }

        /// Iterator interface to get the tokens one by one
        pub fn next(self: *Self) !?Token {
            while (true) {
                if (self.bytes_read == 0) return null;
                return self.nextToken() catch |err| {
                    switch (err) {
                        error.BufferReset => continue,
                        else => return err,
                    }
                };
            }
        }

        fn tokenizeBuffer(self: *Self) !void {
            while (self.crawler.end < self.bytes_read) {
                try self.nextChar();
            } else {
                try self.carryover_buffer.appendSlice(self.buffer[self.crawler.start..self.crawler.end]);
                self.bytes_read = try self.reader.read(self.buffer);
                self.crawler.drop();
            }
        }

        fn nextToken(self: *Self) !?Token {
            while (self.crawler.end < self.bytes_read) {
                try self.nextChar();
                if (self.state == State.COMPLETE_TOKEN) {
                    return self.tokens.pop();
                } else {
                    continue;
                }
            } else {
                if (self.state != State.COMPLETE_TOKEN) {
                    try self.carryover_buffer.appendSlice(self.buffer[self.crawler.start..self.crawler.end]);
                }
                self.bytes_read = try self.reader.read(self.buffer);
                self.crawler.drop();
                return error.BufferReset;
            }
            return null;
        }

        fn nextChar(self: *Self) !void {
            const char: u8 = self.buffer[self.crawler.end];
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
                '\r' => self.crawler.jump(1),
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

            mem.copyForwards(u8, slice[carryover_buffer_len..], self.buffer[self.crawler.start..self.crawler.end]);

            const token = try Token.init(self.allocator, slice, token_type);
            try self.tokens.append(token);
            self.state = State.COMPLETE_TOKEN;
        }
    };
}

pub fn CsvSliceTokenizer(comptime config: CsvConfig) type {
    return struct {
        allocator: *mem.Allocator,
        slice: []const u8,
        crawler: Crawler,
        tokens: std.ArrayList(Token),
        state: State,

        const Self = @This();

        /// Constructor.
        /// Takes a ptr to an allocator, a reader and a buffer size as arguments.
        pub fn read(allocator: *mem.Allocator, slice: []const u8) Self {
            const tokens = std.ArrayList(Token).init(allocator.*);
            return .{ .allocator = allocator, .slice = slice, .crawler = Crawler.init(), .tokens = tokens, .state = State.NEW_TOKEN };
        }

        /// Destructor.
        /// Deinits all dynamic structs and frees the buffer.
        pub fn deinit(self: *Self) void {
            for (self.tokens.items) |*token| {
                token.deinit();
            }
            self.tokens.deinit();
        }

        /// Tokenizes the whole file and stores all the tokens in the .tokens attribute
        pub fn tokenize(self: *Self) !void {
            while (self.crawler.end < self.slice.len) {
                try self.nextChar();
            }
        }

        /// Iterator interface to get the tokens one by one
        pub fn next(self: *Self) !?Token {
            while (self.crawler.end < self.slice.len) {
                try self.nextChar();
                if (self.state == State.COMPLETE_TOKEN) {
                    return self.tokens.pop();
                } else {
                    continue;
                }
            }
            return null;
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
                    self.crawler.crawl();
                    self.crawler.pull();
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
            const slice: []const u8 = self.slice[self.crawler.start..self.crawler.end];
            const token = try Token.init(self.allocator, slice, token_type);
            try self.tokens.append(token);
            self.state = State.COMPLETE_TOKEN;
        }
    };
}
