#! /bin/sh

rootDev="/dev/mtd2"
kernelPart="/dev/mtdblock1"
bootPart="/dev/mtdblock0"

echo 'Installing System!! Please DO NOT cut off the power!!!'

# install rootfs
echo 'Setting up root filesystem...'
./ubiformat $rootDev -e 0 -y
./ubiattach -p $rootDev
./ubimkvol /dev/ubi0 -m -N rootfs
mount -t ubifs ubi0:rootfs /mnt
cp -a /bin /etc /home /init /lib /linuxrc /opt /run /sbin /usr /mnt
(cd /mnt/etc; rm -f udhcpd.conf wifi.conf dict.dat)
bzip2 -dc rootdir.tar.bz2 | tar -xv -C /mnt/
mkdir -p /mnt/gcam_bin
cp -a gcamd_main /mnt/gcam_bin/gcamd
umount /mnt

# install kernel
echo 'Installing OS kernel...'
dd if=uImage of=$kernelPart

# install bootloader
echo 'Installing bootloader...'
dd if=uboot.img of=$bootPart

# reboot
echo "Now system is going to reboot..."
reboot











