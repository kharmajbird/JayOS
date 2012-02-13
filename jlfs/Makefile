#
#
# First run "make", then (optionally) "make strip-man", then "make livecd"
# If you want absolutely everything, run "make bloat" before "make livecd"
#
##########################################################################
#
VERSION=20120213
LFSVERSION=LFS-7.0
#
##########################################################################

ARCH=x86
#ARCH=486
#ARCH=imac
#
LABEL="JayOS-$(ARCH)-$(VERSION)"
#
ADD-JLFS-SKEL=1
ROOTSIZE=160
INITRDSIZE=4
SERVER=0
LFS=/lfs

#
# find what we're looking for
#
MOUNT-BIN=/bin/mount
UMOUNT-BIN=/bin/umount
MKRUNE-BIN=$(LFS)/sbin/mkrune
RUNEWR-BIN=$(LFS)/sbin/runewr
LOSETUP-BIN=/sbin/losetup
MKISOFS-BIN=/usr/bin/mkisofs
MKE2FS-BIN=/sbin/mke2fs
AESPIPE-BIN=$(LFS)/usr/bin/aespipe
MKSQUASHFS-BIN=$(LFS)/sbin/mksquashfs

include Makefile.versions
include Makefile.vars
include Makefile.depends
STUB=stub-ver

##########################################################################

all:
	$(LFS)/usr/sbin/chroot $(LFS) /bin/env -i \
		\
		HOME=/root \
		TERM=$(TERM) \
		PS1='\u:\w\$ ' \
		PATH=/bin:/usr/bin:/sbin:/usr/sbin \
		\
		/bin/bash -c ' \
			SHELL=/bin/bash \
			cd /usr/src && make inside-chroot '

	if [ -f $(LFS)/tmp/sallgood ]; then \
		rm -f $(LFS)/tmp/sallgood && \
		make strip; \
	else \
		/usr/bin/play $(SKEL-JLFS)/root/bin/tos-redalert

include Makefile.targets

livecd:	un-prep strip-man root initrd boot usr opt iso usb
	@echo
	@echo "==========================================================="
	@echo
	@echo "This system has been built without the following packages:"
	@echo
	@echo "$(JLFS-BLOATED)"
	@echo
	@echo -n "If you would like to include them, run \"make bloat\" "
	@echo "from /usr/src"
	@echo
	@echo "==========================================================="
	@echo

#
#
#
bloat:
	$(LFS)/usr/sbin/chroot $(LFS) /bin/env -i \
		\
		HOME=/root \
		TERM=$(TERM) \
		PS1='\u:\w\$ ' \
		PATH=/bin:/usr/bin:/sbin:/usr/sbin \
		\
		/bin/bash -c ' \
			SHELL=/bin/bash \
			cd /usr/src && make inside-bloat '

	if [ -f $(LFS)/tmp/sallgood ]; then \
		rm -f $(LFS)/tmp/sallgood && \
		make strip; \
	fi

	make strip-man
	make usr
	make opt

#
#
#

inside-chroot:
	touch /tmp/timestamp && rm -f /tmp/sallgood

	cd /usr/src && make SHELL=/bin/sh \
		$(BLFS-MISC) $(BLFS-SECURITY) $(BLFS-GEN-LIB) \
		$(BLFS-GRAPHIC-LIBS) $(BLFS-GEN-UTIL) \
		$(BLFS-SYS-UTIL) $(BLFS-PROGRAMMING) $(BLFS-PERL-MODS) \
		$(BLFS-PYTHON-MODS) $(BLFS-NETWORKING) $(BLFS-SERVERS) \
		$(BLFS-X11) $(BLFS-X11-LIBS) $(BLFS-GNOME-CORE) \
		$(BLFS-GNOME-LIB) $(BLFS-GNOME-UTIL) $(BLFS-GUI) \
		$(BLFS-MMEDIA-LIB) $(BLFS-AUDIO-UTIL) $(BLFS-VIDEO-UTIL) \
		$(BLFS-CDDVD-UTIL) $(BLFS-PRINTING) $(BLFS-SCANNING) \
		$(BLFS-TYPESETTING) \
		\
		$(KERNEL)-$(ARCH) \
		$(JLFS-CUSTOM-LIB) \
		$(JLFS-CUSTOM-CLI) \
		$(JLFS-CUSTOM-GUI) \
		$(JLFS-BLACKHAT-TOOLS) \
		$(JLFS-BLACKHAT-LIB) && \
	\
	touch /tmp/sallgood

#
# a 100+ MB saving in cool stuff I rarely use
#

inside-bloat:
	touch /tmp/timestamp && rm -f /tmp/sallgood

	cd /usr/src && make SHELL=/bin/sh \
		$(JLFS-BLOATED) && \
	\
	touch /tmp/sallgood

#
# Begin JLFS Custom-CLI
#

$(EJECT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(EJECT).tar.gz && \
	mv eject $(EJECT) && \
	chmod 755 $(EJECT) && \
	chown -R 0:0 $(EJECT) && \
	cd $(EJECT) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(EJECT)/.in $(EJECT)/.cvsignore $(EJECT)/.deps $(EJECT)/* && \
	make P=$(EJECT) log-package

$(SYSLINUX):  $(NASM) $(MTOOLS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SYSLINUX).tar.bz2 && \
	chmod 755 $(SYSLINUX) && \
	chown -R 0:0 $(SYSLINUX) && \
	cd $(SYSLINUX) && \
	\
	make -j2 && \
	make install && \
	mkdir -p /boot && \
	cp -av mbr/mbr.bin isolinux.bin /boot && \
	\
	cd .. && \
	rm -rf $(SYSLINUX)/* && \
	make P=$(SYSLINUX) log-package

$(BUSYBOX):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(BUSYBOX).tar.bz2 && \
	chmod 755 $(BUSYBOX) && \
	chown -R 0:0 $(BUSYBOX) && \
	cd $(BUSYBOX) && \
	\
	cp -av $(JLFS-CONFIGS)/$(BUSYBOX).config .config && \
	make oldconfig && \
	perl -p -i -e 's/^#error//' applets/applets.c && \
	make -j2 && \
	\
	cd .. && \
	make P=$(BUSYBOX) log-package

$(HFSUTILS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HFSUTILS).tar.gz && \
	chmod 755 $(HFSUTILS) && \
	chown -R 0:0 $(HFSUTILS) && \
	cd $(HFSUTILS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-devlibs && \
	make -j2 && \
	make install && \
	cd .. && \
	\
	rm -rf $(HFSUTILS)/* && \
	make P=$(HFSUTILS) log-package

$(HFSPLUS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(HFSPLUS).src.tar.bz2 && \
	chmod 755 $(HFSPLUS) && \
	chown -R 0:0 $(HFSPLUS) && \
	cd $(HFSPLUS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(HFSPLUS)-errno.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(HFSPLUS)-gcc4.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(HFSPLUS)-includes.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(HFSPLUS)-nullisnotachar.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(HFSPLUS)-no-readwrite-confirm.patch && \
	\
	aclocal && \
	autoconf && \
	autoheader && \
	libtoolize && \
	automake -a && \
	\
	./configure --prefix=/usr --sysconfdir=/etc --disable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HFSPLUS)/* && \
	make P=$(HFSPLUS) log-package

$(DISKDEV-CMDS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DISKDEV-CMDS).tar.gz && \
	chmod 755 $(DISKDEV-CMDS) && \
	chown -R 0:0 $(DISKDEV-CMDS) && \
	cd $(DISKDEV-CMDS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(DISKDEV-CMDS).patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(DISKDEV-CMDS)-cflags.patch && \
	find . -type f -name '*.[ch]' -exec chmod -x {} 2>/dev/null ';' && \
	\
	make -f Makefile.lnx && \
	\
	mkdir -p /usr/share/misc && \
	cp -av newfs_hfs.tproj/newfs_hfs /usr/sbin/mkfs.hfsplus && \
	cp -av fsck_hfs.tproj/fsck_hfs /usr/sbin/fsck.hfsplus && \
	cp -av newfs_hfs.tproj/hfsbootdata.img /usr/share/misc/hfsbootdata && \
	\
	cat fsck_hfs.tproj/fsck_hfs.8| \
		sed -e 's/[F|f]sck_hfs/fsck.hfsplus/g' > \
			/usr/share/man/man8/fsck.hfsplus.8 && \
	cat newfs_hfs.tproj/newfs_hfs.8| \
		sed -e 's/[N|n]ewfs_hfs/mkfs.hfsplus/g' > \
			/usr/share/man/man8/mkfs.hfsplus.8 && \
	\
	ln -sfn /usr/sbin/mkfs.hfsplus /usr/sbin/mkfs.hfs && \
	ln -sfn /usr/sbin/fsck.hfsplus /usr/sbin/fsck.hfs && \
	\
	ln -sfn /usr/share/man/man8/fsck.hfsplus.8 \
		/usr/share/man/man8/fsck.hfs.8 && \
	ln -sfn /usr/share/man/man8/mkfs.hfsplus.8 \
		/usr/share/man/man8/mkfs.hfs.8 && \
	\
	cd .. && \
	rm -rf $(DISKDEV-CMDS)/* && \
	make P=$(DISKDEV-CMDS) log-package

$(AESPIPE):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(AESPIPE).tar.bz2 && \
	chmod 755 $(AESPIPE) && \
	chown -R 0:0 $(AESPIPE) && \
	cd $(AESPIPE) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AESPIPE)/* && \
	make P=$(AESPIPE) log-package

$(RUNEFS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(RUNEFS).tar.gz && \
	chmod 755 $(RUNEFS) && \
	cd $(RUNEFS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/runefs.fs-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/runefs.patch && \
	\
	make -j2 && \
	strip bin/* && \
	cp -av bin/* /sbin && \
	\
	cd .. && \
	rm -rf $(RUNEFS)/* && \
	make P=$(RUNEFS) log-package

$(TCSH):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TCSH).tar.gz && \
	chmod 755 $(TCSH) && \
	chown -R 0:0 $(TCSH) && \
	cd $(TCSH) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	ln -sfn /usr/bin/tcsh /bin/csh && \
	echo "/usr/bin/tcsh" >> /etc/shells && \
	\
	cd .. && \
	rm -rf $(TCSH)/* && \
	make P=$(TCSH) log-package

$(STRACE):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(STRACE).tar.bz2 && \
	chmod 755 $(STRACE) && \
	chown -R 0:0 $(STRACE) && \
	cd $(STRACE) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(STRACE)/.deps $(STRACE)/* && \
	make P=$(STRACE) log-package

$(LSOF):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LSOF)_src.tar.bz2 && \
	mv $(LSOF)_src $(LSOF) && \
	chmod 755 $(LSOF) && \
	chown -R 0:0 $(LSOF) && \
	cd $(LSOF) && \
	\
	touch .neverInv && \
	./Configure -n linux && \
	make -j2 && \
	strip lsof && \
	cp -av lsof /sbin && \
	cp -av lsof.8 /usr/man/man8 && \
	\
	cd .. && \
	rm -rf $(LSOF)/.neverInv $(LSOF)/* && \
	make P=$(LSOF) log-package

$(AFIO):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AFIO).tgz && \
	chmod 755 $(AFIO) && \
	chown -R 0:0 $(AFIO) && \
	cd $(AFIO) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AFIO)/* && \
	make P=$(AFIO) log-package

$(NETCAT):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NETCAT).tar.bz2 && \
	chmod 755 $(NETCAT) && \
	chown -R 0:0 $(NETCAT) && \
	cd $(NETCAT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
        make -j2 && \
        make install && \
	\
	cd .. && \
	rm -rf $(NETCAT)/* && \
	make P=$(NETCAT) log-package

$(PARTED): $(DEVICE-MAPPER)
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(PARTED).tar.gz && \
	chmod 755 $(PARTED) && \
	chown -R 0:0 $(PARTED) && \
	cd $(PARTED) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PARTED)/* && \
	make P=$(PARTED) log-package

$(MINICOM):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MINICOM).tar.gz && \
	chmod 755 $(MINICOM) && \
	chown -R 0:0 $(MINICOM) && \
	cd $(MINICOM) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MINICOM)/* && \
	make P=$(MINICOM) log-package

$(UUDEVIEW):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(UUDEVIEW).tar.gz && \
	chmod 755 $(UUDEVIEW) && \
	chown -R 0:0 $(UUDEVIEW) && \
	cd $(UUDEVIEW) && \
	\
	./configure --prefix=/usr \
		--disable-minews && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(UUDEVIEW)/* && \
	make P=$(UUDEVIEW) log-package

$(MJPEGTOOLS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MJPEGTOOLS).tar.gz && \
	chmod 755 $(MJPEGTOOLS) && \
	chown -R 0:0 $(MJPEGTOOLS) && \
	cd $(MJPEGTOOLS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MJPEGTOOLS)/* && \
	make P=$(MJPEGTOOLS) log-package

$(LSDVD):  $(LIBDVDREAD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LSDVD).tar.gz && \
	chmod 755 $(LSDVD) && \
	chown -R 0:0 $(LSDVD) && \
	cd $(LSDVD) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LSDVD)/.deps $(LSDVD)/* && \
	make P=$(LSDVD) log-package

$(DOSFSTOOLS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DOSFSTOOLS).orig.tar.gz && \
	chmod 755 $(DOSFSTOOLS) && \
	chown -R 0:0 $(DOSFSTOOLS) && \
	cd $(DOSFSTOOLS) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DOSFSTOOLS)/* && \
	make P=$(DOSFSTOOLS) log-package

$(WPA-SUPPLICANT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WPA-SUPPLICANT).tar.gz && \
	chmod 755 $(WPA-SUPPLICANT) && \
	chown -R 0:0 $(WPA-SUPPLICANT) && \
	cd $(WPA-SUPPLICANT) && \
	\
	cd wpa_supplicant && \
	cp -av $(JLFS-CONFIGS)/$(WPA-SUPPLICANT).config .config && \
	\
	make -j2 && \
	strip wpa_passphrase wpa_supplicant wpa_cli && \
	cp -av wpa_passphrase wpa_supplicant wpa_cli /usr/bin && \
	\
	echo sed -e 's/\(^INCLUDEPATH.*\)/\1 \/usr\/include\/qt/'  \
		wpa_gui/wpa_gui.pro > wpa_gui/wpa_gui.pro.new && \
	echo mv wpa_gui/wpa_gui.pro.new wpa_gui/wpa_gui.pro && \
	\
	echo make QTDIR=/usr wpa_gui && \
	echo cp -av wpa_gui/wpa_gui /usr/bin && \
	cd ../.. && \
	\
	rm -rf $(WPA-SUPPLICANT)/* && \
	make P=$(WPA-SUPPLICANT) log-package

$(GIT):  $(PERL) $(TCL) $(TK) $(OPENSSL) $(CURL) $(EXPAT)
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(GIT).tar.gz && \
	chmod 755 $(GIT) && \
	chown -R 0:0 $(GIT) && \
	cd $(GIT) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GIT)/.mailmap $(GIT)/.gitignore $(GIT)/* && \
	make P=$(GIT) log-package

$(XVID4CONF):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XVID4CONF).orig.tar.gz && \
	chmod 755 $(XVID4CONF) && \
	chown -R 0:0 $(XVID4CONF) && \
	cd $(XVID4CONF) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XVID4CONF)/* && \
	make P=$(XVID4CONF) log-package

$(IFTOP):  $(LIBPCAP) $(NCURSES)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IFTOP).tar.gz && \
	chmod 755 $(IFTOP) && \
	chown -R 0:0 $(IFTOP) && \
	cd $(IFTOP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IFTOP)/.deps $(IFTOP)/* && \
	make P=$(IFTOP) log-package

$(MP3GAIN):
	set +h && \
	\
	unzip $(JLFS-TARBALLS)/$(MP3GAIN)-src.zip -d $(MP3GAIN) && \
	chmod 755 $(MP3GAIN) && \
	chown -R 0:0 $(MP3GAIN) && \
	cd $(MP3GAIN) && \
	\
	make -j2 && \
	strip mp3gain && \
	cp -av mp3gain /usr/bin && \
	\
	cd .. && \
	rm -rf $(MP3GAIN)/* && \
	make P=$(MP3GAIN) log-package

$(MADPLAY):  $(LIBID3TAG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MADPLAY).tar.gz && \
	chmod 755 $(MADPLAY) && \
	chown -R 0:0 $(MADPLAY) && \
	cd $(MADPLAY) && \
	\
	./configure --prefix=/usr --enable-shared --with-alsa && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MADPLAY)/.libs $(MADPLAY)/.deps $(MADPLAY)/* && \
	make P=$(MADPLAY) log-package

$(IVMAN):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(IVMAN).tar.bz2 && \
	chmod 755 $(IVMAN) && \
	chown -R 0:0 $(IVMAN) && \
	cd $(IVMAN) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IVMAN)/* && \
	make P=$(IVMAN) log-package

$(FETCHYAHOO):  $(IO-STRINGY-PERL) $(MIME-BASE64-PERL) $(MAILTOOLS-PERL) \
	$(CRYPT-SSLEAY) $(URI) $(LIBWWW-PERL) $(HTML-PARSER) \
	$(MIME-TOOLS-PERL) $(MIME-BASE64-PERL) $(LIBNET)

	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FETCHYAHOO).tar.gz && \
	chmod 755 $(FETCHYAHOO) && \
	chown -R 0:0 $(FETCHYAHOO) && \
	cd $(FETCHYAHOO) && \
	\
	cp -av fetchyahoo /usr/bin && \
	cp -av fetchyahoorc /etc && \
	cp -av fetchyahoo.1 /usr/share/man/man1 && \
	\
	cd .. && \
	\
	rm -rf $(FETCHYAHOO)/* && \
	make P=$(FETCHYAHOO) log-package

$(NTFSPROGS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NTFSPROGS).tar.bz2 && \
	chmod 755 $(NTFSPROGS) && \
	chown -R 0:0 $(NTFSPROGS) && \
	cd $(NTFSPROGS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(NTFSPROGS)-no-glib.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	cd .. && \
	\
	rm -rf $(NTFSPROGS)/* && \
	make P=$(NTFSPROGS) log-package

$(GDB):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GDB).tar.bz2 && \
	chmod 755 $(GDB) && \
	chown -R 0:0 $(GDB) && \
	cd $(GDB) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	cd .. && \
	\
	rm -rf $(GDB)/* && \
	make P=$(GDB) log-package

$(FDISK):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FDISK).tar.bz2 && \
	chmod 755 $(FDISK) && \
	chown -R 0:0 $(FDISK) && \
	cd $(FDISK) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FDISK)/* && \
	make P=$(FDISK) log-package

$(TIGHTVNC):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(TIGHTVNC)_unixsrc.tar.bz2 && \
	mv vnc_unixsrc $(TIGHTVNC) && \
	chmod 755 $(TIGHTVNC) && \
	chown -R 0:0 $(TIGHTVNC) && \
	cd $(TIGHTVNC) && \
	\
	xmkmf && \
	make World && \
	\
	cd Xvnc && \
	./configure --prefix=/usr && \
	echo no make -j && \
	make && \
	cd .. && \
	\
	./vncinstall /usr/bin /usr/man && \
	cd .. && \
	rm -rf $(TIGHTVNC)/* && \
	make P=$(TIGHTVNC) log-package

$(PCMCIA-UTILS):  $(SYSFS-UTILS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PCMCIA-UTILS).tar.bz2 && \
	chmod 755 $(PCMCIA-UTILS) && \
	chown -R 0:0 $(PCMCIA-UTILS) && \
	cd $(PCMCIA-UTILS) && \
	\
	make INSTALL_DIR=/usr/sbin KERNEL_DIR=/usr/src/$(KERNEL)-$(ARCH) && \
	make install && \
	\
	cd .. && \
	rm -rf $(PCMCIA-UTILS)/* && \
	make P=$(PCMCIA-UTILS) log-package

$(SYSFS-UTILS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SYSFS-UTILS).tar.gz && \
	chmod 755 $(SYSFS-UTILS) && \
	chown -R 0:0 $(SYSFS-UTILS) && \
	cd $(SYSFS-UTILS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SYSFS-UTILS)/* && \
	make P=$(SYSFS-UTILS) log-package

$(EXIF):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(EXIF).tar.bz2 && \
	chmod 755 $(EXIF) && \
	chown -R 0:0 $(EXIF) && \
	cd $(EXIF) && \
	touch . && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(EXIF)-5.diff && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(EXIF)/* && \
	make P=$(EXIF) log-package

$(LUA):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LUA).tar.gz && \
	chmod 755 $(LUA) && \
	chown -R 0:0 $(LUA) && \
	cd $(LUA) && \
	\
	perl -p -i -e 's/^INSTALL_TOP.*$$/INSTALL_TOP= \/usr/' \
		Makefile && \
	\
	perl -p -i -e 's/^PLAT=.*$$/PLAT= linux/' \
		src/Makefile && \
	\
	perl -p -i -e 's/\/usr\/local\//\/usr\//' \
		src/luaconf.h && \
	\
	sed -e 's/^prefix=.*$$/prefix= \/usr/' \
		< etc/lua.pc > /usr/lib/pkgconfig/lua5.1.pc && \
	\
	make linux && \
	make linux install && \
	\
	cd .. && \
	rm -rf $(LUA)/* && \
	make P=$(LUA) log-package

$(MACCHANGER):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MACCHANGER).tar.gz && \
	chmod 755 $(MACCHANGER) && \
	chown -R 0:0 $(MACCHANGER) && \
	cd $(MACCHANGER) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MACCHANGER)/* && \
	make P=$(MACCHANGER) log-package

$(POWERTOP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(POWERTOP).tar.gz && \
	chmod 755 $(POWERTOP) && \
	chown -R 0:0 $(POWERTOP) && \
	cd $(POWERTOP) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(POWERTOP)/* && \
	make P=$(POWERTOP) log-package

$(MINGETTY):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MINGETTY).tar.gz && \
	chmod 755 $(MINGETTY) && \
	chown -R 0:0 $(MINGETTY) && \
	cd $(MINGETTY) && \
	\
	make -j2 && \
	strip mingetty && \
	make DESTDIR=/ install && \
	\
	cd .. && \
	rm -rf $(MINGETTY)/* && \
	make P=$(MINGETTY) log-package

$(SOX):
	set +h && \
	\
	tar jxf $(JLFS-TARBALLS)/$(SOX).tar.bz2 && \
	chmod 755 $(SOX) && \
	chown -R 0:0 $(SOX) && \
	cd $(SOX) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SOX)/* && \
	make P=$(SOX) log-package

$(MTOOLS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(MTOOLS).tar.bz2 && \
	chmod 755 $(MTOOLS) && \
	chown -R 0:0 $(MTOOLS) && \
	cd $(MTOOLS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MTOOLS)/* && \
	make P=$(MTOOLS) log-package

$(FUSE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FUSE).tar.gz && \
	chmod 755 $(FUSE) && \
	chown -R 0:0 $(FUSE) && \
	cd $(FUSE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-lib \
		--enable-util \
		--disable-rpath \
		--disable-kernel-module && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FUSE)/* && \
	make P=$(FUSE) log-package

$(FUSEISO):  $(FUSE)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FUSEISO).tar.bz2 && \
	chmod 755 $(FUSEISO) && \
	chown -R 0:0 $(FUSEISO) && \
	cd $(FUSEISO) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FUSEISO)/* && \
	make P=$(FUSEISO) log-package

$(ANYFS-TOOLS): 
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ANYFS-TOOLS).tar.bz2 && \
	chmod 755 $(ANYFS-TOOLS) && \
	chown -R 0:0 $(ANYFS-TOOLS) && \
	cd $(ANYFS-TOOLS) && \
	\
	./configure \
		--prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ANYFS-TOOLS)/* && \
	make P=$(ANYFS-TOOLS) log-package

$(BLUEZ-HCIDUMP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BLUEZ-HCIDUMP).tar.bz2 && \
	chmod 755 $(BLUEZ-HCIDUMP) && \
	chown -R 0:0 $(BLUEZ-HCIDUMP) && \
	cd $(BLUEZ-HCIDUMP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BLUEZ-HCIDUMP)/* && \
	make P=$(BLUEZ-HCIDUMP) log-package

$(LATENCYTOP):  $(NCURSES) $(GLIB2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LATENCYTOP).tar.gz && \
	chmod 755 $(LATENCYTOP) && \
	chown -R 0:0 $(LATENCYTOP) && \
	cd $(LATENCYTOP) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LATENCYTOP)/* && \
	make P=$(LATENCYTOP) log-package

$(BRIDGE-UTILS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BRIDGE-UTILS).tar.gz && \
	chmod 755 $(BRIDGE-UTILS) && \
	chown -R 0:0 $(BRIDGE-UTILS) && \
	cd $(BRIDGE-UTILS) && \
	\
	autoconf && \
	autoheader && \
	libtoolize && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BRIDGE-UTILS)/* && \
	make P=$(BRIDGE-UTILS) log-package

$(MADWIFI):  $(KERNEL)-$(ARCH)
	set +h && \
	\
	( cd $(KERNEL)-$(ARCH) && make modules_install ) && \
	\
	rm -rf $(MADWIFI) && \
	tar xvf $(JLFS-TARBALLS)/$(MADWIFI)-current.tar.gz && \
	mv $(MADWIFI)-$(MADWIFI-VER) $(MADWIFI) && \
	\
	chmod 755 $(MADWIFI) && \
	chown -R 0:0 $(MADWIFI) && \
	cd $(MADWIFI) && \
	\
	make KERNELPATH=/usr/src/$(KERNEL)-$(ARCH) BINDIR=/usr/bin \
		MANDIR=/usr/man && \
	make KERNELPATH=/usr/src/$(KERNEL)-$(ARCH) BINDIR=/usr/bin \
		MANDIR=/usr/man install && \
	\
	cd .. && \
	rm -rf $(MADWIFI)/* && \
	make P=$(MADWIFI) log-package

$(DMIDECODE):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DMIDECODE).tar.bz2 && \
	chmod 755 $(DMIDECODE) && \
	chown -R 0:0 $(DMIDECODE) && \
	cd $(DMIDECODE) && \
	\
	make prefix=/usr && \
	make prefix=/usr install && \
	\
	cd .. && \
	rm -rf $(DMIDECODE)/* && \
	make P=$(DMIDECODE) log-package

$(UNRAR):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(UNRAR).tar.gz && \
	mv unrar $(UNRAR) && \
	chmod 755 $(UNRAR) && \
	chown -R 0:0 $(UNRAR) && \
	cd $(UNRAR) && \
	\
	make -f makefile.unix && \
	cp -av unrar /usr/bin && \
	\
	cd .. && \
	rm -rf $(UNRAR)/* && \
	make P=$(UNRAR) log-package

$(GPART):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GPART).tar.bz2 && \
	chmod 755 $(GPART) && \
	chown -R 0:0 $(GPART) && \
	cd $(GPART) && \
	\
	cp -av gpart.linux /usr/sbin/gpart && \
	\
	cd .. && \
	rm -rf $(GPART)/* && \
	make P=$(GPART) log-package

$(MULTIPATH-TOOLS):  $(LIBAIO)
	set +h && \
	\
	mkdir -p $(MULTIPATH-TOOLS) && \
	tar jxvf $(JLFS-TARBALLS)/$(MULTIPATH-TOOLS).tar.bz2 \
		-C $(MULTIPATH-TOOLS) && \
	chmod 755 $(MULTIPATH-TOOLS) && \
	chown -R 0:0 $(MULTIPATH-TOOLS) && \
	cd $(MULTIPATH-TOOLS) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MULTIPATH-TOOLS)/* && \
	make P=$(MULTIPATH-TOOLS) log-package

$(YOUTUBE-DL):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(YOUTUBE-DL).tar.bz2 && \
	chmod 755 $(YOUTUBE-DL) && \
	chown -R 0:0 $(YOUTUBE-DL) && \
	cd $(YOUTUBE-DL) && \
	\
	cp -av youtube-dl /usr/bin && \
	chmod 755 /usr/bin/youtube-dl && \
	\
	cd .. && \
	rm -rf $(YOUTUBE-DL)/* && \
	make P=$(YOUTUBE-DL) log-package

$(DRDB):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DRDB).tar.gz && \
	chmod 755 $(DRDB) && \
	chown -R 0:0 $(DRDB) && \
	cd $(DRDB) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DRDB)/* && \
	make P=$(DRDB) log-package

$(KEEPALIVED):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(KEEPALIVED).tar.gz && \
	chmod 755 $(KEEPALIVED) && \
	chown -R 0:0 $(KEEPALIVED) && \
	cd $(KEEPALIVED) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(KEEPALIVED)/* && \
	make P=$(KEEPALIVED) log-package

$(IPFSADM):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IPFSADM).tar.gz && \
	chmod 755 $(IPFSADM) && \
	chown -R 0:0 $(IPFSADM) && \
	cd $(IPFSADM) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IPFSADM)/* && \
	make P=$(IPFSADM) log-package

$(EC2-AMI-TOOLS):  $(RUBY)
	set +h && \
	\
	unzip $(JLFS-TARBALLS)/$(EC2-AMI-TOOLS).zip && \
	chmod 755 $(EC2-AMI-TOOLS) && \
	chown -R 0:0 $(EC2-AMI-TOOLS) && \
	cd $(EC2-AMI-TOOLS) && \
	\
	cp -av bin lib $(LFS)/usr && \
	cp -av etc $(LFS)/ && \
	\
	cd .. && \
	rm -rf $(EC2-AMI-TOOLS)/* && \
	make P=$(EC2-AMI-TOOLS) log-package

$(RAR):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(RAR).tar.gz && \
	mv rar $(RAR) && \
	chmod 755 $(RAR) && \
	chown -R 0:0 $(RAR) && \
	cd $(RAR) && \
	\
	make PREFIX=/usr install && \
	\
	cd .. && \
	rm -rf $(RAR)/* && \
	make P=$(RAR) log-package

$(MERCURIAL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MERCURIAL).tar.gz && \
	chmod 755 $(MERCURIAL) && \
	chown -R 0:0 $(MERCURIAL) && \
	cd $(MERCURIAL) && \
	\
	perl -p -i -e 's/^all: build doc/all: build/' Makefile && \
	perl -p -i -e \
		's/^install: install-bin install-doc/install: install-bin/' \
		Makefile && \
	\
	make PREFIX=/usr && \
	make PREFIX=/usr install && \
	\
	cd .. && \
	rm -rf $(MERCURIAL)/* && \
	make P=$(MERCURIAL) log-package

$(PYTHON3):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYTHON3).tar.bz2 && \
	chmod 755 $(PYTHON3) && \
	chown -R 0:0 $(PYTHON3) && \
	cd $(PYTHON3) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYTHON3)/* && \
	make P=$(PYTHON3) log-package

$(KEYFUZZ):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(KEYFUZZ).tar.gz && \
	chmod 755 $(KEYFUZZ) && \
	chown -R 0:0 $(KEYFUZZ) && \
	cd $(KEYFUZZ) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(KEYFUZZ)/* && \
	make P=$(KEYFUZZ) log-package

$(MCRYPT):  $(LIBMCRYPT) $(LIBMHASH)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MCRYPT).tar.gz && \
	chmod 755 $(MCRYPT) && \
	chown -R 0:0 $(MCRYPT) && \
	cd $(MCRYPT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MCRYPT)/* && \
	make P=$(MCRYPT) log-package

$(CMAKE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CMAKE).tar.gz && \
	chmod 755 $(CMAKE) && \
	chown -R 0:0 $(CMAKE) && \
	cd $(CMAKE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CMAKE)/* && \
	make P=$(CMAKE) log-package

$(YASM):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(YASM).tar.gz && \
	chmod 755 $(YASM) && \
	chown -R 0:0 $(YASM) && \
	cd $(YASM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(YASM)/* $(YASM)/.deps && \
	make P=$(YASM) log-package

$(DVDAUTHOR):  
	set +h && \
	\
	tar zxf $(JLFS-TARBALLS)/$(DVDAUTHOR).tar.gz && \
	mv dvdauthor $(DVDAUTHOR) && \
	chmod 755 $(DVDAUTHOR) && \
	chown -R 0:0 $(DVDAUTHOR) && \
	cd $(DVDAUTHOR) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DVDAUTHOR)/* && \
	make P=$(DVDAUTHOR) log-package

$(IPVSADM):  $(LIBNL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IPVSADM).tar.gz && \
	chmod 755 $(IPVSADM) && \
	chown -R 0:0 $(IPVSADM) && \
	cd $(IPVSADM) && \
	\
	perl -p -i -e 's/-lnl/-lnl-3/' Makefile && \
	\
	make CFLAGS="-I/usr/include/libnl3" && \
	make install && \
	\
	cd .. && \
	rm -rf $(IPVSADM)/* && \
	make P=$(IPVSADM) log-package

$(S3CMD):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(S3CMD).tar.gz && \
	chmod 755 $(S3CMD) && \
	chown -R 0:0 $(S3CMD) && \
	cd $(S3CMD) && \
	\
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(S3CMD)/* && \
	make P=$(S3CMD) log-package

$(TUNCTL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TUNCTL).tar.gz && \
	chmod 755 $(TUNCTL) && \
	chown -R 0:0 $(TUNCTL) && \
	cd $(TUNCTL) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(TUNCTL)-no-manpage.patch && \
	make && \
	strip tunctl && \
	make install && \
	\
	cd .. && \
	rm -rf $(TUNCTL)/* && \
	make P=$(TUNCTL) log-package

#
# End JLFS Custom-CLI
# Begin JLFS Custom-GUI
#

$(SEAMONKEY):  $(NSS) $(GTK2) $(LIBIDL) $(ZIP) $(CAIRO) $(LIBNOTIFY) $(SQLITE) \
	$(ALSA-LIB) $(YASM) $(LIBVPX)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SEAMONKEY).source.tar.bz2 && \
	mv comm-release $(SEAMONKEY) && \
	chmod 755 $(SEAMONKEY) && \
	chown -R 0:0 $(SEAMONKEY) && \
	cd $(SEAMONKEY) && \
	\
	cp -av $(JLFS-CONFIGS)/seamonkey.mozconfig .mozconfig && \
	\
	make -j2 -f client.mk && \
	make -C moz-build-dir/suite/installer && \
	mkdir -p /usr/lib/$(SEAMONKEY) && \
	\
	tar xfv moz-build-dir/mozilla/dist/seamonkey*.tar.bz2 \
		-C /usr/lib/$(SEAMONKEY) --strip-components=1 && \
	ln -sfv /usr/lib/$(SEAMONKEY)/seamonkey /usr/bin/seamonkey && \
	mkdir -p /usr/lib/mozilla/plugins && \
	ln -sfv /usr/lib/mozilla/plugins /usr/lib/$(SEAMONKEY)/plugins && \
	ln -sfn /usr/lib/$(SEAMONKEY)/seamonkey /usr/bin/seamonkey && \
	ln -sfn /usr/bin/seamonkey /usr/bin/firefox && \
	chown -R -v root:root /usr/lib/$(SEAMONKEY) && \
	cp -av moz-build-dir/mozilla/dist/man/man1/seamonkey.1 \
		/usr/share/man/man1 && \
	\
	cd .. && \
	rm -rf $(SEAMONKEY)/.mozconfig* $(SEAMONKEY)/* && \
	make P=$(SEAMONKEY) log-package

#$(FIREFOX):  $(NSS) $(GTK2) $(LIBIDL) $(ZIP) $(CAIRO) $(LIBNOTIFY) $(SQLITE) \
#	$(ALSA-LIB) $(YASM)
#
#	set +h && \
#	\
#	tar jxvf $(JLFS-TARBALLS)/$(FIREFOX).source.tar.bz2 && \
#	mv mozilla-release $(FIREFOX) && \
#	chmod 755 $(FIREFOX) && \
#	chown -R 0:0 $(FIREFOX) && \
#	\
#	cp -av $(JLFS-TARBALLS)/firefox.mozconfig $(FIREFOX)/.mozconfig && \
#	\
#	mkdir -p firefox-build && \
#	cd firefox-build && \
#	\
#	make -j2 -f ../$(FIREFOX)/client.mk build && \
#	make -C browser/installer && \
#	mkdir -p /usr/lib/$(FIREFOX) && \
#	\
#	tar xfv dist/firefox-*.tar.bz2 \
#		-C /usr/lib/$(FIREFOX) --strip-components=1 && \
#	ln -sfv /usr/lib/$(FIREFOX)/firefox /usr/bin/firefox && \
#	mkdir -p /usr/lib/mozilla/plugins && \
#	ln -sv /usr/lib/mozilla/plugins /usr/lib/$(FIREFOX)/plugins && \
#	chown -R -v root:root /usr/lib/$(FIREFOX) && \
#	\
#	cd .. && \
#	rm -rf $(FIREFOX)/.mozconfig* $(FIREFOX)/* firefox-build && \
#	make P=$(FIREFOX) log-package

$(GIMP):  $(GTK2) $(LIBART) $(XML-PARSER) $(ATK) $(PANGO) $(LIBPNG) \
	$(BABL) $(GEGL) $(GLIB2)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GIMP).tar.bz2 && \
	chmod 755 $(GIMP) && \
	chown -R 0:0 $(GIMP) && \
	cd $(GIMP) && \
	\
	./configure --prefix=/usr \
            --sysconfdir=/etc --enable-mp --with-x \
            --disable-print && \
	make -j2 && \
	make install && \
	cd .. && \
	rm -rf $(GIMP)/* && \
	make P=$(GIMP) log-package

$(FVWM95):  $(XORG7) $(GCC3)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FVWM95).tar.gz && \
	chmod 755 $(FVWM95) && \
	chown -R 0:0 $(FVWM95) && \
	cd $(FVWM95) && \
	\
	PATH=/opt/$(GCC3)/bin:$(PATH) ./configure --prefix=/usr && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make install && \
	tar xvf $(JLFS-TARBALLS)/fvwm95icons-horen.tar.gz -C /usr/lib/X11 && \
	chown -R 0:0 /usr/lib/X11/icons/* && \
	\
	cd .. && \
	rm -rf $(FVWM95)/* && \
	make P=$(FVWM95) log-package

$(XWC):  $(GCC3) $(XORG7)
	set +h && \
	\
	mkdir $(XWC) && \
	tar xvf $(JLFS-TARBALLS)/$(XWC).tar.gz -C $(XWC) && \
	chmod 755 $(XWC) && \
	chown -R 0:0 $(XWC) && \
	cd $(XWC) && \
	\
	tar jxvf fox-0.99.42.tar.bz2 && \
	tar jxvf xwc-0.91.5.tar.bz2 && \
	bzip2 -d *patch*bz2 && \
	patch -Np0 -i fox-0.99.42.patch && \
	patch -Np0 -i fox-0.99.42.patch2 && \
	patch -Np0 -i fox-0.99.42.patch3 && \
	\
	cd fox && \
	PATH=/opt/$(GCC3)/bin:$(PATH) ./configure --with-opengl=no  \
		--prefix=/usr && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make install && \
	\
	cd ../xwc-0.91.5 && \
	perl -p -i -e "s/echo \"\"/echo \"#include <locale.h>\"/" \
		Makefile && \
	\
	perl -p -i -e "s/^INSTALLDIR=.*/INSTALLDIR= \/usr/" Makefile && \
	perl -p -i -e "s/usr\/local/usr/" Makefile && \
	perl -p -i -e "s/usr\/local/usr/" QueryRPM/Makefile && \
	perl -p -i -e "s/usr\/local/usr/" textedit/Makefile && \
	perl -p -i -e "s/usr\/local/usr/" textview/Makefile && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make FOXLIB=/usr/lib INSTALLDIR=/usr && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make drop && \
	cd ../.. && \
	\
	rm -rf $(XWC)/* && \
	make P=$(XWC) log-package

$(XV):  $(TCSH) $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XV).tar.gz && \
	chmod 755 $(XV) && \
	chown -R 0:0 $(XV) && \
	cd $(XV) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(XV).patch && \
	perl -p -i -e "s/usr\/local/usr/" Makefile && \
	\
	make BINDIR=/usr/bin  \
		MANDIR=/usr/man/man1  LIBDIR=/usr/lib && \
	make install && \
	rm -f /usr/lib/xvdocs.ps && \
	\
	cd .. && \
	rm -rf $(XV)/* && \
	make P=$(XV) log-package

$(GKRELLM):  $(GTK2) $(GLIB2)
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(GKRELLM).tar.gz && \
	chmod 755 $(GKRELLM) && \
	chown -R 0:0 $(GKRELLM) && \
	cd $(GKRELLM) && \
	\
	patch -Np0 -i $(JLFS-PATCHES)/$(GKRELLM)-getline-fix.patch && \
	\
	make -j2 && \
	make INSTALLROOT=/usr install && \
	\
	cd .. && \
	rm -rf $(GKRELLM)/* && \
	make P=$(GKRELLM) log-package

$(XDALICLOCK):  $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XDALICLOCK).tar.gz && \
	chmod 755 $(XDALICLOCK) && \
	chown -R 0:0 $(XDALICLOCK) && \
	cd $(XDALICLOCK) && \
	\
	cd X11 && \
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd ../.. && \
	rm -rf $(XDALICLOCK)/* && \
	make P=$(XDALICLOCK) log-package

$(WIFI-RADAR):  $(PYTHON)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(WIFI-RADAR).tar.bz2 && \
	chmod 755 $(WIFI-RADAR) && \
	chown -R 0:0 $(WIFI-RADAR) && \
	cd $(WIFI-RADAR) && \
	\
	perl -p -i -e 's/init\.d/rc\.d\/init\.d/' Makefile && \
	\
	make -j2 && \
	make install sysconfdir=/etc/wifi-radar && \
	\
	cd .. && \
	rm -rf $(WIFI-RADAR)/* && \
	make P=$(WIFI-RADAR) log-package

$(XXDIFF):  $(TMAKE) $(QT3) $(GCC4-OLD)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(XXDIFF).tar.bz2 && \
	chmod 755 $(XXDIFF) && \
	chown -R 0:0 $(XXDIFF) && \
	cd $(XXDIFF)/src && \
	\
	perl -p -i -e 's/^QTDIR.*/QTDIR = \/usr/' \
		Makefile.bootstrap && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -f Makefile.bootstrap makefile && \
	\
	perl -p -i -e 's/include$$/include\/qt/' Makefile.qmake Makefile && \
	\
        PATH=/opt/$(GCC4-OLD)/bin:$(PATH) QTDIR=/usr make -j2 && \
        cd .. && install bin/xxdiff /usr/bin && \
	\
	cd .. && \
	rm -rf $(XXDIFF)/* && \
	make P=$(XXDIFF) log-package

$(QEMU):  $(SDL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(QEMU).tar.gz && \
	tar xvf $(JLFS-TARBALLS)/$(KQEMU).tar.gz -C $(QEMU) && \
	tar jxvf $(JLFS-TARBALLS)/$(QEMU-EFI).tar.bz2 -C $(QEMU) && \
	chmod 755 $(QEMU) && \
	chown -R 0:0 $(QEMU) && \
	cd $(QEMU) && \
	\
	./configure --prefix=/usr \
		--disable-smartcard \
		--target-list=i386-linux-user,i386-softmmu && \
	\
	make -j2 && \
	echo OK

	# the first make install fails!
	#
	-(cd $(QEMU) && make install)
	cd $(QEMU) && \
	make install && \
	(cd $(LFS)/usr/bin && ln -sfn qemu-system-i386 qemu) && \
	\
	cd $(KQEMU) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(KQEMU)-init_MUTEX.patch && \
	\
	./configure --prefix=/usr \
		--kernel-path=/usr/src/$(KERNEL)-$(ARCH) && \
	make -j2 && \
	\
	mkdir -p $(LFS)/lib/modules/$(KERNEL-VER)-$(ARCH)/misc && \
	cp -av kqemu.ko $(LFS)/lib/modules/$(KERNEL-VER)-$(ARCH)/misc && \
	\
	cd ../.. && \
	\
	mkdir -p $(LFS)/usr/share/qemu/efi-bios && \
	cp -av $(QEMU)/efi-bios/README $(QEMU)/efi-bios/bios.bin \
		$(LFS)/usr/share/qemu/efi-bios && \
	\
	echo wait for kernel modules installs \
		rm -rf $(QEMU)/* $(QEMU)/.cvsignore && \
	make P=$(QEMU) log-package

$(VIRTUALBRICKS):  $(QEMU) $(PYTHON) $(PYGTK2) $(LIBGLADE) $(PIL) $(PYGRAPHVIZ)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(VIRTUALBRICKS).tar.bz2 && \
	mv virtualbricks $(VIRTUALBRICKS) && \
	chmod 755 $(VIRTUALBRICKS) && \
	chown -R 0:0 $(VIRTUALBRICKS) && \
	cd $(VIRTUALBRICKS) && \
	\
	cp -av share/virtualbricks.template.glade share/virtualbricks.glade && \
	\
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(VIRTUALBRICKS)/* && \
	make P=$(VIRTUALBRICKS) log-package

$(PARTIMAGE):  $(NEWT) $(SLANG) $(OPENSSL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PARTIMAGE).tar.bz2 && \
	chmod 755 $(PARTIMAGE) && \
	chown -R 0:0 $(PARTIMAGE) && \
	cd $(PARTIMAGE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
        make -j2 && \
        perl -p -i -e "s/partimag.root/root.root/" Makefile Makefile.am && \
        make install && \
	\
	cd .. && \
	rm -rf $(PARTIMAGE)/* && \
	make P=$(PARTIMAGE) log-package

$(DVDRIP):  $(PERL) $(EVENT-PERL) $(LIBINTL-PERL) $(GTK2-PERL) $(XVID4CONF)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DVDRIP).tar.gz && \
	chmod 755 $(DVDRIP) && \
	chown -R 0:0 $(DVDRIP) && \
	cd $(DVDRIP) && \
	\
	perl Makefile.PL && \
	echo no make -j for you && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(DVDRIP)/* && \
	make P=$(DVDRIP) log-package

$(VLC):  $(XVIDCORE) $(XORG7) $(SDL) $(FFMPEG) $(LIBMAD) \
	$(A52DEC) $(FAAD2) $(LIBVORBIS) $(LIBOGG) $(FAAC) \
	$(FREETYPE) $(FRIBIDI) $(FLAC) $(ALSA-LIB) $(QT4) $(SDL-IMAGE) \
	$(LIBDVDNAV) $(LIBCDIO) $(LIBDVBPSI) $(LUA) $(VCDIMAGER) \
	$(TAGLIB) $(AVAHI) $(GNOME-VFS) $(LIBMUSICBRAINZ) $(X264) \
	$(WXWIDGETS) $(DIVX4LINUX) $(LIBID3TAG) $(LIBDVBCSA) $(CDPARANOIA) \
	$(LIBMPEG3) $(LIBMPEG2)

	set +h && \
	\
	dbus-uuidgen > $(LFS)/var/lib/dbus/machine-id && \
	\
	rm -rf $(VLC) && \
	tar jxvf $(JLFS-TARBALLS)/$(VLC).tar.bz2 && \
	\
	( cd $(VLC)/share/skins2 && \
	unzip $(JLFS-TARBALLS)/$(VLC-SKINS).zip ) && \
	\
	chmod 755 $(VLC) && \
	chown -R 0:0 $(VLC) && \
	cd $(VLC) && \
	\
	PKG_CONFIG_PATH=/opt/qt/lib/pkgconfig ./configure --prefix=/usr \
		--enable-run-as-root \
		--disable-swscale \
		--enable-cdda \
		--enable-x11 \
		--enable-xvideo \
		--enable-sdl \
		--enable-speex \
		--enable-musicbrainz \
		--enable-gnomevfs \
		--enable-id3tag \
		--enable-arts \
		\
		--enable-ffmpeg \
		--with-ffmpeg-tree=/usr/src/$(FFMPEG) \
		\
		--with-ffmpeg-mp3lame \
		--with-ffmpeg-faac \
		--with-ffmpeg-zlib \
		--with-ffmpeg-x264 \
		--with-ffmpeg-a52 \
		--enable-a52 \
		--with-a52-tree=/usr/src/$(A52DEC) \
		\
		--enable-libmpeg2 \
		--with-libmpeg2-tree=/usr/src/$(MPEG2DEC) \
		\
		--enable-x264 \
		--with-x264-tree=/usr/src/$(X264) \
		\
		--enable-faad \
		--with-faad-tree=/usr/src/$(FAAD2) \
		\
		--enable-faac \
		--enable-dvdread \
		--enable-dvdnav --enable-mad \
		--enable-libdvbpsi \
		--enable-libcdio \
		--enable-vcdx \
		\
		--enable-vorbis \
		--enable-ogg \
		--enable-freetype \
		--enable-fribidi \
		--enable-flac \
		--enable-skins2 \
		--enable-alsa \
		--enable-qt4 \
		--enable-wxwidgets \
		\
		--disable-vcd \
		--disable-kde \
		--disable-ncurses \
		--disable-zvbi \
		--disable-dca \
		--disable-fluidsynth \
		--disable-kate \
		--disable-gnutls \
		--disable-pulse \
		--disable-notify \
		--disable-rpath \
		--enable-release && \
	make -j2 && \
	make install && \
	\
	chmod u+s /usr/bin/vlc-wrapper && \
	\
	cd .. && \
	rm -rf $(VLC)/* && \
	rm -f $(LFS)/var/lib/dbus/machine-id && \
	rm -rf $(FFMPEG)/.libs $(FFMPEG)/.depend $(FFMPEG)/* && \
	make P=$(VLC) log-package

$(KISMET):  $(DBUS) $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(KISMET).tar.gz && \
	chmod 755 $(KISMET) && \
	chown -R 0:0 $(KISMET) && \
	cd $(KISMET) && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) \
		./configure --prefix=/usr \
			--sysconfdir=/etc \
			--disable-gpsmap && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(KISMET)/.depend $(KISMET)/* && \
	make P=$(KISMET) log-package

$(ESVN):  $(QT3)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ESVN).tar.gz && \
	mv esvn $(ESVN) && \
	chmod 755 $(ESVN) && \
	chown -R 0:0 $(ESVN) && \
	cd $(ESVN) && \
	\
	make QTDIR=/usr && \
	make QTDIR=/usr install && \
	strip esvn && \
	cp -av esvn /usr/bin && \
	\
	cd .. && \
	rm -rf $(ESVN)/.moc $(ESVN)/.obj $(ESVN)/.ui $(ESVN)/* && \
	make P=$(ESVN) log-package

$(GQVIEW):  $(LCMS) $(GTK2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GQVIEW).tar.gz && \
	chmod 755 $(GQVIEW) && \
	chown -R 0:0 $(GQVIEW) && \
	cd $(GQVIEW) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-gtktest && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GQVIEW)/* && \
	make P=$(GQVIEW) log-package

$(GLADE3):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GLADE3).tar.bz2 && \
	chmod 755 $(GLADE3) && \
	chown -R 0:0 $(GLADE3) && \
	cd $(GLADE3) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-scrollkeeper && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GLADE3)/* && \
	make P=$(GLADE3) log-package

$(GLSOF):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GLSOF).tar.gz && \
	chmod 755 $(GLSOF) && \
	chown -R 0:0 $(GLSOF) && \
	cd $(GLSOF) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GLSOF)/* && \
	make P=$(GLSOF) log-package

$(GTKLP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GTKLP).src.tar.gz && \
	chmod 755 $(GTKLP) && \
	chown -R 0:0 $(GTKLP) && \
	cd $(GTKLP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKLP)/* && \
	make P=$(GTKLP) log-package

$(QUODLIBET):  $(MUTAGEN) $(PYGTK2) $(GST-PLUGINS-BASE) \
	$(GST-PLUGINS-GOOD) $(GST-PLUGINS-UGLY) $(PYTHON) $(GST-PYTHON) \
	$(LIBMAD) $(MADPLAY)

	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(QUODLIBET).tar.gz && \
	chmod 755 $(QUODLIBET) && \
	chown -R 0:0 $(QUODLIBET) && \
	cd $(QUODLIBET) && \
	\
	cp -a $(JLFS-CONFIGS)/quodlibet-cddb.py quodlibet/plugins/cddb.py && \
	cp -a $(JLFS-CONFIGS)/quodlibet-replaygain.py \
		quodlibet/plugins/replaygain.py && \
	cp -a $(JLFS-CONFIGS)/quodlibet-openterminal.2.py \
		quodlibet/plugins/openterminal.2.py && \
	\
	./setup.py build && \
	./setup.py install && \
	\
	cd .. && \
	rm -rf $(QUODLIBET)/* && \
	make P=$(QUODLIBET) log-package

$(LINNEIGHBORHOOD):  $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LINNEIGHBORHOOD).tar.gz && \
	chmod 755 $(LINNEIGHBORHOOD) && \
	chown -R 0:0 $(LINNEIGHBORHOOD) && \
	cd $(LINNEIGHBORHOOD) && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) \
		./configure --prefix=/usr --disable-gtktest && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(LINNEIGHBORHOOD)/* && \
	make P=$(LINNEIGHBORHOOD) log-package

$(LSHW):  $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LSHW).tar.gz && \
	chmod 755 $(LSHW) && \
	chown -R 0:0 $(LSHW) && \
	cd $(LSHW) && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make gui && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install-gui && \
	\
	cd .. && \
	rm -rf $(LSHW)/* && \
	make P=$(LSHW) log-package

$(PINENTRY):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PINENTRY).tar.gz && \
	chmod 755 $(PINENTRY) && \
	chown -R 0:0 $(PINENTRY) && \
	cd $(PINENTRY) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PINENTRY)/* && \
	make P=$(PINENTRY) log-package

$(DIA):  $(PKG-CONFIG) $(GTK2) $(LIBXML2) $(INTLTOOL) $(FREETYPE) $(LIBPNG) \
	$(BLFS-GNOME-LIB) $(LIBART) $(PYTHON) $(PYGTK2) $(LIBXSLT)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DIA).tar.bz2 && \
	chmod 755 $(DIA) && \
	chown -R 0:0 $(DIA) && \
	cd $(DIA) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(DIA)-no-glib.patch && \
	\
	./configure --prefix=/opt --enable-gnome --with-python \
		--enable-db2html && \
	\
	echo "Skipping build of docs because xsltproc is retarded" && \
	perl -p -i -e 's/data doc tests/data tests/' Makefile && \
	\
	make -j2 && \
	make install && \
	\
	(cd /usr/bin; ln -sfn /opt/bin/dia .) && \
	\
	cd .. && \
	rm -rf $(DIA)/* && \
	make P=$(DIA) log-package

$(BAOBAB):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BAOBAB).tar.gz && \
	chmod 755 $(BAOBAB) && \
	chown -R 0:0 $(BAOBAB) && \
	cd $(BAOBAB) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(BAOBAB)-no-glib.patch && \
	\
	PKG_CONFIG_PATH=/usr/lib/pkg-config \
		./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BAOBAB)/* && \
	make P=$(BAOBAB) log-package

$(LAVAPS): $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LAVAPS).tar.gz && \
	chmod 755 $(LAVAPS) && \
	chown -R 0:0 $(LAVAPS) && \
	cd $(LAVAPS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LAVAPS)-no-page.h.patch && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) \
		./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(LAVAPS)/* && \
	make P=$(LAVAPS) log-package

$(DDD):  $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DDD).tar.gz && \
	chmod 755 $(DDD) && \
	chown -R 0:0 $(DDD) && \
	cd $(DDD) && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) \
		./configure --prefix=/usr --sysconfdir=/etc && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(DDD)/* && \
	make P=$(DDD) log-package

$(ETTERCAP-NG):  $(LIBPCAP) $(LIBNET) $(LIBPTHREAD-STUBS) $(GLIB2) $(GTK2) \
	$(OPENSSL) $(PCRE) $(ATK) $(PANGO)

	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ETTERCAP-NG).tar.gz && \
	chmod 755 $(ETTERCAP-NG) && \
	chown -R 0:0 $(ETTERCAP-NG) && \
	cd $(ETTERCAP-NG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ETTERCAP-NG)/* && \
	make P=$(ETTERCAP-NG) log-package

$(FWBUILDER):  $(LIBFWBUILDER)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FWBUILDER).tar.gz && \
	chmod 755 $(FWBUILDER) && \
	chown -R 0:0 $(FWBUILDER) && \
	cd $(FWBUILDER) && \
	\
	QTDIR=/opt/qt QMAKE=/opt/qt/bin/qmake ./autogen.sh \
		--prefix=/usr && \
	QTDIR=/opt/qt make -j2 && \
	QTDIR=/opt/qt make install && \
	\
	cd .. && \
	rm -rf $(FWBUILDER)/* && \
	make P=$(FWBUILDER) log-package

$(XCDROAST):  $(GDK-PIXBUF1) $(GTK) $(GLIB) $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XCDROAST).tar.gz && \
	chmod 755 $(XCDROAST) && \
	chown -R 0:0 $(XCDROAST) && \
	cd $(XCDROAST) && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XCDROAST)-new_configure.tar.gz && \
	patch -Np1 -i $(JLFS-PATCHES)/$(XCDROAST)-wav.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XCDROAST)/* && \
	make P=$(XCDROAST) log-package

$(ETHERAPE):  $(XORG7) $(BLFS-GNOME-CORE) $(LIBPCAP) $(GTK2) $(LIBGLADE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ETHERAPE).tar.gz && \
	chmod 755 $(ETHERAPE) && \
	chown -R 0:0 $(ETHERAPE) && \
	cd $(ETHERAPE) && \
	\
	./configure PKG_CONFIG_PATH=/usr/lib/pkgconfig \
		--prefix=/usr --sysconfdir=/etc && \
	\
	perl -p -i -e 's/^SUBDIRS = src doc/SUBDIRS = src/' \
		Makefile Makefile.in Makefile.am && \
	\
	make -j2 && \
	make install-exec && \
	make install-data && \
	\
	cd .. && \
	rm -rf $(ETHERAPE)/* && \
	make P=$(ETHERAPE) log-package

$(FIRESTARTER):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FIRESTARTER).tar.gz && \
	chmod 755 $(FIRESTARTER) && \
	chown -R 0:0 $(FIRESTARTER) && \
	cd $(FIRESTARTER) && \
	\
	./configure PKG_CONFIG_PATH=/usr/lib/pkgconfig \
		--prefix=/usr  --sysconfdir=/etc  && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FIRESTARTER)/* && \
	make P=$(FIRESTARTER) log-package

$(ASUNDER):  $(LIBCDDB) $(LAME) $(GTK2) $(CDPARANOIA) $(FLAC) $(LIBVORBIS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ASUNDER).tar.bz2 && \
	chmod 755 $(ASUNDER) && \
	chown -R 0:0 $(ASUNDER) && \
	cd $(ASUNDER) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ASUNDER)/* && \
	make P=$(ASUNDER) log-package

$(GTKAM):  $(GTK2) $(LIBEXIF) $(LIBEXIF-GTK)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTKAM).tar.bz2 && \
	chmod 755 $(GTKAM) && \
	chown -R 0:0 $(GTKAM) && \
	cd $(GTKAM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKAM)/* && \
	make P=$(GTKAM) log-package

$(GPHOTO):  $(GTK2) $(LIBGPHOTO2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GPHOTO).tar.bz2 && \
	chmod 755 $(GPHOTO) && \
	chown -R 0:0 $(GPHOTO) && \
	cd $(GPHOTO) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	rm -f /usr/include/gphoto2/gphoto2 && \
	\
	cd .. && \
	rm -rf $(GPHOTO)/* && \
	make P=$(GPHOTO) log-package

$(GPARTED):  $(GTKMM2) $(GPART)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GPARTED).tar.bz2 && \
	chmod 755 $(GPARTED) && \
	chown -R 0:0 $(GPARTED) && \
	cd $(GPARTED) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(GPARTED)-fix-includes.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-scrollkeeper \
		--disable-doc --enable-static && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GPARTED)/* && \
	make P=$(GPARTED) log-package

$(ACETONEISO2):  $(QT4) $(FUSE) $(FUSEISO) $(NAUTILUS) $(POWERISO)
	set +h && \
	\
	rm -rf $(ACETONEISO2) && \
	tar jxvf $(JLFS-TARBALLS)/$(ACETONEISO2)_source.tar.bz2 && \
	mv acetoneiso2 $(ACETONEISO2) && \
	\
	chmod 755 $(ACETONEISO2) && \
	chown -R 0:0 $(ACETONEISO2) && \
	cd $(ACETONEISO2) && \
	\
	cd src && \
	QTDIR=/opt/qt PATH=/opt/qt/bin:$(PATH) qmake && \
	QTDIR=/opt/qt PATH=/opt/qt/bin:$(PATH) make -j2 && \
	QTDIR=/opt/qt PATH=/opt/qt/bin:$(PATH) make install && \
	\
	cd .. && \
	cd .. && \
	rm -rf $(ACETONEISO2)/* && \
	make P=$(ACETONEISO2) log-package

$(GWHERE):  $(XORG7) $(GTK2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GWHERE).tar.gz && \
	chmod 755 $(GWHERE) && \
	chown -R 0:0 $(GWHERE) && \
	cd $(GWHERE) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--enable-gtk20 \
		--disable-rpath \
		--disable-gtktest && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GWHERE)/* && \
	make P=$(GWHERE) log-package

$(POWERISO):
	set +h && \
	\
	mkdir -p $(POWERISO) && \
	chmod 755 $(POWERISO) && \
	chown -R 0:0 $(POWERISO) && \
	cd $(POWERISO) && \
	tar xvf $(JLFS-TARBALLS)/$(POWERISO).tar.gz && \
	\
	cp -av poweriso /usr/bin && \
	\
	cd .. && \
	rm -rf $(POWERISO)/* && \
	make P=$(POWERISO) log-package

$(X3270):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(X3270).$(X3270-PATCHLEVEL).tgz && \
	chmod 755 $(X3270) && \
	chown -R 0:0 $(X3270) && \
	cd $(X3270) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--with-fontdir=/usr/share/fonts/X11 && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(X3270)/* && \
	make P=$(X3270) log-package

$(CINELERRA):  $(OPENEXR) $(LIBSNDFILE) $(FFTW) 
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(CINELERRA).tar.bz2 && \
	chmod 755 $(CINELERRA) && \
	chown -R 0:0 $(CINELERRA) && \
	cd $(CINELERRA) && \
	\
	./autogen.sh && \
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CINELERRA)/* $(CINELERRA)/.git* && \
	make P=$(CINELERRA) log-package

$(OPENSHOT):  $(PYTHON) $(GTK2) $(PYGTK2) $(PYGOOCANVAS) $(MLTFRAMEWORK) \
	$(FREI0R-PLUGINS) $(PYXDG)

	set +h && \
	\
	rm -rf $(OPENSHOT) && \
	tar xvf $(JLFS-TARBALLS)/$(OPENSHOT).tar.gz && \
	\
	chmod 755 $(OPENSHOT) && \
	chown -R 0:0 $(OPENSHOT) && \
	cd $(OPENSHOT) && \
	\
	python setup.py install && \
	ln -sfn /usr/lib/$(PYTHON-VER)/site-packages/openshot \
		/usr/share/openshot  && \
	\
	cd .. && \
	rm -rf $(OPENSHOT)/* && \
	make P=$(OPENSHOT) log-package

$(XVIDCAP):
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(XVIDCAP).tar.gz && \
	chmod 755 $(XVIDCAP) && \
	chown -R 0:0 $(XVIDCAP) && \
	cd $(XVIDCAP) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(XVIDCAP)-no-glib.patch && \
	\
	perl -p -i -e 's/shmstr\.h/shmproto\.h/' src/capture.c && \
	perl -p -i -e 's/^SUBDIRS = xvidcap/SUBDIRS = /' doc/Makefile.in && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XVIDCAP)/* && \
	make P=$(XVIDCAP) log-package

$(TRANSMISSION):  $(LIBEVENT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(TRANSMISSION).tar.bz2 && \
	chmod 755 $(TRANSMISSION) && \
	chown -R 0:0 $(TRANSMISSION) && \
	cd $(TRANSMISSION) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-gtk \
		--enable-libnotify \
		--enable-libappindicator && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TRANSMISSION)/* && \
	make P=$(TRANSMISSION) log-package

$(GXINE):  $(XINE-LIB)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GXINE).tar.bz2 && \
	chmod 755 $(GXINE) && \
	chown -R 0:0 $(GXINE) && \
	cd $(GXINE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GXINE)/* && \
	make P=$(GXINE) log-package

$(DUPEGURU):  $(PYTHON3) $(JOBPROGRESS) $(HSAUDIOTAG) $(PYTEST) $(SPHINX) \
	$(SEND2TRASH) $(PYQT) $(DISTRIBUTE)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DUPEGURU).tar.bz2 && \
	chmod 755 $(DUPEGURU) && \
	chown -R 0:0 $(DUPEGURU) && \
	cd $(DUPEGURU) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(DUPEGURU)-no-demo.patch && \
	\
	python3 configure.py && \
	python3 build.py && \
	\
	cd .. && \
	cp -a $(DUPEGURU) /opt && \
	\
	echo "#!/bin/sh" > /usr/bin/dupeguru && \
	echo ""  >> /usr/bin/dupeguru && \
	echo "mkdir -p /tmp/.local" >> /usr/bin/dupeguru && \
	echo "ln -sfn /tmp/.local /root/.local" >> /usr/bin/dupeguru && \
	echo ""  >> /usr/bin/dupeguru && \
	echo "cd /opt/$(DUPEGURU)" >> /usr/bin/dupeguru && \
	echo "python3 run.py" >> /usr/bin/dupeguru && \
	\
	chmod 755 /usr/bin/dupeguru && \
	\
	rm -rf $(DUPEGURU)/* $(DUPEGURU)/.hg && \
	make P=$(DUPEGURU) log-package

$(PHPMYADMIN):  $(PHP5) $(MYSQL) $(MCRYPT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PHPMYADMIN).tar.bz2 && \
	chmod 755 $(PHPMYADMIN) && \
	chown -R 0:0 $(PHPMYADMIN) && \
	cd $(PHPMYADMIN) && \
	\
	mkdir -p /srv/www/htdocs/phpmyadmin/config && \
	cp -av * /srv/www/htdocs/phpmyadmin && \
	chown -R apache /srv/www/htdocs/phpmyadmin && \
	\
	cd .. && \
	rm -rf $(PHPMYADMIN)/* && \
	make P=$(PHPMYADMIN) log-package

$(AVIDEMUX):  $(CMAKE) $(YASM) $(MPLAYER)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AVIDEMUX).tar.gz && \
	chmod 755 $(AVIDEMUX) && \
	chown -R 0:0 $(AVIDEMUX) && \
	cd $(AVIDEMUX) && \
	\
	perl -p -i -e 's/sudo //' bootStrap.sh && \
	sh ./bootStrap.sh && \
	\
	cd .. && \
	rm -rf $(AVIDEMUX)/* && \
	make P=$(AVIDEMUX) log-package

$(GRAPHVIZ):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GRAPHVIZ).tar.gz && \
	chmod 755 $(GRAPHVIZ) && \
	chown -R 0:0 $(GRAPHVIZ) && \
	cd $(GRAPHVIZ) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(GRAPHVIZ)-no-qt.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-python=yes && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GRAPHVIZ)/* && \
	make P=$(GRAPHVIZ) log-package

$(HANDBRAKE):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(HANDBRAKE).tar.bz2 && \
	chmod 755 $(HANDBRAKE) && \
	chown -R 0:0 $(HANDBRAKE) && \
	cd $(HANDBRAKE) && \
	\
	./configure --prefix=/usr && \
	cd ./build && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HANDBRAKE)/* && \
	make P=$(HANDBRAKE) log-package

$(QDVDAUTHOR):  $(DVDAUTHOR)
	set +h && \
	\
	tar zxf $(JLFS-TARBALLS)/$(QDVDAUTHOR).tar.gz && \
	chmod 755 $(QDVDAUTHOR) && \
	chown -R 0:0 $(QDVDAUTHOR) && \
	cd $(QDVDAUTHOR) && \
	\
	./configure --prefix=/usr \
		--build-qslideshow \
		--no-configurator \
		--qt4-dir=/opt/qt && \
	make -j2 && \
	make install && \
	\
	tar jxf $(JLFS-TARBALLS)/$(QDVDAUTHOR)-masks.tar.bz2 \
		-C /usr/share/qdvdauthor && \
	tar jxf $(JLFS-TARBALLS)/$(QDVDAUTHOR)-buttons.tar.bz2 \
		-C /usr/share/qdvdauthor && \
	tar jxf $(JLFS-TARBALLS)/$(QDVDAUTHOR)-alpha_trans.tar.bz2 \
		-C /usr/share/qdvdauthor && \
	\
	cd .. && \
	rm -rf $(QDVDAUTHOR)/* && \
	make P=$(QDVDAUTHOR) log-package

$(GTKPOD):  $(LIBGPOD)
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(GTKPOD).tar.gz && \
	chmod 755 $(GTKPOD) && \
	chown -R 0:0 $(GTKPOD) && \
	cd $(GTKPOD) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKPOD)/* && \
	make P=$(GTKPOD) log-package

$(CELESTIA):  $(GTKGLEXT)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CELESTIA).tar.gz && \
	chmod 755 $(CELESTIA) && \
	chown -R 0:0 $(CELESTIA) && \
	cd $(CELESTIA) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-cairo \
		--with-gtk && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CELESTIA)/* && \
	make P=$(CELESTIA) log-package

$(BALSA):  $(GMIME-OLD) $(ASPELL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(BALSA).tar.bz2 && \
	chmod 755 $(BALSA) && \
	chown -R 0:0 $(BALSA) && \
	cd $(BALSA) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(BALSA)-no-notify-NULL.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-scrollkeeper && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BALSA)/* && \
	make P=$(BALSA) log-package

#
# End JLFS Custom-GUI
# Begin JLFS Custom-Lib
#

$(NEWT):  $(SLANG) $(POPT) $(TCL) $(PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NEWT).tar.gz && \
	chmod 755 $(NEWT) && \
	chown -R 0:0 $(NEWT) && \
	cd $(NEWT) && \
	\
	./configure --prefix=/usr \
		--without-tcl && \
        make -j2 && \
        make install && \
	\
	cd .. && \
	rm -rf $(NEWT)/.depend $(NEWT)/.cvsignore $(NEWT)/* && \
	make P=$(NEWT) log-package

$(TMAKE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TMAKE).tar.gz && \
	chmod 755 $(TMAKE) && \
	chown -R 0:0 $(TMAKE) && \
	cd $(TMAKE) && \
	\
	mkdir -p /usr/lib/tmake && \
        cp -r lib/linux-g++ /usr/lib/tmake && \
        cp -r lib/unix /usr/lib/tmake && \
        cp -a bin/* /usr/bin && \
	\
	cd .. && \
	rm -rf $(TMAKE)/* && \
	make P=$(TMAKE) log-package

$(LIBGPOD):  $(LIBPLIST)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGPOD).tar.bz2 && \
	chmod 755 $(LIBGPOD) && \
	chown -R 0:0 $(LIBGPOD) && \
	cd $(LIBGPOD) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGPOD)/* && \
	make P=$(LIBGPOD) log-package

$(GTK2-PERL): $(GLIB-PERL) $(EXTUTILS-DEPENDS) $(EXTUTILS-PKGCONFIG) $(CAIRO-PERL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GTK2-PERL).tar.gz && \
	chmod 755 $(GTK2-PERL) && \
	chown -R 0:0 $(GTK2-PERL) && \
	cd $(GTK2-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTK2-PERL)/* && \
	make P=$(GTK2-PERL) log-package

$(GTK2-GLADEXML):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GTK2-GLADEXML).tar.gz && \
	chmod 755 $(GTK2-GLADEXML) && \
	chown -R 0:0 $(GTK2-GLADEXML) && \
	cd $(GTK2-GLADEXML) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTK2-GLADEXML)/* && \
	make P=$(GTK2-GLADEXML) log-package

$(GETTEXT-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GETTEXT-PERL).tar.gz && \
	chmod 755 $(GETTEXT-PERL) && \
	chown -R 0:0 $(GETTEXT-PERL) && \
	cd $(GETTEXT-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GETTEXT-PERL)/* && \
	make P=$(GETTEXT-PERL) log-package

$(GLIB-PERL):  $(EXTUTILS-DEPENDS) $(EXTUTILS-PKGCONFIG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GLIB-PERL).tar.gz && \
	chmod 755 $(GLIB-PERL) && \
	chown -R 0:0 $(GLIB-PERL) && \
	cd $(GLIB-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GLIB-PERL)/* && \
	make P=$(GLIB-PERL) log-package

$(EXTUTILS-DEPENDS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(EXTUTILS-DEPENDS).tar.gz && \
	chmod 755 $(EXTUTILS-DEPENDS) && \
	chown -R 0:0 $(EXTUTILS-DEPENDS) && \
	cd $(EXTUTILS-DEPENDS) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(EXTUTILS-DEPENDS)/* && \
	make P=$(EXTUTILS-DEPENDS) log-package

$(EXTUTILS-PKGCONFIG):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(EXTUTILS-PKGCONFIG).tar.gz && \
	chmod 755 $(EXTUTILS-PKGCONFIG) && \
	chown -R 0:0 $(EXTUTILS-PKGCONFIG) && \
	cd $(EXTUTILS-PKGCONFIG) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(EXTUTILS-PKGCONFIG)/* && \
	make P=$(EXTUTILS-PKGCONFIG) log-package

$(CAIRO-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CAIRO-PERL).tar.gz && \
	chmod 755 $(CAIRO-PERL) && \
	chown -R 0:0 $(CAIRO-PERL) && \
	cd $(CAIRO-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CAIRO-PERL)/* && \
	make P=$(CAIRO-PERL) log-package

$(EVENT-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(EVENT-PERL).tar.gz && \
	chmod 755 $(EVENT-PERL) && \
	chown -R 0:0 $(EVENT-PERL) && \
	cd $(EVENT-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(EVENT-PERL)/* && \
	make P=$(EVENT-PERL) log-package

$(LIBINTL-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBINTL-PERL).tar.gz && \
	chmod 755 $(LIBINTL-PERL) && \
	chown -R 0:0 $(LIBINTL-PERL) && \
	cd $(LIBINTL-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBINTL-PERL)/* && \
	make P=$(LIBINTL-PERL) log-package

$(WXWIDGETS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(WXWIDGETS).tar.bz2 && \
	chmod 755 $(WXWIDGETS) && \
	chown -R 0:0 $(WXWIDGETS) && \
	cd $(WXWIDGETS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(WXWIDGETS)-gsocket.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-unicode \
		--enable-shared \
		--with-gtk=2 \
		--with-gnomeprint \
		--with-gnomevfs \
		--with-sdl && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(WXWIDGETS)/.pch $(WXWIDGETS)/.deps $(WXWIDGETS)/* && \
	make P=$(WXWIDGETS) log-package

$(MUTAGEN):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MUTAGEN).tar.gz && \
	chmod 755 $(MUTAGEN) && \
	chown -R 0:0 $(MUTAGEN) && \
	cd $(MUTAGEN) && \
	\
	./setup.py build && \
	./setup.py install && \
	\
	cd .. && \
	rm -rf $(MUTAGEN)/* && \
	make P=$(MUTAGEN) log-package

$(GST-PYTHON):  $(GST-PLUGINS-BASE)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GST-PYTHON).tar.bz2 && \
	chmod 755 $(GST-PYTHON) && \
	chown -R 0:0 $(GST-PYTHON) && \
	cd $(GST-PYTHON) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GST-PYTHON)/.deps $(GST-PYTHON)/* && \
	make P=$(GST-PYTHON) log-package

$(LIBID3TAG):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBID3TAG).tar.gz && \
	chmod 755 $(LIBID3TAG) && \
	chown -R 0:0 $(LIBID3TAG) && \
	cd $(LIBID3TAG) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBID3TAG)/.libs $(LIBID3TAG)/.deps $(LIBID3TAG)/* && \
	make P=$(LIBID3TAG) log-package

$(LIBGTOP):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGTOP).tar.bz2 && \
	chmod 755 $(LIBGTOP) && \
	chown -R 0:0 $(LIBGTOP) && \
	cd $(LIBGTOP) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGTOP)/* && \
	make P=$(LIBGTOP) log-package

$(NEON):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NEON).tar.gz && \
	chmod 755 $(NEON) && \
	chown -R 0:0 $(NEON) && \
	cd $(NEON) && \
	\
	./configure --prefix=/usr \
		--enable-shared --with-ssl && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(NEON)/.version $(NEON)/.release.sh $(NEON)/.packages $(NEON)/* && \
	make P=$(NEON) log-package

$(IO-STRINGY-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IO-STRINGY-PERL).tar.gz && \
	chmod 755 $(IO-STRINGY-PERL) && \
	chown -R 0:0 $(IO-STRINGY-PERL) && \
	cd $(IO-STRINGY-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IO-STRINGY-PERL)/* && \
	make P=$(IO-STRINGY-PERL) log-package

$(MIME-BASE64-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MIME-BASE64-PERL).tar.gz && \
	chmod 755 $(MIME-BASE64-PERL) && \
	chown -R 0:0 $(MIME-BASE64-PERL) && \
	cd $(MIME-BASE64-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MIME-BASE64-PERL)/* && \
	make P=$(MIME-BASE64-PERL) log-package

$(MIME-TOOLS-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MIME-TOOLS-PERL).tar.gz && \
	chmod 755 $(MIME-TOOLS-PERL) && \
	chown -R 0:0 $(MIME-TOOLS-PERL) && \
	cd $(MIME-TOOLS-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MIME-TOOLS-PERL)/* && \
	make P=$(MIME-TOOLS-PERL) log-package

$(MAILTOOLS-PERL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MAILTOOLS-PERL).tar.gz && \
	chmod 755 $(MAILTOOLS-PERL) && \
	chown -R 0:0 $(MAILTOOLS-PERL) && \
	cd $(MAILTOOLS-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MAILTOOLS-PERL)/* && \
	make P=$(MAILTOOLS-PERL) log-package

$(LIBNET):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBNET).tar.gz && \
	chmod 755 $(LIBNET) && \
	chown -R 0:0 $(LIBNET) && \
	cd $(LIBNET) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBNET)/* && \
	make P=$(LIBNET) log-package

$(LIBFWBUILDER):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBFWBUILDER).tar.gz && \
	chmod 755 $(LIBFWBUILDER) && \
	chown -R 0:0 $(LIBFWBUILDER) && \
	cd $(LIBFWBUILDER) && \
	\
	QMAKE=/opt/qt/bin/qmake ./autogen.sh \
		--prefix=/usr \
		--with-qtdir=/opt/qt && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBFWBUILDER)/* && \
	make P=$(LIBFWBUILDER) log-package

$(SYSTEM-TOOLS-BACKENDS):  $(XML-PARSER) $(DBUS-GLIB) $(POLKIT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SYSTEM-TOOLS-BACKENDS).tar.bz2 && \
	chmod 755 $(SYSTEM-TOOLS-BACKENDS) && \
	chown -R 0:0 $(SYSTEM-TOOLS-BACKENDS) && \
	cd $(SYSTEM-TOOLS-BACKENDS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SYSTEM-TOOLS-BACKENDS)/* && \
	make P=$(SYSTEM-TOOLS-BACKENDS) log-package

$(LIBOOBS):  $(SYSTEM-TOOLS-BACKENDS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBOOBS).tar.bz2 && \
	chmod 755 $(LIBOOBS) && \
	chown -R 0:0 $(LIBOOBS) && \
	cd $(LIBOOBS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBOOBS)/* && \
	make P=$(LIBOOBS) log-package

$(GNOME-SYSTEM-TOOLS):  $(LIBOOBS) $(NAUTILUS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-SYSTEM-TOOLS).tar.bz2 && \
	chmod 755 $(GNOME-SYSTEM-TOOLS) && \
	chown -R 0:0 $(GNOME-SYSTEM-TOOLS) && \
	cd $(GNOME-SYSTEM-TOOLS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--with-help-formats=man \
		--disable-scrollkeeper --disable-nautilus \
		--disable-polkit-gtk \
		--enable-schemas-install && \
	\
	make -j2 && \
	\
	for i in nl; do \
		( cd doc/services/$${i} && \
			ln -sfn services-admin-$${i}.omf \
				services-admin-$${i}.omf.out ); \
		( cd doc/time/$${i} && \
			ln -sfn time-admin-$${i}.omf \
				time-admin-$${i}.omf.out ); \
	done; \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-SYSTEM-TOOLS)/* && \
	make P=$(GNOME-SYSTEM-TOOLS) log-package

$(DIETLIBC):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DIETLIBC).tar.bz2 && \
	chmod 755 $(DIETLIBC) && \
	chown -R 0:0 $(DIETLIBC) && \
	cd $(DIETLIBC) && \
	\
	echo perl -p -i -e 's/opt\/diet/usr\/diet/' libdl/Makefile \
		contrib/Makefile.dyn Makefile && \
	\
	make -j2 && \
	make install && \
	\
	cp -v diet.1 /usr/share/man/man1 && \
	install bin-i386/dietlibc.a /usr/lib && \
	install bin-i386/diet /usr/bin && \
	\
	cd .. && \
	rm -rf $(DIETLIBC)/* && \
	make P=$(DIETLIBC) log-package

$(GDK-PIXBUF1):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GDK-PIXBUF1).tar.bz2 && \
	chmod 755 $(GDK-PIXBUF1) && \
	chown -R 0:0 $(GDK-PIXBUF1) && \
	cd $(GDK-PIXBUF1) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-gtk-doc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GDK-PIXBUF1)/* && \
	make P=$(GDK-PIXBUF1) log-package

$(GDK-PIXBUF):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GDK-PIXBUF).tar.bz2 && \
	chmod 755 $(GDK-PIXBUF) && \
	chown -R 0:0 $(GDK-PIXBUF) && \
	cd $(GDK-PIXBUF) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-gtk-doc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GDK-PIXBUF)/* && \
	make P=$(GDK-PIXBUF) log-package

$(LIBCDDB):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBCDDB).tar.bz2 && \
	chmod 755 $(LIBCDDB) && \
	chown -R 0:0 $(LIBCDDB) && \
	cd $(LIBCDDB) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBCDDB)/* && \
	make P=$(LIBCDDB) log-package

$(LIBUNGIF):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBUNGIF).tar.gz && \
	chmod 755 $(LIBUNGIF) && \
	chown -R 0:0 $(LIBUNGIF) && \
	cd $(LIBUNGIF) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBUNGIF)-va_start.patch && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBUNGIF)/* && \
	make P=$(LIBUNGIF) log-package

$(PYSQLITE2):  $(SQLITE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYSQLITE2).tar.gz && \
	chmod 755 $(PYSQLITE2) && \
	chown -R 0:0 $(PYSQLITE2) && \
	cd $(PYSQLITE2) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	rm -rf /usr/pysqlite2-doc && \
	\
	cd .. && \
	rm -rf $(PYSQLITE2)/* && \
	make P=$(PYSQLITE2) log-package

$(LIBGPHOTO2):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGPHOTO2).tar.bz2 && \
	chmod 755 $(LIBGPHOTO2) && \
	chown -R 0:0 $(LIBGPHOTO2) && \
	cd $(LIBGPHOTO2) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGPHOTO2)/* && \
	make P=$(LIBGPHOTO2) log-package

$(LIBEXIF-GTK):  $(EXIF)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBEXIF-GTK).orig.tar.gz && \
	chmod 755 $(LIBEXIF-GTK) && \
	chown -R 0:0 $(LIBEXIF-GTK) && \
	cd $(LIBEXIF-GTK) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBEXIF-GTK)-wrong-args.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBEXIF-GTK)-3.diff && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBEXIF-GTK)/* && \
	make P=$(LIBEXIF-GTK) log-package

$(SDL-IMAGE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SDL-IMAGE).tar.gz && \
	chmod 755 $(SDL-IMAGE) && \
	chown -R 0:0 $(SDL-IMAGE) && \
	cd $(SDL-IMAGE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SDL-IMAGE)/* $(SDL-IMAGE)/.libs $(SDL-IMAGE)/.deps && \
	make P=$(SDL-IMAGE) log-package

$(LIBDVDNAV):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBDVDNAV).tar.gz && \
	chmod 755 $(LIBDVDNAV) && \
	chown -R 0:0 $(LIBDVDNAV) && \
	cd $(LIBDVDNAV) && \
	\
	./autogen.sh && \
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-static && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBDVDNAV)/* && \
	make P=$(LIBDVDNAV) log-package

$(LIBCDIO):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBCDIO).tar.gz && \
	chmod 755 $(LIBCDIO) && \
	chown -R 0:0 $(LIBCDIO) && \
	cd $(LIBCDIO) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBCDIO)/* && \
	make P=$(LIBCDIO) log-package

$(LIBDVBPSI):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBDVBPSI).tar.bz2 && \
	chmod 755 $(LIBDVBPSI) && \
	chown -R 0:0 $(LIBDVBPSI) && \
	cd $(LIBDVBPSI) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBDVBPSI)/* && \
	make P=$(LIBDVBPSI) log-package

$(VCDIMAGER):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(VCDIMAGER).tar.gz && \
	chmod 755 $(VCDIMAGER) && \
	chown -R 0:0 $(VCDIMAGER) && \
	cd $(VCDIMAGER) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(VCDIMAGER)/* && \
	make P=$(VCDIMAGER) log-package

$(TAGLIB):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TAGLIB).tar.gz && \
	chmod 755 $(TAGLIB) && \
	chown -R 0:0 $(TAGLIB) && \
	cd $(TAGLIB) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-static && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TAGLIB)/* && \
	make P=$(TAGLIB) log-package

$(LIBDAEMON):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBDAEMON).tar.gz && \
	chmod 755 $(LIBDAEMON) && \
	chown -R 0:0 $(LIBDAEMON) && \
	cd $(LIBDAEMON) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBDAEMON)/* && \
	make P=$(LIBDAEMON) log-package

$(AVAHI):  $(LIBDAEMON) $(QT4)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AVAHI).tar.gz && \
	chmod 755 $(AVAHI) && \
	chown -R 0:0 $(AVAHI) && \
	cd $(AVAHI) && \
	\
	groupadd -g 20 avahi; \
	useradd -c "Avahi user" -d /dev/null \
		-u 20 -g avahi -s /bin/false avahi; \
	groupadd -g 21 avahi-autoipd; \
	useradd -c "Avahi AutoIP Daemon User" -d /dev/null \
		-u 21 -g avahi-autoipd -s /bin/false avahi-autoipd; \
	groupadd -g 22 netdev; \
	\
	PKG_CONFIG_PATH=/opt/qt/lib/pkgconfig ./configure \
		--prefix=/usr --sysconfdir=/etc \
		--localstatedir=/var \
		--disable-doxygen-doc \
		--disable-gdbm \
		--disable-mono \
		--disable-monodoc \
		--with-distro=fedora && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AVAHI)/* && \
	make P=$(AVAHI) log-package

$(LIBMCS):  $(GCONF) $(LIBMOWGLI)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMCS).tgz && \
	chmod 755 $(LIBMCS) && \
	chown -R 0:0 $(LIBMCS) && \
	cd $(LIBMCS) && \
	\
	sed -i 's|libmcs|../../&|' src/backends/kconfig/kconfig.cc && \
	\
	./configure --prefix=/usr --enable-gconf --disable-kconfig && \
	make -j2 && \
	make install && \
	install -v -m644 -D README /usr/share/doc/$(LIBMCS)/README && \
	\
	cd .. && \
	rm -rf $(LIBMCS)/* && \
	make P=$(LIBMCS) log-package

$(LIBMOWGLI):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMOWGLI).tar.bz2 && \
	chmod 755 $(LIBMOWGLI) && \
	chown -R 0:0 $(LIBMOWGLI) && \
	cd $(LIBMOWGLI) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBMOWGLI)/* && \
	make P=$(LIBMOWGLI) log-package

$(DIVX4LINUX):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DIVX4LINUX).tgz && \
	chmod 755 $(DIVX4LINUX) && \
	chown -R 0:0 $(DIVX4LINUX) && \
	cd $(DIVX4LINUX) && \
	\
	cp -av *h /usr/include && \
	cp -av *so /usr/lib && \
	ldconfig && \
	\
	cd .. && \
	rm -rf $(DIVX4LINUX)/* && \
	make P=$(DIVX4LINUX) log-package

$(GTKMM):  $(GLIBMM) $(CAIROMM) $(PANGOMM) $(ATKMM)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTKMM).tar.bz2 && \
	chmod 755 $(GTKMM) && \
	chown -R 0:0 $(GTKMM) && \
	cd $(GTKMM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKMM)/* && \
	make P=$(GTKMM) log-package

$(GTKMM2):  $(GTKMM)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTKMM2).tar.bz2 && \
	chmod 755 $(GTKMM2) && \
	chown -R 0:0 $(GTKMM2) && \
	cd $(GTKMM2) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(GTKMM2)-no-glib.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKMM2)/* && \
	make P=$(GTKMM2) log-package

$(GLIBMM):  $(LIBSIGC)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GLIBMM).tar.bz2 && \
	chmod 755 $(GLIBMM) && \
	chown -R 0:0 $(GLIBMM) && \
	cd $(GLIBMM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GLIBMM)/* && \
	make P=$(GLIBMM) log-package

$(LIBSIGC):
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(LIBSIGC).tar.xz| tar xvf - && \
	chmod 755 $(LIBSIGC) && \
	chown -R 0:0 $(LIBSIGC) && \
	cd $(LIBSIGC) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBSIGC)/* && \
	make P=$(LIBSIGC) log-package

$(CAIROMM):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CAIROMM).tar.gz && \
	chmod 755 $(CAIROMM) && \
	chown -R 0:0 $(CAIROMM) && \
	cd $(CAIROMM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CAIROMM)/* && \
	make P=$(CAIROMM) log-package

$(LIBDVBCSA):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBDVBCSA).tar.bz2 && \
	chmod 755 $(LIBDVBCSA) && \
	chown -R 0:0 $(LIBDVBCSA) && \
	cd $(LIBDVBCSA) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBDVBCSA)/* && \
	make P=$(LIBDVBCSA) log-package

$(LIBSAMPLERATE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBSAMPLERATE).tar.gz && \
	chmod 755 $(LIBSAMPLERATE) && \
	chown -R 0:0 $(LIBSAMPLERATE) && \
	cd $(LIBSAMPLERATE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBSAMPLERATE)/* && \
	make P=$(LIBSAMPLERATE) log-package

$(BLUEZ):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BLUEZ).tar.bz2 && \
	chmod 755 $(BLUEZ) && \
	chown -R 0:0 $(BLUEZ) && \
	cd $(BLUEZ) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BLUEZ)/* && \
	make P=$(BLUEZ) log-package

$(LIBNOTIFY):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBNOTIFY).tar.bz2 && \
	chmod 755 $(LIBNOTIFY) && \
	chown -R 0:0 $(LIBNOTIFY) && \
	cd $(LIBNOTIFY) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBNOTIFY)/* && \
	make P=$(LIBNOTIFY) log-package

$(BABL):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(BABL).tar.bz2 && \
	chmod 755 $(BABL) && \
	chown -R 0:0 $(BABL) && \
	cd $(BABL) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BABL)/* && \
	make P=$(BABL) log-package

$(GEGL):  $(BABL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GEGL).tar.bz2 && \
	chmod 755 $(GEGL) && \
	chown -R 0:0 $(GEGL) && \
	cd $(GEGL) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-docs && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GEGL)/* && \
	make P=$(GEGL) log-package

$(MLTFRAMEWORK):  $(SWIG) $(FREI0R-PLUGINS) $(SOX)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MLTFRAMEWORK).tar.gz && \
	chmod 755 $(MLTFRAMEWORK) && \
	chown -R 0:0 $(MLTFRAMEWORK) && \
	cd $(MLTFRAMEWORK) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--aviformat-swscale \
		--swig-languages=python \
		--disable-xine \
		--enable-gpl && \
	make -j2 && \
	make install && \
	\
	cp -av src/swig/python/mlt.py \
		src/swig/python/_mlt.so \
		src/swig/python/mlt_wrap.o \
	/usr/lib/$(PYTHON-VER)/site-packages && \
	\
	ln -sfn /usr/lib/libmlt++.so.$(MLT-VER) /usr/lib/libmlt++.so.2 && \
	\
	cd .. && \
	rm -rf $(MLTFRAMEWORK)/* && \
	make P=$(MLTFRAMEWORK) log-package

$(GOOCANVAS):
	set +h && \
	\
	tar jvxf $(JLFS-TARBALLS)/$(GOOCANVAS).tar.bz2 && \
	chmod 755 $(GOOCANVAS) && \
	chown -R 0:0 $(GOOCANVAS) && \
	cd $(GOOCANVAS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GOOCANVAS)/* $(GOOCANVAS)/.libs $(GOOCANVAS)/.deps && \
	make P=$(GOOCANVAS) log-package


$(SWIG):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SWIG).tar.gz && \
	chmod 755 $(SWIG) && \
	chown -R 0:0 $(SWIG) && \
	cd $(SWIG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SWIG)/* && \
	make P=$(SWIG) log-package

$(FREI0R-PLUGINS):  $(SWIG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FREI0R-PLUGINS).tar.gz && \
	chmod 755 $(FREI0R-PLUGINS) && \
	chown -R 0:0 $(FREI0R-PLUGINS) && \
	cd $(FREI0R-PLUGINS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FREI0R-PLUGINS)/* && \
	make P=$(FREI0R-PLUGINS) log-package

$(LIBAIO):
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(LIBAIO).orig.tar.gz && \
	chmod 755 $(LIBAIO) && \
	chown -R 0:0 $(LIBAIO) && \
	cd $(LIBAIO) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBAIO)-7.diff && \
	\
	make -j2 && \
	make prefix=/usr install && \
	\
	cd .. && \
	rm -rf $(LIBAIO)/* && \
	make P=$(LIBAIO) log-package

$(LIBEVENT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBEVENT).tar.gz && \
	chmod 755 $(LIBEVENT) && \
	chown -R 0:0 $(LIBEVENT) && \
	cd $(LIBEVENT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBEVENT)/* $(LIBEVENT)/.deps $(LIBEVENT)/.libs && \
	make P=$(LIBEVENT) log-package

$(JOBPROGRESS):  $(SETUPUTILS) $(SPHINX) $(PYTHON3)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(JOBPROGRESS).tar.bz2 && \
	chmod 755 $(JOBPROGRESS) && \
	chown -R 0:0 $(JOBPROGRESS) && \
	cd $(JOBPROGRESS) && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(JOBPROGRESS)/* && \
	make P=$(JOBPROGRESS) log-package

$(HSAUDIOTAG):  $(PYTHON3)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(HSAUDIOTAG).tar.bz2 && \
	chmod 755 $(HSAUDIOTAG) && \
	chown -R 0:0 $(HSAUDIOTAG) && \
	cd $(HSAUDIOTAG) && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(HSAUDIOTAG)/* $(HSAUDIOTAG)/.hg* && \
	make P=$(HSAUDIOTAG) log-package

$(SIP):  $(PYTHON3)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SIP).tar.gz && \
	chmod 755 $(SIP) && \
	chown -R 0:0 $(SIP) && \
	cd $(SIP) && \
	\
	python3 configure.py && \
	python3 sipconfig.py && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SIP)/* && \
	make P=$(SIP) log-package

$(PY):  $(PYTHON3)
	set +h && \
	\
	unzip $(JLFS-TARBALLS)/$(PY).zip && \
	chmod 755 $(PY) && \
	chown -R 0:0 $(PY) && \
	cd $(PY) && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(PY)/* && \
	make P=$(PY) log-package

$(PYTEST):  $(PY) $(PYTHON3)
	set +h && \
	\
	unzip $(JLFS-TARBALLS)/$(PYTEST).zip && \
	chmod 755 $(PYTEST) && \
	chown -R 0:0 $(PYTEST) && \
	cd $(PYTEST) && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(PYTEST)/* && \
	make P=$(PYTEST) log-package

$(SEND2TRASH):  $(PYTHON3)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SEND2TRASH).tar.bz2 && \
	chmod 755 $(SEND2TRASH) && \
	chown -R 0:0 $(SEND2TRASH) && \
	cd $(SEND2TRASH) && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(SEND2TRASH)/* && \
	make P=$(SEND2TRASH) log-package

$(SPHINX):  $(SETUPTOOLS) $(GNOME-DOC-UTILS) $(JINJA2) $(PYGMENTS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SPHINX).tar.gz && \
	chmod 755 $(SPHINX) && \
	chown -R 0:0 $(SPHINX) && \
	cd $(SPHINX) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(SPHINX)/* && \
	make P=$(SPHINX) log-package

$(PYQT):  $(PYTHON3) $(SIP)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYQT).tar.gz && \
	chmod 755 $(PYQT) && \
	chown -R 0:0 $(PYQT) && \
	cd $(PYQT) && \
	\
	perl -p -i -e 's/^    check_license()/    #check_license()/' \
		configure.py && \
	\
	python3 configure.py --qmake /opt/qt/bin/qmake && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYQT)/* && \
	make P=$(PYQT) log-package

$(SETUPTOOLS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SETUPTOOLS).tar.gz && \
	chmod 755 $(SETUPTOOLS) && \
	chown -R 0:0 $(SETUPTOOLS) && \
	cd $(SETUPTOOLS) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(SETUPTOOLS)/* && \
	make P=$(SETUPTOOLS) log-package

$(GNOME-DOC-UTILS):  $(INTLTOOL) $(LIBXSLT) $(PYTHON2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-DOC-UTILS).tar.bz2 && \
	chmod 755 $(GNOME-DOC-UTILS) && \
	chown -R 0:0 $(GNOME-DOC-UTILS) && \
	cd $(GNOME-DOC-UTILS) && \
	\
	./configure --prefix /usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-DOC-UTILS)/* && \
	make P=$(GNOME-DOC-UTILS) log-package

$(JINJA2):  $(PYTHON3) $(SETUPTOOLS) $(DISTRIBUTE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(JINJA2).tar.gz && \
	chmod 755 $(JINJA2) && \
	chown -R 0:0 $(JINJA2) && \
	cd $(JINJA2) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(JINJA2)/* && \
	make P=$(JINJA2) log-package

$(PYGMENTS):  $(PYTHON3)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYGMENTS).tar.gz && \
	chmod 755 $(PYGMENTS) && \
	chown -R 0:0 $(PYGMENTS) && \
	cd $(PYGMENTS) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	python3 setup.py build && \
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(PYGMENTS)/* && \
	make P=$(PYGMENTS) log-package

$(DISTRIBUTE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DISTRIBUTE).tar.gz && \
	chmod 755 $(DISTRIBUTE) && \
	chown -R 0:0 $(DISTRIBUTE) && \
	cd $(DISTRIBUTE) && \
	\
	python3 setup.py install && \
	\
	cd .. && \
	rm -rf $(DISTRIBUTE)/* && \
	make P=$(DISTRIBUTE) log-package

$(LIBMCRYPT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMCRYPT).tar.gz && \
	chmod 755 $(LIBMCRYPT) && \
	chown -R 0:0 $(LIBMCRYPT) && \
	cd $(LIBMCRYPT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBMCRYPT)/* && \
	make P=$(LIBMCRYPT) log-package

$(LIBMHASH):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBMHASH).tar.bz2 && \
	chmod 755 $(LIBMHASH) && \
	chown -R 0:0 $(LIBMHASH) && \
	cd $(LIBMHASH) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBMHASH)/* && \
	make P=$(LIBMHASH) log-package

$(DBI):  $(DATA-SHOWTABLE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DBI).tar.gz && \
	chmod 755 $(DBI) && \
	chown -R 0:0 $(DBI) && \
	cd $(DBI) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DBI)/* && \
	make P=$(DBI) log-package

$(DBD-MYSQL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DBD-MYSQL).tar.gz && \
	chmod 755 $(DBD-MYSQL) && \
	chown -R 0:0 $(DBD-MYSQL) && \
	cd $(DBD-MYSQL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DBD-MYSQL)/* && \
	make P=$(DBD-MYSQL) log-package

$(DATE-SHOWTABLE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DATE-SHOWTABLE).tar.gz && \
	chmod 755 $(DATE-SHOWTABLE) && \
	chown -R 0:0 $(DATE-SHOWTABLE) && \
	cd $(DATE-SHOWTABLE) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DATE-SHOWTABLE)/* && \
	make P=$(DATE-SHOWTABLE) log-package

$(PIL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PIL).tar.gz && \
	chmod 755 $(PIL) && \
	chown -R 0:0 $(PIL) && \
	cd $(PIL) && \
	\
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(PIL)/* && \
	make P=$(PIL) log-package

$(PYGRAPHVIZ):  $(GRAPHVIZ)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYGRAPHVIZ).tar.gz && \
	chmod 755 $(PYGRAPHVIZ) && \
	chown -R 0:0 $(PYGRAPHVIZ) && \
	cd $(PYGRAPHVIZ) && \
	\
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(PYGRAPHVIZ)/* && \
	make P=$(PYGRAPHVIZ) log-package


$(PYXDG):
	set +h && \
	\
	tar  zxf $(JLFS-TARBALLS)/$(PYXDG).tar.gz && \
	chmod 755 $(PYXDG) && \
	chown -R 0:0 $(PYXDG) && \
	cd $(PYXDG) && \
	\
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(PYXDG)/* && \
	make P=$(PYXDG) log-package

$(PYGOOCANVAS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYGOOCANVAS).tar.bz2 && \
	chmod 755 $(PYGOOCANVAS) && \
	chown -R 0:0 $(PYGOOCANVAS) && \
	cd $(PYGOOCANVAS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-docs && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYGOOCANVAS)/* && \
	make P=$(PYGOOCANVAS) log-package

$(ILMBASE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ILMBASE).tar.gz && \
	chmod 755 $(ILMBASE) && \
	chown -R 0:0 $(ILMBASE) && \
	cd $(ILMBASE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ILMBASE)/* && \
	make P=$(ILMBASE) log-package

$(OPENEXR):  $(ILMBASE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(OPENEXR).tar.gz && \
	chmod 755 $(OPENEXR) && \
	chown -R 0:0 $(OPENEXR) && \
	cd $(OPENEXR) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(OPENEXR)-fixes.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(OPENEXR)/* && \
	make P=$(OPENEXR) log-package

$(LIBSNDFILE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBSNDFILE).tar.gz && \
	chmod 755 $(LIBSNDFILE) && \
	chown -R 0:0 $(LIBSNDFILE) && \
	cd $(LIBSNDFILE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBSNDFILE)/* && \
	make P=$(LIBSNDFILE) log-package

$(FFTW):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FFTW).tar.gz && \
	chmod 755 $(FFTW) && \
	chown -R 0:0 $(FFTW) && \
	cd $(FFTW) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FFTW)/* && \
	make P=$(FFTW) log-package

$(LIBPLIST):  $(CMAKE) $(SWIG) $(PYTHON)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBPLIST).tar.bz2 && \
	chmod 755 $(LIBPLIST) && \
	chown -R 0:0 $(LIBPLIST) && \
	cd $(LIBPLIST) && \
	\
	cmake . && \
	echo "FUCK cmake" && sleep 10 && \
	perl -p -i -e 's/usr\/local/usr/g' CMakeCache.txt && \
	perl -p -i -e 's/usr\/local/usr/g' CPackConfig.cmake && \
	perl -p -i -e 's/usr\/local/usr/g' CPackSourceConfig.cmake && \
	perl -p -i -e 's/usr\/local/usr/g' cmake_install.cmake && \
	perl -p -i -e 's/usr\/local/usr/g' libplist++.pc && \
	perl -p -i -e 's/usr\/local/usr/g' libplist.pc && \
	perl -p -i -e 's/usr\/local/usr/g' src/cmake_install.cmake && \
	perl -p -i -e 's/usr\/local/usr/g' plutil/cmake_install.cmake && \
	perl -p -i -e 's/usr\/local/usr/g' swig/cmake_install.cmake && \
	perl -p -i -e 's/usr\/local/usr/g' test/cmake_install.cmake && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBPLIST)/* && \
	make P=$(LIBPLIST) log-package

$(GTKGLEXT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GTKGLEXT).tar.gz && \
	chmod 755 $(GTKGLEXT) && \
	chown -R 0:0 $(GTKGLEXT) && \
	cd $(GTKGLEXT) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(GTKGLEXT)-gtk2.20-depreciated.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKGLEXT)/* && \
	make P=$(GTKGLEXT) log-package

$(FARSIGHT2):  $(LIBNICE) $(GST-PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FARSIGHT2).tar.gz && \
	chmod 755 $(FARSIGHT2) && \
	chown -R 0:0 $(FARSIGHT2) && \
	cd $(FARSIGHT2) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FARSIGHT2)/* && \
	make P=$(FARSIGHT2) log-package

$(LIBNICE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBNICE).tar.gz && \
	chmod 755 $(LIBNICE) && \
	chown -R 0:0 $(LIBNICE) && \
	cd $(LIBNICE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBNICE)/* && \
	make P=$(LIBNICE) log-package

$(ATKMM):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ATKMM).tar.bz2 && \
	chmod 755 $(ATKMM) && \
	chown -R 0:0 $(ATKMM) && \
	cd $(ATKMM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ATKMM)/* && \
	make P=$(ATKMM) log-package

$(LIBCANBERRA):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBCANBERRA).tar.gz && \
	chmod 755 $(LIBCANBERRA) && \
	chown -R 0:0 $(LIBCANBERRA) && \
	cd $(LIBCANBERRA) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBCANBERRA)/* && \
	make P=$(LIBCANBERRA) log-package

$(ASPELL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ASPELL).tar.gz && \
	chmod 755 $(ASPELL) && \
	chown -R 0:0 $(ASPELL) && \
	cd $(ASPELL) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ASPELL)/* && \
	make P=$(ASPELL) log-package

(ASPELL-DICT):  $(ASPELL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ASPELL-DICT).tar.bz2 && \
	chmod 755 $(ASPELL-DICT) && \
	chown -R 0:0 $(ASPELL-DICT) && \
	cd $(ASPELL-DICT) && \
	\
	./configure && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ASPELL-DICT)/* && \
	make P=$(ASPELL-DICT) log-package

$(LIBVPX):  $(YASM)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBVPX).tar.bz2 && \
	chmod 755 $(LIBVPX) && \
	chown -R 0:0 $(LIBVPX) && \
	cd $(LIBVPX) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBVPX)/* && \
	make P=$(LIBVPX) log-package

$(GST-FFMPEG):  $(FFMPEG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GST-FFMPEG).tar.gz && \
	chmod 755 $(GST-FFMPEG) && \
	chown -R 0:0 $(GST-FFMPEG) && \
	cd $(GST-FFMPEG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GST-FFMPEG)/* && \
	make P=$(GST-FFMPEG) log-package

$(LIBNL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBNL).tar.gz && \
	chmod 755 $(LIBNL) && \
	chown -R 0:0 $(LIBNL) && \
	cd $(LIBNL) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	ldconfig && \
	\
	cd .. && \
	rm -rf $(LIBNL)/* && \
	make P=$(LIBNL) log-package

$(BOTO):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(BOTO).tar.bz2 && \
	chmod 755 $(BOTO) && \
	chown -R 0:0 $(BOTO) && \
	cd $(BOTO) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	cd .. && \
	rm -rf $(BOTO)/* && \
	make P=$(BOTO) log-package

# End JLFS Custom-Lib
# Begin JLFS-Blackhat-Tools
#

$(AUTOPSY):  $(SLEUTHKIT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(AUTOPSY).tar.bz2 && \
	chmod 755 $(AUTOPSY) && \
	chown -R 0:0 $(AUTOPSY) && \
	cd $(AUTOPSY) && \
	\
	mkdir -p /usr/autopsy && \
	cp -Rv * /usr/autopsy && \
	ln -sfn /usr/autopsy/autopsy /usr/bin/autopsy && \
	\
	cd .. && \
	rm -rf $(AUTOPSY)/* && \
	make P=$(AUTOPSY) log-package

$(DDRESCUE):  $(GCC4-VER)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DDRESCUE).tar.gz && \
	chmod 755 $(DDRESCUE) && \
	chown -R 0:0 $(DDRESCUE) && \
	cd $(DDRESCUE) && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) ./configure --prefix=/usr && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(DDRESCUE)/* && \
	make P=$(DDRESCUE) log-package

$(DRIFTNET):  $(LIBUNGIF)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DRIFTNET).tar.gz && \
	chmod 755 $(DRIFTNET) && \
	chown -R 0:0 $(DRIFTNET) && \
	cd $(DRIFTNET) && \
	\
	PATH=/opt/$(GCC3)/bin:$(PATH) make -j2 && \
	cp -av driftnet /usr/bin && \
	\
	cd .. && \
	rm -rf $(DRIFTNET)/* && \
	make P=$(DRIFTNET) log-package

$(DSNIFF):  $(LIBPCAP) $(LIBNIDS) $(LIBNET) $(OPENSSL) $(BDB4)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DSNIFF).tar.gz && \
	chmod 755 $(DSNIFF) && \
	chown -R 0:0 $(DSNIFF) && \
	cd $(DSNIFF) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(DSNIFF).no-arpspoof.patch && \
	\
	./configure --prefix=/opt --sysconfdir=/etc && \
	\
	perl -p -i -e "s/lcrypto/lcrypto \-lpthread/" Makefile && \
	echo "#include <openssl/blowfish.h>" >> sshcrypto.h && \
	echo "#include <openssl/des.h>" >> sshcrypto.h && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DSNIFF)/* && \
	make P=$(DSNIFF) log-package

$(FOREMOST):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FOREMOST).tar.gz && \
	chmod 755 $(FOREMOST) && \
	chown -R 0:0 $(FOREMOST) && \
	cd $(FOREMOST) && \
	\
	perl -p -i -e 's/usr\/local/usr/;s/CDm/m/' Makefile && \
	make -j2 && \
	make install && \
	cp -v foremost.conf /etc && \
	\
	cd .. && \
	rm -rf $(FOREMOST)/* && \
	make P=$(FOREMOST) log-package

$(HYDRA):  $(LIBSSH) $(LIBSSH2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HYDRA)-src.tar.gz && \
	mv $(HYDRA)-src $(HYDRA) && \
	chmod 755 $(HYDRA) && \
	chown -R 0:0 $(HYDRA) && \
	cd $(HYDRA) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(HYDRA)-nosvn.patch && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HYDRA)/* && \
	make P=$(HYDRA) log-package

$(NESSUS-CORE):  $(NESSUS-LIBRARIES) $(LIBNASL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NESSUS-CORE).tar.gz && \
	mv nessus-core $(NESSUS-CORE) && \
	chmod 755 $(NESSUS-CORE) && \
	chown -R 0:0 $(NESSUS-CORE) && \
	cd $(NESSUS-CORE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--localstatedir=/var && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(NESSUS-CORE)/* && \
	make P=$(NESSUS-CORE) log-package

$(TCT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TCT).tar.gz && \
	chmod 755 $(TCT) && \
	chown -R 0:0 $(TCT) && \
	cd $(TCT) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(TCT)-fs-1.patch && \
	\
	make -j2 && \
	mkdir -p /usr/tct && cp -a * /usr/tct && \
	rm -rf /usr/tct/src && \
	cd /usr/tct/bin && ln -sfn ../lazarus/lazarus . && \
	cd /usr/src && \
	\
	rm -rf $(TCT)/* && \
	make P=$(TCT) log-package

$(TCTUTILS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TCTUTILS).tar.gz && \
	chmod 755 $(TCTUTILS) && \
	chown -R 0:0 $(TCTUTILS) && \
	cd $(TCTUTILS) && \
	\
	perl -p -i -e 's/^TCT_DIR = \/usr\/local\/tct/TCT_DIR = \/usr\/tct/' \
		src/Makefile && \
	\
	PATH=/opt/$(GCC3)/bin:$(PATH) make -j2 && \
	cp -av bin /usr/bin && \
	\
	cd .. && \
	rm -rf $(TCTUTILS)/* && \
	make P=$(TCTUTILS) log-package

$(SLEUTHKIT):  $(AFFLIB)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SLEUTHKIT).tar.gz && \
	chmod 755 $(SLEUTHKIT) && \
	chown -R 0:0 $(SLEUTHKIT) && \
	cd $(SLEUTHKIT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SLEUTHKIT)/* && \
	make P=$(SLEUTHKIT) log-package

$(AIRCRACK):  $(SQLITE) $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AIRCRACK).tar.gz && \
	chmod 755 $(AIRCRACK) && \
	chown -R 0:0 $(AIRCRACK) && \
	cd $(AIRCRACK) && \
	\
	perl -p -i -e 's/usr\/local/usr/g' common.mak && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make SQLITE=true && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(AIRCRACK)/* && \
	make P=$(AIRCRACK) log-package

$(WEPCRACK):  $(TERMREADKEY) $(NET-PCAP) $(LIBPCAP)
	set +h && \
	\
	mkdir $(WEPCRACK) && \
	tar xvf $(JLFS-TARBALLS)/$(WEPCRACK).tar.gz -C $(WEPCRACK) && \
	chmod 755 $(WEPCRACK) && \
	chown -R 0:0 $(WEPCRACK) && \
	cd $(WEPCRACK) && \
	\
	cp -av * /usr/sbin && \
	\
	cd .. && \
	rm -rf $(WEPCRACK)/* && \
	make P=$(WEPCRACK) log-package

#
# End JLFS-Blackhat-Tools
# Begin JLFS-Blackhat-Lib
#

#
# libnasl
# used to be required by a blackhat tool, forget which, keep around
# Tue Apr 15 14:48:09 CDT 2008
#
# by NESSUS-CORE
# Tue Apr 22 15:32:15 CDT 2008
#

$(LIBNASL):  $(NESSUS-LIBRARIES)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBNASL).tar.gz && \
	mv libnasl $(LIBNASL) && \
	chmod 755 $(LIBNASL) && \
	chown -R 0:0 $(LIBNASL) && \
	cd $(LIBNASL) && \
	\
	./configure --prefix=/usr --localstatedir=/var && \
	echo no make -j2 && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBNASL)/* && \
	make P=$(LIBNASL) log-package

$(LIBNIDS):  $(GCC4-OLD)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBNIDS).tar.gz && \
	chmod 755 $(LIBNIDS) && \
	chown -R 0:0 $(LIBNIDS) && \
	cd $(LIBNIDS) && \
	\
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) ./configure --prefix=/usr --sysconfdir=/etc && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC4-OLD)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(LIBNIDS)/* && \
	make P=$(LIBNIDS) log-package

$(LIBSSH):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBSSH).tgz && \
	chmod 755 $(LIBSSH) && \
	chown -R 0:0 $(LIBSSH) && \
	cd $(LIBSSH) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBSSH)/* && \
	make P=$(LIBSSH) log-package

$(LIBSSH2):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBSSH2).tar.gz && \
	chmod 755 $(LIBSSH2) && \
	chown -R 0:0 $(LIBSSH2) && \
	cd $(LIBSSH2) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBSSH2)/* && \
	make P=$(LIBSSH2) log-package

$(NESSUS-LIBRARIES):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NESSUS-LIBRARIES).tar.gz && \
	mv nessus-libraries $(NESSUS-LIBRARIES) && \
	chmod 755 $(NESSUS-LIBRARIES) && \
	chown -R 0:0 $(NESSUS-LIBRARIES) && \
	cd $(NESSUS-LIBRARIES) && \
	\
	PATH=/opt/$(GCC3)/bin:$(PATH) ./configure --prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make -j2 && \
	PATH=/opt/$(GCC3)/bin:$(PATH) make install && \
	\
	cd .. && \
	rm -rf $(NESSUS-LIBRARIES)/* && \
	make P=$(NESSUS-LIBRARIES) log-package

$(NESSUS-PLUGINS):  $(NESSUS-LIBRARIES)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NESSUS-PLUGINS).tar.gz && \
	mv nessus-plugins $(NESSUS-PLUGINS) && \
	chmod 755 $(NESSUS-PLUGINS) && \
	chown -R 0:0 $(NESSUS-PLUGINS) && \
	cd $(NESSUS-PLUGINS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--localstatedir=/var && \
	make -j2 && \
	make install && \
	\
	mkdir -p /usr/var && ln -sfn /var/nessus /usr/var/nessus && \
	mkdir -p /tmp/.desc && \
	ln -sfn /tmp/.desc /usr/lib/nessus/plugins/.desc && \
	rm -rf /usr/com && ln -sfn /var /usr/com && \
	\
	cd .. && \
	rm -rf $(NESSUS-PLUGINS)/* && \
	make P=$(NESSUS-PLUGINS) log-package

$(TERMREADKEY):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TERMREADKEY).tar.gz && \
	chmod 755 $(TERMREADKEY) && \
	chown -R 0:0 $(TERMREADKEY) && \
	cd $(TERMREADKEY) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TERMREADKEY)/* && \
	make P=$(TERMREADKEY) log-package

$(NET-PCAP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NET-PCAP).tar.gz && \
	chmod 755 $(NET-PCAP) && \
	chown -R 0:0 $(NET-PCAP) && \
	cd $(NET-PCAP) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(NET-PCAP)/* && \
	make P=$(NET-PCAP) log-package


$(AFFLIB):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AFFLIB).tar.gz && \
	chmod 755 $(AFFLIB) && \
	chown -R 0:0 $(AFFLIB) && \
	cd $(AFFLIB) && \
	\
	./configure --sysconfdir=/etc --prefix=/usr --enable-s3 && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AFFLIB)/* && \
	make P=$(AFFLIB) log-package

#
# End JLFS-Blackhat-Lib
# Begin BLFS Miscellaneous
#

$(XEN): $(NCURSES) $(PYTHON) $(OPENSSL) $(XORG7) $(BRIDGE-UTILS) $(WHICH) \
	$(XEN-KERNEL)

	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XEN).tar.gz && \
	chmod 755 $(XEN) && \
	chown -R 0:0 $(XEN) && \
	cd $(XEN) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(XEN)-no-firmware.patch && \
	\
	make dist-xen && \
	make dist-tools && \
	make install-xen && \
	make install-tools && \
	\
	\
	cd .. && \
	rm -rf $(XEN)/* && \
	make P=$(XEN) log-package

$(XEN-KERNEL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XEN-KERNEL).tar.gz && \
	chmod 755 $(XEN-KERNEL) && \
	chown -R 0:0 $(XEN-KERNEL) && \
	cd $(XEN-KERNEL) && \
	\
	cp -v $(JLFS-CONFIGS)/$(XEN-KERNEL).config .config && \
	patch -Np1 -i $(JLFS-PATCHES)/$(XEN-KERNEL)-squashfs3.4.patch && \
	\
	make oldconfig && \
	make -j4 && \
	\
	cd .. && \
	echo obsolete rm -rf $(XEN-KERNEL)/* && \
	make P=$(XEN-KERNEL) log-package

$(XZ):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(XZ).tar.bz2 && \
	chmod 755 $(XZ) && \
	chown -R 0:0 $(XZ) && \
	cd $(XZ) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(XZ)/* && \
	make P=$(XZ) log-package

$(AUTOFS): $(OPENLDAP)
	echo obsolete mount -vt proc proc /proc && \
	\
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(AUTOFS).tar.bz2 && \
	chmod 755 $(AUTOFS) && \
	chown -R 0:0 $(AUTOFS) && \
	cd $(AUTOFS) && \
	for i in `cat $(JLFS-CONFIGS)/$(AUTOFS)-patch_order-$(AUTOFS-VER)`; do \
		patch -Np1 -i $(JLFS-PATCHES)/$${i} && \
		echo "Good patch from $${i}"; \
	done && \
	\
	./configure --prefix=/ --mandir=/usr/share/man && \
	make -j2 && \
	make install && \
	\
	mkdir -p /etc/rc.d/rcsysinit.d && \
	ln -sfn  ../init.d/autofs /etc/rc.d/rcsysinit.d/S52autofs && \
	\
	mv /etc/auto.master /etc/auto.master.bak && \
	echo "# Begin /etc/auto.master" > /etc/auto.master && \
	echo "" >> /etc/auto.master && \
	echo "/media/auto  /etc/auto.misc  --ghost" >> /etc/auto.master && \
	echo "#/home        /etc/auto.home" >> /etc/auto.master && \
	echo "" >> /etc/auto.master && \
	echo "# End /etc/auto.master" >> /etc/auto.master && \
	\
	cd .. && \
	rm -rf $(AUTOFS)/.version $(AUTOFS)/.$(AUTOFS) $(AUTOFS)/* && \
	make P=$(AUTOFS) log-package

$(ED):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ED).tar.bz2 && \
	chmod 755 $(ED) && \
	chown -R 0:0 $(ED) && \
	cd $(ED) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ED)/* && \
	make P=$(ED) log-package

$(BLFSBOOT):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(BLFSBOOT).tar.bz2 && \
	chmod 755 $(BLFSBOOT) && \
	chown -R 0:0 $(BLFSBOOT) && \
	touch $(BLFSBOOT) && \
	cd $(BLFSBOOT) && \
	\
	make install-autofs && \
	make install-iptables && \
	make install-dbus && \
	make install-gpm && \
	make install-fcron && \
	make install-sysstat && \
	make install-haldaemon && \
	make install-sshd && \
	make install-random && \
	make install-alsa && \
	echo make install-sendmail && \
	make install-cups && \
	make install-lprng && \
	\
	if [ "$(SERVER)" != "" ]; then \
		make install-httpd && \
		make install-service-dhclient && \
		make install-service-dhcpcd && \
		make install-service-pppoe && \
		make install-ntp && \
		make install-rpcbind && \
		make install-dhcp && \
		make install-proftpd && \
		make install-mysql && \
		make install-nfs-server && \
		make install-nfs-client ; \
	fi

$(OPENVZ-CTL):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(OPENVZ-CTL).tar.bz2 && \
	chmod 755 $(OPENVZ-CTL) && \
	chown -R 0:0 $(OPENVZ-CTL) && \
	cd $(OPENVZ-CTL) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-bashcomp && \
	make -j2 && \
	make install && \
	make install-redhat && \
	\
	perl -p -i -e 's/sbin\/lsmod/bin\/lsmod/' $(LFS)/etc/rc.d/init.d/vz && \
	\
	cd .. && \
	rm -rf $(OPENVZ-CTL)/* && \
	make P=$(OPENVZ-CTL) log-package

$(OPENVZ-PKG):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(OPENVZ-PKG).tar.bz2 && \
	chmod 755 $(OPENVZ-PKG) && \
	chown -R 0:0 $(OPENVZ-PKG) && \
	cd $(OPENVZ-PKG) && \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(OPENVZ-PKG)/* && \
	make P=$(OPENVZ-PKG) log-package

$(OPENVZ-QUOTA):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(OPENVZ-QUOTA).tar.bz2 && \
	chmod 755 $(OPENVZ-QUOTA) && \
	chown -R 0:0 $(OPENVZ-QUOTA) && \
	cd $(OPENVZ-QUOTA) && \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(OPENVZ-QUOTA)/* && \
	make P=$(OPENVZ-QUOTA) log-package


#
# Begin BLFS Security
#

$(OPENSSL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(OPENSSL).tar.gz && \
	chmod 755 $(OPENSSL) && \
	chown -R 0:0 $(OPENSSL) && \
	cd $(OPENSSL) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(OPENSSL)-fix_manpages-1.patch && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(OPENSSL-CA).tar.bz2 && \
	./config --prefix=/usr \
		--openssldir=/etc/ssl \
		shared \
		zlib-dynamic && \
	\
	echo no make -j2 && \
	make && \
	make MANDIR=/usr/share/man install && \
	cp -v -r certs /etc/ssl && \
	install -v -d -m755 /usr/share/doc/$(OPENSSL) && \
	cp -v -r doc/{HOWTO,README,*.{txt,html,gif}} \
		/usr/share/doc/$(OPENSSL) && \
	\
	for pem in /etc/ssl/certs/*.pem; do \
		cat $${pem} && \
		echo ""; \
	done > /etc/ssl/ca-bundle.crt && \
	\
	cd .. && \
	rm -rf $(OPENSSL)/* && \
	make P=$(OPENSSL) log-package

$(PAM):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PAM).tar.bz2 && \
	chmod 755 $(PAM) && \
	chown -R 0:0 $(PAM) && \
	cd $(PAM) && \
	\
	./configure --sysconfdir=/etc \
		--libdir=/usr/lib \
		--sbindir=/lib/security \
		--enable-securedir=/lib/security \
		--docdir=/usr/share/doc/$(PAM) \
		--with-xauth=/usr/bin/xauth \
		--enable-read-both-confs && \
	make -j2 && \
	make install && \
	\
	chmod -v 4755 /lib/security/unix_chkpwd && \
	mv -v /lib/security/pam_tally /sbin && \
	\
	if [ -L /lib/libpam.so ]; then \
		for LINK in libpam{,c,_misc}.so; do \
			ln -v -sf ../../lib/$(shell readlink /lib/$${LINK} ) \
				/usr/lib/$${LINK} && \
			rm -v /lib/$${LINK}; \
		done; \
	fi && \
	\
	cd .. && \
	rm -rf $(PAM)/* && \
	make P=$(PAM) log-package

$(SHADOW):  $(PAM)
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(SHADOW).tar.bz2 && \
	chmod 755 $(SHADOW) && \
	chown -R 0:0 $(SHADOW) && \
	\
	cd $(SHADOW) && \
	\
	sed -i 's/groups$$(EXEEXT) //' src/Makefile.in && \
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \; && \
	sed -i -e 's/ ko//' -e 's/ zh_CN zh_TW//' man/Makefile.in && \
	\
	sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD MD5@' \
		-e 's@/var/spool/mail@/var/mail@' etc/login.defs && \
	\
	./configure --sysconfdir=/etc --libdir=/lib && \
	\
	make -j2 && \
	make install && \
	mv -v /usr/bin/passwd /bin && \
	\
	useradd -D -b /home && \
	sed -i 's/yes/no/' /etc/default/useradd && \
	\
	install -v -m644 /etc/login.defs /etc/login.defs.orig && \
	\
	for FUNCTION in LASTLOG_ENAB MAIL_CHECK_ENAB \
		PORTTIME_CHECKS_ENAB CONSOLE \
		MOTD_FILE NOLOGINS_FILE PASS_MIN_LEN \
		SU_WHEEL_ONLY MD5_CRYPT_ENAB \
		CONSOLE_GROUPS ENVIRON_FILE \
		ULIMIT ENV_TZ ENV_HZ ENV_SUPATH \
		ENV_PATH QMAIL_DIR MAIL_DIR MAIL_FILE \
		CHFN_AUTH FAILLOG_ENAB QUOTAS_ENAB FTMP_FILE \
		OBSCURE_CHECKS_ENAB CRACKLIB_DICTPATH \
		PASS_CHANGE_TRIES PASS_ALWAYS_WARN ISSUE_FILE; do \
	\
			sed -i "s/^$${FUNCTION}/# &/" /etc/login.defs; \
	done && \
	echo "caution dir pam.d might exist"

	-install -v -d -m755 /etc/pam.d

	cd $(SHADOW)/src && \
	for PROGRAM in chpasswd chgpasswd groupadd groupdel groupmems \
		groupmod newusers useradd userdel usermod; do \
		\
		install -v -m644 /etc/pam.d/chage /etc/pam.d/$${PROGRAM}; \
		sed -i "s/chage/$${PROGRAM}/" /etc/pam.d/$${PROGRAM}; \
	done && \
	\
	if [ -f /etc/login.access ]; then \
		mv -v /etc/login.access /etc/login.access.NOUSE; \
	fi && \
	\
	if [ -f /etc/limits ]; then \
		mv -v /etc/limits /etc/limits.NOUSE; \
	fi && \
	\
	ENV_PATH=`grep '^ENV_PATH' /etc/login.defs.orig | \
		awk '{ print $$2 }' | sed 's/PATH=//'` && \
		echo 'PATH        DEFAULT='`echo "$${ENV_PATH}"` \
	'        OVERRIDE=$${PATH}' >> /etc/security/pam_env.conf && \
	unset ENV_PATH && \
	\
	cd ../.. && \
	\
	rm -rf $(SHADOW)/* && \
	make P=$(SHADOW) log-package

$(IPTABLES):  $(KERNEL)-$(ARCH) 
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(IPTABLES).tar.bz2 && \
	chmod 755 $(IPTABLES) && \
	chown -R 0:0 $(IPTABLES) && \
	touch $(IPTABLES) && \
	cd $(IPTABLES) && \
	\
	sed -i '/if_packet/i#define __aligned_u64 __u64 __attribute__((aligned(8)))' \
		extensions/libxt_pkttype.c && \
	./configure --prefix=/usr \
		--bindir=/sbin \
		--sbindir=/sbin \
		--libdir=/lib \
		--libexecdir=/lib \
		--with-pkgconfigdir=/usr/lib/pkgconfig && \
	\
	make -j2 && \
	make install && \
	\
	ln -sfv xtables-multi /sbin/iptables-xml && \
	\
	cd .. && \
	rm -rf $(IPTABLES)/* && \
	make P=$(IPTABLES) log-package

$(GNUPG):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNUPG).tar.bz2 && \
	chmod 755 $(GNUPG) && \
	chown -R 0:0 $(GNUPG) && \
	cd $(GNUPG) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/lib && \
	make -j2 && \
	make install && \
	chmod -v 4755 /usr/bin/gpg && \
	install -v -m755 -d /usr/share/doc/$(GNUPG) && \
	mv -v /usr/share/gnupg/{FAQ,faq.html} /usr/share/doc/$(GNUPG) && \
	install -v -m644 \
		doc/{highlights-1.4.txt,OpenPGP,samplekeys.asc,DETAILS,*.texi} \
		/usr/share/doc/$(GNUPG) && \
	\
	cd .. && \
	rm -rf $(GNUPG)/* && \
	make P=$(GNUPG) log-package

$(NSS):  $(NSPR) $(SQLITE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NSS).tar.gz && \
	chmod 755 $(NSS) && \
	chown -R 0:0 $(NSS) && \
	touch $(NSS) && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NSPR).tar.gz && \
	mv $(NSPR)/mozilla/nsprpub $(NSS)/mozilla && \
	\
	cd $(NSS) && \
	\
	export BUILD_OPT=1 && \
	export NSS_USE_SYSTEM_SQLITE=1 && \
	export NSPR_INCLUDE_DIR=/usr/include/nspr && \
	export USE_SYSTEM_ZLIB=1 && \
	export ZLIB_LIBS=-lz && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(NSS)-standalone-1.patch && \
	make -C mozilla/security/nss nss_build_all && \
	\
	NSS_LINUXDIR=$(shell basename $(NSS)/mozilla/dist/Linux* ) && \
	cd mozilla/dist && \
	\
	install -v -m755 $${NSS_LINUXDIR}/lib/*.so /usr/lib && \
	install -v -m644 $${NSS_LINUXDIR}/lib/{*.chk,libcrmf.a} /usr/lib && \
	install -v -m755 -d /usr/include/nss && \
	install -v -m755 $${NSS_LINUXDIR}/bin/{certutil,nss-config,pk12util} \
		/usr/bin && \
	install -v -m644 $${NSS_LINUXDIR}/lib/pkgconfig/nss.pc \
		/usr/lib/pkgconfig && \
	cp -v -RL {public,private}/nss/* /usr/include/nss && \
	chmod 644 /usr/include/nss/* && \
	\
	cd ../.. && \
	\
	cd .. && \
	rm -rf $(NSS)/* $(NSPR)/* && \
	make P=$(NSS) log-package

$(POLKIT): $(GOBJECT-INTROSPECTION) $(PAM) $(INTLTOOL) $(EGGDBUS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(POLKIT).tar.gz && \
	chmod 755 $(POLKIT) && \
	chown -R 0:0 $(POLKIT) && \
	cd $(POLKIT) && \
	\
	groupadd -fg 27 polkituser; \
	useradd -c "Policy Kit Daemon User" -d /dev/null -u 27 \
		-g polkituser -s /bin/false polkituser; \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-man-pages \
		--libexecdir=/usr/lib/polkit-1 --localstatedir=/var && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(POLKIT)/* && \
	make P=$(POLKIT) log-package

$(LIBFFI):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBFFI).tar.gz && \
	chmod 755 $(LIBFFI) && \
	chown -R 0:0 $(LIBFFI) && \
	cd $(LIBFFI) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBFFI)/* && \
	make P=$(LIBFFI) log-package

$(GNUTLS):  $(LIBGCRYPT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNUTLS).tar.bz2 && \
	chmod 755 $(GNUTLS) && \
	chown -R 0:0 $(GNUTLS) && \
	cd $(GNUTLS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNUTLS)/* && \
	make P=$(GNUTLS) log-package

$(POLKIT-GNOME):  $(POLKIT) $(GTK2) $(GTK3)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(POLKIT-GNOME).tar.bz2 && \
	chmod 755 $(POLKIT-GNOME) && \
	chown -R 0:0 $(POLKIT-GNOME) && \
	cd $(POLKIT-GNOME) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--libexecdir=/usr/lib/polkit-gnome && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(POLKIT-GNOME)/* && \
	make P=$(POLKIT-GNOME) log-package

#
# Begin Xorg Prerequisites
#

$(LIBPNG):
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(LIBPNG).tar.xz| tar xvf - && \
	chmod 755 $(LIBPNG) && \
	chown -R 0:0 $(LIBPNG) && \
	cd $(LIBPNG) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBPNG)-apng-1.patch && \
	\
	./configure --sysconfdir=/etc --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	install -v -m755 -d /usr/share/doc/$(LIBPNG) && \
	install -v -m644 README $(LIBPNG).txt /usr/share/doc/$(LIBPNG) && \
	\
	cd .. && \
	rm -rf $(LIBPNG)/.libs $(LIBPNG)/.deps $(LIBPNG)/* && \
	make P=$(LIBPNG) log-package

$(FONTCONFIG): $(FREETYPE) $(EXPAT)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FONTCONFIG).tar.gz && \
	chmod 755 $(FONTCONFIG) && \
	chown -R 0:0 $(FONTCONFIG) && \
	cd $(FONTCONFIG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
		--disable-docs --without-add-fonts \
		--with-docdir=/usr/share/doc/$(FONTCONFIG) && \
	make -j2 && \
	make install && \
	install -v -m644 doc/*.3 /usr/share/man/man3 && \
	install -v -m644 doc/*.5 /usr/share/man/man5 && \
	install -v -m755 -d /usr/share/doc/$(FONTCONFIG)/fontconfig-devel && \
	install -v -m644 doc/*.{html,pdf,txt} /usr/share/doc/$(FONTCONFIG) && \
	install -v -m644 doc/fontconfig-devel/* \
		/usr/share/doc/$(FONTCONFIG)/fontconfig-devel && \
	\
	cd .. && \
	rm -rf $(FONTCONFIG)/* && \
	make P=$(FONTCONFIG) log-package

$(FREETYPE):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FREETYPE).tar.bz2 && \
	chmod 755 $(FREETYPE) && \
	chown -R 0:0 $(FREETYPE) && \
	cd $(FREETYPE) && \
	\
	sed -i -r -e 's:.*(#.*BYTE.*) .*:\1:' \
		-e 's:.*(#.*SUBPIX.*) .*:\1:' \
		include/freetype/config/ftoption.h && \
	\
	./configure --sysconfdir=/etc --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(FREETYPE) && \
	cp -v -R docs/* /usr/share/doc/$(FREETYPE) && \
	\
	cd .. && \
	rm -rf $(FREETYPE)/* && \
	make P=$(FREETYPE) log-package

$(EXPAT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(EXPAT).tar.gz && \
	chmod 755 $(EXPAT) && \
	chown -R 0:0 $(EXPAT) && \
	cd $(EXPAT) && \
	\
	./configure --sysconfdir=/etc --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(EXPAT) && \
	install -v -m644 doc/*.{html,png,css} /usr/share/doc/$(EXPAT) && \
	\
	cd .. && \
	rm -rf $(EXPAT)/.libs $(EXPAT)/* && \
	make P=$(EXPAT) log-package

$(PKG-CONFIG):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PKG-CONFIG).tar.gz && \
	chmod 755 $(PKG-CONFIG) && \
	chown -R 0:0 $(PKG-CONFIG) && \
	cd $(PKG-CONFIG) && \
	\
	./configure --sysconfdir=/etc --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PKG-CONFIG)/* && \
	make P=$(PKG-CONFIG) log-package

$(LIBDRM):
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(LIBDRM).tar.bz2 && \
	chmod 755 $(LIBDRM) && \
	chown -R 0:0 $(LIBDRM) && \
	cd $(LIBDRM) && \
	\
	./configure --prefix=/usr \
		--enable-nouveau-experimental-api \
		--enable-vmwgfx-experimental-api && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo rm -rf $(LIBDRM)/* && \
	make P=$(LIBDRM) log-package

$(MESA):  $(LIBDRM) $(XORG7-PROTO) $(XORG7-UTIL) $(XORG7-LIB) $(EXPAT) \
	$(TALLOC)

	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(MESALIB).tar.bz2 && \
	chmod 755 $(MESA) && \
	chown -R 0:0 $(MESA) && \
	cd $(MESA) && \
	\
	sed 's@FLAGS=\"-g@FLAGS=\"@' -i configure && \
	\
	./configure --prefix=/usr \
		--enable-xcb --without-gallium-drivers && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo source will be removed with Xorg rm -rf $(MESA)/* && \
	make P=$(MESA) log-package

$(LIBXAU):
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(LIBXAU).tar.bz2 && \
	chmod 755 $(LIBXAU) && \
	chown -R 0:0 $(LIBXAU) && \
	cd $(LIBXAU) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBXAU)/* && \
	make P=$(LIBXAU) log-package

$(LIBXCB):  $(LIBXAU)
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(LIBXCB).tar.bz2 && \
	chmod 755 $(LIBXCB) && \
	chown -R 0:0 $(LIBXCB) && \
	cd $(LIBXCB) && \
	\
	./configure --prefix=/usr --without-doxygen && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBXCB)/* && \
	make P=$(LIBXCB) log-package

$(LIBXDMCP):
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(LIBXDMCP).tar.bz2 && \
	chmod 755 $(LIBXDMCP) && \
	chown -R 0:0 $(LIBXDMCP) && \
	cd $(LIBXDMCP) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBXDMCP)/* && \
	make P=$(LIBXDMCP) log-package

$(UTIL-MACROS):
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/util/$(UTIL-MACROS).tar.bz2 && \
	chmod 755 $(UTIL-MACROS) && \
	chown -R 0:0 $(UTIL-MACROS) && \
	cd $(UTIL-MACROS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(UTIL-MACROS)/* && \
	make P=$(UTIL-MACROS) log-package

$(XCB-PROTO):  $(PYTHON)
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(XCB-PROTO).tar.bz2 && \
	chmod 755 $(XCB-PROTO) && \
	chown -R 0:0 $(XCB-PROTO) && \
	cd $(XCB-PROTO) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XCB-PROTO)/* && \
	make P=$(XCB-PROTO) log-package

$(LIBATOMIC-OPS):
	set +h && \
	\
	tar xvf $(XORG-TARBALLS)/misc/$(LIBATOMIC-OPS).tar.gz && \
	chmod 755 $(LIBATOMIC-OPS) && \
	chown -R 0:0 $(LIBATOMIC-OPS) && \
	cd $(LIBATOMIC-OPS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBATOMIC-OPS)/* && \
	make P=$(LIBATOMIC-OPS) log-package

$(TALLOC):
	set +h && \
	\
	tar xvf $(XORG-TARBALLS)/misc/$(TALLOC).tar.gz && \
	chmod 755 $(TALLOC) && \
	chown -R 0:0 $(TALLOC) && \
	cd $(TALLOC) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TALLOC)/* && \
	make P=$(TALLOC) log-package

$(XKEYBOARD-CONFIG):
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(XKEYBOARD-CONFIG).tar.bz2 && \
	chmod 755 $(XKEYBOARD-CONFIG) && \
	chown -R 0:0 $(XKEYBOARD-CONFIG) && \
	cd $(XKEYBOARD-CONFIG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--mandir=/usr/share/man \
		--localstatedir=/var \
		--with-xkb-base=/usr/share/X11/xkb \
		--enable-xkbcomp-symlink \
		--with-xkb-rules-symlink=xorg \
		--with-config-dir=/usr/lib/X11/config && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XKEYBOARD-CONFIG)/* && \
	make P=$(XKEYBOARD-CONFIG) log-package

#
# Begin Xorg
#
# Hint:  If building some component of Xorg fails, after correcting the 
#        problem, remove /usr/src/$(XORG7) and re-run make to restart.
#        The build will continue approximately where it left off instead
#        of starting the Xorg build all over again.
#

$(XORG7): $(DBUS) $(PKG-CONFIG) $(LIBPNG) $(FONTCONFIG) $(ED) \
	$(XML-PARSER) $(LIBPTHREAD-STUBS) $(LIBXSLT)

	set +h && \
	\
	make $(UTIL-MACROS) && \
	make $(XORG7-PROTO) && \
	make $(XORG7-UTIL) && \
	\
	make $(LIBXAU) && \
	make $(LIBXDMCP) && \
	make $(XCB-PROTO) && \
	make $(LIBXCB) && \
	\
	make $(XORG7-LIB) && \
	\
	make $(MESA) && \
	\
	make $(XORG7-APP) && \
	make $(XORG7-FONT) && \
	make $(XKEYBOARD-CONFIG) && \
	make $(XORG7-SERVER) && \
	make $(XORG7-DRIVER) && \
	\
	mkdir -p /etc/X11 && \
	ln -sfnvt /etc/X11 \
 		/usr/lib/X11/{lbxproxy,proxymngr,rstart} \
 		/usr/lib/X11/{xdm,xinit,xsm} \
 		/usr/share/X11/{app-defaults,twm,xkb} && \
	\
	ln -sfn /usr /usr/X11R6 && \
	echo "/tmp/.ICE-unix dir 1777 root root" \
		>> /etc/sysconfig/createfiles && \
	\
	echo "$(XORG7) built successfully"

$(XORG7-PROTO):
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	for PACKAGE in $(shell grep -v ^# $(XORG-CONFIGS)/proto-$(XORG7-VER).wget ); do \
		tar xvf $(XORG-TARBALLS)/proto/$${PACKAGE} \
			-C $(XORG-BUILD) && \
		PACKAGEDIR=`echo $${PACKAGE}| sed 's/.tar.bz2//'` && \
		chmod 755 $(XORG-BUILD)/$${PACKAGEDIR} && \
		cd $(XORG-BUILD)/$${PACKAGEDIR} && \
		\
		./configure --prefix=/usr --sysconfdir=/etc \
			--mandir=/usr/share/man \
			--localstatedir=/var && \
		make -j2 && \
		make install && \
		\
		cd .. && \
		rm -rf $${PACKAGEDIR} && \
		( cd $(BUILD_JLFS_SRC) && \
			make P=$(XORG7-PROTO)-$${PACKAGEDIR} log-package ) && \
		\
		echo "package build of $${PACKAGEDIR} complete" || \
		( echo "package $${PACKAGEDIR} failed, press ENTER" && read val ); \
		\
	done 2>&1 | tee -a $(BUILD_JLFS_SRC)/$(XORG7)-compile.log && \
	\
	touch $(BUILD_JLFS_SRC)/$(XORG7-PROTO)

$(XORG7-UTIL):
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	for PACKAGE in $(shell grep -v ^# $(XORG-CONFIGS)/util-$(XORG7-VER).wget ); do \
		tar xvf $(XORG-TARBALLS)/util/$${PACKAGE} -C $(XORG-BUILD) && \
		PACKAGEDIR=`echo $${PACKAGE}| sed 's/.tar.bz2//'` && \
		chmod 755 $(XORG-BUILD)/$${PACKAGEDIR} && \
		cd $(XORG-BUILD)/$${PACKAGEDIR} && \
		\
		if [ -f X11.tmpl ]; then \
			echo "Manually patching $${PACKAGEDIR}" && \
			sed -i "s@/usr/X11R6@/usr@" X11.tmpl || \
			( echo "Patch failed" && read val ); \
		fi && \
		\
		./configure --prefix=/usr --sysconfdir=/etc \
			--mandir=/usr/share/man \
			--localstatedir=/var \
			--with-config-dir=/usr/lib/X11/config && \
		make -j2 && \
		make install && \
		\
		cd .. && \
		rm -rf $${PACKAGEDIR} && \
		( cd $(BUILD_JLFS_SRC) && \
			make P=$(XORG7-UTIL)-$${PACKAGEDIR} log-package ) && \
		\
		echo "package build of $${PACKAGEDIR} complete" || \
		( echo "package $${PACKAGEDIR} failed, press ENTER" && read val ); \
		\
	done 2>&1 | tee -a $(BUILD_JLFS_SRC)/$(XORG7)-compile.log && \
	\
	touch $(BUILD_JLFS_SRC)/$(XORG7-UTIL)

$(XORG7-LIB):
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	for PACKAGE in $(shell grep -v ^# $(XORG-CONFIGS)/lib-$(XORG7-VER).wget ); do \
		tar xvf $(XORG-TARBALLS)/lib/$${PACKAGE} \
			-C $(XORG-BUILD) && \
		PACKAGEDIR=`echo $${PACKAGE}| sed 's/.tar.bz2//'` && \
		chmod 755 $(XORG-BUILD)/$${PACKAGEDIR} && \
		cd $(XORG-BUILD)/$${PACKAGEDIR} && \
		\
		P="" && \
		\
		if [ -f modules/im/ximcp/imDefLkup.c ]; then \
			echo "Manually patching libX11" && \
			echo obsolete sed -i 's/_XGet/XGet/' \
				modules/im/ximcp/imDefLkup.c || \
			( echo "Patch failed" && read val ); \
		fi && \
		\
		./configure --prefix=/usr --sysconfdir=/etc \
			--mandir=/usr/share/man \
			--localstatedir=/var && \
		make -j2 && \
		make install && \
		ldconfig && \
		\
		cd .. && \
		rm -rf $${PACKAGEDIR} && \
		( cd $(BUILD_JLFS_SRC) && \
			make P=$(XORG7-LIB)-$${PACKAGEDIR} log-package ) && \
		\
		echo "package build of $${PACKAGEDIR} complete" || \
		( echo "package $${PACKAGEDIR} failed" && read val ); \
	done 2>&1 | tee -a $(BUILD_JLFS_SRC)/$(XORG7)-compile.log && \
	\
	touch $(BUILD_JLFS_SRC)/$(XORG7-LIB)

$(XORG7-APP): $(PIXMAN) $(INTLTOOL)
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	for PACKAGE in $(shell grep -v ^# $(XORG-CONFIGS)/app-$(XORG7-VER).wget ); do \
		tar xvf $(XORG-TARBALLS)/app/$${PACKAGE} -C $(XORG-BUILD) && \
		PACKAGEDIR=`echo $${PACKAGE}| sed 's/.tar.bz2//'` && \
		chmod 755 $(XORG-BUILD)/$${PACKAGEDIR} && \
		cd $(XORG-BUILD)/$${PACKAGEDIR} && \
		\
		C="" && \
		if [ "$${PACKAGEDIR}" = "$(XKEYBOARD-CONFIG)" ]; then \
			C="--with-xkb-base=/usr/share/X11/xkb " && \
			C="$${C} --enable-xkbcomp-symlink " && \
			C="$${C} --with-xkb-rules-symlink=xorg"; \
		fi && \
		\
		./configure --prefix=/usr --sysconfdir=/etc \
			--mandir=/usr/share/man \
			--localstatedir=/var $${C} \
			--with-config-dir=/usr/lib/X11/config && \
		make -j2 && \
		make install && \
		\
		cd .. && \
		rm -rf $${PACKAGEDIR} && \
		( cd $(BUILD_JLFS_SRC) && \
			make P=$(XORG7-APP)-$${PACKAGEDIR} log-package ) && \
		\
		echo "package build of $${PACKAGEDIR} complete" || \
		( echo "package $${PACKAGEDIR} failed, press ENTER" && read val ); \
	done 2>&1 | tee -a $(BUILD_JLFS_SRC)/$(XORG7)-compile.log && \
	\
	touch $(BUILD_JLFS_SRC)/$(XORG7-APP)

$(XORG7-FONT):
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	for PACKAGE in $(shell grep -v ^# $(XORG-CONFIGS)/font-$(XORG7-VER).wget ); do \
		tar xvf $(XORG-TARBALLS)/font/$${PACKAGE} \
			-C $(XORG-BUILD) && \
		PACKAGEDIR=`echo $${PACKAGE}| sed 's/.tar.bz2//'` && \
		chmod 755 $(XORG-BUILD)/$${PACKAGEDIR} && \
		cd $(XORG-BUILD)/$${PACKAGEDIR} && \
		\
		./configure --prefix=/usr --sysconfdir=/etc \
			--mandir=/usr/share/man \
			--localstatedir=/var && \
		make -j2 && \
		make install && \
		\
		cd .. && \
		rm -rf $${PACKAGEDIR} && \
		( cd $(BUILD_JLFS_SRC) && \
			make P=$(XORG7-FONT)-$${PACKAGEDIR} log-package ) && \
		\
		echo "package build of $${PACKAGEDIR} complete" || \
		( echo "package $${PACKAGEDIR} failed, press ENTER" && read val ); \
	done 2>&1 | tee -a $(BUILD_JLFS_SRC)/$(XORG7)-compile.log && \
	\
	install -v -d -m755 /usr/share/fonts && \
	ln -sfn /usr/lib/X11/fonts/OTF /usr/share/fonts/X11-OTF && \
	ln -sfn /usr/lib/X11/fonts/TTF /usr/share/fonts/X11-TTF && \
	\
	tar xvf $(XORG-TARBALLS)/font/$(WEBCORE-FONTS).tar.gz -C $(XORG-BUILD) && \
	cd $(XORG-BUILD)/webcore-fonts && \
	\
	mv fonts/WINGDNG2.TTF fonts/wingdng2.ttf && \
	mv fonts/WINGDNG3.TTF fonts/wingdng3.ttf && \
	\
	install -v -d -m755 /usr/share/fonts/webcore && \
	install -v -m644 fonts/*.ttf /usr/share/fonts/webcore && \
	fc-cache -v /usr/share/fonts/webcore && \
	\
	cd .. && \
	rm -rf webcore-fonts && \
	( cd $(BUILD_JLFS_SRC) && \
		make P=$(XORG7-FONT)-$(WEBCORE-FONTS) log-package ) && \
	\
	echo "package build of webcore-fonts complete" || \
	( echo "package webcore-fonts failed, press ENTER" && read val ); \
	\
	\
	tar xvf $(XORG-TARBALLS)/font/$(BITSTREAM-VERA-FONTS).tar.bz2 \
		-C $(XORG-BUILD) && \
	cd $(XORG-BUILD)/$(BITSTREAM-VERA-FONTS) && \
	\
	install -v -d -m755 /usr/share/fonts/ttf-bitstream-vera && \
	install -v -m644 *.ttf /usr/share/fonts/ttf-bitstream-vera && \
	chmod 644 local.conf && \
	cp -v local.conf /etc/fonts/conf.avail/52-bitstream.conf && \
	fc-cache -v /usr/share/fonts/ttf-bitstream-vera && \
	\
	cd .. && \
	rm -rf $(BITSTREAM-VERA-FONTS) && \
	( cd $(BUILD_JLFS_SRC) && \
		make P=$(XORG7-FONT)-$(BITSTREAM-VERA-FONTS) log-package ) && \
	\
	echo "package build of $(BITSTREAM-VERA-FONTS) complete" || \
	( echo "package $(BITSTREAM-VERA-FONTS) failed, press ENTER" && read val ); \
	\
	touch $(BUILD_JLFS_SRC)/$(XORG7-FONT)

$(XORG7-SERVER):
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	tar jxvf $(XORG-TARBALLS)/xserver/$(XSERVER).tar.bz2 -C $(XORG-BUILD) && \
	cd $(XORG-BUILD)/$(XSERVER) && \
	\
	./configure  --prefix=/usr --sysconfdir=/etc \
		--mandir=/usr/share/man \
		--localstatedir=/var \
		--with-config-dir=/usr/lib/X11/config \
		--with-mesa-source=$(BUILD_JLFS_SRC)/$(MESA) \
		--with-fontdir=/usr/share/fonts/X11 \
		--with-module-dir=/usr/lib/X11/modules \
    		--with-dri-driver-path=/usr/lib/dri \
		--with-xkb-output=/var/lib/xkb \
		\
    		--enable-install-setuid \
		--enable-xcalibrate \
		--enable-tslib \
		--enable-config-dbus \
		--enable-config-hal \
		--enable-xorgcfg && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XSERVER) $(MESA) && \
	\
	echo "package build of $(XSERVER) complete" || \
	( echo "package $(XSERVER) failed, press ENTER" && read val ); \
	\
	cd $(BUILD_JLFS_SRC) && \
	touch $(XORG7)-server && \
	rm -rf $(MESA)/* && \
	make P=$(XORG7)-$(XSERVER) log-package

$(XORG7-DRIVER):
	set +h && \
	mkdir -p $(XORG-BUILD) && \
	cd $(XORG-BUILD) && \
	\
	for PACKAGE in $(shell grep -v ^# $(XORG-CONFIGS)/driver-$(XORG7-VER).wget ); do \
		tar xvf $(XORG-TARBALLS)/driver/$${PACKAGE} \
			-C $(XORG-BUILD) && \
		PACKAGEDIR=`echo $${PACKAGE}| sed 's/.tar.bz2//'` && \
		chmod 755 $(XORG-BUILD)/$${PACKAGEDIR} && \
		cd $(XORG-BUILD)/$${PACKAGEDIR} && \
		\
		./configure --prefix=/usr --sysconfdir=/etc \
			--mandir=/usr/share/man \
			--localstatedir=/var \
			--with-xorg-module-dir=/usr/lib/X11/modules && \
		make -j2 && \
		make install && \
		\
		cd .. && \
		rm -rf $${PACKAGEDIR} && \
		( cd $(BUILD_JLFS_SRC) && \
			make P=$(XORG7-DRIVER)-$${PACKAGEDIR} log-package ) && \
		\
		echo "package build of $${PACKAGEDIR} complete" || \
		( echo "package $${PACKAGEDIR} failed, press ENTER" && read val ); \
	done 2>&1 | tee -a $(BUILD_JLFS_SRC)/$(XORG7)-compile.log && \
	\
	touch $(BUILD_JLFS_SRC)/$(XORG7-DRIVER)

$(XTERM):  $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XTERM).tgz && \
	chmod 755 $(XTERM) && \
	chown -R 0:0 $(XTERM) && \
	cd $(XTERM) && \
	\
	sed -i '/v0/,+1s/new:/new:kb=^?:/' termcap && \
	echo -e '\tkbs=\\177,' >>terminfo && \
	\
	TERMINFO=/usr/lib/terminfo \
	./configure --sysconfdir=/etc --prefix=/usr \
		--enable-luit --with-wide-chars \
		--enable-256-color \
		--with-app-default=/usr/lib/X11/app-defaults && \
	make -j2 && \
	make install && \
	make install-ti && \
	\
	cd .. && \
	rm -rf $(XTERM)/* && \
	make P=$(XTERM) log-package


##
## Begin BLFS General Libraries
##

$(PCRE):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PCRE).tar.bz2 && \
	chmod 755 $(PCRE) && \
	chown -R 0:0 $(PCRE) && \
	cd $(PCRE) && \
	\
	./configure --prefix=/usr \
		--docdir=/usr/share/doc/$(PCRE) \
		--enable-utf8 && \
	make -j2 && \
	make install && \
	mv -v /usr/lib/libpcre.so.* /lib/ && \
	ln -v -sf ../../lib/libpcre.so.0 /usr/lib/libpcre.so && \
	\
	cd .. && \
	rm -rf $(PCRE)/.libs $(PCRE)/.deps $(PCRE)/* && \
	make P=$(PCRE) log-package

$(POPT):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(POPT).tar.gz && \
	chmod 755 $(POPT) && \
	chown -R 0:0 $(POPT) && \
	cd $(POPT) && \
	\
	echo obsolete sed -i -e "/*origOptString ==/c 0)" popt.c && \
	./configure --prefix=/usr && \
	make -j2 && \
	make check && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(POPT) && \
	\
	cd .. && \
	rm -rf $(POPT)/* && \
	make P=$(POPT) log-package

$(SLANG):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SLANG).tar.bz2 && \
	chmod 755 $(SLANG) && \
	chown -R 0:0 $(SLANG) && \
	cd $(SLANG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install_doc_dir=/usr/share/doc/$(SLANG) install-all && \
	chmod -v 755 /usr/lib/libslang.so.2.1.1 \
             /usr/lib/slang/v2/modules/*.so && \
	cd .. && \
	rm -rf $(SLANG)/* && \
	make P=$(SLANG) log-package

$(GAMIN):  $(GLIB2) $(PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GAMIN).tar.gz && \
	chmod 755 $(GAMIN) && \
	chown -R 0:0 $(GAMIN) && \
	cd $(GAMIN) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/sbin && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/gamin-0.1.8 && \
	install -v -m644 doc/*.{html,fig,gif,txt} \
		/usr/share/doc/gamin-0.1.8 && \
	\
	cd .. && \
	rm -rf $(GAMIN)/* && \
	make P=$(GAMIN) log-package

$(FAM):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FAM).tar.gz && \
	chmod 755 $(FAM) && \
	chown -R 0:0 $(FAM) && \
	cd $(FAM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FAM)/* && \
	make P=$(FAM) log-package

$(LIBXML):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBXML).tar.bz2 && \
	chmod 755 $(LIBXML) && \
	chown -R 0:0 $(LIBXML) && \
	cd $(LIBXML) && \
	\
	./configure --prefix=/usr && \
	echo no make -j && \
	make && \
	make install && \
	rm -f /usr/include/gnome-xml/libxml && \
	\
	cd .. && \
	rm -rf $(LIBXML)/.libs $(LIBXML)/* && \
	make P=$(LIBXML) log-package

$(LIBXML2):  $(PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBXML2).tar.gz && \
	chmod 755 $(LIBXML2) && \
	chown -R 0:0 $(LIBXML2) && \
	cd $(LIBXML2) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBXML2)/.deps $(LIBXML2)/.libs $(LIBXML2)/* && \
	make P=$(LIBXML2) log-package

$(PYTHON):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYTHON).tar.bz2 && \
	chmod 755 $(PYTHON) && \
	chown -R 0:0 $(PYTHON) && \
	cd $(PYTHON) && \
	\
	./configure --prefix=/usr --enable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYTHON)/* && \
	make P=$(PYTHON) log-package

$(LIBXSLT):  $(LIBXML2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBXSLT).tar.gz && \
	chmod 755 $(LIBXSLT) && \
	chown -R 0:0 $(LIBXSLT) && \
	cd $(LIBXSLT) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBXSLT)/* && \
	make P=$(LIBXSLT) log-package

$(LIBGTKHTML):  $(GTK2) $(LIBXML2) $(GNOME-VFS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGTKHTML).tar.bz2 && \
	chmod 755 $(LIBGTKHTML) && \
	chown -R 0:0 $(LIBGTKHTML) && \
	cd $(LIBGTKHTML) && \
	\
	./configure --prefix=/usr --disable-accessibility && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGTKHTML)/* && \
	make P=$(LIBGTKHTML) log-package

$(GLIB):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GLIB).tar.gz && \
	chmod 755 $(GLIB) && \
	chown -R 0:0 $(GLIB) && \
	cd $(GLIB) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(GLIB)-gcc34-1.patch && \
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	chmod -v 755 /usr/lib/libgmodule-1.2.so.0.0.10 && \
	\
	cd .. && \
	rm -rf $(GLIB)/.libs $(GLIB)/* && \
	make P=$(GLIB) log-package

$(GLIB2):  $(PKG-CONFIG) $(LIBFFI) $(PYTHON) $(PYTHON3) $(PKG-CONFIG)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GLIB2).tar.bz2 && \
	chmod 755 $(GLIB2) && \
	chown -R 0:0 $(GLIB2) && \
	cd $(GLIB2) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	\
	for i in `grep -rl "^PYTHON =" *`; do \
		echo perl -p -i -e 's/^PYTHON =.*$$/PYTHON = \/usr\/bin\/python/' \
			$${i}; \
	done && \
	\
	make -j2 && \
	make install && \
	\
	if [ ! -d /etc/profile.d ]; then mkdir /etc/profile.d; fi && \
	\
	echo "# Use the current locale charset for filenames" \
		> /etc/profile.d/glib2-locale.sh && \
	echo "# in applications using GLib" \
		>> /etc/profile.d/glib2-locale.sh && \
	echo 'export G_FILENAME_ENCODING=@locale' \
		>> /etc/profile.d/glib2-locale.sh && \
	\
	cd .. && \
	rm -rf $(GLIB2)/* && \
	make P=$(GLIB2) log-package

$(LIBIDL):  $(GLIB2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBIDL).tar.bz2 && \
	chmod 755 $(LIBIDL) && \
	chown -R 0:0 $(LIBIDL) && \
	cd $(LIBIDL) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBIDL)/.libs $(LIBIDL)/.deps $(LIBIDL)/* && \
	make P=$(LIBIDL) log-package

$(LIBCROCO):  $(GLIB2) $(LIBXML2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBCROCO).tar.bz2 && \
	chmod 755 $(LIBCROCO) && \
	chown -R 0:0 $(LIBCROCO) && \
	cd $(LIBCROCO) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(LIBCROCO)/examples && \
	install -v -m644 README docs/usage.txt \
		/usr/share/doc/$(LIBCROCO) && \
	install -v -m644 docs/examples/*.c \
		/usr/share/doc/$(LIBCROCO)/examples && \
	\
	cd .. && \
	rm -rf $(LIBCROCO)/* && \
	make P=$(LIBCROCO) log-package

$(LIBGSF):  $(GLIB2) $(LIBXML2) $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGSF).tar.bz2 && \
	chmod 755 $(LIBGSF) && \
	chown -R 0:0 $(LIBGSF) && \
	cd $(LIBGSF) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGSF)/* && \
	make P=$(LIBGSF) log-package

$(LIBGLADE):  $(LIBXML2) $(GTK2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGLADE).tar.bz2 && \
	chmod 755 $(LIBGLADE) && \
	chown -R 0:0 $(LIBGLADE) && \
	cd $(LIBGLADE) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBGLADE)-no-depreciated.patch && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGLADE)/.libs $(LIBGLADE)/.deps $(LIBGLADE)/* && \
	make P=$(LIBGLADE) log-package

$(LIBESMTP):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBESMTP).tar.bz2 && \
	chmod 755 $(LIBESMTP) && \
	chown -R 0:0 $(LIBESMTP) && \
	cd $(LIBESMTP) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBESMTP)/.deps $(LIBESMTP)/.libs $(LIBESMTP)/* && \
	make P=$(LIBESMTP) log-package

$(LZO):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LZO).tar.gz && \
	chmod 755 $(LZO) && \
	chown -R 0:0 $(LZO) && \
	cd $(LZO) && \
	\
	./configure --prefix=/usr --enable-shared && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(LZO) && \
	install -v -m644 doc/* /usr/share/doc/$(LZO) && \
	\
	cd .. && \
	rm -rf $(LZO)/* && \
	make P=$(LZO) log-package

$(LIBUSB): 
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBUSB).tar.bz2 && \
	chmod 755 $(LIBUSB) && \
	chown -R 0:0 $(LIBUSB) && \
	cd $(LIBUSB) && \
	\
	./configure --prefix=/usr --disable-build-docs && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBUSB)/.libs $(LIBUSB)/.deps $(LIBUSB)/* && \
	make P=$(LIBUSB) log-package

$(LIBUSB-COMPAT): $(LIBUSB)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBUSB-COMPAT).tar.bz2 && \
	chmod 755 $(LIBUSB-COMPAT) && \
	chown -R 0:0 $(LIBUSB-COMPAT) && \
	cd $(LIBUSB-COMPAT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-build-docs && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBUSB-COMPAT)/* && \
	make P=$(LIBUSB-COMPAT) log-package

$(ISO-CODES):  $(PYTHON)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ISO-CODES).tar.bz2 && \
	chmod 755 $(ISO-CODES) && \
	chown -R 0:0 $(ISO-CODES) && \
	cd $(ISO-CODES) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ISO-CODES)/* && \
	make P=$(ISO-CODES) log-package

$(GMIME-OLD):  $(GLIB2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GMIME-OLD).tar.bz2 && \
	chmod 755 $(GMIME-OLD) && \
	chown -R 0:0 $(GMIME-OLD) && \
	cd $(GMIME-OLD) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(GMIME-OLD) && \
	echo install -v -m644 README docs{,/tutorial}/gmime* \
                    /usr/share/doc/$(GMIME-OLD) && \
	\
	cd .. && \
	rm -rf $(GMIME-OLD)/* && \
	make P=$(GMIME-OLD) log-package

$(GMIME):  $(GLIB2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GMIME).tar.bz2 && \
	chmod 755 $(GMIME) && \
	chown -R 0:0 $(GMIME) && \
	cd $(GMIME) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(GMIME) && \
	echo install -v -m644 README docs{,/tutorial}/gmime* \
                    /usr/share/doc/$(GMIME) && \
	\
	cd .. && \
	rm -rf $(GMIME)/* && \
	make P=$(GMIME) log-package

$(LIBIDN):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBIDN).tar.gz && \
	chmod 755 $(LIBIDN) && \
	chown -R 0:0 $(LIBIDN) && \
	cd $(LIBIDN) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	find doc -name "Makefile*" -exec rm {} \; && \
	\
	install -v -m755 -d \
		/usr/share/doc/$(LIBIDN)/{api,java,specifications,tld} && \
	install -v -m644 doc/components* \
		doc/libidn.{pdf,ps,html} \
		/usr/share/doc/$(LIBIDN) && \
	install -v -m644 doc/reference/html/* \
		/usr/share/doc/$(LIBIDN)/api && \
	install -v -m644 doc/specifications/* \
		/usr/share/doc/$(LIBIDN)/specifications && \
	install -v -m644 doc/tld/* /usr/share/doc/$(LIBIDN)/tld && \
	cp -v -R doc/java/* /usr/share/doc/$(LIBIDN)/java && \
	\
	cd .. && \
	rm -rf $(LIBIDN)/* && \
	make P=$(LIBIDN) log-package

$(DBUS-GLIB):  $(DBUS) $(GLIB2) $(EXPAT)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DBUS-GLIB).tar.gz && \
	chmod 755 $(DBUS-GLIB) && \
	chown -R 0:0 $(DBUS-GLIB) && \
	cd $(DBUS-GLIB) && \
	\
	./configure --prefix=/usr \
		--localstatedir=/var \
		--sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DBUS-GLIB)/* && \
	make P=$(DBUS-GLIB) log-package

$(DBUS-PYTHON):  $(PYTHON) $(DBUS-GLIB)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DBUS-PYTHON).tar.gz && \
	chmod 755 $(DBUS-PYTHON) && \
	chown -R 0:0 $(DBUS-PYTHON) && \
	cd $(DBUS-PYTHON) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DBUS-PYTHON)/* && \
	make P=$(DBUS-PYTHON) log-package

$(DBUS-QT3):  $(DBUS) $(QT3)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DBUS-QT3).tar.bz2 && \
	chmod 755 $(DBUS-QT3) && \
	chown -R 0:0 $(DBUS-QT3) && \
	cd $(DBUS-QT3) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DBUS-QT3)/* && \
	make P=$(DBUS-QT3) log-package

$(EGGDBUS):  $(DBUS-GLIB) $(DOCBOOK-XSL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(EGGDBUS).tar.gz && \
	chmod 755 $(EGGDBUS) && \
	chown -R 0:0 $(EGGDBUS) && \
	cd $(EGGDBUS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-man-pages && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(EGGDBUS)/* && \
	make P=$(EGGDBUS) log-package

$(DBUS):  $(EXPAT)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DBUS).tar.gz && \
	chmod 755 $(DBUS) && \
	chown -R 0:0 $(DBUS) && \
	cd $(DBUS) && \
	\
	groupadd -g 18 messagebus; \
	useradd -c "D-BUS Message Daemon User" -d /dev/null \
		-u 18 -g messagebus -s /bin/false messagebus; \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(DBUS) && \
	install -v -m644 doc/{TODO,*.{dtd,xml,xsl,txt,c}} \
		/usr/share/doc/$(DBUS) && \
	\
	cd .. && \
	rm -rf $(DBUS)/* && \
	make P=$(DBUS) log-package

$(LIBPTHREAD-STUBS): 
	set +h && \
	\
	tar jxvf $(XORG-TARBALLS)/misc/$(LIBPTHREAD-STUBS).tar.bz2 && \
	chmod 755 $(LIBPTHREAD-STUBS) && \
	chown -R 0:0 $(LIBPTHREAD-STUBS) && \
	cd $(LIBPTHREAD-STUBS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBPTHREAD-STUBS)/.deps $(LIBPTHREAD-STUBS)/* && \
	make P=$(LIBPTHREAD-STUBS) log-package

$(PTH):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PTH).tar.gz && \
	chmod 755 $(PTH) && \
	chown -R 0:0 $(PTH) && \
	cd $(PTH) && \
	\
	./configure --prefix=/usr && \
	echo no make -j && \
	make && \
	make install && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(PTH) && \
	install -v -m644 README PORTING SUPPORT TESTS \
		/usr/share/doc/$(PTH) && \
	\
	cd .. && \
	rm -rf $(PTH)/* && \
	make P=$(PTH) log-package

$(LIBASSUAN):  $(PTH)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBASSUAN).tar.bz2 && \
	chmod 755 $(LIBASSUAN) && \
	chown -R 0:0 $(LIBASSUAN) && \
	cd $(LIBASSUAN) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 -D README /usr/share/doc/$(LIBASSUAN)/README && \
	\
	cd .. && \
	rm -rf $(LIBASSUAN)/* && \
	make P=$(LIBASSUAN) log-package

$(LIBGPG-ERROR):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGPG-ERROR).tar.bz2 && \
	chmod 755 $(LIBGPG-ERROR) && \
	chown -R 0:0 $(LIBGPG-ERROR) && \
	cd $(LIBGPG-ERROR) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 -D README /usr/share/doc/$(LIBGPG-ERROR)/README && \
	\
	cd .. && \
	rm -rf $(LIBGPG-ERROR)/* && \
	make P=$(LIBGPG-ERROR) log-package

$(LIBGCRYPT):  $(LIBGPG-ERROR)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGCRYPT).tar.bz2 && \
	chmod 755 $(LIBGCRYPT) && \
	chown -R 0:0 $(LIBGCRYPT) && \
	cd $(LIBGCRYPT) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 -D README /usr/share/doc/$(LIBGCRYPT)/README && \
	\
	cd .. && \
	rm -rf $(LIBGCRYPT)/* && \
	make P=$(LIBGCRYPT) log-package

$(LIBKSBA):  $(LIBGPG-ERROR)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBKSBA).tar.bz2 && \
	chmod 755 $(LIBKSBA) && \
	chown -R 0:0 $(LIBKSBA) && \
	cd $(LIBKSBA) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 -D README /usr/share/doc/$(LIBKSBA)/README && \
	\
	cd .. && \
	rm -rf $(LIBKSBA)/* && \
	make P=$(LIBKSBA) log-package

$(ENCHANT):  $(GLIB2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ENCHANT).tar.gz && \
	chmod 755 $(ENCHANT) && \
	chown -R 0:0 $(ENCHANT) && \
	cd $(ENCHANT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ENCHANT)/* && \
	make P=$(ENCHANT) log-package

$(LIBGDATA):  $(LIBSOUP)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGDATA).tar.bz2 && \
	chmod 755 $(LIBGDATA) && \
	chown -R 0:0 $(LIBGDATA) && \
	cd $(LIBGDATA) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGDATA)/* && \
	make P=$(LIBGDATA) log-package

$(LIBSOUP):  $(GLIB2) $(LIBXML2) $(LIBPROXY) $(SQLITE) $(GNOME-KEYRING) \
	$(GNUTLS)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBSOUP).tar.bz2 && \
	chmod 755 $(LIBSOUP) && \
	chown -R 0:0 $(LIBSOUP) && \
	cd $(LIBSOUP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBSOUP)/* && \
	make P=$(LIBSOUP) log-package

$(SQLITE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SQLITE).tar.bz2 && \
	chmod 755 $(SQLITE) && \
	chown -R 0:0 $(SQLITE) && \
	cd $(SQLITE) && \
	\
	CFLAGS="-g -O2 -DSQLITE_SECURE_DELETE -DSQLITE_ENABLE_UNLOCK_NOTIFY=1" \
		./configure --prefix=/usr \
				--enable-threadsafe \
				--enable-readline \
				--enable-dynamic-extensions && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SQLITE)/* && \
	rm -rf $(SQLITE)/.libs && \
	make P=$(SQLITE) log-package

$(NSPR):
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(NSPR).tar.gz && \
	chmod 755 $(NSPR) && \
	chown -R 0:0 $(NSPR) && \
	cd $(NSPR) && \
	\
	cd mozilla/nsprpub && \
	./configure --prefix=/usr \
		--with-mozilla \
		--with-pthreads && \
	make -j2 && \
	make install && \
	cp -v -LR dist/include/nspr /usr/include && \
	rm -v -f /usr/bin/{prerr.properties,compile-et.pl} && \
	\
	cd ../.. && \
	\
	cd .. && \
	rm -rf $(NSPR)/* && \
	make P=$(NSPR) log-package

##
## Begin Graphics and Font Libraries
##

$(LIBJPEG):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBJPEG).tar.gz && \
	chmod 755 $(LIBJPEG) && \
	chown -R 0:0 $(LIBJPEG) && \
	cd $(LIBJPEG) && \
	\
	./configure --prefix=/usr --enable-static --enable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBJPEG)/.libs $(LIBJPEG)/* && \
	make P=$(LIBJPEG) log-package

$(LIBTIFF):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBTIFF).tar.gz && \
	chmod 755 $(LIBTIFF) && \
	chown -R 0:0 $(LIBTIFF) && \
	cd $(LIBTIFF) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBTIFF)/* && \
	make P=$(LIBTIFF) log-package

$(GIFLIB):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GIFLIB).tar.bz2 && \
	chmod 755 $(GIFLIB) && \
	chown -R 0:0 $(GIFLIB) && \
	cd $(GIFLIB) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(GIFLIB)/html && \
	install -v -m644 doc/*.{png,html} \
		/usr/share/doc/$(GIFLIB)/html && \
	install -v -m644 doc/*.txt \
		/usr/share/doc/$(GIFLIB) && \
	\
	cd .. && \
	rm -rf $(GIFLIB)/* && \
	make P=$(GIFLIB) log-package

$(LCMS):  $(LIBTIFF) $(PYTHON) $(LIBJPEG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LCMS).tar.gz && \
	chmod 755 $(LCMS) && \
	chown -R 0:0 $(LCMS) && \
	cd $(LCMS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(LCMS) && \
	install -v -m644 README.1ST doc/* /usr/share/doc/$(LCMS) && \
	\
	cd .. && \
	rm -rf $(LCMS)/* && \
	make P=$(LCMS) log-package

$(LIBMNG):  $(LCMS) $(LIBJPEG)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBMNG).tar.bz2 && \
	chmod 755 $(LIBMNG) && \
	chown -R 0:0 $(LIBMNG) && \
	cd $(LIBMNG) && \
	\
	cp makefiles/makefile.linux Makefile && \
	make -j2 && \
	make prefix=/usr install && \
	echo OK install -v -m644 doc/man/*.3 /usr/share/man/man3 && \
	echo OK install -v -m644 doc/man/*.5 /usr/share/man/man5 && \
	echo OK install -v -m755 -d /usr/share/doc/$(LIBMNG) && \
	echo OK install -v -m644 doc/*.{png,txt} /usr/share/doc/$(LIBMNG) && \
	\
	cd .. && \
	rm -rf $(LIBMNG)/* && \
	make P=$(LIBMNG) log-package

$(LIBART):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBART).tar.bz2 && \
	chmod 755 $(LIBART) && \
	chown -R 0:0 $(LIBART) && \
	cd $(LIBART) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBART)/.libs $(LIBART)/.deps $(LIBART)/* && \
	make P=$(LIBART) log-package

$(LIBRSVG): $(GTK2) $(LIBXML2) $(LIBCROCO) $(LIBGSF)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBRSVG).tar.bz2 && \
	chmod 755 $(LIBRSVG) && \
	chown -R 0:0 $(LIBRSVG) && \
	cd $(LIBRSVG) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc  \
		--disable-mozilla-plugin && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBRSVG)/.libs $(LIBRSVG)/.deps $(LIBRSVG)/* && \
	make P=$(LIBRSVG) log-package

$(AALIB):  $(SLANG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AALIB).tar.gz && \
	chmod 755 $(AALIB) && \
	chown -R 0:0 $(AALIB) && \
	cd $(AALIB) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AALIB)/* && \
	make P=$(AALIB) log-package

$(IMLIB2): $(FREETYPE) $(LIBPNG) $(LIBJPEG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IMLIB2).tar.gz && \
	chmod 755 $(IMLIB2) && \
	chown -R 0:0 $(IMLIB2) && \
	cd $(IMLIB2) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(IMLIB2) && \
	install -v -m644 doc/{*.gif,index.html} \
		/usr/share/doc/$(IMLIB2) && \
	\
	cd .. && \
	rm -rf $(IMLIB2)/* && \
	make P=$(IMLIB2) log-package

$(LIBEXIF):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBEXIF).tar.bz2 && \
	chmod 755 $(LIBEXIF) && \
	chown -R 0:0 $(LIBEXIF) && \
	cd $(LIBEXIF) && \
	\
	./configure --prefix=/usr \
		--with-doc-dir=/usr/share/doc/$(LIBEXIF) && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBEXIF)/* && \
	make P=$(LIBEXIF) log-package

$(FRIBIDI):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FRIBIDI).tar.gz && \
	chmod 755 $(FRIBIDI) && \
	chown -R 0:0 $(FRIBIDI) && \
	cd $(FRIBIDI) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(FRIBIDI)-test_fixes-1.patch && \
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FRIBIDI)/.libs $(FRIBIDI)/.deps $(FRIBIDI)/* && \
	make P=$(FRIBIDI) log-package

$(PIXMAN):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PIXMAN).tar.gz && \
	chmod 755 $(PIXMAN) && \
	chown -R 0:0 $(PIXMAN) && \
	cd $(PIXMAN) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--enable-zlib \
		--disable-utils && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(PIXMAN) && \
	install -v -m644 README* /usr/share/doc/$(PIXMAN) && \
	\
	cd .. && \
	rm -rf $(PIXMAN)/* && \
	make P=$(PIXMAN) log-package

$(CLUTTER):  $(ATK) $(CAIRO) $(COGL) $(GDK-PIXBUF) $(JSON-GLIB) $(PANGO)
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(CLUTTER).tar.xz| tar xvf - && \
	chmod 755 $(CLUTTER) && \
	chown -R 0:0 $(CLUTTER) && \
	cd $(CLUTTER) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(CLUTTER)/* && \
	make P=$(CLUTTER) log-package

$(CLUTTER-GST):  $(CLUTTER) $(GSTREAMER)
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(CLUTTER-GST).tar.xz| tar xvf - && \
	chmod 755 $(CLUTTER-GST) && \
	chown -R 0:0 $(CLUTTER-GST) && \
	cd $(CLUTTER-GST) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(CLUTTER-GST)/* && \
	make P=$(CLUTTER-GST) log-package

$(CLUTTER-GTK):  $(CLUTTER) $(GTK3)
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(CLUTTER-GTK).tar.xz| tar xvf - && \
	chmod 755 $(CLUTTER-GTK) && \
	chown -R 0:0 $(CLUTTER-GTK) && \
	cd $(CLUTTER-GTK) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(CLUTTER-GTK)/* && \
	make P=$(CLUTTER-GTK) log-package

$(MX):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(MX).tar.bz2 && \
	chmod 755 $(MX) && \
	chown -R 0:0 $(MX) && \
	cd $(MX) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(MX)/* && \
	make P=$(STUB) log-package

$(COGL):  $(GLIB2)
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(COGL).tar.xz| tar xvf - && \
	chmod 755 $(COGL) && \
	chown -R 0:0 $(COGL) && \
	cd $(COGL) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(COGL)/* && \
	make P=$(COGL) log-package

$(JSON-GLIB):  $(GLIB2)
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(JSON-GLIB).tar.xz| tar xvf - && \
	chmod 755 $(JSON-GLIB) && \
	chown -R 0:0 $(JSON-GLIB) && \
	cd $(JSON-GLIB) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(JSON-GLIB)/* && \
	make P=$(JSON-GLIB) log-package

$(LIBPEAS): 
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(LIBPEAS).tar.xz| tar xvf - && \
	chmod 755 $(LIBPEAS) && \
	chown -R 0:0 $(LIBPEAS) && \
	cd $(LIBPEAS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install -j2 && \
	\
	cd .. && \
	rm -rf $(LIBPEAS)/* && \
	make P=$(LIBPEAS) log-package

#
# Begin BLFS General Utilities
#

$(BC):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BC).tar.gz && \
	chmod 755 $(BC) && \
	chown -R 0:0 $(BC) && \
	cd $(BC) && \
	\
	sed -i '/PROTO.*readline/d' bc/scan.l && \
	sed -i '/flex -I8/s/8//' configure && \
	sed -i '/stdlib/a #include <string.h>' lib/number.c && \
	sed -i 's/program.*save/static &/' bc/load.c && \
	./configure --prefix=/usr --with-readline && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(BC)/* && \
	make P=$(BC) log-package

$(IMAGEMAGICK):  $(PKG-CONFIG) $(CUPS) $(LPRNG) $(SANE-BACKENDS) $(WGET) \
	$(LCMS) $(LIBEXIF) $(LIBJPEG) $(LIBPNG) $(LIBRSVG) $(LIBXML2) \
	$(LIBTIFF) $(FREETYPE) $(AVIFILE) $(A52DEC) $(GRAPHVIZ) $(XZ)

	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(IMAGEMAGICK).tar.xz| tar xvf - && \
	chmod 755 $(IMAGEMAGICK) && \
	chown -R 0:0 $(IMAGEMAGICK) && \
	cd $(IMAGEMAGICK) && \
	\
	./configure --prefix=/usr --with-modules \
		--disable-static \
		--with-perl=yes && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IMAGEMAGICK)/* && \
	make P=$(IMAGEMAGICK) log-package

$(HD2U):  $(POPT)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HD2U).tgz && \
	chmod 755 $(HD2U) && \
	chown -R 0:0 $(HD2U) && \
	cd $(HD2U) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HD2U)/* && \
	make P=$(HD2U) log-package

$(SCROLLKEEPER):  $(LIBXSLT) $(DOCBOOK-XML) $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SCROLLKEEPER).tar.bz2 && \
	chmod 755 $(SCROLLKEEPER) && \
	chown -R 0:0 $(SCROLLKEEPER) && \
	cd $(SCROLLKEEPER) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--disable-static \
		--with-omfdirs=/usr/share/omf && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SCROLLKEEPER)/* && \
	make P=$(SCROLLKEEPER) log-package

$(INTLTOOL):  $(XML-PARSER)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(INTLTOOL).tar.gz && \
	chmod 755 $(INTLTOOL) && \
	chown -R 0:0 $(INTLTOOL) && \
	cd $(INTLTOOL) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 -D doc/I18N-HOWTO \
		/usr/share/doc/$(INTLTOOL)/I18N-HOWTO && \
	\
	cd .. && \
	rm -rf $(INTLTOOL)/* && \
	make P=$(INTLTOOL) log-package

$(SCREEN):  $(PAM)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SCREEN).tar.gz && \
	chmod 755 $(SCREEN) && \
	chown -R 0:0 $(SCREEN) && \
	cd $(SCREEN) && \
	\
	./configure --prefix=/usr --with-socket-dir=/var/run/screen \
		--with-sys-screenrc=/etc/screenrc && \
	sed -i -e "s%/usr/local/etc/screenrc%/etc/screenrc%" {etc,doc}/* && \
	make -j2 && \
	make install && \
	install -m 644 etc/screenrc /etc/screenrc && \
	\
	cd .. && \
	rm -rf $(SCREEN)/* && \
	make P=$(SCREEN) log-package

$(XSCREENSAVER):  $(BC) $(LIBGLADE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XSCREENSAVER).tar.gz && \
	chmod 755 $(XSCREENSAVER) && \
	chown -R 0:0 $(XSCREENSAVER) && \
	cd $(XSCREENSAVER) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/lib && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XSCREENSAVER)/* && \
	make P=$(XSCREENSAVER) log-package

$(GPERF):
	set +h && \
	\
	tar zxf $(JLFS-TARBALLS)/$(GPERF).tar.gz && \
	chmod 755 $(GPERF) && \
	chown -R 0:0 $(GPERF) && \
	cd $(GPERF) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GPERF)/* && \
	make P=$(GPERF) log-package

$(XCB-UTIL): $(GPERF)
	set +h && \
	\
	tar jvxf $(JLFS-TARBALLS)/$(XCB-UTIL).tar.bz2 && \
	chmod 755 $(XCB-UTIL) && \
	chown -R 0:0 $(XCB-UTIL) && \
	cd $(XCB-UTIL) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XCB-UTIL)/* && \
	make P=$(XCB-UTIL) log-package

#
# Begin BLFS System Utilities
#

$(GPM):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GPM).tar.bz2 && \
	chmod 755 $(GPM) && \
	chown -R 0:0 $(GPM) && \
	cd $(GPM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	echo obsolete LDFLAGS="-lm" make && \
	make -j2 && \
	make install && \
	\
	install-info --dir-file=/usr/share/info/dir \
		/usr/share/info/gpm.info && \
	ln -v -s libgpm.so.2.1.0 /usr/lib/libgpm.so && \
	install -v -m644 conf/gpm-root.conf /etc && \
	install -v -m755 -d /usr/share/doc/gpm-1.20.6 && \
	chmod -v 755 doc/{changes,support} && \
	chmod -v 644 doc/{changes/*,support/*,FAQ,HACK_GPM,README*} && \
	cp -v -R doc/{FAQ,HACK_GPM,README*,changes,support} \
		/usr/share/doc/$(GPM) && \
	ldconfig && \
	\
	cd .. && \
	rm -rf $(GPM)/* && \
	make P=$(GPM) log-package

$(FCRON):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FCRON).tar.gz && \
	chmod 755 $(FCRON) && \
	chown -R 0:0 $(FCRON) && \
	cd $(FCRON) && \
	\
	groupadd -g 22 fcron; \
	useradd -d /dev/null -c "Fcron User" -g fcron -s /bin/false \
		-u 22 fcron; \
	./configure --prefix=/usr --sysconfdir=/etc \
		--localstatedir=/var --without-sendmail \
		--with-boot-install=no  && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FCRON)/* && \
	make P=$(FCRON) log-package

$(HDPARM):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HDPARM).tar.gz && \
	chmod 755 $(HDPARM) && \
	chown -R 0:0 $(HDPARM) && \
	cd $(HDPARM) && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HDPARM)/* && \
	make P=$(HDPARM) log-package

$(WHICH):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WHICH).tar.gz && \
	chmod 755 $(WHICH) && \
	chown -R 0:0 $(WHICH) && \
	cd $(WHICH) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(WHICH)/* && \
	make P=$(WHICH) log-package

$(UNZIP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(UNZIP).tar.gz && \
	chmod 755 $(UNZIP) && \
	chown -R 0:0 $(UNZIP) && \
	cd $(UNZIP) && \
	\
	make -f unix/Makefile LOCAL_UNZIP=-D_FILE_OFFSET_BITS=64 linux && \
	make prefix=/usr install && \
	\
	cd .. && \
	rm -rf $(UNZIP)/* && \
	make P=$(UNZIP) log-package

$(ZIP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ZIP).tar.gz && \
	chmod 755 $(ZIP) && \
	chown -R 0:0 $(ZIP) && \
	cd $(ZIP) && \
	\
	make -f unix/Makefile generic_gcc && \
	make prefix=/usr -f unix/Makefile install && \
	\
	cd .. && \
	rm -rf $(ZIP)/* && \
	make P=$(ZIP) log-package

$(PCIUTILS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PCIUTILS).tar.bz2 && \
	chmod 755 $(PCIUTILS) && \
	chown -R 0:0 $(PCIUTILS) && \
	cd $(PCIUTILS) && \
	\
	make PREFIX=/usr ZLIB=no && \
	make PREFIX=/usr ZLIB=no install && \
	make PREFIX=/usr ZLIB=no install-lib && \
	\
	cd .. && \
	rm -rf $(PCIUTILS)/.git $(PCIUTILS)/* && \
	make P=$(PCIUTILS) log-package

$(USBUTILS):  $(LIBUSB) $(LIBUSB-COMPAT)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(USBUTILS).tar.gz && \
	chmod 755 $(USBUTILS) && \
	chown -R 0:0 $(USBUTILS) && \
	cd $(USBUTILS) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	./configure --prefix=/usr \
		--disable-zlib && \
	make -j2 && \
	make install && \
	install -v -m755 update-usbids.sh /usr/sbin/update-usbids && \
	\
	cd .. && \
	rm -rf $(USBUTILS)/* && \
	make P=$(USBUTILS) log-package

$(CPIO):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(CPIO).tar.bz2 && \
	chmod 755 $(CPIO) && \
	chown -R 0:0 $(CPIO) && \
	cd $(CPIO) && \
	\
	./configure CPIO_MT_PROG=mt \
            --prefix=/usr \
            --bindir=/bin \
            --libexecdir=/tmp \
            --with-rmt=/usr/sbin/rmt && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CPIO)/* && \
	make P=$(CPIO) log-package

$(SYSSTAT):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SYSSTAT).tar.bz2 && \
	chmod 755 $(SYSSTAT) && \
	chown -R 0:0 $(SYSSTAT) && \
	cd $(SYSSTAT) && \
	\
	cp -av $(JLFS-CONFIGS)/$(SYSSTAT).config build/CONFIG && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SYSSTAT)/* && \
	make P=$(SYSSTAT) log-package

#$(HAL):  $(DBUS-GLIB) $(XML-PARSER) $(PYTHON) $(PCIUTILS) $(USBUTILS)
#	set +h && \
#	\
#	tar zxvf $(JLFS-TARBALLS)/$(HAL).tar.gz && \
#	chmod 755 $(HAL) && \
#	chown -R 0:0 $(HAL) && \
#	cd $(HAL) && \
#	\
#	groupadd -g 19 haldaemon; \
#	useradd -c "HAL Daemon User" -d /dev/null -u 19 \
#		-g haldaemon -s /bin/false haldaemon; \
#	\
#	patch -Np1 -i $(JLFS-PATCHES)/$(HAL)-no-glib-dot-h-for-you.patch && \
#	\
#	./configure --prefix=/usr \
#		--sysconfdir=/etc \
#		--libexecdir=/usr/lib/hal \
#		--docdir=/usr/share/$(HAL) \
#		--localstatedir=/var \
#		--enable-policy-kit=no && \
#	\
#	make -j2 && \
#	make install && \
#	\
#	cd .. && \
#	rm -rf $(HAL)/* && \
#	make P=$(HAL) log-package
#
#$(HAL-INFO):  $(HAL)
#	set +h && \
#	\
#	tar xvf $(JLFS-TARBALLS)/$(HAL-INFO).tar.gz && \
#	chmod 755 $(HAL-INFO) && \
#	chown -R 0:0 $(HAL-INFO) && \
#	cd $(HAL-INFO) && \
#	\
#	./configure --prefix=/usr --sysconfdir=/etc && \
#	make install && \
#	\
#	cd .. && \
#	rm -rf $(HAL-INFO)/* && \
#	make P=$(HAL-INFO) log-package

$(DEVICE-MAPPER):
	set +h && \
	\
	tar xzvf $(JLFS-TARBALLS)/$(DEVICE-MAPPER).tgz && \
	chmod 755 $(DEVICE-MAPPER) && \
	chown -R 0:0 $(DEVICE-MAPPER) && \
	cd $(DEVICE-MAPPER) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--libdir=/lib --sbindir=/sbin && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DEVICE-MAPPER)/* && \
	make P=$(DEVICE-MAPPER) log-package

#
# Begin BLFS Programming Tools
#

$(EXPECT):  $(TCL) $(TK)
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(EXPECT).tar.bz2 && \
	chmod 755 $(EXPECT) && \
	chown -R 0:0 $(EXPECT) && \
	cd $(EXPECT) && \
	\
	./configure --prefix=/usr \
            --with-tcl=/usr/lib \
            --with-tclinclude=/usr/include \
            --enable-shared && \
	make -j2 && \
	make install && \
	ln -sf ../libexpect$(EXPECT-VER).a /usr/lib/expect$(EXPECT-VER) && \
	\
	cd .. && \
	rm -rf $(EXPECT)/* && \
	make P=$(EXPECT) log-package

$(GCC3):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GCC3).tar.bz2 && \
	chmod 755 $(GCC3) && \
	chown -R 0:0 $(GCC3) && \
	cd $(GCC3) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(GCC3)-no_fixincludes-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(GCC3)-linkonce-1.patch && \
	mkdir -p ../gcc-build && \
	cd ../gcc-build && \
	../$(GCC3)/configure --prefix=/opt/$(GCC3) \
		--enable-shared --enable-languages=c,c++ \
		--enable-threads=posix && \
	make bootstrap && \
	make install && \
	\
	mv -v /opt/$(GCC3)/lib/libstdc++.so.5* /usr/lib && \
	ln -v -sf /usr/lib/libstdc++.so.5.0.7 /opt/$(GCC3)/lib && \
	ln -v -sf libstdc++.so.5.0.7 /opt/$(GCC3)/lib/libstdc++.so.5 && \
	chown -v -R root:root \
		/opt/$(GCC3)/lib/gcc-lib/i686-pc-linux-gnu/$(GCC3-VER)/include && \
	\
	cd .. && \
	rm -rf $(GCC3)/.cvsignore $(GCC3)/.brik $(GCC3)/* gcc-build && \
	make P=$(GCC3) log-package

$(GCC4-OLD):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GCC4-OLD).tar.bz2 && \
	chmod 755 $(GCC4-OLD) && \
	chown -R 0:0 $(GCC4-OLD) && \
	cd $(GCC4-OLD) && \
	\
	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in && \
	sed -i 's/^XCFLAGS =/XCFLAGS = -fomit-frame-pointer/' gcc/Makefile.in && \
	sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in && \
	sed -i 's/@have_mktemp_command@/yes/' gcc/gccbug.in && \
	\
	mkdir -v ../$(GCC4-OLD)-build && \
	cd ../$(GCC4-OLD)-build && \
	\
	../$(GCC4-OLD)/configure --prefix=/opt/$(GCC4-OLD) \
		--libexecdir=/usr/lib --enable-shared \
		--enable-threads=posix --enable-__cxa_atexit \
		--enable-clocale=gnu --enable-languages=c,c++ && \
	make -j2 && \
	make install && \
	\
	echo 'main(){}' > dummy.c && \
	cc dummy.c -v -Wl,--verbose &> dummy.log && \
	readelf -l a.out | grep ': /lib' && \
	\
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log && \
	grep -B3 '^ /usr/include' dummy.log && \
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' && \
	grep "/lib/libc.so.6 " dummy.log && \
	grep found dummy.log && \
	rm -v dummy.c a.out dummy.log && \
	\
	rm -f /usr/lib/libstdc++.so.6.0.14-gdb.py && \
	\
	cd .. && \
	rm -rf $(GCC4-OLD)-build $(GCC4-OLD)/* && \
	make P=$(GCC4-OLD) log-package

$(NASM):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NASM).tar.bz2 && \
	chmod 755 $(NASM) && \
	chown -R 0:0 $(NASM) && \
	cd $(NASM) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(NASM)-security_fix-1.patch && \
	./configure --prefix=/usr && \
	make -j2 && \
	make -C rdoff/doc && \
	make -C rdoff/doc html && \
	\
	make install && \
	make install_rdf && \
	install -v -m644 rdoff/doc/rdoff.info /usr/share/info && \
	install -v -m755 -d /usr/share/doc/nasm/html && \
	install -v -m644 rdoff/doc/v1-v2.txt /usr/share/doc/nasm && \
	cp -av -R rdoff/doc/rdoff /usr/share/doc/nasm/html && \
	\
	cd .. && \
	rm -rf $(NASM)/* && \
	make P=$(NASM) log-package

$(TK-PERL):  $(TK) $(LIBJPEG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TK-PERL).tar.gz && \
	chmod 755 $(TK-PERL) && \
	chown -R 0:0 $(TK-PERL) && \
	cd $(TK-PERL) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TK-PERL)/* && \
	make P=$(TK-PERL) log-package

$(PHP5):  $(APACHE) $(MYSQL) $(MCRYPT) $(LIBMHASH)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PHP5).tar.bz2 && \
	chmod 755 $(PHP5) && \
	chown -R 0:0 $(PHP5) && \
	cd $(PHP5) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--with-apxs2 \
		--enable-force-cgi-redirect \
		--enable-discard-path \
		--with-config-file-path=/etc \
		--with-zlib \
		--enable-bcmath \
		--with-bz2 \
		--enable-calendar \
		--enable-dba=shared \
		--enable-exif \
		--enable-ftp \
		--with-gettext \
		--enable-mbstring \
		--with-ncurses \
		--with-mysql \
		--with-mcrypt \
		--with-mhash \
		--with-mysqli \
		--with-readline && \
	make -j2 && \
	make install && \
	\
	install -v -m644 php.ini-production /etc/php.ini && \
	install -v -m755 -d /usr/share/doc/$(PHP5) && \
	install -v -m644 CODING_STANDARDS EXTENSIONS INSTALL NEWS \
		README* TODO* UPGRADING php.gif \
		/usr/share/doc/$(PHP5) && \
	ln -v -sfn /usr/lib/php/doc/Archive_Tar/docs/Archive_Tar.txt \
		/usr/share/doc/$(PHP5) && \
	\
	cd .. && \
	rm -rf $(PHP5)/.libs $(PHP5)/.gdbinit $(PHP5)/* && \
	make P=$(PHP5) log-package

$(TCL):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(TCL)-src.tar.gz && \
	chmod 755 $(TCL) && \
	chown -R 0:0 $(TCL) && \
	touch $(TCL) && \
	cd $(TCL) && \
	\
	cd unix && \
	./configure --prefix=/usr --enable-threads --mandir=/usr/share/man && \
	make -j2 && \
	\
	sed -i \
		-e "s@^\(TCL_SRC_DIR='\).*@\1/usr/include'@" \
		-e "/TCL_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" \
	tclConfig.sh && \
	\
	make install && \
	make install-private-headers && \
	ln -v -sfn tclsh8.5 /usr/bin/tclsh && \
	chmod -v 755 /usr/lib/libtcl8.5.so && \
	\
	cd ../.. && \
	rm -rf $(TCL)/* && \
	make P=$(TCL) log-package

$(TK):  $(XORG7) $(TCL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TK)-src.tar.gz && \
	chmod 755 $(TK) && \
	chown -R 0:0 $(TK) && \
	cd $(TK) && \
	\
	cd unix && \
	./configure --prefix=/usr --enable-threads --mandir=/usr/share/man && \
	make -j2 && \
	\
	sed -i \
		-e "s@^\(TK_SRC_DIR='\).*@\1/usr/include'@" \
		-e "/TK_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" \
	tkConfig.sh && \
	\
	make install && \
	make install-private-headers && \
	ln -v -sf wish8.5 /usr/bin/wish && \
	chmod -v 755 /usr/lib/libtk8.5.so && \
	cd .. && \
	\
	cd .. && \
	rm -rf $(TK)/* && \
	make P=$(TK) log-package

$(RUBY):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(RUBY).tar.bz2 && \
	chmod 755 $(RUBY) && \
	chown -R 0:0 $(RUBY) && \
	cd $(RUBY) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/ruby-fix_stack_not_found.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-shared \
		--enable-pthread && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(RUBY)/* $(RUBY)/.ext && \
	make P=$(RUBY) log-package

#
# Begin BLFS Perl Modules
#

$(XML-PARSER):  $(EXPAT) $(LIBWWW-PERL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XML-PARSER).tar.gz && \
	chmod 755 $(XML-PARSER) && \
	chown -R 0:0 $(XML-PARSER) && \
	cd $(XML-PARSER) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XML-PARSER)/* && \
	make P=$(XML-PARSER) log-package

$(ARCHIVE-ZIP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ARCHIVE-ZIP).tar.gz && \
	chmod 755 $(ARCHIVE-ZIP) && \
	chown -R 0:0 $(ARCHIVE-ZIP) && \
	cd $(ARCHIVE-ZIP) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ARCHIVE-ZIP)/* && \
	make P=$(ARCHIVE-ZIP) log-package

$(IO-COMPRESS-ZLIB):  $(COMPRESS-RAW-ZLIB) $(IO-COMPRESS-BZIP2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IO-COMPRESS-ZLIB).tar.gz && \
	chmod 755 $(IO-COMPRESS-ZLIB) && \
	chown -R 0:0 $(IO-COMPRESS-ZLIB) && \
	cd $(IO-COMPRESS-ZLIB) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IO-COMPRESS-ZLIB)/* && \
	make P=$(IO-COMPRESS-ZLIB) log-package

$(COMPRESS-RAW-ZLIB):  $(IO-COMPRESS-BASE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(COMPRESS-RAW-ZLIB).tar.gz && \
	chmod 755 $(COMPRESS-RAW-ZLIB) && \
	chown -R 0:0 $(COMPRESS-RAW-ZLIB) && \
	cd $(COMPRESS-RAW-ZLIB) && \
	\
	sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|" \
		-e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" \
		-e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|" \
	config.in && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(COMPRESS-RAW-ZLIB)/* && \
	make P=$(COMPRESS-RAW-ZLIB) log-package

$(IO-COMPRESS-BASE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IO-COMPRESS-BASE).tar.gz && \
	chmod 755 $(IO-COMPRESS-BASE) && \
	chown -R 0:0 $(IO-COMPRESS-BASE) && \
	cd $(IO-COMPRESS-BASE) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IO-COMPRESS-BASE)/* && \
	make P=$(IO-COMPRESS-BASE) log-package

$(IO-COMPRESS-BZIP2):  $(COMPRESS-RAW-BZIP2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(IO-COMPRESS-BZIP2).tar.gz && \
	chmod 755 $(IO-COMPRESS-BZIP2) && \
	chown -R 0:0 $(IO-COMPRESS-BZIP2) && \
	cd $(IO-COMPRESS-BZIP2) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(IO-COMPRESS-BZIP2)/* && \
	make P=$(IO-COMPRESS-BZIP2) log-package

$(COMPRESS-RAW-BZIP2):  $(IO-COMPRESS-BASE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(COMPRESS-RAW-BZIP2).tar.gz && \
	chmod 755 $(COMPRESS-RAW-BZIP2) && \
	chown -R 0:0 $(COMPRESS-RAW-BZIP2) && \
	cd $(COMPRESS-RAW-BZIP2) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(COMPRESS-RAW-BZIP2)/* && \
	make P=$(COMPRESS-RAW-BZIP2) log-package

$(HTML-PARSER):  $(HTML-TAGSET) $(LIBWWW-PERL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HTML-PARSER).tar.gz && \
	chmod 755 $(HTML-PARSER) && \
	chown -R 0:0 $(HTML-PARSER) && \
	cd $(HTML-PARSER) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HTML-PARSER)/* && \
	make P=$(HTML-PARSER) log-package

$(HTML-TAGSET):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HTML-TAGSET).tar.gz && \
	chmod 755 $(HTML-TAGSET) && \
	chown -R 0:0 $(HTML-TAGSET) && \
	cd $(HTML-TAGSET) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HTML-TAGSET)/* && \
	make P=$(HTML-TAGSET) log-package

$(LIBWWW-PERL):  $(URI) $(COMPRESS-ZLIB) $(CRYPT-SSLEAY)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBWWW-PERL).tar.gz && \
	chmod 755 $(LIBWWW-PERL) && \
	chown -R 0:0 $(LIBWWW-PERL) && \
	cd $(LIBWWW-PERL) && \
	\
	perl Makefile.PL -n && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBWWW-PERL)/* && \
	make P=$(LIBWWW-PERL) log-package

$(URI):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(URI).tar.gz && \
	chmod 755 $(URI) && \
	chown -R 0:0 $(URI) && \
	cd $(URI) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(URI)/* && \
	make P=$(URI) log-package

$(CRYPT-SSLEAY):  $(OPENSSL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CRYPT-SSLEAY).tar.gz && \
	chmod 755 $(CRYPT-SSLEAY) && \
	chown -R 0:0 $(CRYPT-SSLEAY) && \
	cd $(CRYPT-SSLEAY) && \
	\
	yes "N"| perl Makefile.PL --default && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CRYPT-SSLEAY)/* && \
	make P=$(CRYPT-SSLEAY) log-package

$(XML-SIMPLE):  $(TIE-IXHASH)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XML-SIMPLE).tar.gz && \
	chmod 755 $(XML-SIMPLE) && \
	chown -R 0:0 $(XML-SIMPLE) && \
	cd $(XML-SIMPLE) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XML-SIMPLE)/* && \
	make P=$(XML-SIMPLE) log-package

$(TIE-IXHASH):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TIE-IXHASH).tar.gz && \
	chmod 755 $(TIE-IXHASH) && \
	chown -R 0:0 $(TIE-IXHASH) && \
	cd $(TIE-IXHASH) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TIE-IXHASH)/* && \
	make P=$(TIE-IXHASH) log-package

$(DATE-MANIP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DATE-MANIP).tar.gz && \
	chmod 755 $(DATE-MANIP) && \
	chown -R 0:0 $(DATE-MANIP) && \
	cd $(DATE-MANIP) && \
	\
	perl Makefile.PL && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DATE-MANIP)/* && \
	make P=$(DATE-MANIP) log-package

#
# Begin Python Modules
#

$(PYXML):  $(PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYXML).tar.gz && \
	chmod 755 $(PYXML) && \
	chown -R 0:0 $(PYXML) && \
	cd $(PYXML) && \
	\
	python setup.py build && \
	python setup.py install && \
	\
	install -v -m644 doc/man/xmlproc_*.1 /usr/share/man/man1 && \
	install -v -m755 -d /usr/share/doc/$(PYXML) && \
	cp -v -R doc demo test /usr/share/doc/$(PYXML) && \
	install -v -m644 README* /usr/share/doc/$(PYXML) && \
	\
	cd .. && \
	rm -rf $(PYXML)/* && \
	make P=$(PYXML) log-package

$(PYCAIRO-OLD):  $(CAIRO) $(PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYCAIRO-OLD).tar.gz && \
	chmod 755 $(PYCAIRO-OLD) && \
	chown -R 0:0 $(PYCAIRO-OLD) && \
	cd $(PYCAIRO-OLD) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYCAIRO-OLD)/* && \
	make P=$(PYCAIRO-OLD) log-package

$(PYCAIRO):  $(CAIRO) $(PYTHON3)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PYCAIRO).tar.bz2 && \
	chmod 755 $(PYCAIRO) && \
	chown -R 0:0 $(PYCAIRO) && \
	cd $(PYCAIRO) && \
	\
	PYTHON="python3" python3 ./waf configure --prefix=/usr && \
	PYTHON="python3" python3 ./waf build && \
	PYTHON="python3" python3 ./waf install && \
	\
	cd .. && \
	rm -rf $(PYCAIRO)/* $(PYCAIRO)/.get $(PYCAIRO)/.waf* && \
	make P=$(PYCAIRO) log-package

$(PYGOBJECT2):  $(PYTHON) $(GLIB2) $(LIBXSLT) $(PYCAIRO-OLD)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYGOBJECT2).tar.bz2 && \
	chmod 755 $(PYGOBJECT2) && \
	chown -R 0:0 $(PYGOBJECT2) && \
	cd $(PYGOBJECT2) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(PYGOBJECT2)-no-error-domain.patch && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYGOBJECT2)/* && \
	make P=$(PYGOBJECT2) log-package

$(PYGOBJECT3):  $(PYTHON3) $(GLIB2) $(LIBXSLT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYGOBJECT3).tar.bz2 && \
	chmod 755 $(PYGOBJECT3) && \
	chown -R 0:0 $(PYGOBJECT3) && \
	cd $(PYGOBJECT3) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(PYGOBJECT3)-foreign.patch && \
	\
	PYTHON="python3" ./configure --prefix=/usr && \
	PYTHON="python3" make && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYGOBJECT3)/* && \
	make P=$(PYGOBJECT3) log-package

$(PYGTK2):  $(PYGOBJECT2) $(ATK) $(PANGO) $(PYCAIRO) $(GTK2) $(LIBGLADE) \
	$(PYTHON) $(PYTHON3)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYGTK2).tar.bz2 && \
	chmod 755 $(PYGTK2) && \
	chown -R 0:0 $(PYGTK2) && \
	cd $(PYGTK2) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYGTK2)/.libs $(PYGTK2)/.deps $(PYGTK2)/* && \
	make P=$(PYGTK2) log-package

$(PYORBIT):  $(PYTHON) $(ORBIT2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PYORBIT).tar.bz2 && \
	chmod 755 $(PYORBIT) && \
	chown -R 0:0 $(PYORBIT) && \
	cd $(PYORBIT) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PYORBIT)/* && \
	make P=$(PYORBIT) log-package

$(GNOME-PYTHON):  $(PYGTK2) $(LIBGNOME) $(PYORBIT) $(LIBGNOMEUI) \
	$(LIBGNOMECANVAS) $(LIBBONOBOUI)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-PYTHON).tar.bz2 && \
	chmod 755 $(GNOME-PYTHON) && \
	chown -R 0:0 $(GNOME-PYTHON) && \
	cd $(GNOME-PYTHON) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-PYTHON)/* && \
	make P=$(GNOME-PYTHON) log-package

#
# Begin Networking
#

$(PPP): $(LIBPCAP)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PPP).tar.gz && \
	chmod 755 $(PPP) && \
	chown -R 0:0 $(PPP) && \
	cd $(PPP) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	make install-etcppp && \
	\
	cd .. && \
	rm -rf $(PPP)/* && \
	make P=$(PPP) log-package

$(WVDIAL):  $(WVSTREAMS) $(PPP)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WVDIAL).tar.gz && \
	chmod 755 $(WVDIAL) && \
	chown -R 0:0 $(WVDIAL) && \
	cd $(WVDIAL) && \
	\
	perl -p -i -e 's/^prefix=.*/prefix=\/usr/' Makefile && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(WVDIAL)/* && \
	make P=$(WVDIAL) log-package

$(WVSTREAMS):  $(OPENSSL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WVSTREAMS).tar.gz && \
	chmod 755 $(WVSTREAMS) && \
	chown -R 0:0 $(WVSTREAMS) && \
	cd $(WVSTREAMS) && \
	\
	echo obsolete sed -i -e "s/8_3/8_4/"  -e "s/8\.3/8.4/" \
		configure{,.ac} include/wvautoconf.h.in bindings/rules.mk && \
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--with-dbus \
		--with-qt \
		--with-tcl \
		--with-pam && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(WVSTREAMS)/* && \
	make P=$(WVSTREAMS) log-package

$(DHCPCD):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DHCPCD).tar.bz2 && \
	chmod 755 $(DHCPCD) && \
	chown -R 0:0 $(DHCPCD) && \
	cd $(DHCPCD) && \
	\
	./configure --libexecdir=/lib/dhcpcd \
		--dbdir=/run \
		--sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	sed -i "s;/var/lib;/run;g" dhcpcd-hooks/50-dhcpcd-compat && \
	install -v -m 644 dhcpcd-hooks/50-dhcpcd-compat \
		/lib/dhcpcd/dhcpcd-hooks/ && \
	\
	cd .. && \
	rm -rf $(DHCPCD)/* && \
	make P=$(DHCPCD) log-package

$(RP-PPPOE):  $(PPP) $(TK)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(RP-PPPOE).tar.gz && \
	chmod 755 $(RP-PPPOE) && \
	chown -R 0:0 $(RP-PPPOE) && \
	cd $(RP-PPPOE) && \
	\
	cd src && \
	./configure && \
	make -j2 && \
	make install && \
	cd .. && \
	chmod 755 gui/tkpppoe && \
	cp -av gui/tkpppoe /usr/bin && \
	mkdir -p /etc/ppp/rp-pppoe-gui && \
	\
	cd .. && \
	rm -rf $(RP-PPPOE)/* && \
	make P=$(RP-PPPOE) log-package

$(CURL):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(CURL).tar.bz2 && \
	chmod 755 $(CURL) && \
	chown -R 0:0 $(CURL) && \
	cd $(CURL) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	find docs -name "Makefile*" -o -name "*.1" -o -name "*.3" | \
		xargs rm && \
	install -v -d -m755 /usr/share/doc/$(CURL) && \
	cp -v -R docs/* /usr/share/doc/$(CURL) && \
	\
	cd .. && \
	rm -rf $(CURL)/* && \
	make P=$(CURL) log-package

$(GNET):  $(GLIB2)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GNET).tar.gz && \
	chmod 755 $(GNET) && \
	chown -R 0:0 $(GNET) && \
	cd $(GNET) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNET)/* && \
	make P=$(GNET) log-package

$(LIBPROXY): $(GCONF)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBPROXY).tar.gz && \
	chmod 755 $(LIBPROXY) && \
	chown -R 0:0 $(LIBPROXY) && \
	cd $(LIBPROXY) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBPROXY)/* && \
	make P=$(LIBPROXY) log-package

$(LIBPCAP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBPCAP).tar.gz && \
	chmod 755 $(LIBPCAP) && \
	chown -R 0:0 $(LIBPCAP) && \
	cd $(LIBPCAP) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(LIBPCAP) && \
	\
	cd .. && \
	rm -rf $(LIBPCAP)/* && \
	make P=$(LIBPCAP) log-package

$(LYNX):  $(OPENSSL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LYNX).tar.bz2 && \
	mv lynx2-8-6 $(LYNX) && \
	chmod 755 $(LYNX) && \
	chown -R 0:0 $(LYNX) && \
	cd $(LYNX) && \
	\
	./configure --prefix=/usr \
            --sysconfdir=/etc/lynx \
            --datadir=/usr/share/doc/$(LYNX) \
            --with-zlib \
            --with-bzlib \
            --with-ssl \
            --with-screen=ncursesw \
            --enable-locale-charset && \
	make -j2 && \
	make install-full && \
	chgrp -v -R root /usr/share/doc/$(LYNX)/lynx_doc && \
	sed -i 's/#\(LOCALE_CHARSET\):FALSE/\1:TRUE/' /etc/lynx/lynx.cfg && \
	\
	cd .. && \
	rm -rf $(LYNX)/* && \
	make P=$(LYNX) log-package

$(NCFTP):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NCFTP)-src.tar.bz2 && \
	chmod 755 $(NCFTP) && \
	chown -R 0:0 $(NCFTP) && \
	cd $(NCFTP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -C libncftp shared && \
	make -j2 && \
	make -C libncftp soinstall && \
	make install && \
	\
	cd .. && \
	rm -rf $(NCFTP)/* && \
	make P=$(NCFTP) log-package

$(NET-TOOLS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NET-TOOLS).tar.bz2 && \
	chmod 755 $(NET-TOOLS) && \
	chown -R 0:0 $(NET-TOOLS) && \
	cd $(NET-TOOLS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(NET-TOOLS)-gcc34-3.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(NET-TOOLS)-kernel_headers-2.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(NET-TOOLS)-mii_ioctl-1.patch && \
	yes "" | make config && \
	sed -i -e 's|HAVE_IP_TOOLS 0|HAVE_IP_TOOLS 1|g' \
		-e 's|HAVE_MII 0|HAVE_MII 1|g' config.h && \
	sed -i -e 's|# HAVE_IP_TOOLS=0|HAVE_IP_TOOLS=1|g' \
		-e 's|# HAVE_MII=0|HAVE_MII=1|g' config.make && \
	echo no make -j2 && \
	make && \
	make update && \
	cd .. && \
	rm -rf $(NET-TOOLS)/* && \
	make P=$(NET-TOOLS) log-package

$(NTP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(NTP).tar.gz && \
	chmod 755 $(NTP) && \
	chown -R 0:0 $(NTP) && \
	cd $(NTP) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(NTP)-mod_nano-1.patch && \
	./configure --prefix=/usr --sysconfdir=/etc \
		--with-binsubdir=sbin && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(NTP) && \
	cp -v -R html/* /usr/share/doc/$(NTP) && \
	\
	cd .. && \
	rm -rf $(NTP)/* && \
	make P=$(NTP) log-package

$(LIBTIRPC):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBTIRPC).tar.bz2 && \
	chmod 755 $(LIBTIRPC) && \
	chown -R 0:0 $(LIBTIRPC) && \
	cd $(LIBTIRPC) && \
	\
	if [ ! -r /usr/include/rpc/rpc.h ]; then \
		tar -xvf $(JLFS-TARBALLS)/rpcnis-headers.tar.bz2 \
			-C /usr/include; \
	fi && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBTIRPC)-remove-nis-2.patch && \
	\
	autoreconf && \
	./configure --prefix=/usr --libdir=/lib && \
	make && \
	make pkgconfigdir=/usr/lib/pkgconfig install && \
	mv -v /lib/libtirpc.*a /usr/lib && \
	\
	cd .. && \
	rm -rf $(LIBTIRPC)/* && \
	make P=$(LIBTIRPC) log-package

$(RPCBIND):  $(LIBTIRPC) $(TCP-WRAPPER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(RPCBIND).tar.bz2 && \
	chmod 755 $(RPCBIND) && \
	chown -R 0:0 $(RPCBIND) && \
	cd $(RPCBIND) && \
	\
	sed -i 's/^sunrpc/rpcbind/' /etc/services && \
	\
	./configure --prefix=/usr --bindir=/sbin && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(RPCBIND)/* && \
	make P=$(RPCBIND) log-package

$(RSYNC):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(RSYNC).tar.gz && \
	chmod 755 $(RSYNC) && \
	chown -R 0:0 $(RSYNC) && \
	cd $(RSYNC) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(RSYNC)/* && \
	make P=$(RSYNC) log-package

$(OPENSSH):  $(OPENSSL) $(TCP-WRAPPER) $(SHADOW)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(OPENSSH).tar.gz && \
	chmod 755 $(OPENSSH) && \
	chown -R 0:0 $(OPENSSH) && \
	cd $(OPENSSH) && \
	\
	install -v -m700 -d /var/lib/sshd && \
	chown -v root:sys /var/lib/sshd && \
	groupadd -g 50 sshd; \
	useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd \
		-s /bin/false -u 50 sshd; \
	\
	sed -i 's@-lcrypto@/usr/lib/libcrypto.a -ldl@' configure && \
	sed -i.bak 's/ -ldes//' configure && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc/ssh \
		--datadir=/usr/share/sshd \
		--libexecdir=/usr/lib/openssh \
		--with-md5-passwords \
		--with-privsep-path=/var/lib/sshd \
		--with-xauth=/usr/bin/xauth \
		--with-pam \
		--without-rand-helper \
		--with-tcp-wrappers && \
	\
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(OPENSSH) && \
	install -v -m644 INSTALL LICENCE OVERVIEW README* WARNING.RNG \
		/usr/share/doc/$(OPENSSH) && \
	\
	sed 's@d/login@d/sshd@g' /etc/pam.d/login > /etc/pam.d/sshd && \
	chmod 644 /etc/pam.d/sshd && \
	\
	cd .. && \
	rm -rf $(OPENSSH)/* && \
	make P=$(OPENSSH) log-package

$(PROFTPD):  $(PAM)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PROFTPD).tar.bz2 && \
	chmod 755 $(PROFTPD) && \
	chown -R 0:0 $(PROFTPD) && \
	chown -R 0:0 $(PROFTPD) && \
	cd $(PROFTPD) && \
	\
	groupadd -g 46 proftpd; \
	useradd -c proftpd -d /srv/ftp -g proftpd \
		-s /usr/bin/proftpdshell -u 46 proftpd; \
	install -v -d -m775 -o proftpd -g proftpd /srv/ftp && \
	ln -v -sfn /bin/false /usr/bin/proftpdshell && \
	echo /usr/bin/proftpdshell >> /etc/shells && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--localstatedir=/var/run && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PROFTPD)/* && \
	make P=$(PROFTPD) log-package

$(SAMBA):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SAMBA).tar.gz && \
	chmod 755 $(SAMBA) && \
	chown -R 0:0 $(SAMBA) && \
	touch $(SAMBA) && \
	cd $(SAMBA) && \
	\
	cd source3 && \
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--with-piddir=/var/run \
		--with-pammodulesdir=/lib/security \
		--with-fhs \
		--with-automount \
		--with-cifsumount \
		--enable-nss-wrapper \
		--with-pthreads && \
	make -j2 && \
	make install && \
	\
	install -v -m755 ../nsswitch/libnss_win{s,bind}.so /lib && \
	ln -v -sfn libnss_winbind.so /lib/libnss_winbind.so.2 && \
	ln -v -sfn libnss_wins.so /lib/libnss_wins.so.2 && \
	install -v -m644 ../examples/smb.conf.default /etc/samba && \
	install -v -m755 -d /usr/share/doc/$(SAMBA) && \
	install -v -m644 ../docs/*.pdf /usr/share/doc/$(SAMBA) && \
	ln -v -sfn ../../samba/swat  /usr/share/doc/$(SAMBA) && \
	\
	rm -f /usr/bin/*old /usr/sbin/*old && \
	\
	cd ../.. && \
	rm -rf $(SAMBA)/* && \
	make P=$(SAMBA) log-package

$(SUBVERSION):  $(NEON) $(BDB4) $(APACHE)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SUBVERSION).tar.bz2 && \
	chmod 755 $(SUBVERSION) && \
	chown -R 0:0 $(SUBVERSION) && \
	cd $(SUBVERSION) && \
	\
	./configure --prefix=/usr \
		--with-apxs \
		--disable-neon-version-check && \
	make -j2 && \
	make swig-pl && \
	make swig-pl-lib && \
	make install && \
	make install-bdb-lib && \
	make install swig-pl && \
	install -v -m755 -d /usr/share/doc/$(SUBVERSION) && \
	cp -v -R doc/* /usr/share/doc/$(SUBVERSION) && \
	\
	cd subversion/bindings/swig/perl/native && \
	perl Makefile.PL && \
	make install && \
	make install_perl && \
	cp -av ../libsvn_swig_perl/.libs/libsvn_swig_perl-1.so.0.0.0 /usr/lib && \
	cd ../../../../.. && \
	\
	cd .. && \
	rm -rf $(SUBVERSION)/* && \
	make P=$(SUBVERSION) log-package

$(TCP-WRAPPER):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TCP-WRAPPER).tar.gz && \
	chmod 755 $(TCP-WRAPPER) && \
	chown -R 0:0 $(TCP-WRAPPER) && \
	cd $(TCP-WRAPPER) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(TCP-WRAPPER)-shared_lib_plus_plus-1.patch && \
	sed -i -e "s,^extern char \*malloc();,/* & */," scaffold.c && \
	make REAL_DAEMON_DIR=/usr/sbin STYLE=-DPROCESS_OPTIONS linux && \
	make install && \
	\
	cd .. && \
	rm -rf $(TCP-WRAPPER)/* && \
	make P=$(TCP-WRAPPER) log-package

$(TCPDUMP):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TCPDUMP).tar.gz && \
	chmod 755 $(TCPDUMP) && \
	chown -R 0:0 $(TCPDUMP) && \
	cd $(TCPDUMP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-smb && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TCPDUMP)/* && \
	make P=$(TCPDUMP) log-package

$(WGET):  $(LIBIDN) $(OPENSSL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(WGET).tar.bz2 && \
	chmod 755 $(WGET) && \
	chown -R 0:0 $(WGET) && \
	cd $(WGET) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(WGET)/* && \
	make P=$(WGET) log-package

$(WIRELESS-TOOLS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WIRELESS-TOOLS).tar.gz && \
	chmod 755 $(WIRELESS-TOOLS) && \
	chown -R 0:0 $(WIRELESS-TOOLS) && \
	cd $(WIRELESS-TOOLS) && \
	\
	make -j2 && \
	make PREFIX=/usr install && \
	\
	cd .. && \
	rm -rf $(WIRELESS-TOOLS)/* && \
	make P=$(WIRELESS-TOOLS) log-package

$(TRACEROUTE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(TRACEROUTE).tar.gz && \
	chmod 755 $(TRACEROUTE) && \
	chown -R 0:0 $(TRACEROUTE) && \
	cd $(TRACEROUTE) && \
	\
	sed -i -e 's/-o bin/-o root/' Makefile.in && \
	./configure --prefix=/usr && \
	\
	make -j2 && \
	make install && \
	make install-man && \
	\
	chmod -v 0755 /usr/sbin/traceroute && \
	mv -v /usr/sbin/traceroute /usr/bin && \
	\
	cd .. && \
	rm -rf $(TRACEROUTE)/* && \
	make P=$(TRACEROUTE) log-package

$(NMAP):  $(LIBDNET) $(LIBPCAP) $(PCRE) $(GTK2) $(OPENSSL) $(PYSQLITE2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NMAP).tar.bz2 && \
	chmod 755 $(NMAP) && \
	chown -R 0:0 $(NMAP) && \
	cd $(NMAP) && \
	\
	./configure --prefix=/usr \
		--libexecdir=/usr/lib && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(NMAP)/* && \
	make P=$(NMAP) log-package

$(WHOIS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WHOIS).tar.gz && \
	chmod 755 $(WHOIS) && \
	chown -R 0:0 $(WHOIS) && \
	cd $(WHOIS) && \
	\
	make -j2 && \
	make prefix=/usr install && \
	\
	cd .. && \
	rm -rf $(WHOIS)/* && \
	make P=$(WHOIS) log-package

$(APACHE):  $(OPENSSL) $(OPENLDAP) $(PCRE)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(APACHE).tar.bz2 && \
	chmod 755 $(APACHE) && \
	chown -R 0:0 $(APACHE) && \
	cd $(APACHE) && \
	\
	groupadd -g 25 apache; \
	useradd -c "Apache Server" -d /dev/null -g apache \
		-s /bin/false -u 25 apache; \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(APACHE)-config-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(APACHE)-bdb51-1.patch && \
	\
	./configure \
		--enable-layout=FHS \
		--enable-mods-shared=all \
		--with-pcre \
		--with-z \
		--enable-authnz-ldap \
		--enable-ssl --with-ssl=/etc/ssl \
		--with-ldap --enable-ldap \
		--with-egd --with-devrandom \
		--with-dbm=db4 --with-berkeley-db && \
	\
	sed -i -e \
		"s%EXTRA_INCLUDES = -I.%EXTRA_INCLUDES = -I/usr/include -I.%g" \
		build/config_vars.mk && \
	make -j2 && \
	make install && \
	\
	chown -v root:root \
		/usr/lib/apache/httpd.exp \
		/usr/sbin/{apxs,apachectl,dbmmanage,envvars{,-std}} \
		/usr/share/man/man1/{dbmmanage,ht{dbm,digest,passwd}}.1 \
		/usr/share/man/man8/{ab,apachectl,apxs,htcacheclean,httpd}.8 \
		/usr/share/man/man8/{logresolve,rotatelogs,suexec}.8 && \
	\
	chown -v -R apache:apache /srv/www && \
	touch /srv/www/htdocs/favicon.ico && \
	\
	( cd /etc/apache && \
	patch -Np4 -i $(JLFS-PATCHES)/$(APACHE)-configuration.patch ) && \
	\
	cd .. && \
	rm -rf $(APACHE)/.gdbinit $(APACHE)/.libs \
		$(APACHE)/.deps $(APACHE)/* && \
	make P=$(APACHE) log-package

$(BIND):  $(OPENSSL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BIND).tar.gz && \
	chmod 755 $(BIND) && \
	chown -R 0:0 $(BIND) && \
	cd $(BIND) && \
	\
	./configure --prefix=/usr \
		--localstatedir=/var/run && \
	\
	make -C lib/dns && \
	make -C lib/isc && \
	make -C lib/bind9 && \
	make -C lib/isccfg && \
	make -C lib/lwres && \
	make -C bin/dig && \
	make -C bin/dig install && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--enable-threads --with-libtool && \
	\
	sed -i "s@198.32.64.12@199.7.83.42@" \
		lib/dns/rootns.c && \
	\
	make -j2 && \
	make install && \
	cd doc && \
	install -v -d -m755 /usr/share/doc/$(BIND)/{arm,draft,misc,rfc} && \
	install -v -m644 arm/*.html \
		/usr/share/doc/$(BIND)/arm && \
	install -v -m644 draft/*.txt \
		/usr/share/doc/$(BIND)/draft && \
	install -v -m644 rfc/* \
		/usr/share/doc/$(BIND)/rfc && \
	install -v -m644 \
		misc/{dnssec,ipv6,migrat*,options,rfc-compliance,roadmap,sdb} \
		/usr/share/doc/$(BIND)/misc && \
	\
	cd ../.. && \
	rm -rf $(BIND)/* && \
	make P=$(BIND) log-package

$(NFS-UTILS):  $(RPCBIND) $(TCP-WRAPPER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NFS-UTILS).tar.bz2 && \
	chmod 755 $(NFS-UTILS) && \
	chown -R 0:0 $(NFS-UTILS) && \
	cd $(NFS-UTILS) && \
	\
	groupadd -g 99 nogroup; \
	useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup \
		-s /bin/false -u 99 nobody; \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--disable-nfsv4 \
		--disable-nfsv41 \
		--with-tcp-wrappers \
		--disable-gss && \
	make -j2 && \
	make install && \
	\
	echo 'PORT="2049"' > /etc/sysconfig/nfs-server && \
	echo 'PROCESSES="8"' >> /etc/sysconfig/nfs-server && \
	echo 'QUOTAS="no"' >> /etc/sysconfig/nfs-server && \
	echo 'KILLDELAY="10"' >> /etc/sysconfig/nfs-server && \
	\
	cd .. && \
	rm -rf $(NFS-UTILS)/* && \
	make P=$(NFS-UTILS) log-package

$(WIRESHARK):  $(GLIB2) $(GTK2) $(LIBPCAP)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(WIRESHARK).tar.gz && \
	chmod 755 $(WIRESHARK) && \
	chown -R 0:0 $(WIRESHARK) && \
	cd $(WIRESHARK) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-gtktest \
		--disable-glibtest \
		--disable-ipv6 \
		--enable-threads && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(WIRESHARK) && \
	install -v -m644 FAQ README{,.linux} doc/README.* doc/*.{pod,txt} \
		/usr/share/doc/$(WIRESHARK) && \
	\
	pushd /usr/share/doc/$(WIRESHARK) && \
	for FILENAME in ../../wireshark/*.html; do \
		ln -sf -v $${FILENAME} .; \
	done; \
	popd && \
	\
	install -v -m644 -D wireshark.desktop \
		/usr/share/applications/wireshark.desktop && \
	install -v -m644 -D image/wsicon48.png \
		/usr/share/pixmaps/wireshark.png && \
	install -v -m755 -d /usr/share/pixmaps/wireshark && \
	install -v -m644 image/*.{png,ico,xpm,bmp} \
		/usr/share/pixmaps/wireshark && \
	\
	cd .. && \
	rm -rf $(WIRESHARK)/.libs $(WIRESHARK)/.deps $(WIRESHARK)/* && \
	make P=$(WIRESHARK) log-package

$(MAILX):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(MAILX).tar.bz2 && \
	chmod 755 $(MAILX) && \
	chown -R 0:0 $(MAILX) && \
	cd $(MAILX) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(MAILX)-openssl_1.0.0_build_fix-1.patch && \
	\
	make SENDMAIL=/usr/sbin/sendmail && \
	make PREFIX=/usr UCBINSTALL=/usr/bin/install install && \
	ln -v -sf mailx /usr/bin/mail && \
	ln -v -sf mailx /usr/bin/nail && \
	install -v -m755 -d /usr/share/doc/$(MAILX) && \
	install -v -m644 README mailx.1.html /usr/share/doc/$(MAILX) && \
	\
	cd .. && \
	rm -rf $(MAILX)/* && \
	make P=$(MAILX) log-package

$(PROCMAIL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PROCMAIL).tar.gz && \
	chmod 755 $(PROCMAIL) && \
	chown -R 0:0 $(PROCMAIL) && \
	cd $(PROCMAIL) && \
	\
	sed -i 's/getline/get_line/' src/*.[ch] && \
	make LOCKINGTEST=/tmp install && \
	make install-suid && \
	\
	cd .. && \
	rm -rf $(PROCMAIL)/* && \
	make P=$(PROCMAIL) log-package

$(FETCHMAIL):  $(PROCMAIL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FETCHMAIL).tar.bz2 && \
	chmod 755 $(FETCHMAIL) && \
	chown -R 0:0 $(FETCHMAIL) && \
	cd $(FETCHMAIL) && \
	\
	./configure --prefix=/usr --with-ssl \
		--enable-fallback=procmail && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FETCHMAIL)/.deps $(FETCHMAIL)/* && \
	make P=$(FETCHMAIL) log-package

$(PIDGIN):  $(XORG7) $(GLIB2) $(GTK2) $(LIBXML2) $(XML-PARSER) $(GSTREAMER) \
	$(FARSIGHT2) $(AVAHI) $(NSPR)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PIDGIN).tar.bz2 && \
	chmod 755 $(PIDGIN) && \
	chown -R 0:0 $(PIDGIN) && \
	cd $(PIDGIN) && \
	\
	CFLAGS="-I/usr/include/nspr -I/usr/include/nss" \
	./configure --prefix=/usr \
		--disable-nm \
		--disable-meanwhile \
		--disable-gtkspell \
		--with-gconf-schema-file-dir=/etc/gnome/gconf/schemas && \
	CFLAGS="-I/usr/include/nspr -I/usr/include/nss" \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(PIDGIN) && \
	install -v -m644    README* doc/*.txt doc/gtkrc-2.0 \
		/usr/share/doc/$(PIDGIN) && \
	\
	( cd /usr/bin && ln -sfn pidgin gaim ) && \
	\
	cd .. && \
	rm -rf $(PIDGIN)/* && \
	make P=$(PIDGIN) log-package

#
# Begin BLFS Servers
#

$(OPENLDAP):  $(BDB4) $(OPENSSL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(OPENLDAP).tar.gz && \
	chmod 755 $(OPENLDAP) && \
	chown -R 0:0 $(OPENLDAP) && \
	cd $(OPENLDAP) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(OPENLDAP)-bdb5-1.patch && \
	\
	./configure --prefix=/usr \
		--libexecdir=/usr/sbin \
		--sysconfdir=/etc \
		--disable-debug \
		--enable-dynamic \
		--enable-slapd=no && \
	\
	make depend && \
	make install && \
	\
	for LINK in lber ldap ldap_r; do \
		chmod 755 /usr/lib/$(shell readlink /usr/lib/lib${LINK}.so); \
	done && \
	\
	install -v -m755 -d /usr/share/doc/$(OPENLDAP)/{drafts,guide,rfc} && \
	install -v -m644 doc/drafts/* /usr/share/doc/$(OPENLDAP)/drafts && \
	install -v -m644 doc/rfc/*  /usr/share/doc/$(OPENLDAP)/rfc && \
	cp -v -R doc/guide/* /usr/share/doc/$(OPENLDAP)/guide && \
	\
	cd .. && \
	rm -rf $(OPENLDAP)/* && \
	make P=$(OPENLDAP) log-package

$(BDB4):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(BDB4).tar.gz && \
	chmod 755 $(BDB4) && \
	chown -R 0:0 $(BDB4) && \
	touch $(BDB4) && \
	cd $(BDB4) && \
	\
	cd build_unix && \
	../dist/configure --prefix=/usr \
		--enable-compat185 \
		--enable-cxx && \
	make -j2 && \
	make docdir=/usr/share/doc/$(BDB4) install && \
	chown -v root:root /usr/bin/db_* /usr/lib/libdb* /usr/include/db* && \
	chown -v -R root:root /usr/share/doc/$(BDB4) && \
	\
	cd ../.. && \
	rm -rf $(BDB4)/* && \
	make P=$(BDB4) log-package

$(MYSQL):  $(OPENSSL) $(TCP-WRAPPER)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MYSQL).tar.gz && \
	chmod 755 $(MYSQL) && \
	chown -R 0:0 $(MYSQL) && \
	cd $(MYSQL) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(MYSQL)-makefile-1.patch && \
	\
	groupadd -g 40 mysql; \
	useradd -c "MySQL Server" -d /dev/null -g mysql -s /bin/false \
		-u 40 mysql; \
	\
	CFLAGS="-O3" \
	CXX=gcc \
	CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--libexecdir=/usr/sbin \
		--localstatedir=/srv/mysql \
		--enable-thread-safe-client \
		--enable-assembler \
		--enable-local-infile \
		--with-unix-socket-path=/var/run/mysql/mysql.sock \
		--without-debug \
		--without-bench \
		--without-readline \
		--with-berkeley-db \
		--with-libwrap \
		--with-ssl=/usr \
		--with-plugins=innobase,myisam \
		--with-extra-charsets=all && \
	\
	make -j2 && \
	make install && \
	\
	cp -av support-files/my-medium.cnf /etc/my.cnf && \
	./scripts/mysql_install_db --user=mysql && \
	chgrp -v mysql /srv/mysql{,/test,/mysql} && \
	install -v -m755 -o mysql -g mysql -d /var/run/mysql && \
	echo obsolete mysqld_safe --user=mysql 2>&1 >/dev/null && \
	echo obsolete mysqladmin -u root password $(MYSQL-PASSWORD) && \
	echo obsolete mysqladmin -p $(MYSQL-PASSWORD) shutdown && \
	\
	cd .. && \
	rm -rf $(MYSQL)/* /usr/mysql-test /usr/sql-bench && \
	make P=$(MYSQL) log-package

$(DHCP):  $(NET-TOOLS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DHCP).tar.gz && \
	chmod 755 $(DHCP) && \
	chown -R 0:0 $(DHCP) && \
	cd $(DHCP) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(DHCP)-iproute2-1.patch && \
	\
	sed -i 's%\(^sbindir =\).*%\1 @prefix@@sbindir@%' \
		server/Makefile.in && \
	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
		--sbindir=/sbin \
		--with-srv-lease-file=/var/state/dhcp/dhcpd.leases \
		--with-srv6-lease-file=/var/state/dhcp/dhcpd6.leases \
		--with-cli-lease-file=/var/state/dhclient.leases \
		--with-cli6-lease-file=/var/state/dhclient6.leases && \
	sed -i 's/-Werror//' \
		{client,common,dst,omapip,relay,server,tests}/Makefile && \
	\
	make -j2 && \
	make install && \
	mkdir -p /var/state/dhcp/ && \
	\
	cd .. && \
	rm -rf $(DHCP)/* && \
	make P=$(DHCP) log-package

$(SENDMAIL):  $(OPENLDAP) $(OPENSSL) $(TCP-WRAPPER) $(PROCMAIL) $(BDB4)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SENDMAIL).tar.gz && \
	chmod 755 $(SENDMAIL) && \
	chown -R 0:0 $(SENDMAIL)

	-groupadd -g 26 smmsp
	-useradd -c "Sendmail Daemon" -g smmsp -d /dev/null \
		-s /bin/false -u 26 smmsp

	chmod -v 1777 /var/mail
	-install -v -m700 -d /var/spool/mqueue


	cd $(SENDMAIL) && \
	\
	cat $(JLFS-CONFIGS)/$(SENDMAIL)-site.config >> \
		devtools/Site/site.config.m4 && \
	\
	cd sendmail && \
	sh Build && \
	\
	cd ../cf/cf && \
	cp generic-linux.mc sendmail.mc && \
	\
	mkdir -p /etc/mail && \
	\
	sh Build sendmail.cf \
	install -v -d -m 755 /etc/mail && \
	sh Build install-cf && \
	\
	cd ../.. && \
	sh Build install && \
	\
	install -v -m 644 cf/cf/{submit,sendmail}.mc /etc/mail && \
	cp -v -R cf/* /etc/mail && \
	\
	install -v -m 755 -d /usr/share/doc/$(SENDMAIL)/{cf,sendmail} && \
	install -v -m 644 \
		CACerts FAQ KNOWNBUGS LICENSE PGPKEYS README RELEASE_NOTES \
			/usr/share/doc/$(SENDMAIL) && \
	install -v -m 644 sendmail/{README,SECURITY,TRACEFLAGS,TUNING} \
		/usr/share/doc/$(SENDMAIL)/sendmail && \
	install -v -m 644 cf/README /usr/share/doc/$(SENDMAIL)/cf && \
	\
	for manpage in sendmail editmap mailstats makemap praliases smrsh; do \
		install -v -m 444 $${manpage}/$${manpage}.8 \
			/usr/share/man/man8; \
	done && \
	\
	install -v -m 444 sendmail/aliases.5    /usr/share/man/man5 && \
	install -v -m 444 sendmail/mailq.1      /usr/share/man/man1 && \
	install -v -m 444 sendmail/newaliases.1 /usr/share/man/man1 && \
	install -v -m 444 vacation/vacation.1   /usr/share/man/man1 && \
	install -v -d -m 755 /usr/share/doc/$(SENDMAIL) && \
	\
	cd .. && \
	\
	rm -rf $(SENDMAIL)/* && \
	make P=$(SENDMAIL) log-package

#
# Begin BLFS X11 Libraries
#

$(QT3):  $(XORG7)  $(LIBJPEG) $(LIBMNG) $(EXPECT)
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(QT3).tar.gz && \
	mv qt3 $(QT3) && \
	chmod 755 $(QT3) && \
	chown -R 0:0 $(QT3) && \
	cd $(QT3) && \
	\
	for directory in `ls -d mkspecs/linux*`; do \
		sed -i '/QMAKE_RPATH/d' $${directory}/qmake.conf; \
	done && \
	\
	sed -i 's/^QMAKE_INCDIR..=/& \/usr\/include\/qt/' \
		mkspecs/linux*/qmake.conf && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(QT3)-libpng15-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(QT3)-no_debug-1.patch && \
	\
	yes "yes"| ./configure -DQT_CLEAN_NAMESPACE \
		-prefix /usr \
		-docdir /usr/share/doc/qt \
		-headerdir /usr/include/qt \
		-plugindir /usr/lib/qt/plugins \
		-datadir /usr/share/qt \
		-translationdir /usr/share/qt/translations \
		-sysconfdir /etc/qt \
		-qt-gif \
		-system-zlib \
		-system-libpng \
		-system-libjpeg \
		-system-libmng \
		-plugin-imgfmt-png \
		-plugin-imgfmt-jpeg \
		-plugin-imgfmt-mng \
		-no-exceptions \
		-continue \
		-thread \
		-no-ipv6 \
		-tablet && \
	\
	make sub-tools \
		PATH=/usr/src/$(QT3)/bin:$(PATH) \
		LD_LIBRARY_PATH=/usr/src/$(QT3)/lib:$(LD_LIBRARY_PATH) && \
	\
	cd .. && \
	make finish-qt-build

#
# QT3 has a tendency to die a horrible and meaningless death
# when compiled within a chrooted environment. This script
# is an attempt at a roundabout workaround.
#
# This stanza is executed from by the QT3 target when QT3 
# fails to compile cleanly on the first try. When it takes control,
# we are still chrooted to $LFS.
#

finish-qt-build:
	echo && \
	/sbin/ldconfig && \
	\
	cd /usr/src/$(QT3) && \
		PATH=/usr/src/$(QT3)/bin:$(PATH) \
		LD_LIBRARY_PATH=/usr/src/$(QT3)/lib:$(LD_LIBRARY_PATH) \
		QTDIR=/usr/src/$(QT3) \
	make sub-tools && \
	make install && \
	\
	ln -v -sf libqt-mt.so /usr/lib/libqt.so && \
	ln -v -snf ../../bin /usr/share/qt/bin && \
	ln -v -snf ../../include/qt /usr/share/qt/include && \
	ln -v -snf ../../lib /usr/share/qt/lib && \
	cp -v -r doc/man /usr/share && \
	\
	/sbin/ldconfig && \
	cd .. && \
	\
	rm -rf $(QT3)/.qmake.cache $(QT3)/* && \
	make P=$(QT3) log-package

$(QT4):  $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(QT4).tar.gz && \
	chmod 755 $(QT4) && \
	chown -R 0:0 $(QT4) && \
	cd $(QT4) && \
	\
	yes "yes"| ./configure -prefix /opt/$(QT4-VER) \
		-opensource \
		-release \
		-nomake examples \
		-nomake demos \
		-no-separate-debug-info && \
	make -j2 && \
	make install && \
	make uninstall_htmldocs && \
	\
	ln -sfnv $(QT4-VER) /opt/qt && \
	echo "/opt/qt/lib" >> /etc/ld.so.conf && \
	ldconfig && \
	\
	cd .. && \
	rm -rf $(QT4)/* && \
	for i in \
		.LICENSE-MERGED-GPL2-GPL3 \
		.obj \
		.pch \
		.qmake.cache; do \
		\
		rm -rf $(QT4)/$${i}; \
	done && \
	\
	rm -rf $(LFS)/root/.qt $(LFS)/root/.config/Trolltech $(LFS)/root/.config && \
	make P=$(QT4) log-package

$(GTK):  $(XORG7) $(GLIB)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GTK).tar.gz && \
	chmod 755 $(GTK) && \
	chown -R 0:0 $(GTK) && \
	cd $(GTK) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(GTK)/{html,text} && \
	install -v -m644 docs/html/* /usr/share/doc/$(GTK)/html && \
	install -v -m644 docs/text/* /usr/share/doc/$(GTK)/text && \
	\
	cd .. && \
	rm -rf $(GTK)/* && \
	make P=$(GTK) log-package

$(CAIRO):  $(XORG7) $(PKG-CONFIG) $(PIXMAN)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CAIRO).tar.gz && \
	chmod 755 $(CAIRO) && \
	chown -R 0:0 $(CAIRO) && \
	cd $(CAIRO) && \
	\
	./configure --prefix=/usr \
		--enable-tee=yes && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CAIRO)/* && \
	make P=$(CAIRO) log-package

$(PANGO):  $(GLIB2) $(CAIRO)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PANGO).tar.bz2 && \
	chmod 755 $(PANGO) && \
	chown -R 0:0 $(PANGO) && \
	cd $(PANGO) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PANGO)/* && \
	make P=$(PANGO) log-package

$(PANGOMM):  $(GLIBMM) $(CAIROMM)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(PANGOMM).tar.bz2 && \
	chmod 755 $(PANGOMM) && \
	chown -R 0:0 $(PANGOMM) && \
	cd $(PANGOMM) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PANGOMM)/* && \
	make P=$(PANGOMM) log-package

$(ATK):  $(GLIB2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ATK).tar.bz2 && \
	chmod 755 $(ATK) && \
	chown -R 0:0 $(ATK) && \
	cd $(ATK) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ATK)/* && \
	make P=$(ATK) log-package

$(GTK2):  $(CAIRO) $(PANGO) $(ATK) $(LIBTIFF) $(LIBJPEG) $(GDK-PIXBUF)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTK2).tar.bz2 && \
	chmod 755 $(GTK2) && \
	chown -R 0:0 $(GTK2) && \
	cd $(GTK2) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTK2)/* && \
	make P=$(GTK2) log-package

$(GTK3):  $(CAIRO) $(PANGO) $(ATK) $(LIBTIFF) $(LIBJPEG) $(GDK-PIXBUF)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTK3).tar.bz2 && \
	chmod 755 $(GTK3) && \
	chown -R 0:0 $(GTK3) && \
	cd $(GTK3) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTK3)/* && \
	make P=$(GTK3) log-package
$(LESSTIF):  $(XORG7)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LESSTIF).tar.bz2 && \
	chmod 755 $(LESSTIF) && \
	chown -R 0:0 $(LESSTIF) && \
	cd $(LESSTIF) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LESSTIF)-testsuite_fix-1.patch && \
	\
	sed -i -e '/ShellP/d' \
		-e '/XMLIBEXPORT extern Cardinal/i#include <X11/ShellP.h>\n'  \
		include/Motif-2.1/Xm/VendorSP.h && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-build-20 \
		--enable-build-21 \
		--disable-debug \
		--enable-production \
		--with-xdnd && \
	make rootdir=/usr/share/doc/$(LESSTIF) && \
	make rootdir=/usr/share/doc/$(LESSTIF) install && \
	ldconfig && \
	ln -v -sfn /usr/lib/X11/mwm /etc/X11 && \
	\
	cd .. && \
	rm -rf $(LESSTIF)/* && \
	make P=$(LESSTIF) log-package

$(STARTUP-NOTIFICATION):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(STARTUP-NOTIFICATION).tar.bz2 && \
	chmod 755 $(STARTUP-NOTIFICATION) && \
	chown -R 0:0 $(STARTUP-NOTIFICATION) && \
	cd $(STARTUP-NOTIFICATION) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 -D doc/startup-notification.txt \
		/usr/share/doc/$(STARTUP-NOTIFICATION)/startup-notification.txt && \
	cd .. && \
	rm -rf $(STARTUP-NOTIFICATION)/*
	make P=$(STARTUP-NOTIFICATION) log-package

$(SHARED-MIME-INFO):  $(GLIB2) $(LIBXML2) $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(SHARED-MIME-INFO).tar.bz2 && \
	chmod 755 $(SHARED-MIME-INFO) && \
	chown -R 0:0 $(SHARED-MIME-INFO) && \
	cd $(SHARED-MIME-INFO) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SHARED-MIME-INFO)/* && \
	make P=$(SHARED-MIME-INFO) log-package

#
# Begin GNOME Core
#

$(ORBIT2):  $(LIBIDL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ORBIT2).tar.bz2 && \
	chmod 755 $(ORBIT2) && \
	chown -R 0:0 $(ORBIT2) && \
	cd $(ORBIT2) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ORBIT2)/* && \
	make P=$(ORBIT2) log-package

$(LIBBONOBO):  $(ORBIT2) $(LIBXML2) $(POPT) $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBBONOBO).tar.bz2 && \
	chmod 755 $(LIBBONOBO) && \
	chown -R 0:0 $(LIBBONOBO) && \
	cd $(LIBBONOBO) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--libexecdir=/usr/lib/bonobo \
		--mandir=/usr/share/man && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBBONOBO)/* && \
	make P=$(LIBBONOBO) log-package

$(GCONF):  $(ORBIT2) $(LIBXML2) $(GTK2) $(OPENLDAP) $(POLKIT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GCONF).tar.bz2 && \
	chmod 755 $(GCONF) && \
	chown -R 0:0 $(GCONF) && \
	cd $(GCONF) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--libexecdir=/usr/lib/GConf \
		--mandir=/usr/share/man && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GCONF)/* && \
	make P=$(GCONF) log-package

$(GNOME-MIME-DATA):  $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-MIME-DATA).tar.bz2 && \
	chmod 755 $(GNOME-MIME-DATA) && \
	chown -R 0:0 $(GNOME-MIME-DATA) && \
	cd $(GNOME-MIME-DATA) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--mandir=/usr/share/man && \
	make -j2 && \
	make install && \
	install -v -m644 -D man/gnome-vfs-mime.5 \
		/usr/share/man/man5/gnome-vfs-mime.5 && \
	\
	cd .. && \
	rm -rf $(GNOME-MIME-DATA)/* && \
	make P=$(GNOME-MIME-DATA) log-package

$(HICOLOR-ICON-THEME):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(HICOLOR-ICON-THEME).tar.gz && \
	chmod 755 $(HICOLOR-ICON-THEME) && \
	chown -R 0:0 $(HICOLOR-ICON-THEME) && \
	cd $(HICOLOR-ICON-THEME) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(HICOLOR-ICON-THEME)/* && \
	make P=$(HICOLOR-ICON-THEME) log-package

$(DESKTOP-FILE-UTILS):  $(GLIB2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DESKTOP-FILE-UTILS).tar.bz2 && \
	chmod 755 $(DESKTOP-FILE-UTILS) && \
	chown -R 0:0 $(DESKTOP-FILE-UTILS) && \
	cd $(DESKTOP-FILE-UTILS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(DESKTOP-FILE-UTILS)/* && \
	make P=$(DESKTOP-FILE-UTILS) log-package

$(GNOME-VFS):  $(DBUS-GLIB) $(GCONF) $(GNOME-MIME-DATA) $(OPENSSH) \
	$(OPENSSL) $(GAMIN) $(FAM) $(LIBXML2)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-VFS).tar.bz2 && \
	chmod 755 $(GNOME-VFS) && \
	chown -R 0:0 $(GNOME-VFS) && \
	cd $(GNOME-VFS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--libexecdir=/usr/lib/gnome-vfs-2.0 && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-VFS)/* && \
	make P=$(GNOME-VFS) log-package

$(LIBGNOME):  $(LIBBONOBO) $(GNOME-VFS) $(ESOUND)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOME).tar.bz2 && \
	chmod 755 $(LIBGNOME) && \
	chown -R 0:0 $(LIBGNOME) && \
	cd $(LIBGNOME) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--localstatedir=/var/lib \
		--mandir=/usr/share/man && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGNOME)/* && \
	make P=$(LIBGNOME) log-package

$(LIBGNOMECANVAS):  $(LIBGLADE) $(LIBART)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOMECANVAS).tar.bz2 && \
	chmod 755 $(LIBGNOMECANVAS) && \
	chown -R 0:0 $(LIBGNOMECANVAS) && \
	cd $(LIBGNOMECANVAS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGNOMECANVAS)/* && \
	make P=$(LIBGNOMECANVAS) log-package

$(LIBBONOBOUI):  $(LIBGNOME) $(LIBGNOMECANVAS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBBONOBOUI).tar.bz2 && \
	chmod 755 $(LIBBONOBOUI) && \
	chown -R 0:0 $(LIBBONOBOUI) && \
	cd $(LIBBONOBOUI) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	install -v -m755 -d /usr/share/doc/$(LIBBONOBOUI) && \
	install -v -m644 doc/*.{dtd,txt,xml,html} \
		/usr/share/doc/$(LIBBONOBOUI) && \
	\
	cd .. && \
	rm -rf $(LIBBONOBOUI)/* && \
	make P=$(LIBBONOBOUI) log-package

$(GNOME-KEYRING):  $(GTK2) $(XML-PARSER) $(DBUS) $(INTLTOOL) $(LIBTASN1) \
	$(LIBGNOME-KEYRING)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-KEYRING).tar.bz2 && \
	chmod 755 $(GNOME-KEYRING) && \
	chown -R 0:0 $(GNOME-KEYRING) && \
	cd $(GNOME-KEYRING) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/lib/gnome-keyring \
		--sysconfdir=/etc/gnome \
		--with-pam-dir=/lib/security \
		--with-dbus-services=/usr/share/dbus-1/services \
		--with-root-certs=/etc/ssl/certs && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-KEYRING)/.libs $(GNOME-KEYRING)/.deps $(GNOME-KEYRING)/* && \
	make P=$(GNOME-KEYRING) log-package

$(GNOME-ICON-THEME):  $(ICON-NAMING-UTILS) $(XML-PARSER) $(GTK-ENGINES)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-ICON-THEME).tar.bz2 && \
	chmod 755 $(GNOME-ICON-THEME) && \
	chown -R 0:0 $(GNOME-ICON-THEME) && \
	cd $(GNOME-ICON-THEME) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	./configure --prefix=/usr && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-ICON-THEME)/* && \
	make P=$(GNOME-ICON-THEME) log-package

$(ICON-NAMING-UTILS):  $(XML-SIMPLE)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ICON-NAMING-UTILS).tar.bz2 && \
	chmod 755 $(ICON-NAMING-UTILS) && \
	chown -R 0:0 $(ICON-NAMING-UTILS) && \
	cd $(ICON-NAMING-UTILS) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	./configure --prefix=/usr \
            --libexecdir=/usr/lib/icon-naming-utils && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ICON-NAMING-UTILS)/* && \
	make P=$(ICON-NAMING-UTILS) log-package

$(LIBGNOMEUI):  $(LIBBONOBOUI) $(GNOME-KEYRING)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOMEUI).tar.bz2 && \
	chmod 755 $(LIBGNOMEUI) && \
	chown -R 0:0 $(LIBGNOMEUI) && \
	cd $(LIBGNOMEUI) && \
	\
	./configure --prefix=/usr \
            --libexecdir=/usr/lib/libgnomeui && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGNOMEUI)/* && \
	make P=$(LIBGNOMEUI) log-package

$(VTE): $(GTK2) $(XML-PARSER) $(PYTHON) $(PYGTK2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(VTE).tar.bz2 && \
	chmod 755 $(VTE) && \
	chown -R 0:0 $(VTE) && \
	cd $(VTE) && \
	\
	sed -i 's%\\177:%&kh=\\EOH:@7=\\EOF:%' termcaps/xterm && \
	\
	./configure --prefix=/usr --libexecdir=/usr/lib/vte && \
        make -j2 && \
        make install && \
	\
	cd .. && \
	rm -rf $(VTE)/* && \
	make P=$(VTE) log-package

$(GAIL):  $(LIBGNOMECANVAS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GAIL).tar.bz2 && \
	chmod 755 $(GAIL) && \
	chown -R 0:0 $(GAIL) && \
	cd $(GAIL) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GAIL)/* && \
	make P=$(GAIL) log-package

#
# Begin GNOME Desktop
#

$(GNOME-DOC-UTILS):  $(LIBXSLT) $(XML-PARSER) $(WHICH) $(PYTHON)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-DOC-UTILS).tar.bz2 && \
	chmod 755 $(GNOME-DOC-UTILS) && \
	chown -R 0:0 $(GNOME-DOC-UTILS) && \
	cd $(GNOME-DOC-UTILS) && \
	\
	sed -i -e "s|datadir)/pkgconfig|libdir)/pkgconfig|" Makefile.in && \
	\
	sed -i 's/@.*@pkgconfig/pkgconfig/' Makefile.in && \
	./configure --prefix=/usr \
		--disable-scrollkeeper --mandir=/usr/share/man && \
	echo no make -j2 && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-DOC-UTILS)/* && \
	make P=$(GNOME-DOC-UTILS) log-package

$(GNOME-DESKTOP):  $(LIBGNOMEUI) $(GNOME-DOC-UTILS) $(GSETTINGS-DESKTOP-SCHEMA)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-DESKTOP).tar.bz2 && \
	chmod 755 $(GNOME-DESKTOP) && \
	chown -R 0:0 $(GNOME-DESKTOP) && \
	cd $(GNOME-DESKTOP) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--disable-scrollkeeper --disable-gtk-doc \
		--localstatedir=/var/lib && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-DESKTOP)/* && \
	make P=$(GNOME-DESKTOP) log-package

$(GNOME-MENUS):  $(GLIB2) $(XML-PARSER) $(INTLTOOL) $(PYTHON)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-MENUS).tar.bz2 && \
	chmod 755 $(GNOME-MENUS) && \
	chown -R 0:0 $(GNOME-MENUS) && \
	cd $(GNOME-MENUS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--enable-inotify && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-MENUS)/* && \
	make P=$(GNOME-MENUS) log-package

$(NAUTILUS):  $(ESOUND) $(LIBEXIF) $(LIBRSVG) $(LIBUNIQUE) $(GNOME-DESKTOP) \
	$(LIBNOTIFY)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(NAUTILUS).tar.bz2 && \
	chmod 755 $(NAUTILUS) && \
	chown -R 0:0 $(NAUTILUS) && \
	cd $(NAUTILUS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(NAUTILUS) && \
	install -v -m644 docs/*.{txt,dia,pdf,sxw,faq,html} \
		/usr/share/doc/$(NAUTILUS) && \
	\
	cd .. && \
	rm -rf $(NAUTILUS)/* && \
	make P=$(NAUTILUS) log-package

$(GOBJECT-INTROSPECTION):  $(GLIB2) $(PYTHON) $(LIBFFI) $(CAIRO)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GOBJECT-INTROSPECTION).tar.bz2 && \
	chmod 755 $(GOBJECT-INTROSPECTION) && \
	chown -R 0:0 $(GOBJECT-INTROSPECTION) && \
	cd $(GOBJECT-INTROSPECTION) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GOBJECT-INTROSPECTION)/* \
		$(GOBJECT-INTROSPECTION)/.libs \
		$(GOBJECT-INTROSPECTION)/.deps && \
	make P=$(GOBJECT-INTROSPECTION) log-package

$(LIBTASN1):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBTASN1).tar.gz && \
	chmod 755 $(LIBTASN1) && \
	chown -R 0:0 $(LIBTASN1) && \
	cd $(LIBTASN1) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBTASN1)/* && \
	make P=$(LIBTASN1) log-package

$(LIBUNIQUE):  $(GTK2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBUNIQUE).tar.bz2 && \
	chmod 755 $(LIBUNIQUE) && \
	chown -R 0:0 $(LIBUNIQUE) && \
	cd $(LIBUNIQUE) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-introspection && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBUNIQUE)/* && \
	make P=$(LIBUNIQUE) log-package

$(GTK-ENGINES):  $(GTK2) $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTK-ENGINES).tar.bz2 && \
	chmod 755 $(GTK-ENGINES) && \
	chown -R 0:0 $(GTK-ENGINES) && \
	cd $(GTK-ENGINES) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTK-ENGINES)/* && \
	make P=$(GTK-ENGINES) log-package

$(GSETTINGS-DESKTOP-SCHEMA):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GSETTINGS-DESKTOP-SCHEMA).tar.bz2 && \
	chmod 755 $(GSETTINGS-DESKTOP-SCHEMA) && \
	chown -R 0:0 $(GSETTINGS-DESKTOP-SCHEMA) && \
	cd $(GSETTINGS-DESKTOP-SCHEMA) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GSETTINGS-DESKTOP-SCHEMA)/* && \
	make P=$(GSETTINGS-DESKTOP-SCHEMA) log-package

$(GNOME-BLUETOOTH):  $(BLUEZ)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-BLUETOOTH).tar.bz2 && \
	chmod 755 $(GNOME-BLUETOOTH) && \
	chown -R 0:0 $(GNOME-BLUETOOTH) && \
	cd $(GNOME-BLUETOOTH) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--disable-scrollkeeper && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-BLUETOOTH)/* && \
	make P=$(GNOME-BLUETOOTH) log-package

#
# Begin BLFS GNOME Libraries
#

$(GTKHTML):  $(LIBGNOMEUI) $(GAIL) $(GNOME-ICON-THEME) $(LIBGNOMEPRINTUI) \
	$(ENCHANT)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTKHTML).tar.bz2 && \
	chmod 755 $(GTKHTML) && \
	chown -R 0:0 $(GTKHTML) && \
	cd $(GTKHTML) && \
	\
	./configure --prefix=/usr \
            --libexecdir=/usr/lib/gtkhtml && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKHTML)/* && \
	make P=$(GTKHTML) log-package

$(GTKSOURCEVIEW): $(GTK2) $(XML-PARSER) $(LIBGNOMEPRINT) $(INTLTOOL)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GTKSOURCEVIEW).tar.bz2 && \
	chmod 755 $(GTKSOURCEVIEW) && \
	chown -R 0:0 $(GTKSOURCEVIEW) && \
	cd $(GTKSOURCEVIEW) && \
	\
	./configure --prefix=/usr \
		--disable-build-tests && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GTKSOURCEVIEW)/* && \
	make P=$(GTKSOURCEVIEW) log-package

$(LIBGNOMECUPS):  $(CUPS) $(GLIB2) $(XML-PARSER)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOMECUPS-SRC).tar.bz2 && \
	$(SKEL-JLFS)/root/bin/rpm2cpio $(JLFS-TARBALLS)/$(LIBGNOMECUPS).rpm > \
		/tmp/$(LIBGNOMECUPS).cpio && \
	\
	mkdir -p $(LIBGNOMECUPS) && \
	chmod 755 $(LIBGNOMECUPS) && \
	chown -R 0:0 $(LIBGNOMECUPS) && \
	cd $(LIBGNOMECUPS) && \
	cpio -idv < /tmp/$(LIBGNOMECUPS).cpio && \
	mv usr/lib/* /usr/lib && \
	cd .. && \
	\
	cd $(LIBGNOMECUPS-SRC) && \
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBGNOMECUPS-SRC)-glib.patch && \
	\
	cd libgnomecups && \
	mkdir -p /usr/include/libgnomecups-1/libgnomecups && \
	for i in printer queue request util init; do \
		cp -av gnome-cups-$${i}.h \
			/usr/include/libgnomecups-1/libgnomecups; \
	done && \
	\
	cp -av $(JLFS-CONFIGS)/libgnomecups-1.0.pc /usr/lib/pkgconfig && \
	ldconfig && \
	\
	cd ../.. && \
	rm -rf $(LIBGNOMECUPS)/* /tmp/$(LIBGNOMECUPS).cpio \
		$(LIBGNOMECUPS-SRC) && \
	make P=$(LIBGNOMECUPS) log-package

$(LIBGNOMEPRINT):  $(PANGO) $(LIBART) $(POPT) $(LIBXML2) $(XML-PARSER) $(CUPS) $(LIBGNOMECUPS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOMEPRINT).tar.bz2 && \
	chmod 755 $(LIBGNOMEPRINT) && \
	chown -R 0:0 $(LIBGNOMEPRINT) && \
	cd $(LIBGNOMEPRINT) && \
	\
	./configure --prefix=/usr --disable-gtk-doc \
		--without-cups \
		--enable-static=no && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGNOMEPRINT)/* && \
	make P=$(LIBGNOMEPRINT) log-package

$(LIBGNOMEPRINTUI):  $(LIBGNOMECANVAS) $(GNOME-ICON-THEME) $(LIBGNOMEPRINT)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOMEPRINTUI).tar.bz2 && \
	chmod 755 $(LIBGNOMEPRINTUI) && \
	chown -R 0:0 $(LIBGNOMEPRINTUI) && \
	cd $(LIBGNOMEPRINTUI) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGNOMEPRINTUI)/* && \
	make P=$(LIBGNOMEPRINTUI) log-package

$(LIBGNOME-KEYRING):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBGNOME-KEYRING).tar.bz2 && \
	chmod 755 $(LIBGNOME-KEYRING) && \
	chown -R 0:0 $(LIBGNOME-KEYRING) && \
	cd $(LIBGNOME-KEYRING) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBGNOME-KEYRING)/* && \
	make P=$(LIBGNOME-KEYRING) log-package

#
# Begin GNOME Utilities
#

$(GCONF-EDITOR):  $(LIBGNOMEUI) $(GNOME-DOC-UTILS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GCONF-EDITOR).tar.bz2 && \
	chmod 755 $(GCONF-EDITOR) && \
	chown -R 0:0 $(GCONF-EDITOR) && \
	cd $(GCONF-EDITOR) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc/gnome \
		--localstatedir=/var/lib && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GCONF-EDITOR)/* && \
	make P=$(GCONF-EDITOR) log-package

$(FILE-ROLLER):  $(LIBGNOMEUI) $(GNOME-DOC-UTILS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FILE-ROLLER).tar.bz2 && \
	chmod 755 $(FILE-ROLLER) && \
	chown -R 0:0 $(FILE-ROLLER) && \
	cd $(FILE-ROLLER) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc/gnome \
		--localstatedir=/var/lib \
		--disable-nautilus-actions && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FILE-ROLLER)/* && \
	make P=$(FILE-ROLLER) log-package

$(GEDIT):  $(LIBGNOMEUI) $(LIBGNOMEPRINTUI) $(GNOME-DOC-UTILS) \
	$(GTKSOURCEVIEW) $(WHICH) $(PYGTK2)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GEDIT).tar.bz2 && \
	chmod 755 $(GEDIT) && \
	chown -R 0:0 $(GEDIT) && \
	cd $(GEDIT) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc/gnome \
		--localstatedir=/var/lib \
		--disable-scrollkeeper --disable-spell && \
	make -j2 && \
	\
	for i in eu ko ro; do \
		( cd help/$${i} && \
			ln -sfn gedit-$${i}.omf gedit-$${i}.omf.out ); \
	done; \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(GEDIT)/* && \
	make P=$(GEDIT) log-package

$(TOTEM):  $(GNOME-ICON-THEME) $(GNOME-DESKTOP) $(ISO-CODES) \
	$(GST-PLUGINS-GOOD) $(XINE-LIB) $(VLC) $(TOTEM-PL-PARSER) \
	$(LIBUNIQUE) $(LIBGDATA) $(GNOME-DOC-UTILS) $(CLUTTER) $(MX) \
	$(CLUTTER-GTK) $(CLUTTER-GST) $(LIBPEAS)

	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(TOTEM).tar.xz| tar xvf - && \
	chmod 755 $(TOTEM) && \
	chown -R 0:0 $(TOTEM) && \
	cd $(TOTEM) && \
	\
	./configure --prefix=/usr --localstatedir=/var/lib \
		--sysconfdir=/etc/gnome --mandir=/usr/share/man \
		--libexecdir=/usr/lib/totem --disable-scrollkeeper \
		--enable-xine && \
	make -j2 && \
	( cd help/bg && ln -sfn totem-bg.omf totem-bg.omf.out ) && \
	make install && \
	\
	cd .. && \
	rm -rf $(TOTEM)/* && \
	make P=$(TOTEM) log-package

$(TOTEM-PL-PARSER):  $(GMIME) $(GTK2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(TOTEM-PL-PARSER).tar.bz2 && \
	chmod 755 $(TOTEM-PL-PARSER) && \
	chown -R 0:0 $(TOTEM-PL-PARSER) && \
	cd $(TOTEM-PL-PARSER) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TOTEM-PL-PARSER)/* && \
	make P=$(TOTEM-PL-PARSER) log-package

$(ZENITY):  $(LIBGNOMECANVAS) $(GNOME-DOC-UTILS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ZENITY).tar.bz2 && \
	chmod 755 $(ZENITY) && \
	chown -R 0:0 $(ZENITY) && \
	cd $(ZENITY) && \
	\
	./configure --prefix=/usr --localstatedir=/var/lib \
		--disable-scrollkeeper --mandir=/usr/share/man && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ZENITY)/* && \
	make P=$(ZENITY) log-package

$(GNOME-UTILITIES):  $(LIBCANBERRA) $(LIBGTOP)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GNOME-UTILITIES).tar.bz2 && \
	chmod 755 $(GNOME-UTILITIES) && \
	chown -R 0:0 $(GNOME-UTILITIES) && \
	cd $(GNOME-UTILITIES) && \
	\
	patch -Np1 -i \
		$(JLFS-PATCHES)/$(GNOME-UTILITIES)-force-no-scrollkeeper.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--enable-compile-warnings=no \
		--disable-scrollkeeper && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GNOME-UTILITIES)/* && \
	make P=$(GNOME-UTILITIES) log-package

#
# Begin BLFS Multimedia Libraries & Drivers
#

$(ALSA-LIB):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ALSA-LIB).tar.bz2 && \
	chmod 755 $(ALSA-LIB) && \
	chown -R 0:0 $(ALSA-LIB) && \
	cd $(ALSA-LIB) && \
	\
	./configure --prefix=/usr --enable-static && \
	make -j2 && \
	make install && \
	install -v -m644 -D doc/asoundrc.txt \
		/usr/share/doc/$(ALSA-LIB)/asoundrc.txt && \
	\
	cd .. && \
	rm -rf $(ALSA-LIB)/* && \
	make P=$(ALSA-LIB) log-package

$(ALSA-PLUGINS):  $(PKG-CONFIG) $(ALSA-LIB)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ALSA-PLUGINS).tar.bz2 && \
	chmod 755 $(ALSA-PLUGINS) && \
	chown -R 0:0 $(ALSA-PLUGINS) && \
	cd $(ALSA-PLUGINS) && \
	\
	./configure && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(ALSA-PLUGINS) && \
	install -v -m644 doc/{README*,*.txt} \
		/usr/share/doc/$(ALSA-PLUGINS) && \
	\
	cd .. && \
	rm -rf $(ALSA-PLUGINS)/* && \
	make P=$(ALSA-PLUGINS) log-package

$(ALSA-UTILS):  $(ALSA-LIB)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ALSA-UTILS).tar.bz2 && \
	chmod 755 $(ALSA-UTILS) && \
	chown -R 0:0 $(ALSA-UTILS) && \
	cd $(ALSA-UTILS) && \
	\
	./configure --prefix=/usr \
		--disable-xmlto && \
	make -j2 && \
	make install && \
	\
	touch /etc/asound.state && \
	\
	cd .. && \
	rm -rf $(ALSA-UTILS)/* && \
	make P=$(ALSA-UTILS) log-package

$(ALSA-OSS):  $(ALSA-LIB)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ALSA-OSS).tar.bz2 && \
	chmod 755 $(ALSA-OSS) && \
	chown -R 0:0 $(ALSA-OSS) && \
	cd $(ALSA-OSS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ALSA-OSS)/* && \
	make P=$(ALSA-OSS) log-package

$(ARTS):  $(QT3) $(GLIB2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ARTS).tar.bz2 && \
	chmod 755 $(ARTS) && \
	chown -R 0:0 $(ARTS) && \
	cd $(ARTS) && \
	\
	./configure --prefix=/usr --disable-debug \
		--disable-dependency-tracking \
		--enable-final && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ARTS)/* && \
	make P=$(ARTS) log-package

$(AUDIOFILE):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(AUDIOFILE).tar.gz && \
	chmod 755 $(AUDIOFILE) && \
	chown -R 0:0 $(AUDIOFILE) && \
	cd $(AUDIOFILE) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AUDIOFILE)/* && \
	make P=$(AUDIOFILE) log-package

$(ESOUND):  $(AUDIOFILE)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ESOUND).tar.bz2 && \
	chmod 755 $(ESOUND) && \
	chown -R 0:0 $(ESOUND) && \
	cd $(ESOUND) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(ESOUND)/.libs $(ESOUND)/.deps $(ESOUND)/* && \
	make P=$(ESOUND) log-package

$(SDL):  $(ESOUND) $(ARTS) $(NASM) $(XORG7) $(AALIB) $(PTH) $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SDL).tar.gz && \
	chmod 755 $(SDL) && \
	chown -R 0:0 $(SDL) && \
	cd $(SDL) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(SDL)/html && \
	install -v -m644 docs/html/*.html /usr/share/doc/$(SDL)/html && \
	\
	cd .. && \
	rm -rf $(SDL)/* && \
	make P=$(SDL) log-package

$(LIBAO):  $(ESOUND) $(ARTS) $(NASM) $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBAO).tar.gz && \
	chmod 755 $(LIBAO) && \
	chown -R 0:0 $(LIBAO) && \
	cd $(LIBAO) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 README /usr/share/doc/$(LIBAO) && \
	\
	cd .. && \
	rm -rf $(LIBAO)/* && \
	make P=$(LIBAO) log-package

$(LIBOGG):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBOGG).tar.gz && \
	chmod 755 $(LIBOGG) && \
	chown -R 0:0 $(LIBOGG) && \
	cd $(LIBOGG) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBOGG)/* && \
	make P=$(LIBOGG) log-package

$(LIBVORBIS):  $(LIBOGG)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBVORBIS).tar.bz2 && \
	chmod 755 $(LIBVORBIS) && \
	chown -R 0:0 $(LIBVORBIS) && \
	cd $(LIBVORBIS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m644 doc/Vorbis* /usr/share/doc/$(LIBVORBIS) && \
	\
	cd .. && \
	rm -rf $(LIBVORBIS)/* && \
	make P=$(LIBVORBIS) log-package

$(FAAC):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FAAC).tar.gz && \
	mv faac $(FAAC) && \
	chmod 755 $(FAAC) && \
	chown -R 0:0 $(FAAC) && \
	cd $(FAAC) && \
	\
	./bootstrap && \
	sed -i -e '/obj-type/d' -e '/Long Term/d' frontend/main.c && \
	./configure --prefix=/usr \
		--enable-shared --with-mp4v2 && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo wait for vlc rm -rf $(FAAC)/* && \
	make P=$(FAAC) log-package

$(FAAD2):  $(XMMS) $(LIBID3TAG) $(ID3LIB)
	set +h && \
	\
	rm -rf $(FAAD2) && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FAAD2).tar.gz && \
	chmod 755 $(FAAD2) && \
	chown -R 0:0 $(FAAD2) && \
	cd $(FAAD2) && \
	\
	autoreconf -vif && \
	./configure --prefix=/usr \
		--with-drm \
		--with-mp4v2 \
		--with-xmms && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo wait for vlc rm -rf $(FAAD2)/* && \
	make P=$(FAAD2) log-package

$(LIBMPEG2):  $(NASM) $(A52DEC) $(SDL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMPEG2).tar.gz && \
	chmod 755 $(LIBMPEG2) && \
	chown -R 0:0 $(LIBMPEG2) && \
	cd $(LIBMPEG2) && \
	\
	./configure --prefix=/usr --enable-shared-liba52 && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo obsolete rm -rf $(LIBMPEG2)/* && \
	make P=$(LIBMPEG2) log-package

$(LIBMPEG3):  $(NASM) $(A52DEC)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBMPEG3)-src.tar.bz2 && \
	chmod 755 $(LIBMPEG3) && \
	chown -R 0:0 $(LIBMPEG3) && \
	cd $(LIBMPEG3) && \
	\
	patch -Np0 -i $(JLFS-PATCHES)/$(LIBMPEG3)-libmpeg3.so.patch && \
	\
	./configure --prefix=/usr --enable-shared-liba52 && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo obsolete rm -rf $(LIBMPEG3)/* && \
	make P=$(LIBMPEG3) log-package

$(LIBMAD):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMAD).tar.gz && \
	chmod 755 $(LIBMAD) && \
	chown -R 0:0 $(LIBMAD) && \
	cd $(LIBMAD) && \
	\
	sed -i '/-fforce-mem/d' configure && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	cp -av $(JLFS-CONFIGS)/libmad.pc /usr/lib/pkgconfig/mad.pc && \
	\
	cd .. && \
	rm -rf $(LIBMAD)/.libs $(LIBMAD)/.deps $(LIBMAD)/* && \
	make P=$(LIBMAD) log-package

$(LIBQUICKTIME):  $(PKG-CONFIG) $(LIBPNG) $(LIBJPEG) $(XORG7) $(GTK2) \
	$(ALSA-LIB) $(LIBVORBIS) $(LAME) $(LIBDV) $(X264) \
	$(FAAC) $(FAAD2)

	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBQUICKTIME).tar.gz && \
	chmod 755 $(LIBQUICKTIME) && \
	chown -R 0:0 $(LIBQUICKTIME) && \
	cd $(LIBQUICKTIME) && \
	\
	./configure --prefix=/usr \
		--without-doxygen && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(LIBQUICKTIME) && \
	install -v -m644 README doc/{*.txt,*.html,mainpage.incl} \
		/usr/share/doc/$(LIBQUICKTIME) && \
	\
	cd .. && \
	rm -rf $(LIBQUICKTIME)/* && \
	make P=$(LIBQUICKTIME) log-package

$(LIBFAME):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBFAME).tar.gz && \
	chmod 755 $(LIBFAME) && \
	chown -R 0:0 $(LIBFAME) && \
	cd $(LIBFAME) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBFAME)-gcc34-1.patch && \
	sed -i 's/$CC --version/$CC -dumpversion/' configure && \
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBFAME)/* && \
	make P=$(LIBFAME) log-package

$(SPEEX):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SPEEX).tar.gz && \
	chmod 755 $(SPEEX) && \
	chown -R 0:0 $(SPEEX) && \
	cd $(SPEEX) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SPEEX)/* && \
	make P=$(SPEEX) log-package

$(ID3LIB):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(ID3LIB).tar.gz && \
	chmod 755 $(ID3LIB) && \
	chown -R 0:0 $(ID3LIB) && \
	cd $(ID3LIB) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(ID3LIB)-gcc43-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(ID3LIB)-test_suite-1.patch && \
	./configure --prefix=/usr \
		--enable-shared --disable-static && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(ID3LIB) && \
	install -v -m644 doc/*.{gif,jpg,png,ico,css,txt,php,html} \
		/usr/share/doc/$(ID3LIB) && \
	\
	cd .. && \
	rm -rf $(ID3LIB)/* && \
	make P=$(ID3LIB) log-package

$(FLAC):  $(LIBOGG) $(XMMS) $(NASM)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(FLAC).tar.gz && \
	chmod 755 $(FLAC) && \
	chown -R 0:0 $(FLAC) && \
	cd $(FLAC) && \
	\
	sed -i 's/#include <stdio.h>/&\n#include <string.h>/' \
		examples/cpp/encode/file/main.cpp && \
	\
	./configure --prefix=/usr --disable-thorough-tests && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(FLAC)/* && \
	make P=$(FLAC) log-package

$(LIBDVDCSS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(LIBDVDCSS).tar.bz2 && \
	chmod 755 $(LIBDVDCSS) && \
	chown -R 0:0 $(LIBDVDCSS) && \
	cd $(LIBDVDCSS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBDVDCSS)/* && \
	make P=$(LIBDVDCSS) log-package

$(LIBDVDREAD):  $(LIBDVDCSS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBDVDREAD).tar.gz && \
	chmod 755 $(LIBDVDREAD) && \
	chown -R 0:0 $(LIBDVDREAD) && \
	cd $(LIBDVDREAD) && \
	\
	./configure --prefix=/usr --with-libdvdcss && \
	make -j2 && \
	make install && \
	\
	( cd /usr/include && \
		patch -Np0 -i $(JLFS-PATCHES)/$(LIBDVDREAD)-include-inttypes.patch ) && \
	\
	cd .. && \
	rm -rf $(LIBDVDREAD)/* && \
	make P=$(LIBDVDREAD) log-package

$(LIBDV):  $(POPT) $(PKG-CONFIG) $(SDL) $(GTK) $(XORG7)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBDV).tar.gz && \
	chmod 755 $(LIBDV) && \
	chown -R 0:0 $(LIBDV) && \
	cd $(LIBDV) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(LIBDV) && \
	install -v -m644 README* /usr/share/doc/$(LIBDV) && \
	\
	cd .. && \
	rm -rf $(LIBDV)/* && \
	make P=$(LIBDV) log-package

$(A52DEC):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(A52DEC).tar.gz && \
	chmod 755 $(A52DEC) && \
	chown -R 0:0 $(A52DEC) && \
	cd $(A52DEC) && \
	\
	./configure --prefix=/usr --enable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo wait for VLC rm -rf $(A52DEC)/* && \
	make P=$(A52DEC) log-package

$(XVIDCORE):  $(NASM)
	set +h && \
	\
	tar zxvf $(JLFS-TARBALLS)/$(XVIDCORE).tar.gz && \
	mv xvidcore $(XVIDCORE) && \
	chmod 755 $(XVIDCORE) && \
	chown -R 0:0 $(XVIDCORE) && \
	cd $(XVIDCORE) && \
	\
	cd build/generic && \
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	chmod -v 755 /usr/lib/libxvidcore.so.4.2 && \
	ln -v -sf libxvidcore.so.4.1 /usr/lib/libxvidcore.so.4 && \
	ln -v -sf libxvidcore.so.4 /usr/lib/libxvidcore.so && \
	\
	install -v -m755 -d /usr/share/doc/$(XVIDCORE)/examples && \
	install -v -m644 ../../doc/* /usr/share/doc/$(XVIDCORE) && \
	install -v -m644 ../../examples/* \
		/usr/share/doc/$(XVIDCORE)/examples && \
	cd ../.. && \
	\
	cd .. && \
	rm -rf $(XVIDCORE)/* && \
	make P=$(XVIDCORE) log-package

$(XINE-LIB):  $(XORG7) $(ESOUND) $(ALSA-LIB) $(ARTS) $(PKG-CONFIG) \
	$(AALIB) $(LIBVORBIS) $(LIBFAME) $(LIBMNG) $(FLAC) $(SDL) \
	$(SPEEX) $(IMAGEMAGICK) $(FFMPEG)

	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(XINE-LIB).tar.xz| tar xvf - && \
	chmod 755 $(XINE-LIB) && \
	chown -R 0:0 $(XINE-LIB) && \
	cd $(XINE-LIB) && \
	\
	echo for zlib-1.2.6 sed -i 's#gzgetc(#gzgetc_(#' src/xine-engine/osd.c && \
	\
	./configure --prefix=/usr \
		--disable-musepack \
		--disable-vcd \
		--enable-static \
		--docdir=/usr/share/doc/$(XINE-LIB) && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XINE-LIB)/* && \
	make P=$(XINE-LIB) log-package

$(LIBMIKMOD):  $(ALSA-LIB) $(ESOUND)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMIKMOD).tar.gz && \
	chmod 755 $(LIBMIKMOD) && \
	chown -R 0:0 $(LIBMIKMOD) && \
	cd $(LIBMIKMOD) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(LIBMIKMOD)-a.diff && \
	\
	sed -i -e "s/VERSION=10/VERSION=11/" \
		-e "s/sys_asoundlib/alsa_asoundlib/" \
		-e "s/snd_cards/snd_card_load/g" \
		-e "s|sys/asoundlib.h|alsa/asoundlib.h|g" \
		-e "s/^LIBOBJS/#LIBOBJS/" \
			configure.in && \
	\
	autoconf && \
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	chmod 755 /usr/lib/libmikmod.so.2.0.4 && \
	install -v -m644 -D docs/mikmod.html \
		/usr/share/doc/$(LIBMIKMOD)/mikmod.html && \
	\
	cd .. && \
	rm -rf $(LIBMIKMOD)/* && \
	make P=$(LIBMIKMOD) log-package

$(GSTREAMER):  $(GLIB2) $(LIBXML2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GSTREAMER).tar.bz2 && \
	chmod 755 $(GSTREAMER) && \
	chown -R 0:0 $(GSTREAMER) && \
	cd $(GSTREAMER) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GSTREAMER)/* && \
	make P=$(GSTREAMER) log-package

$(LIBOIL):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBOIL).tar.gz && \
	chmod 755 $(LIBOIL) && \
	chown -R 0:0 $(LIBOIL) && \
	cd $(LIBOIL) && \
	\
	./configure --prefix=/usr --enable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBOIL)/* && \
	make P=$(LIBOIL) log-package

$(GST-PLUGINS-BASE):  $(GSTREAMER) $(LIBOIL) $(ALSA-LIB) $(LIBOGG) \
	$(LIBVORBIS) $(CDPARANOIA) $(FREETYPE) $(PANGO) $(GTK2) $(XORG7) \
	$(GNOME-VFS)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GST-PLUGINS-BASE).tar.bz2 && \
	chmod 755 $(GST-PLUGINS-BASE) && \
	chown -R 0:0 $(GST-PLUGINS-BASE) && \
	cd $(GST-PLUGINS-BASE) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GST-PLUGINS-BASE)/* && \
	make P=$(GST-PLUGINS-BASE) log-package

$(GST-PLUGINS-GOOD):  $(GST-PLUGINS-BASE) $(AALIB) $(CAIRO) $(LIBDV) \
	$(ESOUND) $(FLAC) $(GTK2) $(LIBJPEG) $(LIBPNG) \
	$(SPEEX) $(XORG7) $(GCONF)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GST-PLUGINS-GOOD).tar.bz2 && \
	chmod 755 $(GST-PLUGINS-GOOD) && \
	chown -R 0:0 $(GST-PLUGINS-GOOD) && \
	cd $(GST-PLUGINS-GOOD) && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc/gnome && \
	make -j2 && \
	make install && \
	echo make -C docs/plugins install-data && \
	\
	cd .. && \
	rm -rf $(GST-PLUGINS-GOOD)/* && \
	make P=$(GST-PLUGINS-GOOD) log-package

$(GST-PLUGINS-UGLY):  $(GST-PLUGINS-BASE) $(LAME) $(A52DEC) $(LIBDVDREAD) \
	$(LIBMAD) $(MPEG2DEC) $(LIBID3TAG) $(MADPLAY) $(ID3LIB)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GST-PLUGINS-UGLY).tar.bz2 && \
	chmod 755 $(GST-PLUGINS-UGLY) && \
	chown -R 0:0 $(GST-PLUGINS-UGLY) && \
	cd $(GST-PLUGINS-UGLY) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	echo make -C docs/plugins install-data && \
	\
	cd .. && \
	rm -rf $(GST-PLUGINS-UGLY)/* && \
	make P=$(GST-PLUGINS-UGLY) log-package

$(LIBMUSICBRAINZ):  $(EXPAT) $(PYTHON)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LIBMUSICBRAINZ).tar.gz && \
	chmod 755 $(LIBMUSICBRAINZ) && \
	chown -R 0:0 $(LIBMUSICBRAINZ) && \
	cd $(LIBMUSICBRAINZ) && \
	\
	patch -Np1 -i \
		$(JLFS-PATCHES)/$(LIBMUSICBRAINZ)-missing-includes-1.patch && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	(cd python && python setup.py build) && \
	make install && \
	(cd python && python setup.py install) && \
	\
	cd .. && \
	rm -rf $(LIBMUSICBRAINZ)/* && \
	make P=$(LIBMUSICBRAINZ) log-package

$(MPEG2DEC):  $(XORG7) $(SDL)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(MPEG2DEC).tar.gz && \
	chmod 755 $(MPEG2DEC) && \
	chown -R 0:0 $(MPEG2DEC) && \
	cd $(MPEG2DEC) && \
	\
	./configure --prefix=/usr --enable-shared && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo wait for VLC rm -rf $(MPEG2DEC)/* && \
	make P=$(MPEG2DEC) log-package

$(X264):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(X264).tar.bz2 && \
	chmod 755 $(X264) && \
	chown -R 0:0 $(X264) && \
	cd $(X264) && \
	\
	./configure --prefix=/usr --enable-shared \
		--disable-asm && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	echo wait for VLC rm -rf $(X264)/* && \
	make P=$(X264) log-package

$(LIBTHEORA):
	set +h && \
	\
	tar jxf $(JLFS-TARBALLS)/$(LIBTHEORA).tar.bz2 && \
	chmod 755 $(LIBTHEORA) && \
	chown -R 0:0 $(LIBTHEORA) && \
	cd $(LIBTHEORA) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBTHEORA)/* && \
	make P=$(LIBTHEORA) log-package

#
# Begin Audio Utilities
#

$(MPG123):  $(ALSA-LIB)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(MPG123).tar.bz2 && \
	chmod 755 $(MPG123) && \
	chown -R 0:0 $(MPG123) && \
	cd $(MPG123) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(MPG123)/* && \
	make P=$(MPG123) log-package

$(VORBIS-TOOLS):  $(LIBVORBIS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(VORBIS-TOOLS).tar.gz && \
	chmod 755 $(VORBIS-TOOLS) && \
	chown -R 0:0 $(VORBIS-TOOLS) && \
	cd $(VORBIS-TOOLS) && \
	\
	./configure --prefix=/usr \
		--enable-vcut \
		--mandir=/usr/share/man \
		--without-curl && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(VORBIS-TOOLS)/* && \
	make P=$(VORBIS-TOOLS) log-package

$(XMMS):  $(GTK)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(XMMS).tar.bz2 && \
	chmod 755 $(XMMS) && \
	chown -R 0:0 $(XMMS) && \
	cd $(XMMS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(XMMS) && \
	install -v -m644 FAQ README /usr/share/doc/$(XMMS) && \
	\
	cd .. && \
	rm -rf $(XMMS)/* && \
	make P=$(XMMS) log-package

$(LAME):  $(GTK) $(NASM)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LAME).tar.gz && \
	chmod 755 $(LAME) && \
	chown -R 0:0 $(LAME) && \
	cd $(LAME) && \
	\
	./configure --prefix=/usr --enable-mp3rtp && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(LAME)/* && \
	make P=$(LAME) log-package

$(CDPARANOIA):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(CDPARANOIA).src.tgz && \
	chmod 755 $(CDPARANOIA) && \
	chown -R 0:0 $(CDPARANOIA) && \
	cd $(CDPARANOIA) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(CDPARANOIA)-gcc_fixes-1.patch && \
	\
	./configure --prefix=/usr && \
	echo no make -j2 && \
	make && \
	make install && \
	chmod -v 755 /usr/lib/libcdda_*.so.0.10.2 && \
	\
	cd .. && \
	rm -rf $(CDPARANOIA)/* && \
	make P=$(CDPARANOIA) log-package

$(AUDACIOUS):  $(GLADE) $(LIBMCS) $(PCRE) $(LIBMAD) $(LAME) \
	$(LIBSAMPLERATE) $(GLIB2) $(GLIB3) $(LIBMOWGMI)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(AUDACIOUS).tar.bz2 && \
	chmod 755 $(AUDACIOUS) && \
	chown -R 0:0 $(AUDACIOUS) && \
	cd $(AUDACIOUS) && \
	\
	./configure --prefix=/usr \
		--enable-one-plugin-dir \
		--enable-samplerate && \
	make -j2 && \
	make install && \
	install -v -m644 -D README /usr/share/doc/$(AUDACIOUS)/README && \
	\
	cd .. && \
	rm -rf $(AUDACIOUS)/* && \
	make P=$(AUDACIOUS) log-package

$(AUDACIOUS-PLUGINS):  $(AUDACIOUS)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(AUDACIOUS-PLUGINS).tar.bz2 && \
	chmod 755 $(AUDACIOUS-PLUGINS) && \
	chown -R 0:0 $(AUDACIOUS-PLUGINS) && \
	cd $(AUDACIOUS-PLUGINS) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AUDACIOUS-PLUGINS)/* && \
	make P=$(AUDACIOUS-PLUGINS) log-package

#
# Begin BLFS Video Utilities
#

$(FFMPEG):  $(A52DEC) $(XVIDCORE) $(FAAC) $(FAAD2) $(FREETYPE) $(LAME) \
	$(LIBVORBIS) $(SDL) $(LIBOGG) $(X264) $(DIVX4LINUX) $(YASM)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FFMPEG).tar.bz2 && \
	chmod 755 $(FFMPEG) && \
	chown -R 0:0 $(FFMPEG) && \
	cd $(FFMPEG) && \
	\
	./configure --prefix=/usr \
		--enable-gpl \
		--disable-static \
		--enable-shared \
		--enable-postproc \
		--enable-pthreads \
		--enable-libmp3lame \
		--enable-libfaac \
		--enable-libxvid \
		--enable-libx264 \
		\
		--enable-nonfree \
		--enable-swscale && \
	\
	make -j2 && \
	\
	gcc tools/qt-faststart.c -o qt-faststart && \
	\
	make install && \
	make install-man && \
	mkdir -p /usr/share/doc/$(FFMPEG) && \
	cp -av doc/*.txt /usr/share/doc/$(FFMPEG) && \
	cp -av qt-faststart /usr/bin && \
	\
	cd .. && \
	echo source wait for VLC \
		rm -rf $(FFMPEG)/.libs $(FFMPEG)/.depend $(FFMPEG)/* && \
	make P=$(FFMPEG) log-package

$(FFMPEG-OLD):  $(A52DEC) $(XVIDCORE) $(FAAC) $(FAAD2) $(FREETYPE) $(LAME) \
	$(LIBVORBIS) $(SDL) $(LIBOGG) $(X264) $(DIVX4LINUX)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(FFMPEG-OLD).tar.bz2 && \
	chmod 755 $(FFMPEG-OLD) && \
	chown -R 0:0 $(FFMPEG-OLD) && \
	cd $(FFMPEG-OLD) && \
	\
	./configure --prefix=$(LFS)/usr/src/$(FFMPEG-OLD)/usr \
		--enable-gpl \
		--enable-shared \
		--enable-postproc \
		--enable-pthreads \
		--enable-libmp3lame \
		--enable-libfaac \
		--enable-libxvid \
		--enable-libfaad \
		--enable-libx264 \
		\
		--enable-nonfree \
		--enable-swscale && \
	\
	make -j2 && \
	make install-libs && \
	make install-headers && \
	make distclean

$(AVIFILE):  $(QT3) $(SDL) $(LIBVORBIS) $(A52DEC) $(LAME) $(LIBMAD) \
	$(XVIDCORE) $(FAAD2) $(DIVX4LINUX)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(AVIFILE).tar.bz2 && \
	chmod 755 $(AVIFILE) && \
	chown -R 0:0 $(AVIFILE) && \
	cd $(AVIFILE) && \
	\
	install -v -d -m755 /usr/lib/$(AVIFILE)/win32 && \
	tar -xvf $(JLFS-TARBALLS)/$(AVIFILE-BINS).tgz -C /usr/lib/$(AVIFILE) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(AVIFILE)-gcc41-1.patch && \
	sed -i '/^SUBDIRS/s/qtvidcap //' samples/Makefile.am && \
	sed -i '/^SUBDIRS/s/qtvidcap //' samples/Makefile.in && \
	\
	./configure --prefix=/usr \
		--with-win32-path=/usr/lib/$(AVIFILE)/win32 && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(AVIFILE)/* && \
	make P=$(AVIFILE) log-package

$(MPLAYER):  $(XORG7) $(GTK2) $(CDPARANOIA) $(LIBDV) $(LIBDVREAD) $(ALSA) \
	$(ARTS) $(ESOUND) $(SDL) $(AALIB) $(FONTCONFIG) $(FREETYPE) \
	$(FRIBIDI) $(GIFLIB) $(LIBJPEG) $(LIBPNG) $(FAAC) $(FAAD2) $(FFMPEG) \
	$(LAME) $(LIBFAME) $(LIBMAD) $(LIBVORBIS) $(LZO) $(X264) $(XVIDCORE) \
	$(LIBDVDNAV) $(DIVX4LINUX)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(MPLAYER).tar.bz2 && \
	chmod 755 $(MPLAYER) && \
	chown -R 0:0 $(MPLAYER) && \
	cd $(MPLAYER) && \
	\
	install -v -d -m755 /usr/lib/mplayer/codecs && \
	\
	for i in $(MPLAYER-CODECS-ALL) \
		$(MPLAYER-CODECS-ESSENTIAL) \
		$(MPLAYER-CODECS-QT5DLLS) \
		$(MPLAYER-CODECS-QT6DLLS) \
		$(MPLAYER-CODECS-QT63DLLS) \
		$(MPLAYER-CODECS-QT65DLLS) \
		$(MPLAYER-CODECS-QTEXTRAS) \
		$(MPLAYER-CODECS-RP8) \
		$(MPLAYER-CODECS-RP9) \
		$(MPLAYER-CODECS-UNSUPPORTED) \
		$(MPLAYER-CODECS-WIN32) \
		$(MPLAYER-CODECS-XANIMDLLS); do \
		\
		tar jxf $(JLFS-TARBALLS)/$${i}.tar.bz2 \
			-C /usr/lib/mplayer/codecs --strip-components=1; \
	done && \
	echo unzip $(JLFS-TARBALLS)/$(MPLAYER-CODECS-WINDOWS-ALL).zip \
		-d /usr/lib/mplayer/codecs && \
	chown -v -R root:root /usr/lib/mplayer/codecs && \
	\
	install -v -d -m755 /usr/share/mplayer/Skin && \
	tar jxvf $(JLFS-TARBALLS)/$(MPLAYER-BLUE-SKIN).tar.bz2 \
		-C /usr/share/mplayer/Skin && \
	chown -v -R root:root /usr/share/mplayer/Skin/Blue && \
	chmod -v 755 /usr/share/mplayer/Skin/Blue{,/icons} && \
	ln -sfv Blue /usr/share/mplayer/Skin/default && \
	\
	./configure --prefix=/usr --confdir=/etc/mplayer \
		--disable-ivtv \
		--enable-largefiles \
		--enable-menu \
		--enable-gui \
		--enable-dynamic-plugins \
		--enable-xmms \
		--enable-joystick \
		\
		--codecsdir=/usr/lib/mplayer/codecs && \
	make -j2 && \
	make install && \
	\
	ln -v -sfn libdha.so.1.0 /usr/lib/libdha.so && \
	install -v -d -m755 /etc/mplayer && \
	install -m644 etc/codecs.conf /etc/mplayer && \
	install -m644 etc/*.conf /etc/mplayer && \
	echo "dev.rtc.max-user-freq=1024" >> /etc/sysctl.conf && \
	\
	install -v -m750 -d /root/.mplayer && \
	install -v -m750 -d /usr/share/mplayer/font && \
	ln -v -sfn /usr/share/fonts/X11-TTF/luxisri.ttf \
		/root/.mplayer/subfont.ttf && \
	tar jxvf $(JLFS-TARBALLS)/$(MPLAYER-FONT).tar.bz2 \
		-C /usr/share/mplayer/font && \
	chown -v -R root:root /usr/share/mplayer/font && \
	cd /usr/share/mplayer/font && \
	ln -v -sfn font-arial-iso-8859-1/font-arial-14-iso-8859-1/* . && \
	\
	cd /usr/src && \
	rm -rf $(MPLAYER)/* && \
	make P=$(MPLAYER) log-package

$(XINE-UI):  $(AALIB)
	set +h && \
	\
	xz -dc $(JLFS-TARBALLS)/$(XINE-UI).tar.xz| tar xvf - && \
	chmod 755 $(XINE-UI) && \
	chown -R 0:0 $(XINE-UI) && \
	cd $(XINE-UI) && \
	\
	sed -i -e 's/info_ptr->//' \
		-e '/RGB/icolor_type = png_get_color_type(png_ptr, info_ptr);' \
			src/xitk/Imlib-light/load.c && \
	sed -i -e '/#include.*curl.types.h*/d' src/xitk/download.c && \
	\
	./configure --prefix=/usr --disable-lirc && \
	make -j2 && \
	make docsdir=/usr/share/doc/$(XINE-UI) install && \
	\
	cd .. && \
	rm -rf $(XINE-UI)/* && \
	make P=$(XINE-UI) log-package

$(TRANSCODE):  $(LIBXML2) $(FREETYPE) $(FFMPEG-OLD) $(MPEG2DEC) $(LAME) \
	$(PKG-CONFIG) $(XORG7) $(XVIDCORE) $(FREETYPE) \
	$(AVIFILE) $(LIBOGG) $(LIBVORBIS) $(LIBDVDREAD) $(LIBDV) \
	$(LIBQUICKTIME) $(A52DEC) $(LIBXML2) $(SDL) $(GTK) $(LIBFAME) \
	$(IMAGEMAGICK) $(LIBJPEG) $(MJPEGTOOLS) $(LIBMPEG3)

	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(TRANSCODE).tar.bz2 && \
	chmod 755 $(TRANSCODE) && \
	chown -R 0:0 $(TRANSCODE) && \
	cd $(TRANSCODE) && \
	\
	PKG_CONFIG_PATH=$(LFS)/usr/src/$(FFMPEG-OLD)/usr/lib/pkgconfig \
	./configure --prefix=/usr \
		--enable-imagemagick \
		--enable-x264 \
		--enable-xvid \
		--enable-a52 \
		--enable-faac \
		--enable-a52-default-decoder \
		--enable-libmpeg3 \
		--enable-libpostproc \
		--enable-sdl \
		--enable-gtk \
		--enable-mjpegtools \
		--enable-freetype2 \
		--enable-libxml2 \
		--enable-lame \
		--enable-ogg \
		--enable-vorbis \
		--enable-libdvdread \
		--enable-libdv \
		--enable-libquicktime \
		--enable-libfame \
		--with-libpostproc-includes=/usr/include/libpostproc \
		--with-libswscale \
		--with-x && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(TRANSCODE)/* && \
	make P=$(TRANSCODE) log-package

#
# Begin CDDVD Utilities
#

$(CDRTOOLS):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(CDRTOOLS).tar.bz2 && \
	chmod 755 $(CDRTOOLS) && \
	chown -R 0:0 $(CDRTOOLS) && \
	touch $(CDRTOOLS) && \
	cd $(CDRTOOLS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(CDRTOOLS)-mkisofs_iconv-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(CDRTOOLS)-ascii-2.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(CDRTOOLS)-glibc_conflicts-3.patch && \
	\
	make INS_BASE=/usr DEFINSUSR=root DEFINSGRP=root && \
	make INS_BASE=/usr DEFINSUSR=root DEFINSGRP=root install && \
	\
	install -v -m755 -d /usr/share/doc/$(CDRTOOLS) && \
	install -v -m644 README.* ABOUT doc/*.ps /usr/share/doc/$(CDRTOOLS) && \
	\
	cd .. && \
	rm -rf $(CDRTOOLS)/* && \
	make P=$(CDRTOOLS) log-package

$(CDRDAO):  $(LIBAO) $(LIBVORBIS) $(LIBMAD) $(LAME)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(CDRDAO).tar.bz2 && \
	chmod 755 $(CDRDAO) && \
	chown -R 0:0 $(CDRDAO) && \
	cd $(CDRDAO) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(CDRDAO)-gcc43_fixes-2.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(CDRDAO)-glibc210_fixes-1.patch && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make install && \
	install -v -m755 -d /usr/share/doc/$(CDRDAO) && \
	install -v -m644 README* /usr/share/doc/$(CDRDAO) && \
	\
	cd .. && \
	rm -rf $(CDRDAO)/* && \
	make P=$(CDRDAO) log-package

$(UDFTOOLS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(UDFTOOLS).tar.gz && \
	chmod 755 $(UDFTOOLS) && \
	chown -R 0:0 $(UDFTOOLS) && \
	cd $(UDFTOOLS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(UDFTOOLS)-limits.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(UDFTOOLS)-gcc4-1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(UDFTOOLS)-misc_fixes-1.patch && \
	\
	sed -i -e 's/(char\*)spm +=/spm = (char\*)spm +/' wrudf/wrudf.c && \
	./configure --prefix=/usr && \
	\
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(UDFTOOLS)/* && \
	make P=$(UDFTOOLS) log-package

$(DVD-RW-TOOLS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(DVD-RW-TOOLS).tar.gz && \
	chmod 755 $(DVD-RW-TOOLS) && \
	chown -R 0:0 $(DVD-RW-TOOLS) && \
	cd $(DVD-RW-TOOLS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(DVD-RW-TOOLS)-limits.patch && \
	\
	make all rpl8 btcflash && \
	make prefix=/usr install && \
	install -v -m644 -D index.html \
		/usr/share/doc/$(DVD-RW-TOOLS)/index.html && \
	cd .. && \
	rm -rf $(DVD-RW-TOOLS)/* && \
	make P=$(DVD-RW-TOOLS) log-package

#
# Begin BLFS Printing
#

$(CUPS):  $(LIBJPEG) $(LIBPNG) $(LIBTIFF) $(OPENLDAP) $(OPENSSL) $(PAM) $(DBUS) $(PKG-CONFIG)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(CUPS)-source.tar.bz2 && \
	chmod 755 $(CUPS) && \
	chown -R 0:0 $(CUPS) && \
	cd $(CUPS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(CUPS)-security_fixes-2.patch && \
	\
	useradd -c "Print Service User" -d /dev/null -g lp -s /bin/false \
		-u 9 lp; \
	\
	./configure && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(CUPS)/* && \
	make P=$(CUPS) log-package

$(LPRNG):  $(OPENSSL) $(TCP-WRAPPER)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LPRNG).tgz && \
	chmod 755 $(LPRNG) && \
	chown -R 0:0 $(LPRNG) && \
	cd $(LPRNG) && \
	\
	sed -i 's@CLEAR,0@CLEAR,CLEAR,NULL@' src/common/lpq.c && \
	sed -i 's@ fd, l@ fd, (char*) l@' src/common/krb5_auth.c && \
	sed -i -e 's@\(fi\|done\) \\@\1; \\@' \
		-e "s/^SHELL/#&/" Makefile.in && \
	\
	./configure --prefix=/usr \
		--libexecdir=/usr/lib/lprng \
		--enable-tcpwrappers \
		--sysconfdir=/etc \
		--enable-shared \
		--disable-werror && \
	echo no make -j2 && \
	make && \
	make install && \
	\
	install -v -m755 -d /usr/share/doc/$(LPRNG) && \
	cp -v -R DOCS/* PrintingCookbook /usr/share/doc/$(LPRNG) && \
	rm -f /etc/rc.d/init.d/lpd && \
	\
	cd .. && \
	\
	rm -rf $(LPRNG)/* && \
	make P=$(LPRNG) log-package

$(ESPGS):  $(CUPS) $(GTK2) $(LIBPNG) $(XORG7)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(ESPGS)-source.tar.bz2 && \
	chmod 755 $(ESPGS) && \
	chown -R 0:0 $(ESPGS) && \
	cd $(ESPGS) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(ESPGS)-bov_fix-1.patch && \
	\
	sed -i "s/bbox.dev/x11.dev/" Makefile.in && \
	./configure --prefix=/usr --enable-threads --without-omni && \
	echo no make -j2 && \
	make && \
	make so && \
	make install && \
	\
	install -d /usr/share/doc/$(ESPGS) && \
	ln -v -sfn ../../ghostscript/8.15/doc /usr/share/doc/$(ESPGS) && \
	\
	make soinstall && \
	install -v -d -m755 /usr/include/ps && \
	install -v -m644 src/*.h /usr/include/ps && \
	ln -v -sfn ps /usr/include/ghostscript && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GNU-GS-FONTS-OTHER).tar.gz \
		-C /usr/share/ghostscript && \
	tar xvf $(JLFS-TARBALLS)/$(GHOSTSCRIPT-FONTS-STD).tar.gz \
		-C /usr/share/ghostscript && \
	chown -v root:root /usr/share/ghostscript/fonts/* && \
	\
	cd .. && \
	rm -rf $(ESPGS)/* && \
	make P=$(ESPGS) log-package

$(GUTENPRINT):  $(CUPS) $(GTK2) $(GIMP)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(GUTENPRINT).tar.bz2 && \
	chmod 755 $(GUTENPRINT) && \
	chown -R 0:0 $(GUTENPRINT) && \
	cd $(GUTENPRINT) && \
	\
	./configure --prefix=/usr --with-translated-ppds=no && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(GUTENPRINT)/* && \
	make P=$(GUTENPRINT) log-package

#
# Begin BLFS Scanning
#

$(SANE-BACKENDS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(SANE-BACKENDS).tar.gz && \
	chmod 755 $(SANE-BACKENDS) && \
	chown -R 0:0 $(SANE-BACKENDS) && \
	cd $(SANE-BACKENDS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(SANE-BACKENDS)/* && \
	make P=$(SANE-BACKENDS) log-package

$(XSANE):  $(GTK2) $(SANE-BACKENDS) $(LIBTIFF) $(LIBJPEG) $(LCMS) $(GIMP)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XSANE).tar.gz && \
	chmod 755 $(XSANE) && \
	chown -R 0:0 $(XSANE) && \
	cd $(XSANE) && \
	\
	./configure --prefix=/usr && \
	make -j2 && \
	make xsanedocdir=/usr/share/doc/$(XSANE) install && \
	ln -v -sfn ../../doc/$(XSANE) /usr/share/sane/xsane/doc && \
	ln -v -sfn /usr/bin/xsane /usr/lib/gimp/2.0/plug-ins/ && \
	\
	cd .. && \
	rm -rf $(XSANE)/* && \
	make P=$(XSANE) log-package

#
# Begin BLFS Typesetting
#

$(A2PS):  $(CUPS) $(LPRNG)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(A2PS).tar.gz && \
	chmod 755 $(A2PS) && \
	chown -R 0:0 $(A2PS) && \
	cd $(A2PS) && \
	\
	sed -i "s|emacs||" contrib/Makefile.in && \
	sed -i 's/+0 -1/-k 1,2/' afm/make_fonts_map.sh && \
	sed -i "s|/usr/local/share|/usr/share|" configure && \
	sed -i "s|char \*malloc ();|/* & */|" \
		lib/path-concat.c && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc/a2ps --localstatedir=/var \
		--enable-shared --with-medium=letter && \
	make -j2 && \
	make install && \
	\
	tar xvf $(JLFS-TARBALLS)/$(I18N-FONTS).tar.gz && \
	cp -v $(I18N-FONTS)/fonts/* /usr/share/a2ps/fonts && \
	cp -v $(I18N-FONTS)/afm/* /usr/share/a2ps/afm && \
	\
	cd /usr/share/a2ps/afm && \
	./make_fonts_map.sh && \
	mv fonts.map.new fonts.map && \
	\
	cd /usr/src && \
	rm -rf $(A2PS)/* && \
	make P=$(A2PS) log-package

$(PSUTILS):
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(PSUTILS).tar.gz && \
	mv psutils $(PSUTILS) && \
	chmod 755 $(PSUTILS) && \
	chown -R 0:0 $(PSUTILS) && \
	cd $(PSUTILS) && \
	\
	sed 's@/usr/local@/usr@g' Makefile.unix > Makefile && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(PSUTILS)/* && \
	make P=$(PSUTILS) log-package

$(GSVIEW):  $(GTK) $(ESPGS) $(A2PS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(GSVIEW).tar.gz && \
	chmod 755 $(GSVIEW) && \
	chown -R 0:0 $(GSVIEW) && \
	cd $(GSVIEW) && \
	\
	sed -i 's:netscape:firefox:' srcunx/gvxreg.c && \
	sed -i 's:999:99999:' src/gvcver.h && \
	sed 's:/local::' srcunx/unx.mak > Makefile && \
	echo no make -j2 && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GSVIEW)/* && \
	make P=$(GSVIEW) log-package

$(XPDF):  $(LESSTIF) $(FREETYPE) $(ESPGS)
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(XPDF).tar.gz && \
	chmod 755 $(XPDF) && \
	chown -R 0:0 $(XPDF) && \
	cd $(XPDF) && \
	\
	patch -Np1 -i $(JLFS-PATCHES)/$(XPDF)pl1.patch && \
	patch -Np1 -i $(JLFS-PATCHES)/$(XPDF)pl2.patch && \
	\
	./configure --prefix=/usr --sysconfdir=/etc \
		--with-freetype2-includes=/usr/include/freetype2 \
		--enable-opi \
		--enable-multithreaded \
		--enable-wordlist && \
	make -j2 && \
	make install && \
	\
	cd .. && \
	rm -rf $(XPDF)/* && \
	make P=$(XPDF) log-package

$(DOCBOOK-XSL):  $(LIBXML2)
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(DOCBOOK-XSL).tar.bz2 && \
	chmod 755 $(DOCBOOK-XSL) && \
	chown -R 0:0 $(DOCBOOK-XSL) && \
	cd $(DOCBOOK-XSL) && \
	\
	install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-$(XSL-VER) && \
	\
	cp -v -R VERSION common eclipse extensions fo highlighting html \
		htmlhelp images javahelp lib manpages params profiling \
		slides template tools website xhtml \
	/usr/share/xml/docbook/xsl-stylesheets-$(XSL-VER) && \
	\
	install -v -m644 -D README \
		/usr/share/doc/docbook-xsl-$(XSL-VER)/README.XSL && \
	install -v -m755 RELEASE-NOTES* NEWS* \
		/usr/share/doc/docbook-xsl-$(XSL-VER) && \
	\
	cd .. && \
	rm -rf $(DOCBOOK-XSL)/* && \
	make P=$(DOCBOOK-XSL) log-package

$(DOCBOOK-XML-DTD):  $(LIBXML2)
	set +h && \
	\
	mkdir $(DOCBOOK-XML-DTD) && \
	chmod 755 $(DOCBOOK-XML-DTD) && \
	chown -R 0:0 $(DOCBOOK-XML-DTD) && \
	cd $(DOCBOOK-XML-DTD) && \
	unzip $(JLFS-TARBALLS)/$(DOCBOOK-XML-DTD).zip && \
	\
	install -v -d -m755 /usr/share/xml/docbook/$(DTD-VER) && \
	install -v -d -m755 /etc/xml && \
	\
	chown -R root:root . && \
	cp -v -af docbook.cat *.dtd ent/ *.mod \
		/usr/share/xml/docbook/$(DTD-VER) && \
	\
	if [ ! -e /etc/xml/docbook ]; then \
		xmlcatalog --noout --create /etc/xml/docbook; \
	fi && \
	\
	xmlcatalog --noout --add "public" \
		"-//OASIS//DTD DocBook XML V4.5/$(DTD-VER)/EN" \
		"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//DTD DocBook XML CALS Table Model V4.5/$(DTD-VER)/EN" \
		"file:///usr/share/xml/docbook//calstblx.dtd" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/soextblx.dtd" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/dbpoolx.mod" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/dbhierx.mod" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/htmltblx.mod" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//ENTITIES DocBook XML Notations V4.5//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/dbnotnx.mod" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/dbcentx.mod" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "public" \
		"-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
		"file:///usr/share/xml/docbook/$(DTD-VER)/dbgenent.mod" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "rewriteSystem" \
		"http://www.oasis-open.org/docbook/xml/4.5" \
		"file:///usr/share/xml/docbook/$(DTD-VER)" \
		/etc/xml/docbook && \
	xmlcatalog --noout --add "rewriteURI" \
		"http://www.oasis-open.org/docbook/xml/4.5" \
		"file:///usr/share/xml/docbook/$(DTD-VER)" \
		/etc/xml/docbook && \
	\
	if [ ! -e /etc/xml/catalog ]; then \
		xmlcatalog --noout --create /etc/xml/catalog; \
	fi && \
	\
	xmlcatalog --noout --add "delegatePublic" \
		"-//OASIS//ENTITIES DocBook XML" \
		"file:///etc/xml/docbook" \
		/etc/xml/catalog && \
	xmlcatalog --noout --add "delegatePublic" \
		"-//OASIS//DTD DocBook XML" \
		"file:///etc/xml/docbook" \
		/etc/xml/catalog && \
	xmlcatalog --noout --add "delegateSystem" \
		"http://www.oasis-open.org/docbook/" \
		"file:///etc/xml/docbook" \
		/etc/xml/catalog && \
	xmlcatalog --noout --add "delegateURI" \
		"http://www.oasis-open.org/docbook/" \
		"file:///etc/xml/docbook" \
		/etc/xml/catalog && \
	\
	cd .. && \
	rm -rf $(DOCBOOK-XML-DTD)/* && \
	make P=$(DOCBOOK-XML-DTD) log-package

$(STUB):
	set +h && \
	\
	tar jxvf $(JLFS-TARBALLS)/$(STUB).tar.bz2 && \
	chmod 755 $(STUB) && \
	chown -R 0:0 $(STUB) && \
	cd $(STUB) && \
	\
	cd .. && \
	rm -rf $(STUB)/* && \
	make P=$(STUB) log-package

