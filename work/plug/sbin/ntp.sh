#! /bin/sh

set -x

killall -q ntp_routine.sh
killall -q sleep

if [ -e "/sys/class/net/$wifi_iface" ]; then
	ntp_routine.sh &
fi












