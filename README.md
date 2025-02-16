# zing
Ping but with Zig language

# Trying it

Current test with tcpdump. First is a message sent with regular ping
second is a message sent with zing

```
root@witty-xenon-1821:~# tcpdump -i lo -n -n -s0 -A proto \\icmp 
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on lo, link-type EN10MB (Ethernet), snapshot length 262144 bytes
21:48:55.507878 IP 127.0.0.1 > 127.0.0.1: ICMP echo request, id 3, seq 1, length 64
E..T.h@.@..>................7O.g....d....................... !"#$%&'()*+,-./01234567
21:48:55.507930 IP 127.0.0.1 > 127.0.0.1: ICMP echo reply, id 3, seq 1, length 64
E..T.i..@..=................7O.g....d....................... !"#$%&'()*+,-./01234567



21:49:05.840987 IP 127.0.0.1 > 127.0.0.1: ICMP type-#112, length 4
E.....@.@..K........ping
21:49:14.802517 IP 127.0.0.1 > 127.0.0.1: ICMP type-#112, length 4
E.....@.@...........ping
```
