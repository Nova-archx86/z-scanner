const std = @import("std");
const SplitIterator = std.mem.SplitIterator;
const sequence = std.mem.DelimiterType.sequence;
const expect = std.testing.expect;
const string = []const u8;

// In our case the max size of a port is a u16...
pub fn getSequenceIteratorLen(itr: *SplitIterator(u8, sequence)) u16 {
    var count: u16 = 0;
    while (itr.next()) |i| {
        _ = i;
        count += 1;
    }

    return count;
}

test "get iterator length" {
    const str: string = "Port scanning is an art!";
    var words = std.mem.splitSequence(u8, str, " ");
    const iterLen = getSequenceIteratorLen(&words);
    try expect(iterLen == 5);
}
