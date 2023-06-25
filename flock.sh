#!/bin/bash
# https://jdimpson.livejournal.com/5685.html

lockfile="/tmp/test.txt"
exec 8>${lockfile}

flock -n 8 || { echo "$$ cannot acquire lock"; exit -1; }

# echo "$$" > /tmp/test.txt  # NOTE!!! doesn't work
echo "$$ running"

sleep 20

rm -fv ${lockfile}  # OK
echo "$$ done"
