##########################################################################
#
# First run make prep, then make, then make un-prep
#
##########################################################################

LFS=/lfs
LFS_TGT=$(shell uname -m)-lfs-linux-gnu
LFS-HOSTNAME=vaio
LFS-TARBALLS=$(LFS)/build/JayOS/tarballs/lfs
LFS-PATCHES=$(LFS)/build/JayOS/patches/lfs
JLFS-TARBALLS=$(LFS)/build/JayOS/tarballs/jlfs
LFS-SRC=$(LFS)/build/JayOS/lfs
HEAD=$(LFS)/build/JayOS

include Makefile.lfs.versions
include Makefile.lfs.depends

REDO-TEMP=1
REDO-BASIC=0

##########################################################################
#
# System config files/directories created:
#     /etc/passwd, /etc/group, /etc/nsswitch.conf, /etc/syslog.conf,
#     /etc/inittab, /etc/udev, /etc/sysconfig, /etc/vimrc, /etc/inputrc
#     /etc/hosts
#    
#
##########################################################################

all:
	if [ "$(REDO-TEMP)" = "1" ]; then \
		make redo-lfs-temp-system; \
	else \
		make lfs-temp-system; \
	fi && \
	\
	if [ "$(REDO-BASIC)" = "1" ]; then \
		make redo-lfs-basic-system; \
	else \
		make lfs-basic-system; \
	fi && \
	\
	make config-setclock && \
	make config-console && \
	make config-inputrc && \
	make config-localnet && \
	make config-hosts && \
	make config-network && \
	make config-shadow && \
	make config-initd

# establish a clean-room environment

prep:
	@make prep-lfs-tools && \
	make prep-lfs-environ && \
	ln -sfn build/JayOS $(LFS)/src

un-prep:
	@if [ -f /root/.bashrc.orig ]; then \
		echo "" && \
		echo "Restoring /root/.bashrc and /root/.bash_profile" && \
		\
		mv /root/.bashrc.orig /root/.bashrc && \
		mv /root/.bash_profile.orig /root/.bash_profile; \
	fi

	@rm -f /tools

	-umount -v $(LFS)/sys
	-umount -v $(LFS)/proc
	-umount -v $(LFS)/dev/shm
	-umount -v $(LFS)/dev/pts
	-umount -v $(LFS)/dev

prep-lfs-tools:
	@if [ ! -d $(LFS)/tools ]; then \
		mkdir -vp $(LFS)/tools/src && \
		ln -sfn $(LFS)/tools / && \
		\
		for i in \
			Makefile \
			Makefile.lfs.depends \
			Makefile.lfs.versions; do \
			\
			ln -sfn $(LFS-SRC)/$${i} $(LFS)/tools/src/$${i}; \
		done; \
	fi

prep-lfs-environ:
	@if [ ! -f /root/.bashrc.orig ]; then \
		echo "" && \
		echo "Backing up root's .bashrc and .bash_profile" && \
		echo "" && \
		\
		( cd /root && \
			cp -av .bashrc .bashrc.orig && \
			cp -av .bash_profile .bash_profile.orig ) && \
		\
		echo "" && \
		echo "Creating a clean-room shell environment" && \
		echo "" && \
		\
		echo "set +h" > /root/.bashrc && \
		echo "umask 022" >> /root/.bashrc && \
		echo "#LANG=C" >> /root/.bashrc && \
		echo "LC_ALL=POSIX" >> /root/.bashrc && \
		echo "LFS_TGT=$(shell uname -m)-lfs-linux-gnu" >> /root/.bashrc && \
		echo "LFS=$(LFS)" >> /root/.bashrc && \
		echo "PATH=/tools/bin:/bin:/usr/bin" >> /root/.bashrc && \
		echo "export LC_ALL LFS_TGT LFS LANG PATH" >> /root/.bashrc && \
		\
		echo -en "exec env -i " > /root/.bash_profile && \
		echo -en "HOME=$$HOME " >> /root/.bash_profile && \
		echo -en "TERM=$$TERM " >> /root/.bash_profile && \
		echo -en PS1=\'\\u:\\w$$ \' >> /root/.bash_profile && \
		echo -e ' /bin/bash' >> /root/.bash_profile; \
	fi

log-package:
	@rm -f /var/lib/packages/$(P)
	
	@find /{etc,bin,lib,sbin,usr} -type f \
		-cnewer /tmp/timestamp \
		-print -exec sh -c \
			" md5sum {} >> /var/lib/packages/$(P) " \;

	touch /tmp/timestamp

clean:  un-prep
	rm -rf /tools /lfs/src /lfs/tools

##########################################################################
#
#
##########################################################################

