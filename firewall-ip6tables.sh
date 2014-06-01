#!/bin/bash
set -o nounset
set -o errexit

ip6tables -F
ip6tables -X
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -t mangle -F
ip6tables -t mangle -X
ip6tables -t raw -F
ip6tables -t raw -X
ip6tables -t security -F
ip6tables -t security -X
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

ip6tables -N logdrop
ip6tables -N TCP
ip6tables -N UDP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT
ip6tables -P INPUT DROP
ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -i enp5s0 -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
ip6tables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
ip6tables -A INPUT -p udp -j REJECT --reject-with icmp6-port-unreachable
ip6tables -A TCP -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH"
ip6tables -A TCP -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS"
ip6tables -A TCP -p tcp --dport 32400 -j ACCEPT -m comment --comment "PLEX"
ip6tables -A TCP -p tcp --dport 32443 -j ACCEPT -m comment --comment "SSL PLEX"
ip6tables -A UDP -p udp --dport 53 -j ACCEPT -m comment --comment "DNS"
ip6tables -A INPUT -p tcp -m tcp --dport 111 -j ACCEPT -m comment --comment "NFS"
ip6tables -A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT -m comment --comment "NFS"
ip6tables -A INPUT -p tcp -m tcp --dport 20048 -j ACCEPT -m comment --comment "NFS"
ip6tables -A INPUT -p udp -m udp --dport 111 -j ACCEPT -m comment --comment "NFS"
ip6tables -A INPUT -p udp -m udp --dport 2049 -j ACCEPT -m comment --comment "NFS"
ip6tables -A INPUT -p udp -m udp --dport 20048 -j ACCEPT -m comment --comment "NFS"
ip6tables -N IN_SSH -m comment --comment "SSH BRUTE FORCE PROTECTION"
ip6tables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -j IN_SSH -m comment --comment "SSH BRUTE FORCE PROTECTION"
ip6tables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 3 --seconds 10 -j DROP -m comment --comment "SSH BRUTE FORCE PROTECTION"
ip6tables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 4 --seconds 1800 -j DROP -m comment --comment "SSH BRUTE FORCE PROTECTION"
ip6tables -A IN_SSH -m recent --name sshbf --set -j ACCEPT -m comment --comment "SSH BRUTE FORCE PROTECTION"
ip6tables -A INPUT -s fe80::/64 -p icmpv6 -j ACCEPT
ip6tables -t raw -A PREROUTING -p icmpv6 -s fe80::/64 -j ACCEPT
ip6tables -t raw -A PREROUTING -m rpfilter -j ACCEPT
ip6tables -t raw -A PREROUTING -j DROP

rm /etc/iptables/ip6tables.rules
ip6tables-save > /etc/iptables/ip6tables.rules
systemctl reload ip6tables
