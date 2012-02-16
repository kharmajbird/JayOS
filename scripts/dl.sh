#!/bin/sh

#
# script to download all tarballs from S3 storage
# runs from build.sh
#

S3=http://jayosrc.s3-website-us-west-1.amazonaws.com/tarballs
PKGLIST=/lfs/build/JayOS/figs/pkglist
HEAD=/lfs/build/JayOS/tarballs
DIRS="jlfs lfs usb"
XDIRS="xorg/app xorg/driver xorg/font xorg/lib xorg/proto xorg/util xorg/xserver xorg/misc"

STICK1=jlfs-USB-stick1.img.gz
STICK2=jlfs-USB-stick2.img.gz



for i in $DIRS $XDIRS; do mkdir -p $HEAD/$i; done

for i in `cat $PKGLIST| grep -v ^#`; do
    ( cd $HEAD/`dirname $i` && \
    wget -nH $S3/$i )
done

(cd $HEAD/usb && \
    wget -nH $S3/usb/$STICK1 && \
    wget -nH $S3/usb/$STICK2 )
