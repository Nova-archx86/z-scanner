const std = @import("std");
const clap = @import("clap");

const log = std.log;
const net = std.net;
const testing = std.testing;

const string = []const u8;
const stdout = std.io.getStdOut().writer(); // Errors when cross compiling for x86_64-windows
const alloc = std.heap.page_allocator;
const parseInt = std.fmt.parseInt;

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

pub fn main() !u8 {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-p, --ports <str>   Specifys a single port or multiple ports Ex: -p 22 or -p 22-1023
        \\-t, --target <str>  Target hostname/ip address to scan
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{ .allocator = alloc, .diagnostic = &diag }) catch |err| {
        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
        try stdout.print("\n", .{});
        return err;
    };

    defer res.deinit();

    if (res.args.help != 0) {
        try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
        return 0;
    }

    if (res.args.ports == null and res.args.help == 0) {
        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
        try stdout.print("\n", .{});
        return 1;
    }

    if (res.args.target == null and res.args.help == 0) {
        try clap.usage(std.io.getStdErr().writer(), clap.Help, &params);
        try stdout.print("\n", .{});
        return 1;
    }

    // Using classic nmap style port args (e.g -p22-1023 or -p 22-1023)
    const host: string = res.args.target.?;

    var ports = [_]u16{ 0, 0 }; // stores two values representing the first port to scan and the last (if a range was provided)
    var index: u8 = 0;

    var str_ports = std.mem.splitSequence(u8, res.args.ports.?, "-");

    while (str_ports.next()) |p| {
        ports[index] = try parseInt(u16, p, 10);
        index += 1;
    }

    var num_closed: u16 = 0;
    var first_port = ports[0];

    // if the second slot is not filled (only one port was provided)
    if (ports[1] != 0) {
        const last_port = ports[1];

        while (first_port < last_port) {
            var state = scan(host, first_port) catch |err| return err;

            if (state == PortState.OPEN) {
                try stdout.print("Port {d}: {s}\n", .{ first_port, @tagName(state) });
            } else {
                num_closed += 1;
            }

            first_port += 1;
        }
    } else {
        const state = scan(host, first_port) catch |err| return err;

        if (state == PortState.OPEN) {
            try stdout.print("Port {d}: {s}\n", .{ first_port, @tagName(state) });
        } else {
            num_closed += 1;
        }
    }

    if (num_closed > 0) try stdout.print("Not shown: {d} closed ports (conn refused)\n", .{num_closed});

    return 0;
}

test "scan localhost" {
    const result = try scan("localhost", 6969);
    try testing.expect(result == PortState.CLOSED);
}
