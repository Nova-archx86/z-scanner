const std = @import("std");
const clap = @import("clap");

const log = std.log;
const net = std.net;
const testing = std.testing;
const string = []const u8;
const stdout = std.io.getStdOut().writer();
const alloc = std.heap.page_allocator;

pub const PortState = enum {
    OPEN,
    CLOSED,
};

pub fn scan(host: string, port: u16) !PortState {
    if (net.tcpConnectToHost(alloc, host, port)) |res| {
        res.close();
        return PortState.OPEN;
    } else |err| switch (err) {
        error.ConnectionRefused => {
            return PortState.CLOSED;
        },

        else => {
            log.err("error whlie creating tcp socket!\n", .{});
            return err;
        },
    }
}

fn logArgs(res: anytype) !void {
    if (res.args.ports) |p| log.info("--ports: {s}\n", .{p});
    if (res.args.target) |t| log.info("--target: {s}\n", .{t});
}

pub fn main() !void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-l, --log      Log arguments passed to this program (useful when debuging)
        \\-p, --ports <str>   Specifys a single port or multiple ports Ex: -p 22 or -p 22-1023
        \\-t, --target <str>  Target hostname/ip address to scan
    );

    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{}) catch |err| {
        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
        return err;
    };

    if (res.args.help != 0) try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    if (res.args.log != 0) try logArgs(res);

    if (res.args.ports == null) try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
    if (res.args.target == null) try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);

    defer res.deinit();
}
