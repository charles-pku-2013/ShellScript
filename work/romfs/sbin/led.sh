#! /bin/sh

turn_off_all()
{
	gpio l 0 4000 0 1 0 4000
	gpio l 9 4000 0 1 0 4000
}

gpioNO=""

if [ "$1" = "red" ]; then
	gpioNO="0"
elif [ "$1" = "green" ]; then
	gpioNO="9"
elif [ "$1" = "alternate" ]; then
	turn_off_all
	# turn on red
	gpio l 0 0 4000 0 1 4000
	# blink green
	gpio l 9 5 5 4000 0 4000
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
	gpio l $gpioNO 0 4000 0 1 4000
elif [ "$2" = "fast" ]; then
	gpio l $gpioNO 1 1 4000 0 4000
elif [ "$2" = "slow" ]; then
	gpio l $gpioNO 5 5 4000 0 4000
elif [ "$2" = "off" ]; then
	gpio l $gpioNO 4000 0 1 0 4000
else
	echo "wrong usage"
	exit 1
fi












