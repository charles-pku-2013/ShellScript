#! /bin/sh

. /sbin/global.sh

iface="eth0"
mode=`nvram get ethernet_mode`

set -x

killall -q syslogd
killall -q udhcpc
killall -q pppd

ifconfig $wifi_iface down
set_value APMode 0

if [ "$mode" = "STATIC" ]; then
	ip=`nvram get ethernet_address`
	nm=`nvram get ethernet_netmask`
	gw=`nvram get ethernet_gateway`
	pd=`nvram get ethernet_primary_dns`
	sd=`nvram get ethernet_secondary_dns`
	ifconfig $iface $ip netmask $nm
	route del default
	if [ "$gw" != "" ]; then
		route add default gw $gw
	fi
	config-dns.sh $pd $sd	
elif [ "$mode" = "PPPOE" ]; then
	ifconfig $iface 0.0.0.0
	username=`nvram get wan_pppoe_user`
	password=`nvram get wan_pppoe_pass`
	pppoe_opmode=`nvram get wan_pppoe_opmode`
	if [ "$pppoe_opmode" = "OnDemand" ]; then
		idle_time=`nvram get wan_pppoe_idle`
		if [ "$idle_time" = "" ]; then
			idle_time="60"
		fi
		config-pppoe.sh $username $password $iface OnDemand $idle_time
	else
		config-pppoe.sh $username $password $iface KeepAlive
	fi
else
	# dhcp
	udhcpc -i $iface -s /sbin/udhcpc.sh -p /var/run/udhcpc.pid -q &
fi

check_ntp.sh


