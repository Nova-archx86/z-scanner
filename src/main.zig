const std = @import("std");
const net = std.net;
const log = std.log;
const testing = std.testing;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = std.heap.page_allocator;
const stdout = std.io.getStdOut().writer();

const ScannerResult = enum {
    OPEN,
    CLOSED,
    NOTSET,
};

const ScannerReport = struct {
    host: []const u8,
    port: u16,
    status: ScannerResult,

    fn show(self: *ScannerReport) !void {
        const str_status = @tagName(self.status);
        try stdout.print("Host: {s}\nPort: {any}\nStatus: {s}\n", .{ self.host, self.port, str_status });
    }
};

fn scan(hostIp: []const u8, hostPort: u16) !ScannerReport {
    var report = ScannerReport{ .host = hostIp, .port = hostPort, .status = ScannerResult.NOTSET };

    if (net.tcpConnectToHost(alloc, hostIp, hostPort)) |res| {
        res.close();
        report.status = ScannerResult.OPEN;
        return report;
    } else |err| switch (err) {
        error.ConnectionRefused => {
            report.status = ScannerResult.CLOSED;
            return report;
        },

        else => {
            log.err("Error whlie creating tcp socket!\n", .{});
            return err;
        },
    }
}

pub fn main() !void {
    const galloc = gpa.allocator();
    const args = try std.process.argsAlloc(galloc);

    var report = try scan("localhost", 8000);
    try report.show();

    std.process.argsFree(galloc, args);
    _ = gpa.deinit();
}

// Good enough for testing basic scan() functionality
// can't really test for default open ports since
// every os has different defaults and services
// localhost:6969 should *normally* be closed by default no matter what

test "closed port result" {
    var res = try scan("localhost", 6969);
    testing.expect(res.status == ScannerResult.CLOSED) catch unreachable;
}
