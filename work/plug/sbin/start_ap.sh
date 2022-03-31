#! /bin/sh
. /sbin/global.sh

set -x

if [ ! -e "/sys/class/net/$wifi_iface" ]; then
	killall -q udhcpd uaputl
	ifconfig $ap_iface down
	rmmod sd8xxx mlan
	modprobe sd8787 drv_mode=1
	ifconfig $wifi_iface up
fi

iwlist $wifi_iface scanning > /tmp/wifi_scan

ifconfig $wifi_iface down
killall -q ntp.sh ntp_routine.sh
killall -q sleep
killall -q udhcpd udhcpc ntpclient pppd syslogd wpa_supplicant
if [ "$#" = "0" ]; then
	set_value APMode 1
	killall -q check_ntp.sh wifi.sh ethernet.sh download_update.sh wget gcamd
fi

rmmod sd8xxx mlan
modprobe sd8787 drv_mode=2

generate_udhcpd_config
ifconfig $ap_iface $router_ip netmask 255.255.255.0
SSID="$manufacturer-$model#`cat /sys/class/net/$ap_iface/address | sed 's/://g'`"
change_route
uaputl sys_cfg_ssid $SSID
uaputl bss_start
udhcpd

if [ "$#" = "0" ]; then
	# for reset
	cd /gcam_bin/
	rm -f *.xml
	set_timezone
	./gcamd &
fi
#fi
