#! /bin/sh
if [ "$#" != "1" -a "$#" != "2" ]; then
	echo "usage: load_file.sh filename [destdir]"
fi

device=/dev/mtdblock5
mountdir=/mnt/configs/
destdir=$2
if [ "$destdir" = "" ]; then
	destdir="./"
fi

mkdir -p $mountdir
mount $device $mountdir
if [ "$?" != "0" ]; then
	exit 1
fi
cp -f $mountdir$1 $destdir
umount $mountdir
