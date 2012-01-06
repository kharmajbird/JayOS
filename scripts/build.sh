#!/bin/sh

#
# Initiate the build of a JayOS Live CD (based on Linux From Scratch)
#

FS=1

# ensure these two directories exist
# LFS should be a mount point; /fs/fs should have 12GB available
#
LFS=/lfs
SCRATCH=/fs/fs
#

HEAD=$LFS/build/JayOS

#
# create the filesystem, mount, and populate with sources
#

if [ $FS = "1" ]; then
    echo "Creating /lfs loopback filesystem on $SCRATCH..." && \
    dd if=/dev/zero of=$SCRATCH/lfs.fs count=12288 bs=1024k && \
    mke2fs -j -m 0 $SCRATCH/lfs.fs && \
    mount -o loop $SCRATCH/lfs.fs /lfs && \
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
# due to the clean room, we need the user's help
#

(cd $HEAD/lfs && make prep)

echo "=============================================================="
echo
echo "You are now within a clean shell environment, ready to begin"
echo "the LFS/BLFS/JLFS build process."
echo
echo "Please run the two commands below to continue the build:"
echo
echo "=============================================================="
echo
echo "source /root/.bash_profile"
echo "$HEAD/scripts/mkjlfs.sh"
echo
