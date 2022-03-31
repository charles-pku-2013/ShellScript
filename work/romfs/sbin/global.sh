#!/bin/sh

manufacturer="Camvie"
model="360j"
imageVer="0.0.2"

configPartition="/dev/mtdblock5"

networkType=`nvram_get 2860 OperationMode`
wifi_iface="ra0"
start_ip=1.1.1.244
end_ip=1.1.1.253
router_ip=1.1.1.254

#value_change="0"

ip_list="1.1.1.244
		1.1.1.245
		1.1.1.246
		1.1.1.247
		1.1.1.248
		1.1.1.249
		1.1.1.250
		1.1.1.251
		1.1.1.252
		1.1.1.253"

generate_udhcpd_config()
{
	echo "interface	ra0" > /etc/udhcpd.conf
	echo "start	$start_ip" >> /etc/udhcpd.conf
	echo "end $end_ip" >> /etc/udhcpd.conf
	echo "option subnet 255.255.255.0" >> /etc/udhcpd.conf
	echo "option router $router_ip" >> /etc/udhcpd.conf
}
	
change_route()
{
	route del -net 1.1.1.0 netmask 255.255.255.0 ra0
	for i in $ip_list
	do
		route add -host $i ra0
	done
}		

set_value()
{
	value="`nvram_get 2860 $1`"
	if [ "$value" != "$2" ]; then
		echo "change value of key $1 from $value to $2"
		nvram_set 2860 $1 "$2"
	fi
}

# for updating
imagefileUrl=`nvram_get 2860 UpdateURL`
#imagefileUrl="http://127.0.0.1/firmware/camvie/test.img"
checkfileUrl=$imagefileUrl".md5"
imagefile="/tmp/update.img"
checkfile="/tmp/update.md5"
imageDestFile="/usr/update.img"






