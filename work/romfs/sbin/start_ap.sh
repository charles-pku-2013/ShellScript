#! /bin/sh
. /sbin/global.sh

set -x

generate_udhcpd_config
ifconfig ra0 down
killall -q ntp.sh ntp_routine.sh
killall -q sleep
killall -q udhcpd udhcpc ntpclient pppd syslogd wpa_supplicant
if [ "$#" = "0" ]; then
	set_value APMode 1
	killall -q check_ntp.sh wifi.sh ethernet.sh download_update.sh wget gcamd
	rm -f /gcam_bin/*.xml
fi

rmmod rt2860v2_sta
ralink_init make_wireless_config rt2860
insmod -q rt2860v2_ap
ifconfig ra0 $router_ip netmask 255.255.255.0
change_route
iwpriv ra0 set SSID="$manufacturer-$model#`cat /sys/class/net/ra0/address | sed 's/://g'`"
iwpriv ra0 set SiteSurvey=1
udhcpd

if [ "$#" = "0" ]; then
	# for reset
	mkdosfs $configPartition
	cd /gcam_bin/
	./gcamd &
fi
#fi
