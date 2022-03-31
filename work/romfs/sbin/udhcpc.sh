#!/bin/sh
. /sbin/global.sh

# udhcpc script edited by Tim Riker <Tim@Rikers.org>
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

statusFile="/var/run/ipAcquired"

[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1

echo "0" > $statusFile

RESOLV_CONF="/etc/resolv.conf"
[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"

case "$1" in
    deconfig)
        /sbin/ifconfig $interface 0.0.0.0
        ;;

    renew|bound)
        /sbin/ifconfig $interface $ip $BROADCAST $NETMASK
        #set wifi Ip info
        if [ "$interface" = "$wifi_iface" ]; then
            set_value wifi_address $ip
            set_value wifi_netmask $subnet
        fi
        
        if [ -n "$router" ] ; then
            echo "deleting routers"
            while route del default gw 0.0.0.0 dev $interface ; do
                :
            done

            metric=0
            for i in $router ; do
                metric=`expr $metric + 1`
                route add default gw $i dev $interface metric $metric
                #set wifi Ip info
                if [ "$interface" = "$wifi_iface" ]; then
                    set_value wifi_gateway $i
                fi
            done
        fi

        echo -n > $RESOLV_CONF
        [ -n "$domain" ] && echo search $domain >> $RESOLV_CONF
        j=1
        for i in $dns ; do
            echo adding dns $i
            echo nameserver $i >> $RESOLV_CONF
            #set wifi Ip info
            if [ "$interface" = "$wifi_iface" ]; then
                wifiDns=$i
		        dnsName=`get_dnsName $pref $j`
		        set_value $dnsName $wifiDns
		        j=`expr $j + 1`
		    fi
        done
		# notify goahead when the WAN IP has been acquired. --yy
		killall -SIGTSTP goahead

		# restart igmpproxy daemon
		config-igmpproxy.sh
		echo "1" > $statusFile
        ;;
esac

exit 0

