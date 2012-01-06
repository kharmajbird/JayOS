#!/bin/sh

#
##########################################################################
# script to create a bootable CD for Intel Macs under Linux
#
# CD will have an Apple partition map and one HFS+ volume
#
# Written by Jay Lewis 20061115
#
##########################################################################
#

# $VOL $SIZE and $DISK passed from Makefile.targets
VOL=$1
SIZE=$2
DISK=$3
#
LFS=/lfs
LOOP=/dev/loop6
MNT=/mnt
BUILD=$LFS/build
LIVECD=$BUILD/livecd

#
##########################################################################
# Background:
#
# "New world" Intel Macs based on EFI firmware require an HFS+ partition
# to boot from. More specifically, rEFIT makes this requirement. 
#
# The Apple utilities used to create and fsck HFS+ volumes are available
# for Linux, but the hfsplusutils package is broken in that it won't mount
# HFS+ volumes created with the Apple new_hfs or Linux mkfs.hfsplus
# commands. Fortunately, the kernel hfsplus driver is savvy enough to mount 
# such filesystems so we're OK there. The real problem is how to bless the 
# volume from Linux after it has been populated with data.
#
# Both HFS and HFS+ volumes need to be "blessed" so the firmware knows
# where to locate the boot file. Until now, blessing had to be done
# under OS X because there is no Linux counterpart to Apple's bless
# command. (The command hattrib from the hfsutils packages will only
# bless HFS volumes, not HFS+)
#
# The method I chose to bless under Linux is to note the CNIDs of the 
# folder to bless (efi/refit) and the boot file (efi/refit/refit.efi),
# and patch those values into the volume's master directory block.
#
# In order to find the CNID of the blessed folder and boot file, I made
# sure efi/refit and efi/refit/refit.efi were respectively the first directory 
# and file created on the volume. Then I created the CD as usual by
# running the now obsolete BurnFromOSX.sh. After mounting the resulting
# CD image, I ran bless -info against it. The output looked similar to:
#
# finderinfo[0]:     18 => Blessed System Folder is /Volumes/JayOS-iMac-20061108/efi/refit
# finderinfo[1]:     19 => Blessed System File is /Volumes/JayOS-iMac-20061108/efi/refit/refit.efi
# finderinfo[2]:      0 => Open-folder linked list empty
# finderinfo[3]:      0 => No OS 9 + X blessed 9 folder
# finderinfo[4]:      0 => Unused field unset
# finderinfo[5]:     18 => OS X blessed folder is /Volumes/JayOS-iMac-20061108/efi/refit
# 64-bit VSDB volume id:  0x9BBE7CE6C036544F
#
# The finderinfo data structure is located 1107 bytes into the HFS+ volume.
#
##########################################################################
# The following technical notes were helpful in developing this process:
#     http://developer.apple.com/technotes/tn/tn1150.html
##########################################################################
#

# create and partition disk
dd if=/dev/zero of=$DISK bs=1024k count=$SIZE
parted $DISK mklabel mac
parted $DISK mkpart primary hfs 0.031 $SIZE
parted $DISK name 2 Apple_Boot

# create and mount HFS+ filesystem
losetup -o 32768 $LOOP $DISK
mkfs.hfsplus -v $VOL $LOOP
mount -t hfsplus -o rw,force $LOOP $MNT

# create blessed dir/file
mkdir $MNT/efi
mkdir $MNT/efi/refit
cp -a $LIVECD/efi/refit/refit.efi $MNT/efi/refit

# copy livecd contents into HFS+ filesystem
for i in efi boot fs; do
    cp -a $LIVECD/$i $MNT
done

if [ $SIZE -gt 700 ]; then 
    cp -a $BUILD/src $MNT/lfs
fi

#for i in lfs doc; do
#    cp -a $BUILD/$i $MNT
#done

umount $MNT

# patch finderInfo into HFS+ filesystem; ^R represents 0x12, ^S is 0x13
echo -n  > hfs.finderinfo1
echo -n  > hfs.finderinfo2
echo -n  > hfs.finderinfo5

dd if=hfs.finderinfo1 of=$LOOP bs=1c seek=1107 conv=notrunc
dd if=hfs.finderinfo2 of=$LOOP bs=1c seek=1111 conv=notrunc
dd if=hfs.finderinfo5 of=$LOOP bs=1c seek=1127 conv=notrunc

#fsck.hfsplus -r $LOOP
fsck.hfsplus $LOOP
losetup -d $LOOP
rm -f hfs.finderinfo[0-9]
