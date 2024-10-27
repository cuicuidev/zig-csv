const std = @import("std");

const csv = @import("root.zig");

const heap = std.heap;
const fs = std.fs;
const io = std.io;
const testing = std.testing;

// SETUP
const csv_config = csv.CsvConfig.csv();
const ssv_config = csv.CsvConfig.ssv();
const psv_config = csv.CsvConfig.psv();
const tsv_config = csv.CsvConfig.tsv();

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
    \\
;

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
    \\
;

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
    \\
;

const slice_iris_tsv = "\"sepal.length\"\t\"sepal.width\"\t\"petal.length\"\t\"petal.width\"\t\"variety\"\n5.1\t3.5\t1.4\t.2\t\"Setosa\"\n7\t3.2\t4.7\t1.4\t\"Versicolor\"\n6.3\t3.3\t6\t2.5\t\"Virginica\"\n";

// TESTS
test "reader 512bytes iris.csv" {
    var allocator = testing.allocator;
    var file = try fs.cwd().openFile("src/data/iris.csv", .{});
    var tokenizer = try csv.CsvReaderTokenizer(csv_config).init(&allocator, file.reader(), 512);
    defer tokenizer.deinit();
    try tokenizer.tokenize();
    try testing.expectEqual(1510, tokenizer.tokenizer.tokens.items.len);
}

test "reader 8192bytes iris.csv" {
    var allocator = testing.allocator;
    var file = try fs.cwd().openFile("src/data/iris.csv", .{});
    var tokenizer = try csv.CsvReaderTokenizer(csv_config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();
    try tokenizer.tokenize();
    try testing.expectEqual(1510, tokenizer.tokenizer.tokens.items.len);
}

test "reader iter 512bytes iris.csv" {
    var allocator = testing.allocator;
    var file = try fs.cwd().openFile("src/data/iris.csv", .{});
    var tokenizer = try csv.CsvReaderTokenizer(csv_config).init(&allocator, file.reader(), 512);
    defer tokenizer.deinit();
    while (try tokenizer.next()) |token| {
        token.deinit();
    }
    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}

test "reader iter 8192bytes iris.csv" {
    var allocator = testing.allocator;
    var file = try fs.cwd().openFile("src/data/iris.csv", .{});
    var tokenizer = try csv.CsvReaderTokenizer(csv_config).init(&allocator, file.reader(), 8192);
    defer tokenizer.deinit();
    while (try tokenizer.next()) |token| {
        token.deinit();
    }
    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}

test "slice iris_csv" {
    var allocator = testing.allocator;
    var tokenizer = csv.CsvSliceTokenizer(csv_config).init(&allocator, slice_iris);
    defer tokenizer.deinit();
    try tokenizer.tokenize();
    try testing.expectEqual(90, tokenizer.tokenizer.tokens.items.len);
}

test "slice iter iris_csv" {
    var allocator = testing.allocator;
    var tokenizer = csv.CsvSliceTokenizer(csv_config).init(&allocator, slice_iris);
    defer tokenizer.deinit();
    while (try tokenizer.next()) |token| {
        token.deinit();
    }
    try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
}

test "slice iris_ssv" {
    var allocator = testing.allocator;
    var tokenizer = csv.CsvSliceTokenizer(ssv_config).init(&allocator, slice_iris_ssv);
    defer tokenizer.deinit();
    try tokenizer.tokenize();
    try testing.expectEqual(90, tokenizer.tokenizer.tokens.items.len);
}

test "slice iris_psv" {
    var allocator = testing.allocator;
    var tokenizer = csv.CsvSliceTokenizer(psv_config).init(&allocator, slice_iris_psv);
    defer tokenizer.deinit();
    try tokenizer.tokenize();
    try testing.expectEqual(90, tokenizer.tokenizer.tokens.items.len);
}

test "slice iris_tsv" {
    var allocator = testing.allocator;
    var tokenizer = csv.CsvSliceTokenizer(tsv_config).init(&allocator, slice_iris_tsv);
    defer tokenizer.deinit();
    try tokenizer.tokenize();
    try testing.expectEqual(40, tokenizer.tokenizer.tokens.items.len);
}
