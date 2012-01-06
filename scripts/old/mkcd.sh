#!/bin/sh
mkisofs -o jlfs-iMac.iso \
	-V jlfs-iMac \
	-v -pad \
	-b boot/isolinux.bin \
	-c boot/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-graft-points \
		/boot=/lfs/build/livecd/boot \
		/isolinux.cfg=/lfs/build/livecd/boot/isolinux.cfg \
		/isolinux.bin=/lfs/build/livecd/boot/isolinux.bin \
		/fs=/lfs/build/livecd/fs \
		/JayOS=/lfs/build/livecd/JayOS
