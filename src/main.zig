const std = @import("std");
const clap = @import("clap");

const utils = @import("utils.zig");

const log = std.log;
const net = std.net;
const testing = std.testing;
const string = []const u8;
const stdout = std.io.getStdOut().writer();
const alloc = std.heap.page_allocator;

const PortState = enum {
    OPEN,
    CLOSED,
};

fn scan(host: string, port: u16) !PortState {
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

pub fn main() !void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-p, --ports <str>   Specifys a single port or multiple ports Ex: -p 22 or -p 22-1023
        \\-t, --target <str>  Target hostname/ip address to scan
    );

    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{}) catch |err| {
        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
        return err;
    };

    if (res.args.help != 0) try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    if (res.args.ports == null and res.args.help == 0) try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
    if (res.args.target == null and res.args.help == 0) try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);

    var parsed_ports = std.mem.splitSequence(u8, res.args.ports.?, "-");

    // TODO: Figure out a way to specify a comptime array length
    // as this will not compile.
    // run zig build for more info.

    const host: string = res.args.target.?;
    comptime var itr_len: u16 = utils.getSequenceIteratorLen(&parsed_ports);

    const ports: [itr_len]u16 = undefined;
    var port = ports[0];
    var num_closed: u16 = 0;

    if (ports.len == 2) {
        const last_port = ports[1];

        while (port < last_port) {
            var state = scan(host, port) catch |err| return err;

            if (state == PortState.OPEN) {
                try stdout.print("Port {d}: {s}\n", .{ port, @tagName(state) });
            } else {
                num_closed += 1;
            }

            port += 1;
        }
    } else {
        const state = scan(host, port) catch |err| return err;

        if (state == PortState.OPEN) {
            try stdout.print("Port {d}: {s}\n", .{ port, @tagName(state) });
        } else {
            num_closed += 1;
        }
    }

    try stdout.print("{d} closed ports (conn refused)\n", .{num_closed});

    defer res.deinit();
}

test "scan localhost" {
    const result = try scan("localhost", 6969);
    try testing.expect(result == PortState.CLOSED);
}
