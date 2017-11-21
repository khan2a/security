#!/bin/bash
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -P FORWARD ACCEPT
service isc-dhcp-server stop
for pid in `ps -edf |egrep 'air|dhcpd|tail' | awk '{print $2}'`; do kill -9 $pid; done 2> /dev/null
