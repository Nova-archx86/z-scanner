const std = @import("std");

const net = std.net;
const log = std.log;
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
            log.err("Error whlie creating tcp socket!\n", .{});
            return err;
        },
    }
}
