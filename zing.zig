const std = @import("std");
const endian = @import("builtin").target.cpu.arch.endian();
const stdout = std.io.getStdOut().writer();
const net = std.net;

//https://datatracker.ietf.org/doc/html/rfc792
const icmp_packet = packed struct { type: u8 = 8, code: u8 = 0, checksum: u16 = 0, identifier: u16 = 0, sequence: u16 = 0, data: u16 };

fn icmp_checksum(seq: u16, msg: *const [2]u8) [10]u8 {
    var data: u16 = 0;
    for (msg) |elem| {
        data <<= 8;
        data += elem;
    }
    var pkt: icmp_packet = .{ .identifier = 3, .sequence = 7, .data = data };
    //https://stackoverflow.com/questions/20247551/icmp-echo-checksum
    const pkt_sum: u16 = @as(u16, pkt.type) * 256 + pkt.code + pkt.identifier + pkt.sequence + pkt.data;
    pkt.checksum = ~pkt_sum;
    const pkt_vector: @Vector(5, u16) = @bitCast(pkt);
    var return_val: [10]u8 = undefined;
    if (endian == .little) {
        return_val = @bitCast(@byteSwap(pkt_vector));
    } else {
        return_val = @bitCast(pkt_vector);
    }
    std.debug.print("seq {} msg {any} data {} ret: {any}\n", .{ seq, msg, data, return_val });
    return return_val;
}

pub fn main() anyerror!void {
    const sock = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.RAW, std.posix.IPPROTO.ICMP);
    defer std.posix.close(sock);
    try std.posix.setsockopt(sock, std.posix.SOL.SOCKET, std.posix.SO.DONTROUTE, &std.mem.toBytes(@as(c_int, 1)));
    const dst_addr = try std.net.Address.parseIp4("127.0.0.1", 0);
    const echo_request = icmp_checksum(5, "AB");
    const ping = try std.posix.sendto(sock, &echo_request, 0, &dst_addr.any, dst_addr.getOsSockLen());
    std.debug.print("socket: {any}\n", .{sock});
    std.debug.print("dst: {any}\n", .{dst_addr});
    std.debug.print("ping {any}\n", .{ping});
    try stdout.print("OK\n", .{});
}
