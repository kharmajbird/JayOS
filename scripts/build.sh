#!/bin/sh

#
# Script to initiate the build of a JayOS Live CD (based on Linux From Scratch)
#

# set FS=0 if sources are already in /lfs/build/JayOS
FS=1

# ensure these two directories exist
# LFS should be a mount point; /fs/fs should have 12GB available
#
LFS=/lfs
SCRATCH=/fs/fs
#

#
# create a 12GB filesystem, mount, and populate with sources
#

HEAD=$LFS/build/JayOS

if [ $FS = "1" ]; then
    echo "Creating /lfs loopback filesystem on $SCRATCH..." && \
    dd if=/dev/zero of=$SCRATCH/lfs.fs count=12288 bs=1024k && \
    mke2fs -j -m 0 $SCRATCH/lfs.fs && \
    sleep 5 && \
    mount -o loop -t ext3 $SCRATCH/lfs.fs /lfs && \
    \
    mkdir -p $LFS/build $SCRATCH && \
    cd $LFS/build && \
    git clone git://github.com/kharmajbird/JayOS && \
    \
    echo "Attempting to download source tarballs from S3..." && \
    sh $HEAD/scripts/dl.sh || \
        echo "Download failed"; \
fi

#
# launch the LFS build
# due to the clean room ahead, we need the user's help
#

(cd $HEAD/lfs && make prep)

echo "=============================================================="
echo
echo "Ready to begin the LFS/BLFS/JLFS build process!"
echo
echo "You are about to step within a clean shell environment..."
echo "Please run the two commands below to continue the build"
echo
echo "=============================================================="
echo
echo "source /root/.bash_profile"
echo "$HEAD/scripts/mkjlfs.sh"
echo
