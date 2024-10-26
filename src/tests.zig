const std = @import("std");

const csv = @import("root.zig");

const heap = std.heap;
const fs = std.fs;
const io = std.io;
const testing = std.testing;

const config = csv.CsvConfig.default();

// **START** TOKENIZATION TESTS USING THE IRIS DATASET CSV
test "full tokenization 64 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/iris.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 64);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1510, tokenizer.tokens.items.len);
}

test "full tokenization 2048 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/iris.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 2048);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1510, tokenizer.tokens.items.len);
}

test "full tokenization 8192 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/iris.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1510, tokenizer.tokens.items.len);
}

test "iterator tokenization 64 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/iris.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 64);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokens.items.len);
}

test "iterator tokenization 2048 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/iris.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 2048);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokens.items.len);
}

test "iterator tokenization 8192 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/iris.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokens.items.len);
}

// **END** TOKENIZATION TESTS USING THE IRIS DATASET CSV
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// **START** TOKENIZATION TESTS USING THE KVKS BOUNCESHOT CSV
test "full tokenization 64 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 64);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1427, tokenizer.tokens.items.len);
}

test "full tokenization 2048 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 2048);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1427, tokenizer.tokens.items.len);
}

test "full tokenization 8192 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1427, tokenizer.tokens.items.len);
}

test "iterator tokenization 64 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 64);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokens.items.len);
}

test "iterator tokenization 2048 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 2048);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokens.items.len);
}

test "iterator tokenization 8192 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokens.items.len);
}
// **END** TOKENIZATION TESTS USING THE IRIS DATASET CSV
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// **START** ~~
