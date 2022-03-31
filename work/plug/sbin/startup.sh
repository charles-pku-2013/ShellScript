. /sbin/global.sh

set -x

# install drivers
modprobe uvcvideo

# load key-value file

led.sh red on
# set image info
set_value Manufacturer $manufacturer
set_value Model $model
set_value Version $imageVer
#set_value NTPServerIP time.nist.gov
#set_value NTPSync 1
Initialized=`nvram get Initialized`
if [ "$Initialized" != "1" ]; then
	echo "First time to use!"
#	checkKeyValues
	nvram set APMode 1
	nvram set Initialized 1
fi

set_timezone

echo "0" > /var/run/gcamd.pid

cd /gcam_bin
chmod a+rx gcamd
#cp -sf /sys/kernel/debug/gcam.pid /var/run/gcamd.pid
ln -sf /proc/gcamd.pid /var/run/gcamd.pid

fake_gcamd &

if [ "`nvram get APMode`" = "1" ]; then
	killall -q fake_gcamd
	start_ap.sh
else
	wifi.sh
	killall -q fake_gcamd
	cd /gcam_bin
	./gcamd &
fi

















