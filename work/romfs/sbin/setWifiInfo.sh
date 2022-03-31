#! /bin/sh
. /sbin/global.sh

get_dnsName() 
{
newname=${1}${2}
eval "echo $`echo $newname`"
}
pref=var
indx=1
eval "$pref$indx=wifi_primary_dns"
indx=2
eval "$pref$indx=wifi_secondary_dns"
	
setWifiInfo()
{
    wifiAddress=`ifconfig $wifi_iface | grep 'inet addr' | cut -d ':' -f 2-4 | cut -d ' ' -f 1`
    wifiGateway=`route | grep $wifi_iface | grep default | cut -c17-28`
    wifiNetMask=`ifconfig $wifi_iface | grep 'inet addr' | cut -d ':' -f 4`
    set_value wifi_address $wifiAddress
    set_value wifi_gateway $wifiGateway
    set_value wifi_netmask $wifiNetMask
    
    j=1     
    for i in `cat /etc/resolv.conf | grep 'nameserver' | cut -d' ' -f2`
    do
            wifiDns=$i
		    dnsName=`get_dnsName $pref $j`
		    set_value $dnsName $wifiDns
		    j=`expr $j + 1`
   done
}

setWifiInfo
