0. For VirtualMachine, set the Network Adapter setting to NAT

1. Make sure to have the following packagages installed:
apt-get update && apt-get upgrade
apt-get install bridge-utils
apt-get install isc-dhcp-server
apt-get install mitmf

2. Make sure to have the file /etc/dhcp/dhcpd.conf
authoritative;
default-lease-time 3600;
max-lease-time 7200;
subnet 192.168.1.128 netmask 255.255.255.128 {
option subnet-mask 255.255.255.128;
option broadcast-address 192.168.1.128;
option routers 192.168.1.129;
option domain-name-servers 8.8.8.8;
range 192.168.1.130 192.168.1.140;
}

3. Run the scripts cleanup.sh first, then mitmf.sh

4. (optional) How to setup auto-proxy
	- create a file /home/proxy.pac
	function FindProxyForURL(url, host) {
    var proxy = "PROXY proxy-us-austin.gemalto.com:8080; DIRECT";
    var direct = "DIRECT";

    // no proxy for local hosts without domain:
    if(isPlainHostName(host)) return direct;

    // no proxy for local host:
    if (dnsDomainIs(host, "opennac.mydomain.com"))
    return direct;

    // proxy everything else:
    return proxy;
	}
	- run a proxy script server
	while true; do nc -l -p 80 -v -C -t -q 1 < proxy.pac ; done
	- Try to access proxy.pac
	wget http://192.168.1.129/proxy.pac
	- Update /etc/dhcp/dhcpd.conf
		authoritative;
		option local-proxy-config code 252 = text; 
		default-lease-time 3600;
		max-lease-time 7200;
		subnet 192.168.1.128 netmask 255.255.255.128 {
		option subnet-mask 255.255.255.128;
		option broadcast-address 192.168.1.128;
		option routers 192.168.1.129;
		option domain-name-servers 8.8.8.8;
		option local-proxy-config "http://localhost/proxy.pac";
		range 192.168.1.130 192.168.1.140;
		}


