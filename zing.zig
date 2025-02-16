const std = @import("std");
const stdout = std.io.getStdOut().writer();
const net = std.net;
const packet_size = 4096;
const icmp_data_len = 56;
pub fn main() anyerror!void {
    const sock = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.RAW, std.posix.IPPROTO.ICMP);
    try std.posix.setsockopt(sock, std.posix.SOL.SOCKET, std.posix.SO.DONTROUTE, &std.mem.toBytes(@as(c_int, 1)));
    //std.posix.sa_family
    const src_addr = try std.net.Address.parseIp4("127.0.0.1", 0);
    const dst_addr = try std.net.Address.parseIp4("127.0.0.1", 0);
    //https://datatracker.ietf.org/doc/html/rfc792
    //\x08 type 8 echo //\x00 code. always 0 msg0
    //\x00 \x00 checksum 16 bit              msg1
    //\x00 \x00 identifier. may be 0 16 bit  msg2
    //\x00 \x00 sequence may be 0 16 bit     msg3
    //ZI        data
    //\x5a \x49   Z I
    const msg0: u16 = 8 * 256;
    const msg1: u16 = 0;
    const msg2: u16 = 0;
    const msg3: u16 = 0;
    const msg4: u16 = 90 * 256 + 73;
    const sum = msg0 + msg1 + msg2 + msg3 + msg4;
    const csum = ~sum;
    const csum_lo = csum & 0xff;
    const csum_hi = (csum & 0xff00) >> 8;
    std.debug.print("msg {} {} {} {} {} = {}, csum {} low {} high {}\n", .{ msg0, msg1, msg2, msg3, msg4, sum, csum, csum_lo, csum_hi });
    const message = [_]u8{ 8, 0, csum_hi, csum_lo, 0, 0, 0, 0, 90, 73 };
    //https://stackoverflow.com/questions/20247551/icmp-echo-checksum
    const ping = try std.posix.sendto(sock, &message, 0, &dst_addr.any, dst_addr.getOsSockLen());
    // std.posix.sendto(sockfd: socket_t, buf: []const u8, flags: u32, dest_addr: ?*const sockaddr, addrlen: socklen_t)
    //std.posix.setsockopt(fd: socket_t, level: i32, optname: u32, opt: []const u8)
    //std.posix.SO.RCVBUF
    std.debug.print("socket: {any}\n", .{sock});
    std.debug.print("src: {any} dst: {any}\n", .{ src_addr, dst_addr });
    std.debug.print("ping {any}\n", .{ping});
    try stdout.print("OK\n", .{});
}

// socket (AF_INET, SOCK_RAW, IPPROTO_ICMP);
//https://github.com/coding-fans/linux-network-programming/blob/master/src/c/icmp/ping/ping.c
//https://linux.die.net/man/2/sendto
//https://github.com/neelkanth13/ipv4-and-ipv6-raw-sockets/blob/master/icmpv4%20ping%20packet%20raw%20socket%20code.c
//https://github.com/ziglang/zig/blob/86064e66d60241ae1c56c6852ebd1ad880edfcce/lib/std/net.zig#L245
//https://github.com/ziglang/zig/blob/master/lib/libc/include/any-linux-any/linux/icmp.h
//https://github.com/ziglang/zig/blob/master/lib/libc/include/generic-glibc/bits/socket.h
//https://github.com/ziglang/zig/blob/master/lib/libc/include/generic-glibc/bits/socket_type.h
