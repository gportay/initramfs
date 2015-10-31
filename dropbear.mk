.PHONY:: dropbear

dropbear:: dropbear/dropbearmulti

dropbear/Makefile: dropbear/configure
	@echo "Configuring dropbear..."
	( cd dropbear && ./configure --prefix=$(prefix) --host=$(host) --disable-zlib )

dropbear/dropbearmulti: dropbear/Makefile
	@echo "Compiling dropbear..."
	make -C dropbear PROGRAMS="dropbear dbclient scp dropbearkey dropbearconvert" MULTI=1 STATIC=1 SCPPROGRESS=1

packages-initramfs/dropbear/usr/bin/dropbearmulti: dropbear/dropbearmulti
	@echo "Installing dropbear..."
	make -C dropbear install DESTDIR=$(CURDIR)/packages-initramfs/dropbear PROGRAMS="dropbear dbclient scp dropbearkey dropbearconvert" MULTI=1 STATIC=1 SCPPROGRESS=1
	$(CROSS_COMPILE)strip -s $@
	rm -Rf packages-initramfs/dropbear/usr/share/

packages-initramfs/dropbear/etc/init.d/dropbear:
	install -d $(@D)/
	cp dropbear/debian/dropbear.init $@
	chmod a+x $@

install-initramfs/dropbear.tgz: packages-initramfs/dropbear/usr/bin/dropbearmulti packages-initramfs/dropbear/etc/init.d/dropbear

ifeq (,$(CROSS_COMPILE))
dropbear/dropbearkey: dropbear/dropbearmulti
	ln -sf $(<F) $@

packages-initramfs/dropbear/etc/dropbear/dropbear_%_host_key: dropbear/dropbearkey
	install -d $(@D)/
	$< -t $* -f $@

install-initramfs/dropbear.tgz:: packages-initramfs/dropbear/etc/dropbear/dropbear_rsa_host_key packages-initramfs/dropbear/etc/dropbear/dropbear_dss_host_key packages-initramfs/dropbear/etc/dropbear/dropbear_ecdsa_host_key
endif

dropbear_%::
	make -C dropbear $*

dropbear:: dropbear_all

dropbear_configure:
	make -f Makefile dropbear/Makefile

dropbear_compile:
	make -f Makefile dropbear/dropbearmulti

dropbear_install:
	make -f Makefile packages-initramfs/dropbear/usr/bin/dropbearmulti

dropbear_clean::
	-make -C dropbear clean
	rm -f install-initramfs/dropbear.tgz

dropbear_cleanall:: dropbear_clean
	-make -C dropbear distclean
	rm -Rf packages-initramfs/dropbear/*

reallyclean:: dropbear_clean

mrproper:: dropbear_cleanall
