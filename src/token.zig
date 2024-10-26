const std = @import("std");
const mem = std.mem;
const fs = std.fs;

/// The type of the token
pub const TokenType = enum {
    INT,
    FLOAT,
    STRING,
    COL_SEP,
    ROW_SEP,
};

/// This struct holds the token
pub const Token = struct {
    allocator: *mem.Allocator,
    value: []const u8,
    token_type: TokenType,

    const Self = @This();

    pub fn init(allocator: *mem.Allocator, value: []const u8, token_type: TokenType) !Self {
        const val = try allocator.alloc(u8, value.len);
        mem.copyForwards(u8, val, value);
        return .{ .allocator = allocator, .value = val, .token_type = token_type };
    }

    pub fn deinit(self: *const Self) void {
        self.allocator.free(self.value);
    }

    pub fn printRepr(self: *const Self, writer: fs.File.Writer) !void {
        try writer.print("Token{{ .value=\"", .{});
        for (self.value) |c| {
            if (c == '\n') {
                try writer.writeAll("\\n");
            } else {
                try writer.print("{c}", .{c});
            }
        }
        try writer.print("\", .token_type = {} }}\n", .{self.token_type});
    }
};
