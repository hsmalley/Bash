#!/bin/bash
set -o nounset
set -o errexit

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -N logdrop
iptables -N TCP
iptables -N UDP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i enp5s0 -j ACCEPT
iptables -A INPUT -i enp6s0 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-rst
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable
iptables -A TCP -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH"
iptables -A TCP -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS"
iptables -A TCP -p tcp --dport 32400 -j ACCEPT -m comment --comment "PLEX"
iptables -A TCP -p tcp --dport 32443 -j ACCEPT -m comment --comment "SSL PLEX"
iptables -A UDP -p udp --dport 53 -j ACCEPT -m comment --comment "DNS"
iptables -A INPUT -p tcp -m tcp --dport 111 -j ACCEPT -m comment --comment "NFS"
iptables -A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT -m comment --comment "NFS"
iptables -A INPUT -p tcp -m tcp --dport 20048 -j ACCEPT -m comment --comment "NFS"
iptables -A INPUT -p udp -m udp --dport 111 -j ACCEPT -m comment --comment "NFS"
iptables -A INPUT -p udp -m udp --dport 2049 -j ACCEPT -m comment --comment "NFS"
iptables -A INPUT -p udp -m udp --dport 20048 -j ACCEPT -m comment --comment "NFS"
iptables -N IN_SSH -m comment --comment "SSH BRUTE FORCE PROTECTION"
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -j IN_SSH -m comment --comment "SSH BRUTE FORCE PROTECTION"
iptables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 3 --seconds 10 -j DROP -m comment --comment "SSH BRUTE FORCE PROTECTION"
iptables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 4 --seconds 1800 -j DROP -m comment --comment "SSH BRUTE FORCE PROTECTION"
iptables -A IN_SSH -m recent --name sshbf --set -j ACCEPT -m comment --comment "SSH BRUTE FORCE PROTECTION"

rm /etc/iptables/iptables.rules
iptables-save > /etc/iptables/iptables.rules
systemctl reload iptables


