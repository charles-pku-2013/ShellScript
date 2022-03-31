. /sbin/config.sh
. /sbin/global.sh


genSysFiles()
{
	login=`nvram_get 2860 Login`
	pass=`nvram_get 2860 Password`
	if [ "$login" != "" -a "$pass" != "" ]; then
		echo "$login::0:0:Adminstrator:/:/bin/sh" > /etc/passwd
		echo "$login:x:0:$login" > /etc/group
		chpasswd.sh $login $pass
	fi
	if [ "$CONFIG_PPPOL2TP" == "y" ]; then
		echo "l2tp 1701/tcp l2f" > /etc/services
		echo "l2tp 1701/udp l2f" >> /etc/services
	fi
}

genDevNode()
{
	#Linux2.6 uses udev instead of devfs, we have to create static dev node by myself.
	if [ "$CONFIG_USB_EHCI_HCD" != "" -o "$CONFIG_DWC_OTG" != "" -a "$CONFIG_HOTPLUG" == "y" ]; then
		mounted=`mount | grep mdev | wc -l`
		if [ $mounted -eq 0 ]; then
			mount -t ramfs mdev /dev
			mkdir /dev/pts
			mount -t devpts devpts /dev/pts
			mdev -s

#			mknod   /dev/video0      c       81      0
			mknod   /dev/spiS0       c       217     0
			mknod   /dev/i2cM0       c       218     0
			mknod   /dev/rdm0        c       254     0
			mknod   /dev/flash0      c       200     0
			mknod   /dev/swnat0      c       210     0
			mknod   /dev/hwnat0      c       220     0
			mknod   /dev/acl0        c       230     0
			mknod   /dev/ac0         c       240     0
			mknod   /dev/mtr0        c       250     0
			mknod   /dev/gpio        c       252     0	
			mknod	/dev/pcm0	 c	 233	 0
			mknod	/dev/i2s0	 c	 234	 0	
			mknod   /dev/cls0        c       235     0
			 
			 # for audio
			/bin/mkdir -p /dev/snd
			/bin/cp -s /dev/pcmC0D0c /dev/snd/pcmC0D0c
			/bin/cp -s /dev/pcmC0D0p /dev/snd/pcmC0D0p
			/bin/cp -s /dev/controlC0 /dev/snd/controlC0
			/bin/cp -s /dev/pcmC1D0c /dev/snd/pcmC1D0c
			/bin/cp -s /dev/pcmC1D0p /dev/snd/pcmC1D0p
			/bin/cp -s /dev/controlC1 /dev/snd/controlC1
			/bin/cp -s /dev/seq /dev/snd/seq
			/bin/cp -s /dev/timer /dev/snd/timer        
		fi
		echo "# <device regex> <uid>:<gid> <octal permissions> [<@|$|*> <command>]" > /etc/mdev.conf
		echo "# The special characters have the meaning:" >> /etc/mdev.conf
		echo "# @ Run after creating the device." >> /etc/mdev.conf
		echo "# $ Run before removing the device." >> /etc/mdev.conf
		echo "# * Run both after creating and before removing the device." >> /etc/mdev.conf
		echo "sd[a-z][1-9] 0:0 0660 */sbin/automount.sh \$MDEV" >> /etc/mdev.conf
		echo "sd[a-z] 0:0 0660 */sbin/automount.sh \$MDEV" >> /etc/mdev.conf
		if [ "$CONFIG_USB_SERIAL" = "y" ] || [ "$CONFIG_USB_SERIAL" = "m" ]; then
			echo "ttyUSB0 0:0 0660 @/sbin/autoconn3G.sh connect" >> /etc/mdev.conf
		fi
		if [ "$CONFIG_BLK_DEV_SR" = "y" ] || [ "$CONFIG_BLK_DEV_SR" = "m" ]; then
			echo "sr0 0:0 0660 @/sbin/autoconn3G.sh connect" >> /etc/mdev.conf
		fi
		if [ "$CONFIG_USB_SERIAL_HSO" = "y" ] || [ "$CONFIG_USB_SERIAL_HSO" = "m" ]; then
			echo "ttyHS0 0:0 0660 @/sbin/autoconn3G.sh connect" >> /etc/mdev.conf
		fi

		#enable usb hot-plug feature
		echo "/sbin/mdev" > /proc/sys/kernel/hotplug
	fi
	
	insmod uvcvideo.ko
}

set -x

led.sh red on
# set image info
set_value Manufacturer $manufacturer
set_value Model $model
set_value Version $imageVer
#set_value NTPServerIP time.nist.gov
#set_value NTPSync 1
Initialized=`nvram_get 2860 Initialized`
if [ "$Initialized" != "1" ]; then
	echo "First time to use!"
#	checkKeyValues
	nvram_set 2860 APMode 1
	nvram_set 2860 Initialized 1
fi
genSysFiles
genDevNode

ifconfig lo 127.0.0.1
ifconfig eth2 0.0.0.0

ralink_init make_wireless_config rt2860
ifconfig ra0 0.0.0.0
config-vlan.sh 2 0
echo "0" > /var/run/gcamd.pid

cd /gcam_bin
chmod a+rx gcamd

if [ "`nvram_get 2860 APMode`" = "1" ]; then
	start_ap.sh
else
	wifi.sh
	cd /gcam_bin
	./gcamd &
fi

















