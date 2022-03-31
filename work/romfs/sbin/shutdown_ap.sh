#! /bin/sh

. /sbin/global.sh

set -x

if [ "$1" = "set_apmode_only" ]; then
	set_value APMode 0
	exit 0
fi

#if [ "`nvram_get 2860 APMode`" = "1" ]; then
if [ "$#" = "0" ]; then
	set_value APMode 0
fi
killall -q udhcpd
ifconfig ra0 down
#ntp.sh
#fi







