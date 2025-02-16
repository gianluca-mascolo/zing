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
    const ping = try std.posix.sendto(sock, "ping", 0, &dst_addr.any, dst_addr.getOsSockLen());

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
