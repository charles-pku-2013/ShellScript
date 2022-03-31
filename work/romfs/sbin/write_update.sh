#! /bin/sh
. /sbin/global.sh

set -x

echo "WRITTING FLASH!!!"
#mtd_write -q write $imageDestFile mtd4
dd if=$imageDestFile of=/dev/mtdblock4

exit $?
