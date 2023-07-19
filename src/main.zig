const std = @import("std");
const scanner = @import("zscan");

const fmt = std.fmt;
const eql = std.mem.eql;
const testing = std.testing;
const string = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const stdout = std.io.getStdOut().writer();

fn printUsage() !void {
    try stdout.print("Usage: [Options] <TargetIP> <TargetPort>\n", .{});
}

fn printHelp() !void {
    try printUsage();
    try stdout.print("\n-h Prints this message.\n", .{});
}

pub fn main() !void {
    const galloc = gpa.allocator();
    const args = try std.process.argsAlloc(galloc);

    var hPort: u16 = undefined;
    // var host: string = undefined;

    if (args.len == 1) {
        try printUsage();
    } else if (eql(u8, args[1], "-h")) {
        try printHelp();
    } else if (eql(u8, args[1], "-p")) {
        if (args.len > 2) {
            hPort = try std.fmt.parseInt(u16, args[2], 10);
        } else {
            try printHelp();
        }
    }

    try stdout.print("args: {s}\n", .{args});
    try stdout.print("hPort: {any}\n", .{hPort});

    std.process.argsFree(galloc, args);
    _ = gpa.deinit();
}

// Good enough for testing basic scan() functionality
// can't really test for default open ports since
// every os has different defaults and services
// localhost:6969 should *normally* be closed by default no matter what

test "closed port result" {
    var res = try scanner.scan("localhost", 6969);
    testing.expect(res.status == scanner.PortStatus.CLOSED) catch unreachable;
}