lfs-temp-system:
	cd $(LFS)/tools/src && \
	\
	make $(LFS-TEMPSYS) && \
	\
	rm -rf /tools/{info,man}

	-strip --strip-debug /tools/lib/*
	-strip --strip-unneeded /tools/{,s}bin/*

	chown -R root:root $(LFS)/tools

redo-lfs-temp-system:
	cd $(LFS)/tools/src && \
	\
	make $(REDO-LFS-TEMPSYS) && \
	\
	rm -rf /tools/{info,man}

	-strip --strip-debug /tools/lib/*
	-strip --strip-unneeded /tools/{,s}bin/*

	chown -R root:root $(LFS)/tools

##########################################################################
#
#
##########################################################################

lfs-basic-system:
	mkdir -pv $(LFS)/{dev,proc,sys} && \
	mknod -m 600 $(LFS)/dev/console c 5 1 && \
	mknod -m 666 $(LFS)/dev/null c 1 3 && \
	mount -v --bind /dev $(LFS)/dev && \
	mount -vt devpts devpts $(LFS)/dev/pts && \
	mount -vt tmpfs shm $(LFS)/dev/shm && \
	mount -vt proc proc $(LFS)/proc && \
	mount -vt sysfs sysfs $(LFS)/sys && \
	\
	echo "Systems mounts created" && \
	\
	su -c " \
	/tools/bin/chroot $(LFS) /tools/bin/env -i \
		\
		LFS_TGT=$(LFS_TGT) \
		HOME=/root \
		TERM=$(TERM) \
		PS1='\u:\w\$ ' \
		PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
		\
		/tools/bin/bash -c ' \
			cd /tools/src && \
			make SHELL=/tools/bin/bash lfs-basic-system-chroot ' "
	
	/tools/bin/find $(LFS)/{,usr/}lib -type f \
		-exec /usr/bin/strip --strip-debug '{}' ';'
	/tools/bin/find $(LFS)/{,usr/}{bin,sbin} -type f \
		-exec /usr/bin/strip --strip-all '{}' ';'

	-umount -v $(LFS)/sys
	-umount -v $(LFS)/proc
	-umount -v $(LFS)/dev/shm
	-umount -v $(LFS)/dev/pts
	-umount -v $(LFS)/dev

redo-lfs-basic-system:
	su -c " \
	/tools/bin/chroot $(LFS) /tools/bin/env -i \
		\
		LFS_TGT=$(LFS_TGT) \
		HOME=/root \
		TERM=$(TERM) \
		PS1='\u:\w\$ ' \
		PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
		\
		/tools/bin/bash -c ' \
			cd /tools/src && \
			make SHELL=/tools/bin/bash redo-lfs-basic-system-chroot ' "

	/tools/bin/find $(LFS)/{,usr/}lib -type f \
		-exec /usr/bin/strip --strip-debug '{}' ';'
	/tools/bin/find $(LFS)/{,usr/}{bin,sbin} -type f \
		-exec /usr/bin/strip --strip-all '{}' ';'

	-umount -v $(LFS)/sys
	-umount -v $(LFS)/proc
	-umount -v $(LFS)/dev/shm
	-umount -v $(LFS)/dev/pts
	-umount -v $(LFS)/dev


##########################################################################
#
#
##########################################################################

lfs-basic-system-chroot:
	ln -sfn / /lfs && \
	\
	mkdir -pv /{bin,boot,etc,home,lib,mnt,opt} && \
	mkdir -pv /{media/{floppy,cdrom},sbin,srv,var} && \
	install -dv -m 0750 /root && \
	install -dv -m 1777 /tmp /var/tmp && \
	mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src} && \
	mkdir -pv /usr/{,local/}share/{doc,info,locale,man} && \
	mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo} && \
	mkdir -pv /usr/{,local/}share/man/man{1..8} && \
	\
	for DIR in /usr /usr/local; do \
		ln -sv share/{man,doc,info} $${DIR}; \
	done && \
	\
	if [ "`uname -m`" = "x86_64" ]; then \
		ln -sv lib /lib64 && ln -sv lib /usr/lib64; \
	fi && \
	\
	mkdir -v /var/{lock,log,mail,run,spool} && \
	mkdir -pv /var/{opt,cache,lib/{misc,locate},local} && \
	\
	ln -sv /tools/bin/{bash,cat,echo,grep,pwd,stty} /bin && \
	ln -sv /tools/bin/perl /usr/bin && \
	ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib && \
	ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib && \
	ln -sv bash /bin/sh && \
	\
	touch /etc/mtab && \
	\
	echo "root:x:0:0:root:/root:/bin/bash" > /etc/passwd && \
	echo "bin:x:1:1:bin:/dev/null:/bin/false" >> /etc/passwd && \
	echo "nobody:x:99:99:Unprivileged User:/dev/null:/bin/false" \
		>> /etc/passwd && \
	\
	echo "root:x:0:" > /etc/group && \
	echo "bin:x:1:" >> /etc/group && \
	echo "sys:x:2:" >> /etc/group && \
	echo "kmem:x:3:" >> /etc/group && \
	echo "tty:x:4:" >> /etc/group && \
	echo "tape:x:5:" >> /etc/group && \
	echo "daemon:x:6:" >> /etc/group && \
	echo "floppy:x:7:" >> /etc/group && \
	echo "disk:x:8:" >> /etc/group && \
	echo "lp:x:9:" >> /etc/group && \
	echo "dialout:x:10:" >> /etc/group && \
	echo "audio:x:11:" >> /etc/group && \
	echo "video:x:12:" >> /etc/group && \
	echo "utmp:x:13:" >> /etc/group && \
	echo "usb:x:14:" >> /etc/group && \
	echo "cdrom:x:15:" >> /etc/group && \
	echo "mail:x:34:" >> /etc/group && \
	echo "nogroup:x:99:" >> /etc/group && \
	\
	touch /var/run/utmp /var/log/{btmp,lastlog,wtmp} && \
	chgrp -v utmp /var/run/utmp /var/log/lastlog && \
	chmod -v 664 /var/run/utmp /var/log/lastlog && \
	mkdir -p /var/lib/packages && \
	\
	cd /tools/src && \
	touch /tmp/timestamp && \
	make SHELL=/bin/sh $(LFS-BASICSYS)

redo-lfs-basic-system-chroot:
	cd /tools/src && \
	touch /tmp/timestamp && \
	make SHELL=/bin/sh $(REDO-LFS-BASICSYS)

##########################################################################
#
# Begin Temp System
#
##########################################################################

PASS1-$(BINUTILS):
	tar xvf $(LFS-TARBALLS)/$(BINUTILS).tar.bz2 && \
	chmod 755 $(BINUTILS) && \
	chown -R 0:0 $(BINUTILS) && \
	cd $(BINUTILS) && \
	\
	mkdir -v ../$(BINUTILS)-build && \
	cd ../$(BINUTILS)-build && \
	\
	../$(BINUTILS)/configure \
		--target=$(LFS_TGT) \
		--prefix=/tools --disable-nls --disable-werror && \
	make && \
	if [ "`uname -m`" = "x86_64" ]; then \
		mkdir -v /tools/lib && ln -sv lib /tools/lib64;  \
	fi  && \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(BINUTILS)-build $(BINUTILS)

PASS1-$(GCC4):
	tar xvf $(LFS-TARBALLS)/$(GCC4).tar.bz2 && \
	chmod 755 $(GCC4) && \
	chown -R 0:0 $(GCC4) && \
	cd $(GCC4) && \
	\
	tar xvf $(LFS-TARBALLS)/$(MPFR).tar.bz2 && \
	chmod 755 $(MPFR) && \
	chown -R 0:0 $(MPFR) && \
	mv -v $(MPFR) mpfr && \
	\
	tar xvf $(LFS-TARBALLS)/$(GMP).tar.bz2 && \
	chmod 755 $(GMP) && \
	chown -R 0:0 $(GMP) && \
	mv -v $(GMP) gmp && \
	\
	tar xvf $(LFS-TARBALLS)/$(MPC).tar.gz && \
	chmod 755 $(MPC) && \
	chown -R 0:0 $(MPC) && \
	mv -v $(MPC) mpc && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(GCC4)-cross_compile-1.patch && \
	\
	mkdir -v ../$(GCC4)-build && \
	cd ../$(GCC4)-build && \
	\
	../$(GCC4)/configure --prefix=/tools \
		--target=$(LFS_TGT) \
		--disable-nls --disable-shared --disable-multilib \
    		--disable-decimal-float --disable-threads \
    		--disable-libmudflap --disable-libssp \
    		--disable-libgomp --disable-libquadmath \
		--disable-target-libiberty --disable-target-zlib \
		--enable-languages=c --without-ppl --without-cloog \
		--with-gmp-include=/tools/src/$(GCC4)-build/gmp \
		--with-gmp-lib=/tools/src/$(GCC4)-build/gmp/.libs \
		--with-mpfr-include=/tools/src/$(GCC4)/mpfr/src \
		--with-mpfr-lib=/tools/src/$(GCC4)-build/mpfr/src/.libs && \
	\
	make && \
	make install && \
	\
	ln -vsf libgcc.a `/tools/bin/$(LFS_TGT)-gcc -print-libgcc-file-name | \
		sed 's/libgcc/&_eh/'` && \
	\
	cd .. && \
	rm -rf $(GCC4)-build $(GCC4)

TEMP-linux-headers:
	tar xvf $(JLFS-TARBALLS)/$(LINUX).tar.bz2 && \
	chmod 755 $(LINUX) && \
	chown -R 0:0 $(LINUX) && \
	cd $(LINUX) && \
	\
	make mrproper && \
	make headers_check && \
	make INSTALL_HDR_PATH=dest headers_install && \
	cp -rv dest/include/* /tools/include && \
	\
	cd .. && \
	rm -rf $(LINUX)

TEMP-$(GLIBC):
	tar xvf $(LFS-TARBALLS)/$(GLIBC).tar.bz2 && \
	chmod 755 $(GLIBC) && \
	chown -R 0:0 $(GLIBC) && \
	cd $(GLIBC) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(GLIBC)-gcc_fix-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GLIBC)-cpuid-1.patch && \
	\
	mkdir -v ../$(GLIBC)-build && \
	cd ../$(GLIBC)-build && \
	\
	if [ "`uname -m`" = "i486" -o "`uname -m`" = "i586" -o "`uname -m`" = "i686" ]; then \
 		echo "CFLAGS += -march=i486 -mtune=native" > configparms; \
	fi && \
	\
	../$(GLIBC)/configure --prefix=/tools \
		--host=$(LFS_TGT) \
		--build=$(shell ../$(GLIBC)/scripts/config.guess) \
 		--disable-profile --enable-add-ons \
 		--enable-kernel=2.6.25 --with-headers=/tools/include \
 		libc_cv_forced_unwind=yes libc_cv_c_cleanup=yes && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GLIBC)-build $(GLIBC)

	# not I, said the rabbit
	#SPECS=`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/specs && \
	#/tools/bin/$(LFS_TGT)-gcc -print-libgcc-file-name > /tmp/tgt
	#FILE=$(shell cat /tmp/tgt)
	#SPECS=$(shell dirname $${FILE})/specs && \

adjust-toolchain:
	SPECS="/lfs/tools/bin/../lib/gcc/$(LFS_TGT)/$(GCC4-VER)/specs" && \
	\
	/tools/bin/$(LFS_TGT)-gcc -dumpspecs | \
	sed -e "s@/lib\(64\)\?/ld@/tools&@g" \
		-e "/^\*cpp:$$/{n;s,$$, -isystem /tools/include,}" > $${SPECS} && \
	echo "New specs file is: $${SPECS}" && \
	unset SPECS && \
	\
	echo 'main(){}' > dummy.c && \
	/tools/bin/$(LFS_TGT)-gcc -B/tools/lib dummy.c && \
	readelf -l a.out | grep ': /tools' && \
	rm -v dummy.c a.out

	echo obsolete CC="$(LFS_TGT)-gcc -B/tools/lib/" \

PASS2-$(BINUTILS):
	tar xvf $(LFS-TARBALLS)/$(BINUTILS).tar.bz2 && \
	chmod 755 $(BINUTILS) && \
	chown -R 0:0 $(BINUTILS) && \
	cd $(BINUTILS) && \
	\
	mkdir -v ../$(BINUTILS)-build && \
	cd ../$(BINUTILS)-build && \
	\
	CC="/tools/bin/$(LFS_TGT)-gcc -B/tools/lib/" \
		AR=/tools/bin/$(LFS_TGT)-ar \
		RANLIB=/tools/bin/$(LFS_TGT)-ranlib \
	../$(BINUTILS)/configure --prefix=/tools \
		--disable-nls --with-lib-path=/tools/lib && \
	\
	make && \
	make install && \
	\
	make -C ld clean && \
	make -C ld LIB_PATH=/usr/lib:/lib && \
	cp -v ld/ld-new /tools/bin && \
	\
	cd .. && \
	rm -rf $(BINUTILS)-build $(BINUTILS)

PASS2-$(GCC4):
	tar xvf $(LFS-TARBALLS)/$(GCC4).tar.bz2 && \
	chmod 755 $(GCC4) && \
	chown -R 0:0 $(GCC4) && \
	cd $(GCC4) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(GCC4)-startfiles_fix-1.patch && \
	echo obsolete patch -Np1 -i $(LFS-PATCHES)/$(GCC4)-cross_compile-1.patch && \
	echo obsolete patch -Np1 -i $(LFS-PATCHES)/$(GCC4)-locale-1.patch && \
	\
	cp -v gcc/Makefile.in{,.orig} && \
	sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig \
		> gcc/Makefile.in && \
	\
	cp -v gcc/Makefile.in{,.tmp} && \
	sed "s/^T_CFLAGS =$$/& -fomit-frame-pointer/" gcc/Makefile.in.tmp \
		> gcc/Makefile.in && \
	\
	for file in \
	`find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h`; \
		do \
			cp -uv $${file}{,.orig} && \
			sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
				-e 's@/usr@/tools@g' $${file}.orig > $${file} && \
		\
		echo "#undef STANDARD_INCLUDE_DIR" >> $${file} && \
		echo "#define STANDARD_INCLUDE_DIR 0" >> $${file} && \
		echo "#define STANDARD_STARTFILE_PREFIX_1 \"\"" >> $${file} && \
		echo "#define STANDARD_STARTFILE_PREFIX_2 \"\"" >> $${file} && \
		touch $${file}.orig; \
		\
		done && \
	\
	if [ "`uname -m`" = "x86_64" ]; then \
		for file in `find gcc/config -name t-linux64`; do \
			cp -v $${file}{,.orig} && \
			sed '/MULTILIB_OSDIRNAMES/d' $${file}.orig > $${file}; \
		done; \
	fi && \
	\
	tar xvf $(LFS-TARBALLS)/$(MPFR).tar.bz2 && \
	chmod 755 $(MPFR) && \
	chown -R 0:0 $(MPFR) && \
	mv -v $(MPFR) mpfr && \
	\
	tar xvf $(LFS-TARBALLS)/$(GMP).tar.bz2 && \
	chmod 755 $(GMP) && \
	chown -R 0:0 $(GMP) && \
	mv -v $(GMP) gmp && \
	\
	tar xvf $(LFS-TARBALLS)/$(MPC).tar.gz && \
	chmod 755 $(MPC) && \
	chown -R 0:0 $(MPC) && \
	mv -v $(MPC) mpc && \
	\
	mkdir -v ../$(GCC4)-build && \
	cd ../$(GCC4)-build && \
	\
	CC="$(LFS_TGT)-gcc -B/tools/lib/" \
		AR=$(LFS_TGT)-ar \
		RANLIB=$(LFS_TGT)-ranlib \
	../$(GCC4)/configure --prefix=/tools \
		--with-local-prefix=/tools --enable-clocale=gnu \
		--enable-shared --enable-threads=posix \
		--enable-__cxa_atexit --enable-languages=c,c++ \
		--disable-libstdcxx-pch --disable-multilib \
		--disable-bootstrap --disable-libgomp \
		--without-ppl --without-cloog \
		--with-gmp-include=/tools/src/$(GCC4)-build/gmp \
		--with-gmp-lib=/tools/src/$(GCC4)-build/gmp/.libs \
		--with-mpfr-include=/tools/src/$(GCC4)/mpfr/src \
		--with-mpfr-lib=/tools/src/$(GCC4)-build/mpfr/src/.libs && \
	\
	make && \
	make install && \
	ln -vsfn gcc /tools/bin/cc && \
	\
	cd .. && \
	rm -rf $(GCC4)-build $(GCC4) && \
	\
	echo 'main(){}' > dummy.c && \
	cc dummy.c && \
	readelf -l a.out | grep ': /tools' && \
	rm -v dummy.c a.out

TEMP-$(TCL):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(TCL)-src.tar.gz && \
	chmod 755 $(TCL) && \
	chown -R 0:0 $(TCL) && \
	cd $(TCL) && \
	\
	cd unix && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	chmod -v u+w /tools/lib/libtcl8.5.so && \
	make install-private-headers && \
	ln -sv tclsh8.5 /tools/bin/tclsh && \
	cd .. && \
	\
	cd .. && \
	rm -rf $(TCL)


TEMP-$(EXPECT):  TEMP-$(TCL)
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(EXPECT).tar.bz2 && \
	chmod 755 $(EXPECT) && \
	chown -R 0:0 $(EXPECT) && \
	cd $(EXPECT) && \
	\
	cp configure{,.orig} && \
	sed 's:/usr/local/bin:/bin:' configure.orig > configure && \
	\
	./configure --prefix=/tools --with-tcl=/tools/lib \
		--with-tclinclude=/tools/include --with-x=no && \
	make && \
	make SCRIPTS="" install && \
	\
	cd .. && \
	rm -rf $(EXPECT)

TEMP-$(DEJAGNU):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(DEJAGNU).tar.gz && \
	chmod 755 $(DEJAGNU) && \
	chown -R 0:0 $(DEJAGNU) && \
	cd $(DEJAGNU) && \
	\
	./configure --prefix=/tools && \
	make install && \
	\
	cd .. && \
	rm -rf $(DEJAGNU)

TEMP-$(CHECK):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(CHECK).tar.gz && \
	chmod 755 $(CHECK) && \
	chown -R 0:0 $(CHECK) && \
	cd $(CHECK) && \
	\
	./configure --prefix=/tools && \
	make install && \
	\
	cd .. && \
	rm -rf $(CHECK)

TEMP-$(NCURSES):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(NCURSES).tar.gz && \
	chmod 755 $(NCURSES) && \
	chown -R 0:0 $(NCURSES) && \
	cd $(NCURSES) && \
	\
	./configure --prefix=/tools --with-shared \
		--without-debug --without-ada --enable-overwrite && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(NCURSES)

TEMP-$(BASH):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(BASH).tar.gz && \
	chmod 755 $(BASH) && \
	chown -R 0:0 $(BASH) && \
	cd $(BASH) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(BASH)-fixes-3.patch && \
	\
	./configure --prefix=/tools --without-bash-malloc && \
	\
	make && \
	make install && \
	ln -vs bash /tools/bin/sh && \
	\
	cd .. && \
	rm -rf $(BASH)

TEMP-$(BZIP2):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(BZIP2).tar.gz && \
	chmod 755 $(BZIP2) && \
	chown -R 0:0 $(BZIP2) && \
	cd $(BZIP2) && \
	\
	make && \
	make PREFIX=/tools install && \
	\
	cd .. && \
	rm -rf $(BZIP2)

TEMP-$(COREUTILS):  TEMP-$(XZ)
	set +h && \
	\
	xz -dc $(LFS-TARBALLS)/$(COREUTILS).tar.xz| tar xvf - && \
	chmod 755 $(COREUTILS) && \
	chown -R 0:0 $(COREUTILS) && \
	cd $(COREUTILS) && \
	\
	./configure --prefix=/tools  --enable-install-program=hostname && \
	make && \
	make install && \
	cp -v src/su /tools/bin/su-tools && \
	\
	cd .. && \
	rm -rf $(COREUTILS)

TEMP-$(DIFFUTILS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(DIFFUTILS).tar.gz && \
	chmod 755 $(DIFFUTILS) && \
	chown -R 0:0 $(DIFFUTILS) && \
	cd $(DIFFUTILS) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(DIFFUTILS)

TEMP-$(FILE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(FILE).tar.gz && \
	chmod 755 $(FILE) && \
	chown -R 0:0 $(FILE) && \
	cd $(FILE) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(FILE)/* && \

TEMP-$(FINDUTILS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(FINDUTILS).tar.gz && \
	chmod 755 $(FINDUTILS) && \
	chown -R 0:0 $(FINDUTILS) && \
	cd $(FINDUTILS) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(FINDUTILS)

TEMP-$(GAWK):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GAWK).tar.bz2 && \
	chmod 755 $(GAWK) && \
	chown -R 0:0 $(GAWK) && \
	cd $(GAWK) && \
	\
	./configure --prefix=/tools && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GAWK)

TEMP-$(GETTEXT):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GETTEXT).tar.gz && \
	chmod 755 $(GETTEXT) && \
	chown -R 0:0 $(GETTEXT) && \
	cd $(GETTEXT) && \
	\
	cd gettext-tools && \
	./configure --prefix=/tools --disable-shared && \
	\
	make -C gnulib-lib && \
	make -C src msgfmt && \
	\
	cp -v src/msgfmt /tools/bin && \
	cd .. && \
	\
	cd .. && \
	rm -rf $(GETTEXT)

TEMP-$(GREP):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GREP).tar.gz && \
	chmod 755 $(GREP) && \
	chown -R 0:0 $(GREP) && \
	cd $(GREP) && \
	\
	./configure --prefix=/tools \
		--disable-perl-regexp && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GREP)

TEMP-$(GZIP):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GZIP).tar.gz && \
	chmod 755 $(GZIP) && \
	chown -R 0:0 $(GZIP) && \
	cd $(GZIP) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GZIP)

TEMP-$(M4):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(M4).tar.bz2 && \
	chmod 755 $(M4) && \
	chown -R 0:0 $(M4) && \
	cd $(M4) && \
	\
	echo obsolete sed -i -e '/"m4.h"/a\
		#include <sys/stat.h>' src/path.c && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(M4)

TEMP-$(MAKE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(MAKE).tar.bz2 && \
	chmod 755 $(MAKE) && \
	chown -R 0:0 $(MAKE) && \
	cd $(MAKE) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(MAKE)

TEMP-$(PATCH):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(PATCH).tar.bz2 && \
	chmod 755 $(PATCH) && \
	chown -R 0:0 $(PATCH) && \
	cd $(PATCH) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(PATCH)-test_fix-1.patch && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(PATCH)

TEMP-$(PERL):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(PERL).tar.bz2 && \
	chmod 755 $(PERL) && \
	chown -R 0:0 $(PERL) && \
	cd $(PERL) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(PERL)-libc-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(PERL)-security_fix-1.patch && \
	\
	sh Configure -des -Dprefix=/tools && \
	make && \
	\
	cp -v perl cpan/podlators/pod2man /tools/bin && \
	mkdir -pv /tools/lib/perl5/$(PERL-VER) && \
	cp -Rv lib/* /tools/lib/perl5/$(PERL-VER) && \
	\
	cd .. && \
	rm -rf $(PERL)

TEMP-$(SED):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(SED).tar.bz2 && \
	chmod 755 $(SED) && \
	chown -R 0:0 $(SED) && \
	cd $(SED) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(SED)

TEMP-$(TAR):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(TAR).tar.bz2 && \
	chmod 755 $(TAR) && \
	chown -R 0:0 $(TAR) && \
	cd $(TAR) && \
	\
	FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(TAR)

TEMP-$(TEXINFO):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(TEXINFO).tar.gz && \
	chmod 755 $(TEXINFO) && \
	chown -R 0:0 $(TEXINFO) && \
	cd $(TEXINFO) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(TEXINFO)

TEMP-$(XZ):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(XZ).tar.bz2 && \
	chmod 755 $(XZ) && \
	chown -R 0:0 $(XZ) && \
	cd $(XZ) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(XZ)

##########################################################################
#
# Begin Basic System
#
##########################################################################

linux-headers:
	set +h && \
	\
	tar xvf $(JLFS-TARBALLS)/$(LINUX).tar.bz2 && \
	chmod 755 $(LINUX) && \
	chown -R 0:0 $(LINUX) && \
	cd $(LINUX) && \
	\
	make mrproper && \
	make headers_check && \
	make INSTALL_HDR_PATH=dest headers_install && \
	find dest/include \( -name .install -o -name ..install.cmd \) -delete && \
	cp -rv dest/include/* /usr/include && \
	\
	cd .. && \
	rm -rf $(LINUX) && \
	make P=$(LINUX)-headers log-package

$(MAN-PAGES):
	set +h && \
	\
	tar zxvf $(LFS-TARBALLS)/$(MAN-PAGES).tar.gz && \
	chmod 755 $(MAN-PAGES) && \
	chown -R 0:0 $(MAN-PAGES) && \
	cd $(MAN-PAGES) && \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(MAN-PAGES)/* && \
	make P=$(MAN-PAGES) log-package

$(GLIBC):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GLIBC).tar.bz2 && \
	chmod 755 $(GLIBC) && \
	chown -R 0:0 $(GLIBC) && \
	cd $(GLIBC) && \
	\
	DL=`readelf -l /bin/sh| sed -n 's@.*interpret.*/tools\(.*\)]$$@\1@p'` && \
	sed -i \
	"s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=$${DL} -o|" \
        	scripts/test-installation.pl && \
	unset DL && \
	\
	sed -i -e 's/"db1"/& \&\& $name ne "nss_test1"/' \
		scripts/test-installation.pl && \
	\
	sed -i 's|@BASH@|/bin/bash|' elf/ldd.bash.in && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(GLIBC)-fixes-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GLIBC)-gcc_fix-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GLIBC)-cpuid-1.patch && \
	\
	sed -i '195,213 s/PRIVATE_FUTEX/FUTEX_CLOCK_REALTIME/' \
		nptl/sysdeps/unix/sysv/linux/x86_64/pthread_rwlock_timed{rd,wr}lock.S && \
	\
	mkdir -v ../$(GLIBC)-build && \
	cd ../$(GLIBC)-build && \
	\
	if [ "`uname -m`" = "i486" -o "`uname -m`" = "i586" -o "`uname -m`" = "i686" ]; then \
		echo "CFLAGS += -march=i486 -mtune=native -O3 -pipe" > configparms; \
	fi && \
	\
	../$(GLIBC)/configure --prefix=/usr \
		--disable-profile --enable-add-ons \
		--enable-kernel=2.6.25 --libexecdir=/usr/lib/glibc && \
	\
	make && \
	cp -v ../$(GLIBC)/iconvdata/gconv-modules iconvdata && \
	make -k check 2>&1 | tee glibc-check-log && \
	grep Error glibc-check-log && \
	\
	touch /etc/ld.so.conf && \
	make install && \
	\
	cp -v ../$(GLIBC)/sunrpc/rpc/*.h /usr/include/rpc
	cp -v ../$(GLIBC)/sunrpc/rpcsvc/*.h /usr/include/rpcsvc
	cp -v ../$(GLIBC)/nis/rpcsvc/*.h /usr/include/rpcsvc && \
	\
	mkdir -pv /usr/lib/locale && \
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8 && \
	localedef -i de_DE -f ISO-8859-1 de_DE && \
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro && \
	localedef -i en_HK -f ISO-8859-1 en_HK && \
	localedef -i en_PH -f ISO-8859-1 en_PH && \
	localedef -i en_US -f ISO-8859-1 en_US && \
	localedef -i en_US -f UTF-8 en_US.UTF-8 && \
	localedef -i es_MX -f ISO-8859-1 es_MX && \
	localedef -i fa_IR -f UTF-8 fa_IR && \
	localedef -i fr_FR -f ISO-8859-1 fr_FR && \
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro && \
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8 && \
	localedef -i it_IT -f ISO-8859-1 it_IT && \
	localedef -i ja_JP -f EUC-JP ja_JP && \
	\
	make localedata/install-locales && \
	\
	echo "# Begin /etc/nsswitch.conf" > /etc/nsswitch.conf && \
	echo "" >> /etc/nsswitch.conf && \
	echo "passwd: files" >> /etc/nsswitch.conf && \
	echo "group: files" >> /etc/nsswitch.conf && \
	echo "shadow: files" >> /etc/nsswitch.conf && \
	echo "" >> /etc/nsswitch.conf && \
	echo "hosts: files dns" >> /etc/nsswitch.conf && \
	echo "networks: files" >> /etc/nsswitch.conf && \
	echo "" >> /etc/nsswitch.conf && \
	echo "protocols: files" >> /etc/nsswitch.conf && \
	echo "services: files" >> /etc/nsswitch.conf && \
	echo "ethers: files" >> /etc/nsswitch.conf && \
	echo "rpc: files" >> /etc/nsswitch.conf && \
	echo "" >> /etc/nsswitch.conf && \
	echo "# End /etc/nsswitch.conf" >> /etc/nsswitch.conf && \
	\
	cp -v --remove-destination /usr/share/zoneinfo/America/Los_Angeles \
		/etc/localtime && \
	\
	echo "# Begin /etc/ld.so.conf" > /etc/ld.so.conf && \
	echo "" >> /etc/ld.so.conf && \
	echo "/usr/local/lib" >> /etc/ld.so.conf && \
	echo "/opt/lib" >> /etc/ld.so.conf && \
	echo "" >> /etc/ld.so.conf && \
	echo "# End /etc/ld.so.conf" >> /etc/ld.so.conf && \
	\
	cd .. && \
	rm -rf $(GLIBC)-build $(GLIBC)/* && \
	make P=$(GLIBC) log-package

readjust-toolchain:
	mv -v /tools/bin/{ld,ld-old} && \
	mv -v /tools/$(shell gcc -dumpmachine)/bin/{ld,ld-old} && \
	mv -v /tools/bin/{ld-new,ld} && \
	ln -sv /tools/bin/ld /tools/$(shell gcc -dumpmachine)/bin/ld && \
	\
	gcc -dumpspecs | sed \
		-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
		-e '/\*cpp:/{n;s@$$@ -isystem /usr/include@}' \
	> `dirname $(shell gcc --print-libgcc-file-name)`/specs && \
	\
	sed -i 's/\/tools//g' \
		`dirname $(shell gcc --print-libgcc-file-name)`/specs && \
	\
	echo 'main(){}' > dummy.c && \
	cc dummy.c -v -Wl,--verbose &> dummy.log && \
	readelf -l a.out | grep ': /lib' && \
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log && \
	grep -B1 '^ /usr/include' dummy.log && \
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' && \
	grep "/lib.*/libc.so.6 " dummy.log && \
	grep found dummy.log && \
	\
	rm -v dummy.c a.out dummy.log

$(ZLIB):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(ZLIB).tar.bz2 && \
	chmod 755 $(ZLIB) && \
	chown -R 0:0 $(ZLIB) && \
	cd $(ZLIB) && \
	\
	sed -i 's/ifdef _LARGEFILE64_SOURCE/ifndef _LARGEFILE64_SOURCE/' \
		zlib.h && \
	\
	CFLAGS='-mstackrealign -fPIC -O3' ./configure \
		--prefix=/usr --shared --libdir=/lib && \
	make && \
	make install && \
	\
	rm -v /lib/libz.so && \
	ln -sfv ../../lib/libz.so.$(ZLIB-VER) /usr/lib/libz.so && \
	\
	make clean && \
	./configure --prefix=/usr && \
	make && \
	make install && \
	chmod -v 644 /usr/lib/libz.a && \
	\
	cd .. && \
	rm -rf $(ZLIB)/* && \
	make P=$(ZLIB) log-package

$(FILE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(FILE).tar.gz && \
	chmod 755 $(FILE) && \
	chown -R 0:0 $(FILE) && \
	cd $(FILE) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(FILE)/* && \
	make P=$(FILE) log-package

$(BINUTILS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(BINUTILS).tar.bz2 && \
	chmod 755 $(BINUTILS) && \
	chown -R 0:0 $(BINUTILS) && \
	cd $(BINUTILS) && \
	\
	rm -fv etc/standards.info && \
	sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in && \
	\
	sed -i "/exception_defines.h/d" ld/testsuite/ld-elf/new.cc && \
	sed -i "s/-fvtable-gc //" ld/testsuite/ld-selective/selective.exp && \
	\
	mkdir -v ../$(BINUTILS)-build && \
	cd ../$(BINUTILS)-build && \
	\
	../$(BINUTILS)/configure \
		--prefix=/usr --enable-shared && \
	make tooldir=/usr && \
	\
	echo NO make -k check && \
	make -k check && \
	\
	make tooldir=/usr install && \
	\
	cp -v ../$(BINUTILS)/include/libiberty.h /usr/include && \
	\
	cd .. && \
	rm -rf $(BINUTILS)-build $(BINUTILS)/* && \
	make P=$(BINUTILS) log-package

$(GMP): $(M4)
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(GMP).tar.bz2 && \
	chmod 755 $(GMP) && \
	chown -R 0:0 $(GMP) && \
	cd $(GMP) && \
	\
	sed -i 's/np + dn, qn/& - dn/' mpn/generic/dcpi1_bdiv_q.c && \
	\
	./configure --prefix=/usr --enable-cxx --enable-mpbsd && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GMP)/* && \
	make P=$(GMP) log-package

$(MPFR):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(MPFR).tar.bz2 && \
	chmod 755 $(MPFR) && \
	chown -R 0:0 $(MPFR) && \
	cd $(MPFR) && \
	\
	./configure --prefix=/usr --enable-thread-safe && \
	make && \
	make check && \
	make install && \
	\
	cd .. && \
	rm -rf $(MPFR)/* && \
	make P=$(MPFR) log-package

$(MPC):  $(MPFR)
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(MPC).tar.gz && \
	chmod 755 $(MPC) && \
	chown -R 0:0 $(MPC) && \
	cd $(MPC) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(MPC)/* && \
	make P=$(MPC) log-package

$(GCC4):  $(GMP) $(MPFR) $(MPC)
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GCC4).tar.bz2 && \
	chmod 755 $(GCC4) && \
	chown -R 0:0 $(GCC4) && \
	cd $(GCC4) && \
	\
	sed -i "s/install_to_$$(INSTALL_DEST) //" libiberty/Makefile.in && \
	\
	if [ "`uname -m`" = "i486" -o "`uname -m`" = "i586" -o "`uname -m`" = "i686" ]; then \
		sed -i "s/^T_CFLAGS =$$/& -fomit-frame-pointer/" \
			gcc/Makefile.in; \
	fi && \
	\
	sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in && \
	sed -i 's/getline/get_line/' libiberty/testsuite/test-demangle.c && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(GCC4)-locale-1.patch && \
	\
	mkdir -v ../$(GCC4)-build && \
	cd ../$(GCC4)-build && \
	\
	../$(GCC4)/configure --prefix=/usr \
		--libexecdir=/usr/lib --enable-shared \
		--enable-threads=posix --enable-__cxa_atexit \
		--enable-clocale=gnu --enable-languages=c,c++ \
		--disable-multilib --disable-bootstrap --with-system-zlib && \
	make && \
	ulimit -s 16384 && \
	\
	make install && \
	\
	ln -sfv ../usr/bin/cpp /lib && \
	ln -sfv gcc /usr/bin/cc && \
	\
	echo 'main(){}' > dummy.c && \
	cc dummy.c -v -Wl,--verbose &> dummy.log && \
	readelf -l a.out | grep ': /lib' && \
	\
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log && \
	grep -B3 '^ /usr/include' dummy.log && \
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' && \
	grep "/lib.*/libc.so.6 " dummy.log && \
	grep found dummy.log && \
	rm -v dummy.c a.out dummy.log && \
	\
	cd .. && \
	rm -rf $(GCC4)-build $(GCC4)/* && \
	make P=$(GCC4) log-package

$(SED):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(SED).tar.bz2 && \
	chmod 755 $(SED) && \
	chown -R 0:0 $(SED) && \
	cd $(SED) && \
	\
	./configure --prefix=/usr --bindir=/bin \
		--htmldir=/usr/share/doc/$(SED) && \
	make && \
	make html && \
	make install && \
	\
	cd .. && \
	rm -rf $(SED)/* && \
	make P=$(SED) log-package

$(BZIP2):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(BZIP2).tar.gz && \
	chmod 755 $(BZIP2) && \
	chown -R 0:0 $(BZIP2) && \
	cd $(BZIP2) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(BZIP2)-install_docs-1.patch && \
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile && \
	\
	make -f Makefile-libbz2_so && \
	make clean && \
	make && \
	make PREFIX=/usr install && \
	\
	cp -v bzip2-shared /bin/bzip2 && \
	cp -av libbz2.so* /lib && \
	ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so && \
	rm -v /usr/bin/{bunzip2,bzcat,bzip2} && \
	ln -sv bzip2 /bin/bunzip2 && \
	ln -sv bzip2 /bin/bzcat && \
	\
	cd .. && \
	rm -rf $(BZIP2)/* && \
	make P=$(BZIP2) log-package

$(NCURSES):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(NCURSES).tar.gz && \
	chmod 755 $(NCURSES) && \
	chown -R 0:0 $(NCURSES) && \
	cd $(NCURSES) && \
	\
	./configure --prefix=/usr --with-shared \
		--without-debug --enable-widec && \
	make && \
	make install && \
	\
	chmod -v 644 /usr/lib/libncurses++w.a && \
	mv -v /usr/lib/libncursesw.so.5* /lib && \
	ln -sfv ../../lib/libncursesw.so.5 /usr/lib/libncursesw.so && \
	\
	for lib in curses ncurses form panel menu; do \
		rm -vf /usr/lib/lib$${lib}.so; \
		echo "INPUT(-l$${lib}w)" >/usr/lib/lib$${lib}.so; \
		ln -sfv lib$${lib}w.a /usr/lib/lib$${lib}.a; \
	done && \
	\
	ln -sfv libncurses++w.a /usr/lib/libncurses++.a && \
	rm -vf /usr/lib/libcursesw.so && \
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so && \
	ln -sfv libncurses.so /usr/lib/libcurses.so && \
	ln -sfv libncursesw.a /usr/lib/libcursesw.a && \
	ln -sfv libncurses.a /usr/lib/libcurses.a && \
	\
	cd .. && \
	rm -rf $(NCURSES)/* && \
	make P=$(NCURSES) log-package

$(UTIL-LINUX):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(UTIL-LINUX).tar.bz2 && \
	chmod 755 $(UTIL-LINUX) && \
	chown -R 0:0 $(UTIL-LINUX) && \
	cd $(UTIL-LINUX) && \
	\
	echo "TODO:  make hwclock FHS-compliant"
	echo figure out later sed -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
		-i $(shell grep -rl '/etc/adjtime' .) && \
	mkdir -pv /var/lib/hwclock && \
	\
	./configure --enable-arch --enable-partx --enable-write && \
	\
	make && \
	make install && \
	\
	echo obsolete patch -Np1 -i $(LFS-PATCHES)/$(UTIL-LINUX)-swapon-no-page.h.patch && \
	echo obsolete perl -p -i -e \
		's/sh swap\.configure/echo this breaks my patch sh swap\.configure/' mount/Makefile && \
	echo obsolete echo "#define SWAPON_HAS_TWO_ARGS" > mount/swapargs.h && \
	echo obsolete echo "" >> mount/swapargs.h && \
	echo obsolete echo "#include <sys/swap.h>" >> mount/swapargs.h && \
	echo obsolete echo "#define PAGE_SIZE 4096" >> mount/swapargs.h && \
	\
	echo obsolete make HAVE_KILL=yes HAVE_SLN=yes && \
	echo obsolete make HAVE_KILL=yes HAVE_SLN=yes install && \
	\
	cd .. && \
	rm -rf $(UTIL-LINUX)/* && \
	make P=$(UTIL-LINUX) log-package

$(E2FSPROGS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(E2FSPROGS).tar.gz && \
	chmod 755 $(E2FSPROGS) && \
	chown -R 0:0 $(E2FSPROGS) && \
	cd $(E2FSPROGS) && \
	\
	mkdir -v build && \
	cd build && \
	\
	PKG_CONFIG=/tools/bin/true LDFLAGS=-lblkid  ../configure \
		--prefix=/usr --with-root-prefix="" \
		--enable-elf-shlibs --disable-libblkid --disable-libuuid \
		--disable-uuidd --disable-fsck && \
	make && \
	make install && \
	make install-libs && \
	\
	chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a && \
	\
	gunzip -v /usr/share/info/libext2fs.info.gz && \
	install-info --dir-file=/usr/share/info/dir \
		/usr/share/info/libext2fs.info && \
	\
	cd .. && \
	cd .. && \
	rm -rf $(E2FSPROGS)/* && \
	make P=$(E2FSPROGS) log-package

$(COREUTILS):
	set +h && \
	\
	xz -dc $(LFS-TARBALLS)/$(COREUTILS).tar.xz| tar xvf - && \
	chmod 755 $(COREUTILS) && \
	chown -R 0:0 $(COREUTILS) && \
	cd $(COREUTILS) && \
	\
	if [ "`uname -m`" = "i486" -o "`uname -m`" = "i586" -o "`uname -m`" = "i686" -o "`uname -m`" = "x86_64" ]; then \
		patch -Np1 -i $(LFS-PATCHES)/$(COREUTILS)-uname-2.patch; \
	fi && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(COREUTILS)-i18n-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(COREUTILS)-test_fix-1.patch && \
	\
	./configure --prefix=/usr \
		--enable-no-install-program=kill,uptime && \
	make && \
	\
	make NON_ROT_USERNAME=nobody check-root && \
	echo "dummy:x:1000:nobody" >> /etc/group && \
	chown -Rv nobody . && \
	su-tools nobody -s /bin/bash -c "make RUN_EXPENSVE_TESTS=yes check" && \
	sed -i '/dummy/d' /etc/group && \
	\
	make install && \
	\
	mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} \
		/bin && \
	mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,readlink,rm} \
		/bin && \
	mv -v /usr/bin/{rmdir,stty,sync,true,uname} \
		/bin && \
	mv -v /usr/bin/chroot /usr/sbin && \
	mv -v /usr/bin/{head,sleep,nice} /bin && \
	\
	cd .. && \
	rm -rf $(COREUTILS)/* && \
	make P=$(COREUTILS) log-package

$(IANA-ETC):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(IANA-ETC).tar.bz2 && \
	chmod 755 $(IANA-ETC) && \
	chown -R 0:0 $(IANA-ETC) && \
	cd $(IANA-ETC) && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(IANA-ETC)/* && \
	make P=$(IANA-ETC) log-package

$(M4):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(M4).tar.bz2 && \
	chmod 755 $(M4) && \
	chown -R 0:0 $(M4) && \
	cd $(M4) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(M4)/* && \
	make P=$(M4) log-package

$(BISON):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(BISON).tar.bz2 && \
	chmod 755 $(BISON) && \
	chown -R 0:0 $(BISON) && \
	cd $(BISON) && \
	\
	./configure --prefix=/usr && \
	echo '#define YYENABLE_NLS 1' >> config.h && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(BISON)/* && \
	make P=$(BISON) log-package

$(PROCPS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(PROCPS).tar.gz && \
	chmod 755 $(PROCPS) && \
	chown -R 0:0 $(PROCPS) && \
	cd $(PROCPS) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(PROCPS)-fix_HZ-errors-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(PROCPS)-watch_unicode-1.patch && \
	\
	sed -i -e 's@\*/module.mk@proc/module.mk ps/module.mk@' Makefile && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(PROCPS)/* && \
	make P=$(PROCPS) log-package 

$(GREP):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GREP).tar.gz && \
	chmod 755 $(GREP) && \
	chown -R 0:0 $(GREP) && \
	cd $(GREP) && \
	\
	sed -i 's/cp/#&/' tests/unibyte-bracket-expr && \
	\
	./configure --prefix=/usr --bindir=/bin && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GREP)/* && \
	make P=$(GREP) log-package

$(READLINE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(READLINE).tar.gz && \
	chmod 755 $(READLINE) && \
	chown -R 0:0 $(READLINE) && \
	cd $(READLINE) && \
	\
	sed -i '/MV.*old/d' Makefile.in && \
	sed -i '/{OLDSUFF}/c:' support/shlib-install && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(READLINE)-fixes-1.patch && \
	\
	./configure --prefix=/usr --libdir=/lib && \
	make SHLIB_LIBS=-lncurses && \
	make install && \
	\
	mv -v /lib/lib{readline,history}.a /usr/lib && \
	rm -v /lib/lib{readline,history}.so && \
	ln -sfv ../../lib/libreadline.so.6 /usr/lib/libreadline.so && \
	ln -sfv ../../lib/libhistory.so.6 /usr/lib/libhistory.so && \
	\
	cd .. && \
	rm -rf $(READLINE)/* && \
	make P=$(READLINE) log-package

$(BASH):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(BASH).tar.gz && \
	chmod 755 $(BASH) && \
	chown -R 0:0 $(BASH) && \
	cd $(BASH) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(BASH)-fixes-3.patch && \
	\
	./configure --prefix=/usr --bindir=/bin \
		--htmldir=/usr/share/doc/$(BASH) \
		--without-bash-malloc --with-installed-readline && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(BASH)/* && \
	make P=$(BASH) log-package

$(LIBTOOL):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(LIBTOOL).tar.gz && \
	chmod 755 $(LIBTOOL) && \
	chown -R 0:0 $(LIBTOOL) && \
	cd $(LIBTOOL) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBTOOL)/* && \
	make P=$(LIBTOOL) log-package

$(GDBM):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GDBM).tar.gz && \
	chmod 755 $(GDBM) && \
	chown -R 0:0 $(GDBM) && \
	cd $(GDBM) && \
	\
	./configure --prefix=/usr --enable-libgdbm-compat && \
	make && \
	make install && \
	make install-compat && \
	\
	cd .. && \
	rm -rf $(GDBM)/.libs $(GDBM)/* && \
	make P=$(GDBM) log-package

$(INETUTILS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(INETUTILS).tar.gz && \
	chmod 755 $(INETUTILS) && \
	chown -R 0:0 $(INETUTILS) && \
	cd $(INETUTILS) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/sbin \
		--sysconfdir=/etc --localstatedir=/var \
		--disable-ifconfig --disable-logger --disable-syslogd \
		--disable-whois --disable-servers && \
	make && \
	make install && \
	\
	mv -v /usr/bin/{hostname,ping,ping6} /bin && \
	mv -v /usr/bin/traceroute /sbin && \
	\
	cd .. && \
	rm -rf $(INETUTILS)/* && \
	make P=$(INETUTILS) log-package

$(PERL):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(PERL).tar.bz2 && \
	chmod 755 $(PERL) && \
	chown -R 0:0 $(PERL) && \
	cd $(PERL) && \
	\
	echo "127.0.0.1 localhost $(LFS-HOSTNAME)" > /etc/hosts && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(PERL)-libc-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(PERL)-security-fix-1.patch && \
	\
	sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|" \
		-e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" \
		-e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|" \
			ext/Compress-Raw-Zlib/config.in && \
	\
	sh Configure -des -Dprefix=/usr \
		-Dvendorprefix=/usr           \
		-Dman1dir=/usr/share/man/man1 \
		-Dman3dir=/usr/share/man/man3 \
		-Dpager="/usr/bin/less -isR" \
		-Duseshrplib && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(PERL)/* && \
	make P=$(PERL) log-package

$(AUTOCONF):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(AUTOCONF).tar.bz2 && \
	chmod 755 $(AUTOCONF) && \
	chown -R 0:0 $(AUTOCONF) && \
	cd $(AUTOCONF) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(AUTOCONF)/* && \
	make P=$(AUTOCONF) log-package

$(AUTOMAKE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(AUTOMAKE).tar.bz2 && \
	chmod 755 $(AUTOMAKE) && \
	chown -R 0:0 $(AUTOMAKE) && \
	cd $(AUTOMAKE) && \
	\
	./configure --prefix=/usr --docdir=/usr/share/doc/$(AUTOMAKE) && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(AUTOMAKE)/* && \
	make P=$(AUTOMAKE) log-package

$(DIFFUTILS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(DIFFUTILS).tar.gz && \
	chmod 755 $(DIFFUTILS) && \
	chown -R 0:0 $(DIFFUTILS) && \
	cd $(DIFFUTILS) && \
	\
	./configure --prefix=/usr && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(DIFFUTILS)/* && \
	make P=$(DIFFUTILS) log-package

$(GAWK):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GAWK).tar.bz2 && \
	chmod 755 $(GAWK) && \
	chown -R 0:0 $(GAWK) && \
	cd $(GAWK) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/lib && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GAWK)/* && \
	make P=$(GAWK) log-package

$(FINDUTILS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(FINDUTILS).tar.gz && \
	chmod 755 $(FINDUTILS) && \
	chown -R 0:0 $(FINDUTILS) && \
	cd $(FINDUTILS) && \
	\
	./configure --prefix=/usr --libexecdir=/usr/lib/findutils \
		--localstatedir=/var/lib/locate && \
	make && \
	make install && \
	\
	mv -v /usr/bin/find /bin && \
	sed -i -e 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb && \
	\
	cd .. && \
	rm -rf $(FINDUTILS)/* && \
	make P=$(FINDUTILS) log-package

$(FLEX):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(FLEX).tar.bz2 && \
	chmod 755 $(FLEX) && \
	chown -R 0:0 $(FLEX) && \
	cd $(FLEX) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(FLEX)-gcc44-1.patch && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	ln -sfv libfl.a /usr/lib/libl.a && \
	\
	echo "#!/bin/sh" > /usr/bin/lex && \
	echo "# Begin /usr/bin/lex" >> /usr/bin/lex && \
	echo "" >> /usr/bin/lex && \
	echo 'exec /usr/bin/flex -l $$@' >> /usr/bin/lex && \
	echo "" >> /usr/bin/lex && \
	echo "# End /usr/bin/lex" >> /usr/bin/lex && \
	\
	chmod -v 755 /usr/bin/lex && \
	\
	cd .. && \
	rm -rf $(FLEX)/* && \
	make P=$(FLEX) log-package

	#echo "AM_PROG_AS" >> configure.ac && \

$(GETTEXT):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GETTEXT).tar.gz && \
	chmod 755 $(GETTEXT) && \
	chown -R 0:0 $(GETTEXT) && \
	cd $(GETTEXT) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(GETTEXT)/* && \
	make P=$(GETTEXT) log-package

$(GROFF):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GROFF).tar.gz && \
	chmod 755 $(GROFF) && \
	chown -R 0:0 $(GROFF) && \
	cd $(GROFF) && \
	\
	PAGE=letter ./configure --prefix=/usr && \
	make && \
	make install && \
	\
	ln -sv eqn /usr/bin/geqn && \
	ln -sv tbl /usr/bin/gtbl && \
	\
	cd .. && \
	rm -rf $(GROFF)/* && \
	make P=$(GROFF) log-package

$(GRUB):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GRUB).tar.gz && \
	chmod 755 $(GRUB) && \
	chown -R 0:0 $(GRUB) && \
	cd $(GRUB) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(GRUB)-graphics.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GRUB)-disk_geometry-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GRUB)-a20.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GRUB)-256byte_inode-1.patch && \
	patch -Np1 -i $(LFS-PATCHES)/$(GRUB)-AM_PROG_AS.patch && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc \
		--disable-grub-emu \
		--disable-grub-emu-usb \
		--disable-grub-fstest \
		--disable-efiemu && \
	\
	make && \
	make install && \
	\
	mkdir -pv /boot/grub && \
	cp -v /usr/lib/grub/i386-pc/stage{1,2} /boot/grub && \
	\
	cd .. && \
	rm -rf $(GRUB)/* && \
	make P=$(GRUB) log-package

$(GZIP):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(GZIP).tar.gz && \
	chmod 755 $(GZIP) && \
	chown -R 0:0 $(GZIP) && \
	cd $(GZIP) && \
	\
	./configure --prefix=/usr --bindir=/bin && \
	make && \
	make install && \
	\
	mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin && \
	mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin && \
	\
	cd .. && \
	rm -rf $(GZIP)/* && \
	make P=$(GZIP) log-package

$(IPROUTE):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(IPROUTE).tar.bz2 && \
	chmod 755 $(IPROUTE) && \
	chown -R 0:0 $(IPROUTE) && \
	cd $(IPROUTE) && \
	sed -i '/^TARGETS/s@arpd@@g' misc/Makefile && \
	\
	make DESTDIR= SBINDIR=/sbin && \
	make DESTDIR= SBINDIR=/sbin install && \
	\
	cd .. && \
	rm -rf $(IPROUTE)/* && \
	make P=$(IPROUTE) log-package

$(KBD):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(KBD).tar.gz && \
	chmod 755 $(KBD) && \
	chown -R 0:0 $(KBD) && \
	cd $(KBD) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(KBD)-backspace-1.patch && \
	\
	./configure --prefix=/usr --datadir=/lib/kbd && \
	make && \
	make install && \
	\
	mv -v /usr/bin/{kbd_mode,openvt,setfont} /bin && \
	\
	cd .. && \
	rm -rf $(KBD)/* && \
	make P=$(KBD) log-package

$(LESS):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(LESS).tar.gz && \
	chmod 755 $(LESS) && \
	chown -R 0:0 $(LESS) && \
	cd $(LESS) && \
	\
	./configure --prefix=/usr --sysconfdir=/etc && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(LESS)/* && \
	make P=$(LESS) log-package

$(LIBPIPELINE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(LIBPIPELINE).tar.gz && \
	chmod 755 $(LIBPIPELINE) && \
	chown -R 0:0 $(LIBPIPELINE) && \
	cd $(LIBPIPELINE) && \
	\
	./configure CHECK_CFLAGS=-I/tools/include \
		CHECK_LIBS="-L/tools/lib -lcheck" --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(LIBPIPELINE)/* && \
	make P=$(LIBPIPELINE) log-package

$(MAKE):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(MAKE).tar.bz2 && \
	chmod 755 $(MAKE) && \
	chown -R 0:0 $(MAKE) && \
	cd $(MAKE) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(MAKE)/* && \
	make P=$(MAKE) log-package

$(XZ):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(XZ).tar.bz2 && \
	chmod 755 $(XZ) && \
	chown -R 0:0 $(XZ) && \
	cd $(XZ) && \
	\
	./configure --prefix=/tools && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(XZ) && \
	make P=$(XZ) log-package

$(MAN-DB):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(MAN-DB).tar.gz && \
	chmod 755 $(MAN-DB) && \
	chown -R 0:0 $(MAN-DB) && \
	cd $(MAN-DB) && \
	\
	PKG_CONFIG=/tools/bin/true \
		libpipeline_CFLAGS='' \
		libpipeline_LIBS='-lpipeline' \
	./configure --prefix=/usr --libexecdir=/usr/lib \
		--sysconfdir=/etc --disable-setuid \
		--with-browser=/usr/bin/lynx --with-vgrind=/usr/bin/vgrind \
		--with-grap=/usr/bin/grap && \
	\
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(MAN-DB)/* && \
	make P=$(MAN-DB) log-package

$(MODULE-INIT-TOOLS):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(MODULE-INIT-TOOLS).tar.bz2 && \
	chmod 755 $(MODULE-INIT-TOOLS) && \
	chown -R 0:0 $(MODULE-INIT-TOOLS) && \
	cd $(MODULE-INIT-TOOLS) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(MODULE-INIT-TOOLS)-man_pages-1.patch && \
	\
	DOCBOOKTOMAN=/bin/true ./configure && \
	make check && \
	sed -i -e 's@../../configure@DOCBOOKTOMAN=/bin/true &@' \
		tests/runtests && \
	./tests/runtests && \
	make clean && \
	DOCBOOKTOMAN=/bin/true ./configure --prefix=/ \
		--enable-zlib-dynamic --mandir=/usr/share/man && \
	\
	make && \
	make INSTALL=install install && \
	\
	cd .. && \
	rm -rf $(MODULE-INIT-TOOLS)/* && \
	make P=$(MODULE-INIT-TOOLS) log-package

$(PATCH):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(PATCH).tar.bz2 && \
	chmod 755 $(PATCH) && \
	chown -R 0:0 $(PATCH) && \
	cd $(PATCH) && \
	\
	patch -Np1 -i $(LFS-PATCHES)/$(PATCH)-test_fix-1.patch && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(PATCH)/* && \
	make P=$(PATCH) log-package

$(PSMISC):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(PSMISC).tar.gz && \
	chmod 755 $(PSMISC) && \
	chown -R 0:0 $(PSMISC) && \
	cd $(PSMISC) && \
	\
	./configure --prefix=/usr --exec-prefix="" && \
	make && \
	make install && \
	\
	mv -v /usr/bin/fuser /bin && \
	mv -v /usr/bin/killall /bin && \
	\
	mv -v /bin/pstree* /usr/bin && \
	ln -sv killall /bin/pidof && \
	\
	cd .. && \
	rm -rf $(PSMISC)/* && \
	make P=$(PSMISC) log-package

$(SHADOW):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(SHADOW).tar.bz2 && \
	chmod 755 $(SHADOW) && \
	chown -R 0:0 $(SHADOW) && \
	cd $(SHADOW) && \
	\
	sed -i 's/groups$$(EXEEXT) //' src/Makefile.in && \
	find man -name Makefile -exec sed -i 's/groups\.1 / /' {} \; && \
	\
	sed -i -e 's/ ko//' -e 's/ zh_CN zh_TW//' man/Makefile.in && \
	\
	sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD MD5@' \
		-e 's@/var/spool/mail@/var/mail@' etc/login.defs && \
	\
	./configure --sysconfdir=/etc && \
	\
	make && \
	make install && \
	\
	mv -v /usr/bin/passwd /bin && \
	\
	pwconv && \
	grpconv && \
	useradd -D -b /home && \
	sed -i 's/yes/no/' /etc/default/useradd && \
	\
	cd .. && \
	rm -rf $(SHADOW)/* && \
	make P=$(SHADOW) log-package

$(SYSKLOGD):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(SYSKLOGD).tar.gz && \
	chmod 755 $(SYSKLOGD) && \
	chown -R 0:0 $(SYSKLOGD) && \
	cd $(SYSKLOGD) && \
	\
	make && \
	make BINDIR=/sbin install && \
	\
	echo "# Begin /etc/syslog.conf" > /etc/syslog.conf && \
	echo "" >> /etc/syslog.conf && \
	echo "auth,authpriv.* -/var/log/auth.log" \
		>> /etc/syslog.conf && \
	echo "*.*;auth,authpriv.none -/var/log/sys.log" \
		>> /etc/syslog.conf && \
	echo "daemon.* -/var/log/daemon.log" >> /etc/syslog.conf && \
	echo "kern.* -/var/log/kern.log" >> /etc/syslog.conf && \
	echo "mail.* -/var/log/mail.log" >> /etc/syslog.conf && \
	echo "user.* -/var/log/user.log" >> /etc/syslog.conf && \
	echo "*.emerg *" >> /etc/syslog.conf && \
	echo "" >> /etc/syslog.conf && \
	echo "# End /etc/syslog.conf" >> /etc/syslog.conf && \
	\
	cd .. && \
	rm -rf $(SYSKLOGD)/* && \
	make P=$(SYSKLOGD) log-package

$(SYSVINIT):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(SYSVINIT).tar.bz2 && \
	chmod 755 $(SYSVINIT) && \
	chown -R 0:0 $(SYSVINIT) && \
	cd $(SYSVINIT) && \
	\
	sed -i 's@Sending processes@& configured via /etc/inittab@g' \
		src/init.c && \
	\
	sed -i -e 's/utmpdump wall/utmpdump/' \
		-e 's/mountpoint.1 wall.1/mountpoint.1/' src/Makefile && \
	\
	make -C src && \
	make -C src install && \
	\
	echo "# Begin /etc/inittab" > /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "id:3:initdefault:" >> /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "si::sysinit:/etc/rc.d/init.d/rc sysinit" >> /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "l0:0:wait:/etc/rc.d/init.d/rc 0" >> /etc/inittab && \
	echo "l1:S1:wait:/etc/rc.d/init.d/rc 1" >> /etc/inittab && \
	echo "l2:2:wait:/etc/rc.d/init.d/rc 2" >> /etc/inittab && \
	echo "l3:3:wait:/etc/rc.d/init.d/rc 3" >> /etc/inittab && \
	echo "l4:4:wait:/etc/rc.d/init.d/rc 4" >> /etc/inittab && \
	echo "l5:5:wait:/etc/rc.d/init.d/rc 5" >> /etc/inittab && \
	echo "l6:6:wait:/etc/rc.d/init.d/rc 6" >> /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now" \
		>> /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "su:S016:once:/sbin/sulogin" >> /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "1:2345:respawn:/sbin/agetty tty1 9600" >> /etc/inittab && \
	echo "2:2345:respawn:/sbin/agetty tty2 9600" >> /etc/inittab && \
	echo "3:2345:respawn:/sbin/agetty tty3 9600" >> /etc/inittab && \
	echo "4:2345:respawn:/sbin/agetty tty4 9600" >> /etc/inittab && \
	echo "5:2345:respawn:/sbin/agetty tty5 9600" >> /etc/inittab && \
	echo "6:2345:respawn:/sbin/agetty tty6 9600" >> /etc/inittab && \
	echo "" >> /etc/inittab && \
	echo "# End /etc/inittab" >> /etc/inittab && \
	\
	cd .. && \
	rm -rf $(SYSVINIT)/* && \
	make P=$(SYSVINIT) log-package

$(TAR):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(TAR).tar.bz2 && \
	chmod 755 $(TAR) && \
	chown -R 0:0 $(TAR) && \
	cd $(TAR) && \
	\
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
		--prefix=/usr --bindir=/bin --libexecdir=/usr/sbin && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(TAR)/* && \
	make P=$(TAR) log-package

$(TEXINFO):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(TEXINFO).tar.gz && \
	chmod 755 $(TEXINFO) && \
	chown -R 0:0 $(TEXINFO) && \
	cd $(TEXINFO) && \
	\
	./configure --prefix=/usr && \
	make && \
	make install && \
	\
	cd .. && \
	rm -rf $(TEXINFO)/* && \
	make P=$(TEXINFO) log-package

$(UDEV):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(UDEV).tar.bz2 && \
	chmod 755 $(UDEV) && \
	chown -R 0:0 $(UDEV) && \
	cd $(UDEV) && \
	\
	sed -i -e '/deprecated/d' udev/udevadm-trigger.c && \
	\
	tar jxvf $(LFS-TARBALLS)/$(UDEV-CONFIG).tar.bz2 && \
	\
	install -dv /lib/{firmware,udev/devices/{pts,shm}} && \
	mknod -m0666 /lib/udev/devices/null c 1 3 && \
	\
	./configure --prefix=/usr \
		--sysconfdir=/etc --sbindir=/sbin \
		--with-rootlibdir=/lib --libexecdir=/lib/udev \
		--docdir=/usr/share/doc/$(UDEV) \
		--disable-gtk-doc \
		--disable-extras --disable-introspection \
		--disable-hwdb --disable-keymap --disable-gudev && \
	make && \
	make install && \
	ldconfig && \
	\
	echo obsolete install -m644 -v rules/packages/64-*.rules \
		/etc/udev/rules.d/ && \
	echo obsolete install -m644 -v rules/packages/40-pilot-links.rules \
		/etc/udev/rules.d/40-pilot-links.rules && \
	\
	cd $(UDEV-CONFIG) && \
	make install && \
	make install-doc && \
	cd .. && \
	\
	cd .. && \
	rm -rf $(UDEV)/* && \
	make P=$(UDEV) log-package

$(VIM):
	set +h && \
	\
	tar xvf $(LFS-TARBALLS)/$(VIM).tar.bz2 && \
	\
	mv vim$(VIM-VER) $(VIM) && \
	\
	chmod 755 $(VIM) && \
	chown -R 0:0 $(VIM) && \
	cd $(VIM) && \
	\
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h && \
	\
	./configure --prefix=/usr --enable-multibyte && \
	make && \
	make install && \
	\
	ln -sv vim /usr/bin/vi && \
	ln -sv vim.1 /usr/share/man/man1/vi.1 && \
	\
	echo "set nocompatible" > /etc/vimrc && \
	echo "set backspace=2" >> /etc/vimrc && \
	echo "syntax off" >> /etc/vimrc && \
	\
	cd .. && \
	rm -rf $(VIM)/* && \
	make P=$(VIM) log-package

$(LFS-BOOTSCRIPTS):
	set +h && \
	\
	tar jxvf $(LFS-TARBALLS)/$(LFS-BOOTSCRIPTS).tar.bz2 && \
	chmod 755 $(LFS-BOOTSCRIPTS) && \
	chown -R 0:0 $(LFS-BOOTSCRIPTS) && \
	cd $(LFS-BOOTSCRIPTS) && \
	\
	make install && \
	\
	cd .. && \
	rm -rf $(LFS-BOOTSCRIPTS)/* && \
	make P=$(LFS-BOOTSCRIPTS) log-package

##########################################################################
#
# Begin Chapter8 stuff
# built outside chrooted environment
#
##########################################################################

config-setclock:
	mkdir -p $(LFS)/etc/sysconfig && \
	\
	echo "# Begin /etc/sysconfig/clock" > $(LFS)/etc/sysconfig/clock && \
	echo "" >> $(LFS)/etc/sysconfig/clock && \
	echo "UTC=0" >> $(LFS)/etc/sysconfig/clock && \
	echo "" >> $(LFS)/etc/sysconfig/clock && \
	echo "# End /etc/sysconfig/clock" >> $(LFS)/etc/sysconfig/clock

config-console:
	echo "# Begin /etc/sysconfig/console" \
		> $(LFS)/etc/sysconfig/console && \
	echo "" >> $(LFS)/etc/sysconfig/console && \
	echo "KEYMAP=defkeymap" >> $(LFS)/etc/sysconfig/console && \
	echo 'FONT="lat1-16 -m 8859-1"' >> $(LFS)/etc/sysconfig/console && \
	echo "" >> $(LFS)/etc/sysconfig/console && \
	echo "# End /etc/sysconfig/console" >> $(LFS)/etc/sysconfig/console

config-inputrc:
	echo '# Begin /etc/inputrc' > $(LFS)/etc/inputrc && \
	echo '# Modified by Chris Lynn <roryo@roryo.dynup.net>' \
		>> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# Allow the command prompt to wrap to the next line' \
		>> $(LFS)/etc/inputrc && \
	echo 'set horizontal-scroll-mode Off' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# Enable 8bit input' >> $(LFS)/etc/inputrc && \
	echo 'set meta-flag On' >> $(LFS)/etc/inputrc && \
	echo 'set input-meta On' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# Turns off 8th bit stripping' >> $(LFS)/etc/inputrc && \
	echo 'set convert-meta Off' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# Keep the 8th bit for display' >> $(LFS)/etc/inputrc && \
	echo 'set output-meta On' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# none, visible or audible' >> $(LFS)/etc/inputrc && \
	echo 'set bell-style none' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# All of the following map the escape sequence of the value' \
		>> $(LFS)/etc/inputrc && \
	echo '# contained in 1st argument to readline specific functions' \
		>> $(LFS)/etc/inputrc && \
	echo '"\eOd": backward-word' >> $(LFS)/etc/inputrc && \
	echo '"\eOc": forward-word' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# for linux console' >> $(LFS)/etc/inputrc && \
	echo '"\e[1~": beginning-of-line' >> $(LFS)/etc/inputrc && \
	echo '"\e[4~": end-of-line' >> $(LFS)/etc/inputrc && \
	echo '"\e[5~": beginning-of-history' >> $(LFS)/etc/inputrc && \
	echo '"\e[6~": end-of-history' >> $(LFS)/etc/inputrc && \
	echo '"\e[3~": delete-char' >> $(LFS)/etc/inputrc && \
	echo '"\e[2~": quoted-insert' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# for xterm' >> $(LFS)/etc/inputrc && \
	echo '"\eOH": beginning-of-line' >> $(LFS)/etc/inputrc && \
	echo '"\eOF": end-of-line' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# for Konsole' >> $(LFS)/etc/inputrc && \
	echo '"\e[H": beginning-of-line' >> $(LFS)/etc/inputrc && \
	echo '"\e[F": end-of-line' >> $(LFS)/etc/inputrc && \
	echo '' >> $(LFS)/etc/inputrc && \
	echo '# End /etc/inputrc' >> $(LFS)/etc/inputrc

config-localnet:
	echo "HOSTNAME=$(LFS-HOSTNAME)" > $(LFS)/etc/sysconfig/network

config-hosts:
	echo "127.0.0.1 localhost" > $(LFS)/etc/hosts

config-network:
	echo DangerWillRogers /lib/udev/write_net_rules all_interfaces && \
	\
	mkdir -p $(LFS)/etc/sysconfig/network-devices/ifconfig.eth0 && \
	\
	echo 'ONBOOT="no"' > \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo 'SERVICE="dhclient"' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo 'DHCP_START="-q"' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo 'DHCP_STOP="-q -r"' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo '' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo '# Set PRINTIP="yes" to have the script print' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo '# the DHCP assigned IP address' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo 'PRINTIP="no"' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo '' >> \
		 $(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo '# Set PRINTALL="yes" to print the DHCP assigned values for' \
		>> $(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo '# IP, SM, DG, and 1st NS. This requires PRINTIP="yes".' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient && \
	echo 'PRINTALL="no"' >> \
		$(LFS)/etc/sysconfig/network-devices/ifconfig.eth0/dhclient

config-shadow:
	sed -i \
	's/^root:x:.*$$/root:$$1$$ghS0jZGH$$BBivcw4YdpU8mE1EqrKBI1:13967:0:99999:7:::/' \
		$(LFS)/etc/shadow && \
	\
	echo 'Root password has been reset to "lfsroot"'

config-initd:
	if [ -d $(LFS)/etc/init.d ]; then \
		echo "Found /etc/init.d as directory, stopping" && \
		exit; \
	elif [ -l $(LFS)/etc/init.d ]; then \
		echo "Found /etc/init.d as link, stopping" && \
		exit; \
	fi && \
	\
	echo "Linking /etc/init.d" && \
	ln -sfn /etc/rc.d/init.d $(LFS)/etc/init.d 


