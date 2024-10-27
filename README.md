# zig-csv

A library that allows you to parse, create and maniupalte CSV data.
`v0.1.0`
---

## Features
- Tokenize CSV structured data using `CsvTokenizer`. You can either use `.tokenize()` and keep all the tokens in memory as long as needed:
    ```zig
    const std = @import("std");

    const csv = @import("csv");

    const heap = std.heap;
    const fs = std.fs;
    const io = std.io;
    ```

    Or you could use the iterator interface if you don't need to store all the tokens at once:

    ```zig
    const std = @import("std");

    const csv = @import("csv");

    const heap = std.heap;
    const fs = std.fs;
    const io = std.io;
    ```

- Parse CSVs into a table format:

    ```zig
    const std = @import("std");

    const csv = @import("csv");

    const heap = std.heap;
    const fs = std.fs;
    const io = std.io;
    ```

    And manipulate the data as you wish!

    - Indexing:

        ```zig
        const std = @import("std");

        const csv = @import("csv");

        const heap = std.heap;
        const fs = std.fs;
        const io = std.io;
        ```

    - Filtering:

        ```zig
        const std = @import("std");

        const csv = @import("csv");

        const heap = std.heap;
        const fs = std.fs;
        const io = std.io;
        ```

    - Sorting:

        ```zig
        const std = @import("std");

        const csv = @import("csv");

        const heap = std.heap;
        const fs = std.fs;
        const io = std.io;
        ```

    - Grouping:

        ```zig
        const std = @import("std");

        const csv = @import("csv");

        const heap = std.heap;
        const fs = std.fs;
        const io = std.io;
        ```

    - Joining:

        ```zig
        const std = @import("std");

        const csv = @import("csv");

        const heap = std.heap;
        const fs = std.fs;
        const io = std.io;
        ```

---

## Full documentation:

