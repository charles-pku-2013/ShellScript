#! /bin/sh
. /sbin/global.sh

iface="ra0"
mode=`nvram_get 2860 wifi_mode`
wifiSSID=`nvram_get 2860 wifiSSID`
wifiAuthMode=`nvram_get 2860 wifiAuthMode`
wifiEncrypType=`nvram_get 2860 wifiEncrypType`
wifiPassword=`nvram_get 2860 wifiPassword`
wifiChannel=`nvram_get 2860 Channel`
wifiConf="/etc/wifi.conf"
udhcpcStatus="/var/run/ipAcquired"

set -x

killall -q ntp.sh ntp_routine.sh
killall -q sleep
killall -q udhcpc udhcpd pppd syslogd wpa_supplicant ntpclient check_ntp.sh ethernet.sh download_update.sh wget

ifconfig eth2 down

# install driver
if [ "`lsmod | grep 'rt2860v2_sta'`" = "" ]; then
	ifconfig ra0 down
	rmmod rt2860v2_ap
	ralink_init make_wireless_config rt2860
	insmod -q rt2860v2_sta
	ifconfig ra0 0.0.0.0
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

	wpa_supplicant -i$iface -Dralink -c$wifiConf -B
fi

#?? need check if successfully associated.
if [ "$mode" = "STATIC" ]; then
	ip=`nvram_get 2860 wifi_address`
	nm=`nvram_get 2860 wifi_netmask`
	gw=`nvram_get 2860 wifi_gateway`
	pd=`nvram_get 2860 wifi_primary_dns`
	sd=`nvram_get 2860 wifi_secondary_dns`
	ifconfig $iface $ip netmask $nm
	route del default
	if [ "$gw" != "" ]; then
		route add default gw $gw
	fi
	config-dns.sh $pd $sd		
else
	udhcpc -i $iface -s /sbin/udhcpc.sh -p /var/run/udhcpc.pid -q &
	for i in `seq 30`
	do
		sleep 1
		if [ "`cat $udhcpcStatus`" = "1" ]; then
			break
		fi
	done
fi

#if [ "`cat $udhcpcStatus`" = "1" ]; then
#    setWifiInfo.sh
#fi

if [ "$#" = "0" -a "`cat $udhcpcStatus`" = "1" ]; then
	ntp.sh
fi


