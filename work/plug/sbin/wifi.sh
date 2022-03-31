#! /bin/sh
. /sbin/global.sh

mode=`nvram get wifi_mode`
wifiSSID=`nvram get wifiSSID`
wifiAuthMode=`nvram get wifiAuthMode`
wifiEncrypType=`nvram get wifiEncrypType`
wifiPassword=`nvram get wifiPassword`
wifiChannel=`nvram get Channel`
wifiConf="/etc/wifi.conf"
udhcpcStatus="/var/run/ipAcquired"

set -x

killall -q ntp.sh ntp_routine.sh
killall -q sleep
killall -q udhcpc udhcpd pppd syslogd wpa_supplicant ntpclient check_ntp.sh ethernet.sh download_update.sh wget

#ifconfig eth0 down

# install driver
if [ ! -e "/sys/class/net/$wifi_iface" ]; then
	killall -q udhcpd uaputl
	ifconfig $ap_iface down
	rmmod sd8xxx mlan
	modprobe sd8787 drv_mode=1
	ifconfig $wifi_iface up
	set_value APMode 0
fi

# wait for wpa_supplicant to be killed
while [ -e "/var/run/wpa_supplicant" ]
do
	sleep 1
	killall wpa_supplicant
done

if [ "$wifiAuthMode" = "OPEN" -a "$wifiEncrypType" = "WEP" ]; then
	iwpriv ra0 set NetworkType=Infra
	iwpriv ra0 set AuthMode=$wifiAuthMode
	iwpriv ra0 set EncrypType=$wifiEncrypType
	iwpriv ra0 set DefaultKeyID=1
	iwpriv ra0 set Key1=$wifiPassword		
	iwpriv ra0 set SSID=$wifiSSID	
else
	# create config file for wpa_supplicant
	echo "ctrl_interface=/var/run/wpa_supplicant" > $wifiConf
	echo "update_config=1" >> $wifiConf
	echo "" >> $wifiConf
	echo "network={" >> $wifiConf
	echo "	ssid=\"$wifiSSID\"" >> $wifiConf
	echo "	scan_ssid=1" >> $wifiConf

	if [ "$wifiAuthMode" = "OPEN" -a "$wifiEncrypType" = "NONE" ]; then
		echo "	key_mgmt=NONE" >> $wifiConf	
	else
		# for all WPA
		echo "	key_mgmt=WPA-PSK" >> $wifiConf
		echo "	psk=\"$wifiPassword\"" >> $wifiConf
	fi
	echo "}" >> $wifiConf	

	wpa_supplicant -i$wifi_iface -Dwext -c$wifiConf -B
fi

#?? need check if successfully associated.

if [ "$mode" = "STATIC" ]; then
	ip=`nvram get wifi_address`
	nm=`nvram get wifi_netmask`
	gw=`nvram get wifi_gateway`
	pd=`nvram get wifi_primary_dns`
	sd=`nvram get wifi_secondary_dns`
	ifconfig $wifi_iface $ip netmask $nm
	route del default
	if [ "$gw" != "" ]; then
		route add default gw $gw
	fi
	config-dns.sh $pd $sd		
else
	udhcpc -i $wifi_iface -s /sbin/udhcpc.sh -p /var/run/udhcpc.pid -q &
	for i in `seq 30`
	do
		sleep 1
		if [ "`cat $udhcpcStatus`" = "1" ]; then
			break
		fi
	done	
fi

if [ "$#" = "0" -a "`cat $udhcpcStatus`" = "1" ]; then
	ntp.sh
fi


