const std = @import("std");
const zargparse = @import("zargparse");
const ArgParser = zargparse.ArgumentParser;
const ParserArg = zargparse.ParserArg;
const ArgIterator = std.process.ArgIterator;
const ArrayList = std.ArrayList;
const stdout = std.io.getStdOut().writer();

pub fn getArgs(iter: *ArgIterator, arr: *ArrayList([]const u8)) !void {
    _ = iter.next();

    while (iter.next()) |arg| {
        try arr.append(arg);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // using an arena allocator so we don't need the denit for ArgParser
    var parser = ArgParser.init(allocator);
    var iter = try ArgIterator.initWithAllocator(allocator);
    var arr = ArrayList([]const u8).init(allocator);

    defer {
        parser.deinit();
        iter.deinit();
        arr.deinit();
    }

    try getArgs(&iter, &arr);

    try parser.addArgument(ParserArg{
        .name = "--dispatcher-server",
        .help = "dispatcher host :port, by default it uses localhost:8888",
        .default = "localhost:8888",
        .action = "store",
    });

    try parser.addArgument(ParserArg{
        .name = "repo",
        .metavar = "REPO",
        .arg_type = ParserArg.ArgType.STRING,
        .help = "path to the repository this will observe",
    });

    try parser.parseArgs(arr.items);

    if (parser.getValue("dispatcher_server")) |val| {
        var server = std.mem.splitSequence(u8, val.str, ":");

        const dispatcher_host = server.next() orelse std.debug.panic("missing dispatcher host\n", .{});
        const dispatcher_port = server.next() orelse std.debug.panic("missing dispatcher port\n", .{});

        try stdout.print("\nhost is {s}\nport is {s}", .{ dispatcher_host, dispatcher_port });
    }
}
