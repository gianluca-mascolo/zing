const std = @import("std");

pub fn main() anyerror!void {
    const number1: u16 = 42837;
    const number2: u16 = 37651;
    const sumoverflow: struct { @TypeOf(number1, number2), u1 } = @addWithOverflow(number1, number2);
    std.debug.print("sum: {any}\n", .{sumoverflow[0] + sumoverflow[1]});
}
