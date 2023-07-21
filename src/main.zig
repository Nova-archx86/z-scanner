//-------------------------
const std = @import("std");
const ap = @import("args");
//-------------------------

//-----------------------------
const zs = @import("zscan.zig");
//-----------------------------

//----------------------------------------------
const fmt = std.fmt;
const eql = std.mem.eql;
const testing = std.testing;
const string = []const u8;
const stdout = std.io.getStdOut().writer();
//----------------------------------------------

fn printUsage() !void {
    try stdout.print("Usage: [Options] <TargetIP> <TargetPort>\n", .{});
}

fn printHelp() !void {
    try printUsage();
    try stdout.print("\n-h Prints this message.\n", .{});
}

pub fn main() !u8 {
    const alloc = std.heap.page_allocator;
    const options = ap.parseForCurrentProcess(struct {
        host: ?string = null,
        @"port-range": ?string = null,
        quiet: bool = false,
        all: bool = false,

        pub const shorthands = .{
            .p = "port-range",
            .q = "quiet",
            .a = "all",
            .h = "host",
        };
    }, alloc, .print) catch return 1;

    defer options.deinit();
    std.debug.print("executable name: {?s}\n", .{options.executable_name});

    std.debug.print("parsed options:\n", .{});
    inline for (std.meta.fields(@TypeOf(options.options))) |fld| {
        std.debug.print("\t{s} = {any}\n", .{
            fld.name,
            @field(options.options, fld.name),
        });
    }

    return 0;
}

// Good enough for testing basic scan() functionality
// can't really test for default open ports since
// every os has different defaults and services
// localhost:6969 should *normally* be closed by default no matter what

test "scan localhost" {
    var res = try zs.scan("localhost", 6969);
    testing.expect(res == zs.PortState.CLOSED) catch unreachable;
}
