/// Config struct that holds the delimiter character, the terminator character the text qualifier character and
/// whether to ignore or not the \r character.
///
/// - delimiter: the actual separator. The big C in the CSV, the Comma. Although it could be something else such as a semicolon.
/// - terminator: the character that separates the rows from one another, which is typically the line break (\n).
/// - text_qualifier: the character that determines the start and end of a string.
/// - ignore_slash_r: if set to true, every \r character is ignored, otherwise the \r character will become it's own string type token.
pub const CsvConfig = struct {
    // TODO: implement an escape character.
    delimiter: u8,
    terminator: u8,
    text_qualifier: u8,
    ignore_slash_r: bool,

    const Self = @This();

    /// Returns the default CSV config with ',' as the delimiter, '\n' as the terminator and '"' as the text qualifier.
    pub fn csv() Self {
        return .{ .delimiter = ',', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }

    /// Returns the default TSV config with '\t' as the delimiter, '\n' as the terminator and '"' as the text qualifier.
    pub fn tsv() Self {
        return .{ .delimiter = '\t', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }

    /// Returns the default SSV config with ';' as the delimiter, '\n' as the terminator and '"' as the text qualifier.
    pub fn ssv() Self {
        return .{ .delimiter = ';', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }

    /// Returns the default PSV config with '|' as the delimiter, '\n' as the terminator and '"' as the text qualifier.
    pub fn psv() Self {
        return .{ .delimiter = '|', .terminator = '\n', .text_qualifier = '"', .ignore_slash_r = true };
    }
};
