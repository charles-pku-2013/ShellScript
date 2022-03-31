#! /bin/sh
if [ "$#" != "1" ]; then
	echo "usage: save_file.sh filename"
fi

device=/dev/mtdblock5
dest=/mnt/configs/

mkdir -p $dest
mount $device $dest
if [ "$?" != "0" ]; then
	exit 1
fi
cp -f $1 $dest
umount $dest
