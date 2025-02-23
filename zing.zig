const std = @import("std");
const endian = @import("builtin").target.cpu.arch.endian();
const stdout = std.io.getStdOut().writer();
const net = std.net;
const ECHO_TYPE: u8 = 8;
const MSG_LEN: u8 = 24; // bytes
const PAYLOAD = "ZigPingerZing%0123456789";
//https://datatracker.ietf.org/doc/html/rfc792
const icmp_packet = packed struct { type: u8 = ECHO_TYPE, code: u8 = 0, checksum: u16 = 0, identifier: u16 = 0, sequence: u16 = 0, data: @Vector(MSG_LEN, u8) };

const icmp_header = packed struct { version: u4, ihl: u4, tos: u8, total_len: u16, identification: u16, flags: u3, fragment_offset: u13, ttl: u8, protocol: u8, header_checksum: u16, src: u16, dst: u16, type: u8, code: u8, checksum: u16 };
fn icmp_checksum(seq: u16, msg: []const u8) [8 + MSG_LEN]u8 {
    var msg_vec: @Vector(MSG_LEN, u8) = [_]u8{0} ** MSG_LEN;
    //https://stackoverflow.com/questions/20247551/icmp-echo-checksum
    var data_sum: u16 = 0;
    for (0..MSG_LEN) |n| {
        msg_vec[n] = msg[n];
        if (n % 2 == 1) {
            const sum_overflow = @addWithOverflow(data_sum, @as(u16, msg[n - 1]) * 256 + msg[n]);
            data_sum = (sum_overflow[0] + sum_overflow[1]);
        }
    }
    const pkt_checksum: u16 = @as(u16, ECHO_TYPE) * 256 + seq + @as(u16, @intCast(data_sum & 0xFFFF));
    var pkt: icmp_packet = .{ .data = msg_vec };
    if (endian == .little) {
        pkt.checksum = @byteSwap(~pkt_checksum);
        pkt.sequence = @byteSwap(seq);
    } else {
        pkt.checksum = ~pkt_checksum;
        pkt.sequence = seq;
    }
    return @as([8 + MSG_LEN]u8, @bitCast(pkt));
}

pub fn main() anyerror!void {
    const sock = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.RAW, std.posix.IPPROTO.ICMP);
    defer std.posix.close(sock);
    try std.posix.setsockopt(sock, std.posix.SOL.SOCKET, std.posix.SO.DONTROUTE, &std.mem.toBytes(@as(c_int, 1)));
    var src_addr = try std.net.Address.parseIp4("127.0.0.1", 0);
    var src_len = src_addr.getOsSockLen();
    const dst_addr = try std.net.Address.parseIp4("127.0.0.1", 0);
    const echo_request = icmp_checksum(85, PAYLOAD);
    std.debug.print("echo request: {any}\n", .{echo_request});
    var echo_reply = [_]u8{0} ** (20 + 8 + MSG_LEN);
    const ping = try std.posix.sendto(sock, &echo_request, 0, &dst_addr.any, dst_addr.getOsSockLen());
    const pong = try std.posix.recvfrom(sock, &echo_reply, 0, &src_addr.any, &src_len);
    std.debug.print("echo reply: {any}\n", .{echo_reply});

    var icmp_header_vec: @Vector(20, u8) = [_]u8{0} ** 20;
    for (0..20) |n| {
        icmp_header_vec[n] = echo_reply[n];
    }

    const reply_header: icmp_header = @bitCast(icmp_header_vec);
    std.debug.print("reply header: {any}\n", .{reply_header});

    std.debug.print("ping {any}\n", .{ping});
    std.debug.print("pong {any}\n", .{pong});
    //https://book.huihoo.com/iptables-tutorial/x1078.htm
    try stdout.print("OK\n", .{});
}
