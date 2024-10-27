const std = @import("std");
const mem = std.mem;
const fs = std.fs;

/// The token type specifies the semantics of each token.
pub const TokenType = enum {
    INT,
    FLOAT,
    STRING,
    DELIMITER,
    TERMINATOR,
};

/// A token is a substring that has semantic meaning within the context of a csv file structure. It has a value, which is a slice,
/// and a token_type, which holds the actual meaning of the slice. Also, since the value of a token is actually a copy of a slice,
/// the size of the token is unknown at compile time, thus it needs an allocator.
pub const Token = struct {
    allocator: *mem.Allocator,
    value: []const u8,
    token_type: TokenType,

    const Self = @This();

    /// Constructor
    /// Takes an ptr to an allocator, a slice and a TokenType. Allocates enough space to store a copy of the slice, copies it to the
    /// heap and returns the initialized Token struct.
    pub fn init(allocator: *mem.Allocator, value: []const u8, token_type: TokenType) !Self {
        const val = try allocator.alloc(u8, value.len);
        mem.copyForwards(u8, val, value);
        return .{ .allocator = allocator, .value = val, .token_type = token_type };
    }

    /// Destructor
    /// Frees the memory that holds the value field.
    pub fn deinit(self: *const Self) void {
        self.allocator.free(self.value);
    }

    /// Util method that takes a writer and writes a string representation of the token that looks something like this:
    /// Token{ .value = "value", .token_type = TokenType.STRING }
    pub fn writeRepr(self: *const Self, writer: fs.File.Writer) !void {
        try writer.print("Token{{ .value = \"", .{});
        for (self.value) |c| {
            if (c == '\n') {
                try writer.writeAll("\\n");
            } else {
                try writer.print("{c}", .{c});
            }
        }
        try writer.print("\", .token_type = {} }}", .{self.token_type});
    }
};
