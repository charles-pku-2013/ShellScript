#! /bin/sh

. /sbin/global.sh

set -x

if [ "$1" = "set_apmode_only" ]; then
	set_value APMode 0
	exit 0
fi

if [ "$#" = "0" ]; then
	set_value APMode 0
fi
killall -q udhcpd
ifconfig $ap_iface down
#ntp.sh
#fi







