const std = @import("std");

const net = std.net;
const log = std.log;
const string = []const u8;
const stdout = std.io.getStdOut().writer();
const alloc = std.heap.page_allocator;

const PortStatus = enum {
    OPEN,
    CLOSED,
    NOTSET,
};

const ScannerReport = struct {
    host: string,
    port: u16,
    status: PortStatus,

    fn show(self: *ScannerReport) !void {
        const str_status = @tagName(self.status);
        try stdout.print("Host: {s}\nPort: {any}\nStatus: {s}\n", .{ self.host, self.port, str_status });
    }
};

fn scan(hostIp: string, hostPort: u16) !ScannerReport {
    var report = ScannerReport{ .host = hostIp, .port = hostPort, .status = PortStatus.NOTSET };

    if (net.tcpConnectToHost(alloc, hostIp, hostPort)) |res| {
        res.close();
        report.status = PortStatus.OPEN;
        return report;
    } else |err| switch (err) {
        error.ConnectionRefused => {
            report.status = PortStatus.CLOSED;
            return report;
        },

        else => {
            log.err("Error whlie creating tcp socket!\n", .{});
            return err;
        },
    }
}
