#!/bin/sh

#
# script to download all tarballs from S3 storage
# run after build.sh
#

S3=http://jayosrc.s3-website-us-west-1.amazonaws.com/tarballs
PKGLIST=/lfs/build/JayOS/figs/pkglist
HEAD=/lfs/build/JayOS/tarballs
DIRS="jlfs lfs"
XDIRS="xorg/app xorg/driver xorg/font xorg/lib xorg/proto xorg/util xorg/xserver"

for i in $DIRS $XDIRS; do mkdir -p $HEAD/$i; done

for i in `cat $PKGLIST| grep -v ^#`; do
    ( cd $HEAD/`dirname $i` && \
    wget -nH $S3/$i )
done
