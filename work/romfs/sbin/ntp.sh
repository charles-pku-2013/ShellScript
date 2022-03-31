#! /bin/sh

set -x

killall -q ntp_routine.sh
killall -q sleep

tz=`nvram_get 2860 TZ`

if [ "$tz" = "" ]; then
	tz="UCT_000"
fi

echo $tz > /etc/tmpTZ
sed -e 's#.*_\(-*\)0*\(.*\)#GMT-\1\2#' /etc/tmpTZ > /etc/tmpTZ2
sed -e 's#\(.*\)--\(.*\)#\1\2#' /etc/tmpTZ2 > /etc/TZ
rm -rf /etc/tmpTZ
rm -rf /etc/tmpTZ2

if [ "`lsmod | grep 'rt2860v2_sta'`" != "" ]; then
	ntp_routine.sh &
fi
