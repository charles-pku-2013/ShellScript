#! /bin/sh

redled="/sys/class/leds/guruplug:green:health/trigger"
greenled="/sys/class/leds/guruplug:red:wmode/trigger"
slow="timer"
fast="heartbeat"
off="none"
on="default-on"

turn_off_all()
{
	echo "$off" > $redled
	echo "$off" > $greenled
}

led=""

if [ "$1" = "red" ]; then
	led=$redled
elif [ "$1" = "green" ]; then
	led=$greenled
elif [ "$1" = "alternate" ]; then
	turn_off_all
	# turn on red
	echo "$on" > $redled
	# blink green
	echo "$slow" > $greenled
	exit 0
elif [ "$1" = "alloff" ]; then
	turn_off_all
	exit 0
else
	echo "wrong usage"
	exit 1
fi

turn_off_all

if [ "$2" = "on" ]; then
	echo "$on" > $led
elif [ "$2" = "fast" ]; then
	echo "$fast" > $led
elif [ "$2" = "slow" ]; then
	echo "$slow" > $led
elif [ "$2" = "off" ]; then
	echo "$off" > $led
else
	echo "wrong usage"
	exit 1
fi












