#! /bin/sh
. /sbin/global.sh

set -x

rm -f $checkfile
rm -f $imagefile
rm -f $imageDestFile

wget $checkfileUrl -O $checkfile -q

if [ "$?" != "0" ]; then
	echo "#return 1 download error#"
	exit 1
fi

wget $imagefileUrl -O $imagefile 2>&1

if [ "$?" != "0" ]; then
	echo "#return 1 download error#"
	exit 1
fi

if [ "`md5sum $imagefile | cut -d' ' -f1`" != "`cat $checkfile | cut -d' ' -f1`" ]; then
	echo "#return 1 check error#"
	exit 1
fi

mv $imagefile $imageDestFile
echo "#return 0 success#"

exit 0









