/// Config struct that holds the column separator character, the row separator character and the quotes character.
pub const CsvConfig = struct {
    delimiter: u8,
    terminator: u8,
    text_qualifier: u8,
    ignore_slash_r: bool,

    const Self = @This();

    pub fn csv() Self {
        return .{ .delimiter = ',', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }

    pub fn tsv() Self {
        return .{ .delimiter = '\t', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }

    pub fn ssv() Self {
        return .{ .delimiter = ';', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }

    pub fn psv() Self {
        return .{ .delimiter = '|', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }
};
