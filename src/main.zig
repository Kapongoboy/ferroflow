const std = @import("std");
const zargparse = @import("zargparse");
const ArgParser = zargparse.ArgumentParser;
const ParserArg = zargparse.ParserArg;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // using an arena allocator so we don't need the denit for ArgParser
    var parser = try ArgParser.init(allocator);

    try parser.add_argument(ParserArg{
        .name = "--dispatcher-server",
        .help = "dispatcher host :port, by default it uses localhost:8888",
        .default = "localhost:8888",
        .action = "store",
    });

    try parser.add_argument(ParserArg{
        .name = "repo",
        .metavar = "REPO",
        .arg_type = ParserArg.ArgType.STRING,
        .help = "path to the repository this will observe",
    });

    try parser.parseArgs();
}
