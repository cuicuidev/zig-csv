# zig-csv

A library that allows you to tokenize CSV data.

`v0.1.0`

---

## Features
- Tokenize CSV structured data using `CsvSliceTokenizer`. You can either use `.tokenize()` and keep all the tokens in memory as long as needed:
    ```zig
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

    test "slice iris_csv" {
        var allocator = testing.allocator;

        var tokenizer = csv.CsvSliceTokenizer(csv_config).init(&allocator, slice_iris);
        defer tokenizer.deinit();

        try tokenizer.tokenize();

        try testing.expectEqual(90, tokenizer.tokenizer.tokens.items.len);
    }
    ```

    Or you could use the iterator interface if you want to access the tokens only once and one at a time:

    ```zig
    test "slice iter iris_csv" {
        var allocator = testing.allocator;

        var tokenizer = csv.CsvSliceTokenizer(csv_config).init(&allocator, slice_iris);
        defer tokenizer.deinit();

        while (try tokenizer.next()) |token| {
            token.deinit(); // SET THEM FREE!!!
        }

        try testing.expectEqual(0, tokenizer.tokenizer.tokens.items.len);
    }
    ```

- You can also use `CsvReaderTokenizer` if you'd like to directly read from file:

    ```zig
    test "reader 512bytes iris.csv" {
        var allocator = testing.allocator;

        var file = try fs.cwd().openFile("src/data/iris.csv", .{});

        var tokenizer = try csv.CsvReaderTokenizer(csv_config).init(&allocator, file.reader(), 512);
        defer tokenizer.deinit();

        try tokenizer.tokenize();

        try testing.expectEqual(1510, tokenizer.tokenizer.tokens.items.len);
    }
    ```

    And this one also implements the iterator interface:

    ```zig
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
    ```

---

## Full documentation:

There is no comprehensive documentation as of now, but the library is not as big either. Feel free to check `src/tests.zig` for more examples.

## Issues:

Any bug you might find, any functionality you feel this might be missing, feel free to open an issue, I'll get to it ASAP!

PRs are also welcome, but please:
- Open an issue first and get in touch, I don't want you to put in the effort only to later find out that I don't need/want the contribution.
- Document the code and ensure that the interfaces are well understood.
- Any changes to the current code are also great, but please let me know how are they an improvement as compared to what we had previously.
- Focus on performance and modularity. Sometimes there should be a trade-off between the two, and it's not always clear which one is more important, but as long as it's documented and the alternative approach is presented, thats great.