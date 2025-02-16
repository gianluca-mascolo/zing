const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() anyerror!void {
    try stdout.print("OK\n", .{});
}
