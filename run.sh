#!/usr/bin/env bash
iptables="sudo /usr/sbin/iptables"

function press() {
	echo ""
	if [ -z "$1" ]; then
		echo "=== Please press [enter] to continue"
	else 
		echo "=== Please press [enter] to continue with $1"
	fi
	read
}

press "testing initial setup (ping should work)"
ping -c 1 172.16.1.14 -W 1

press "blocking all incoming and outgoing traffic for 172.16.1.0/24"
$iptables -I OUTPUT 1 -d 172.16.1.0/24 -j DROP
$iptables -I INPUT 1 -d 172.16.1.0/24 -j DROP
ping -c 1 172.16.1.14 -W 1

press "allowing incoming clients"
$iptables -I INPUT 1 -p TCP -d 172.16.1.0/24 -j ACCEPT --dport 50000 
$iptables -I OUTPUT 1 -p TCP -d 172.16.1.0/24 -j ACCEPT --sport 50000

press "cleanup"
$iptables -D INPUT -p TCP -d 172.16.1.0/24 -j ACCEPT --dport 50000 
$iptables -D OUTPUT -p TCP -d 172.16.1.0/24 -j ACCEPT --sport 50000

press "allowing only client usage (UDP)"
$iptables -I INPUT 1 -p TCP -d 172.16.1.0/24 -j ACCEPT --sport 50000 
$iptables -I OUTPUT 1 -p TCP -d 172.16.1.0/24 -j ACCEPT --dport 50000
$iptables -I INPUT 1 -p UDP -d 172.16.1.0/24 -j ACCEPT --dport 50001
$iptables -I OUTPUT 1 -p UDP -d 172.16.1.0/24 -j ACCEPT --dport 50001

press "cleanup"
$iptables -D INPUT -p TCP -d 172.16.1.0/24 -j ACCEPT --sport 50000 
$iptables -D OUTPUT -p TCP -d 172.16.1.0/24 -j ACCEPT --dport 50000
$iptables -D INPUT -p UDP -d 172.16.1.0/24 -j ACCEPT --dport 50001
$iptables -D OUTPUT -p UDP -d 172.16.1.0/24 -j ACCEPT --dport 50001
# cleanup "Block all incoming and outgoging traffic for 172.16.1.0/24"
$iptables -D OUTPUT -d 172.16.1.0/24 -j DROP
$iptables -D INPUT -d 172.16.1.0/24 -j DROP

press "drop incoming ICMP and allow outgoing"
$iptables -I OUTPUT 1 -p ICMP --icmp-type echo-reply -d 172.16.1.0/24 -j ACCEPT
$iptables -I INPUT 1 -p ICMP --icmp-type echo-request -d 172.16.1.0/24 -j DROP

press "cleanup"
$iptables -D OUTPUT -p ICMP --icmp-type echo-reply -d 172.16.1.0/24 -j ACCEPT
$iptables -D INPUT -p ICMP --icmp-type echo-request -d 172.16.1.0/24 -j DROP

echo "bye"
