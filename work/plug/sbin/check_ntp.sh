#! /bin/sh

. /sbin/global.sh

set -x

fail="1"

renice +19 `pidof check_ntp.sh`

# wait for udhcpc
sleep 2

echo "0" > /var/run/NTPValid

for i in `seq 20`
do
	if [ "`ifconfig $wifi_iface | grep 'inet addr'`" = "" ]; then
		sleep 2
	else
		break
	fi
done

sleep 1
ntp.sh
for i in `seq 20`
do
	sleep 2
	if [ "`cat /var/run/NTPValid`" = "1" ]; then
		exit 0
	fi
done

exit 1
