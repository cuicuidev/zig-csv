const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const conf = @import("config.zig");
const CsvConfig = conf.CsvConfig;

const token = @import("token.zig");
const Token = token.Token;
const TokenType = token.TokenType;

pub fn Table(comptime config: CsvConfig) type {
    return struct {
        allocator: *mem.Allocator,
        config: CsvConfig,
        columns: std.ArrayList(Token),
        indices: std.ArrayList(Token),

        const Self = @This();

        pub fn init(allocator: *mem.Allocator) !Self {
            const columns = try std.ArrayList(Token).init(allocator.*);
            const indices = try std.ArrayList(Token).init(allocator.*);

            return .{
                .allocator = allocator,
                .config = config,
                .columns = columns,
                .indices = indices,
            };
        }

        pub fn deinit(self: *Self) void {
            self.columns.deinit();
            self.indices.deinit();
        }
    };
}
