#!/bin/sh

DISK="usb-DMI_HTS541260H9AT00_001010055000C4E10-0:0"
DEVICE=`file /dev/disk/by-id/$DISK| sed -e 's/.*\/\(.*\).$/\1/'`


if [ -f /sys/block/$DEVICE/device/max_sectors ]; then
    echo 128 > /sys/block/$DEVICE/device/max_sectors
fi


