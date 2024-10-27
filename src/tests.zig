const std = @import("std");

const csv = @import("root.zig");

const heap = std.heap;
const fs = std.fs;
const io = std.io;
const testing = std.testing;

const config = csv.CsvConfig.csv();

// **START** READER TOKENIZATION TESTS USING THE IRIS DATASET CSV
test "full tokenization 512 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/iris.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 512);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1510, tokenizer.tokenizer.tokens.items.len);
}

test "full tokenization 8192 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/iris.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1510, tokenizer.tokenizer.tokens.items.len);
}

test "iterator tokenization 512 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/iris.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 512);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}

test "iterator tokenization 8192 bytes buffer iris" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/iris.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}

// **END** READER TOKENIZATION TESTS USING THE IRIS DATASET CSV
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// **START** READER TOKENIZATION TESTS USING THE KVKS BOUNCESHOT CSV
test "full tokenization 512 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 512);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1427, tokenizer.tokenizer.tokens.items.len);
}

test "full tokenization 8192 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(1427, tokenizer.tokenizer.tokens.items.len);
}

test "iterator tokenization 512 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 512);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}

test "iterator tokenization 8192 bytes buffer bounceshot" {
    var allocator = testing.allocator;

    var file = try fs.cwd().openFile("src/data/bounceshot.csv", .{});

    var tokenizer = try csv.CsvReaderTokenizer(config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}
// **END** READER TOKENIZATION TESTS USING THE IRIS DATASET CSV
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// **START** SLICE TOKENIZATION TESTS
const slice_bounceshot =
    \\Kill #,Timestamp,Bot,Weapon,TTK,Shots,Hits,Accuracy,Damage Done,Damage Possible,Efficiency,Cheated,OverShots
    \\1,15:07:37.574,High,b180 pistol,0.000000s,1,1,1.000000,50.000000,125.000000,0.400000,0,0
    \\2,15:07:38.640,Mid,b180 pistol,0.000000s,1,1,1.000000,50.000000,125.000000,0.400000,0,0
    \\
    \\Weapon,Shots,Hits,Damage Done,Damage Possible,,Sens Scale,Horiz Sens,Vert Sens,FOV,Hide Gun,Crosshair,Crosshair Scale,Crosshair Color,ADS Sens,ADS Zoom Scale
    \\b180 pistol,66,46,2300.0,8250.0,
    \\
    \\Game Version:,3.5.4.2024-05-24-14-41-42-7f44301bd0
    \\Challenge Start:,15:07:36.204
    \\Pause Count:,0
    \\
    \\Input Lag:,0
    \\Max FPS (config):,999.0
    \\Sens Scale:,Valorant
;

test "full slice tokenization bounceshot" {
    var allocator = testing.allocator;

    var tokenizer = csv.CsvSliceTokenizer(config).init(&allocator, slice_bounceshot);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(145, tokenizer.tokenizer.tokens.items.len);
}

test "iterator slice tokenization bounceshot" {
    var allocator = testing.allocator;

    var tokenizer = csv.CsvSliceTokenizer(config).init(&allocator, slice_bounceshot);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}
// **END** SLICE TOKENIZATION TESTS USING THE IRIS DATASET CSV
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// **START** SLICE TOKENIZATION TESTS USING THE KVKS BOUNCESHOT CSV
const slice_iris =
    \\"sepal.length","sepal.width","petal.length","petal.width","variety"
    \\5.1,3.5,1.4,.2,"Setosa"
    \\4.9,3,1.4,.2,"Setosa"
    \\7,3.2,4.7,1.4,"Versicolor"
    \\6.4,3.2,4.5,1.5,"Versicolor"
    \\6.9,3.1,4.9,1.5,"Versicolor"
    \\6.3,3.3,6,2.5,"Virginica"
    \\5.8,2.7,5.1,1.9,"Virginica"
    \\7.1,3,5.9,2.1,"Virginica"
;

test "full slice tokenization iris" {
    var allocator = testing.allocator;

    var tokenizer = csv.CsvSliceTokenizer(config).init(&allocator, slice_iris);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(89, tokenizer.tokenizer.tokens.items.len);
}

test "iterator slice tokenization iris" {
    var allocator = testing.allocator;

    var tokenizer = csv.CsvSliceTokenizer(config).init(&allocator, slice_iris);
    defer tokenizer.deinit();

    while (try tokenizer.next()) |token| {
        token.deinit();
    }

    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}
// **END** SLICE TOKENIZATION TESTS USING THE IRIS DATASET CSV
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// **START** DEFAULTS FOR CSV CONFIG
const slice_iris_ssv =
    \\"sepal.length";"sepal.width";"petal.length";"petal.width";"variety"
    \\5.1;3.5;1.4;.2;"Setosa"
    \\4.9;3;1.4;.2;"Setosa"
    \\7;3.2;4.7;1.4;"Versicolor"
    \\6.4;3.2;4.5;1.5;"Versicolor"
    \\6.9;3.1;4.9;1.5;"Versicolor"
    \\6.3;3.3;6;2.5;"Virginica"
    \\5.8;2.7;5.1;1.9;"Virginica"
    \\7.1;3;5.9;2.1;"Virginica"
;

const ssv_config = csv.CsvConfig.ssv();

test "full slice tokenization iris using ssv" {
    var allocator = testing.allocator;

    var tokenizer = csv.CsvSliceTokenizer(ssv_config).init(&allocator, slice_iris_ssv);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(89, tokenizer.tokenizer.tokens.items.len);
}

const slice_iris_psv =
    \\"sepal.length"|"sepal.width"|"petal.length"|"petal.width"|"variety"
    \\5.1|3.5|1.4|.2|"Setosa"
    \\4.9|3|1.4|.2|"Setosa"
    \\7|3.2|4.7|1.4|"Versicolor"
    \\6.4|3.2|4.5|1.5|"Versicolor"
    \\6.9|3.1|4.9|1.5|"Versicolor"
    \\6.3|3.3|6|2.5|"Virginica"
    \\5.8|2.7|5.1|1.9|"Virginica"
    \\7.1|3|5.9|2.1|"Virginica"
;

const psv_config = csv.CsvConfig.psv();

test "full slice tokenization iris using psv" {
    var allocator = testing.allocator;

    var tokenizer = csv.CsvSliceTokenizer(psv_config).init(&allocator, slice_iris_psv);
    defer tokenizer.deinit();

    try tokenizer.tokenize();

    try testing.expectEqual(89, tokenizer.tokenizer.tokens.items.len);
}

// const slice_iris_tsv =
//     \\"sepal.length","sepal.width","petal.length","petal.width","variety"
//     \\5.1,3.5,1.4,.2,"Setosa"
//     \\4.9,3,1.4,.2,"Setosa"
//     \\7,3.2,4.7,1.4,"Versicolor"
//     \\6.4,3.2,4.5,1.5,"Versicolor"
//     \\6.9,3.1,4.9,1.5,"Versicolor"
//     \\6.3,3.3,6,2.5,"Virginica"
//     \\5.8,2.7,5.1,1.9,"Virginica"
//     \\7.1,3,5.9,2.1,"Virginica"
// ;
