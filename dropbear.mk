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
