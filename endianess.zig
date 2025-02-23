const std = @import("std");

pub fn main() anyerror!void {
    const number: u16 = 42857;
    std.debug.print("number [u16] is {d} in decimal\n", .{number});
    std.debug.print("number [u16] is 0x{X} in hex\n", .{number});
    const upperbyte: u8 = @intCast((number & 0xFF00) >> 8);
    const lowerbyte: u8 = @intCast((number & 0x00FF));
    std.debug.print("number upperbyte: 0x{X} lowerbyte 0x{X}\n", .{ upperbyte, lowerbyte });
    std.debug.print("number upperbyte (dec): {d} lowerbyte (dec) {d}\n", .{ upperbyte, lowerbyte });
    const number_splitted: [2]u8 = @bitCast(number);
    std.debug.print("number splitted by bitcast is {X}\n", .{number_splitted});
    const number_join_by_bytes: u16 = @as(u16, upperbyte) * 256 + lowerbyte;
    const number_join_by_bitcast: u16 = @bitCast(number_splitted);
    std.debug.print("HB*256+LB={}, Bitcast Split={}\n", .{ number_join_by_bytes, number_join_by_bitcast });

    const num_vec: @Vector(2, u8) = [2]u8{ 167, 105 };
    //    const vect_bitcast: u16 = @bitCast(num_vec);
    const vect_bitcast: u16 = @byteSwap(@as(u16, @bitCast(num_vec)));
    const upper_vec: u8 = @intCast((vect_bitcast & 0xFF00) >> 8);
    const lower_vec: u8 = @intCast((vect_bitcast & 0x00FF));
    std.debug.print("number vector: {X} number bitcast: {}\n", .{ num_vec, vect_bitcast });
    std.debug.print("H: {X} L: {X}\n", .{ upper_vec, lower_vec });
}
