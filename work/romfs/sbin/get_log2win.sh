#! /bin/sh

echo $#

if [ "$#" == "0" ]; then
	echo "usage: "
	echo "one param:get_log2win.sh filename"
	echo "two params:get_log2win.sh filename srcip"
	echo "three params: get_log2win.sh filename srcip destip"
	exit 1
fi

ifconfig ra0 0.0.0.0
chmod a+r $1

if [ "$#" == "1" ]; then
	ifconfig eth2 192.168.11.88
	tftp  -l  $1  -r  $1  -p  192.168.11.30  69	
fi

if [ "$#" == "2" ]; then
	ifconfig eth2 $2
	tftp  -l  $1  -r  $1  -p  192.168.11.30  69	
fi

if [ "$#" == "3" ]; then
	ifconfig eth2 $2
	tftp  -l  $1  -r  $1  -p  $3  69	
fi

ifconfig eth2 0.0.0.0 down
udhcpc -i ra0 -s /sbin/udhcpc.sh -p /var/run/udhcpc.pid
