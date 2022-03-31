#! /bin/sh

set -x

goon=1

killall -q ntpsync ntpclient

while [ "$goon" = "1" ]
do
	ntpsync &
	sleep 86400
done
