.PHONY:: kexec-tools

kexec-tools:: kexec-tools/build/sbin/kexec

kexec-tools/Makefile: kexec-tools/configure
	@echo "Configuring kexec-tools..."
	( cd kexec-tools && ./configure --prefix=$(prefix) --host=$(host) LDFLAGS=-static )

kexec-tools/build/sbin/kexec: kexec-tools/Makefile
	@echo "Compiling kexec-tools..."
	make -C kexec-tools
	touch $@

packages-initramfs/kexec-tools/usr/sbin/kexec: kexec-tools/build/sbin/kexec
	@echo "Installing kexec-tools..."
	make -C kexec-tools install DESTDIR=$(CURDIR)/packages-initramfs/kexec-tools
	$(CROSS_COMPILE)strip -s $@
	rm packages-initramfs/kexec-tools/usr/sbin/kdump packages-initramfs/kexec-tools/usr/sbin/vmcore-dmesg
	rm -Rf packages-initramfs/kexec-tools/usr/share

install-initramfs/kexec-tools.tgz: packages-initramfs/kexec-tools/usr/sbin/kexec

kexec-tools_%::
	make -C kexec-tools $*

kexec-tools:: kexec-tools_all

kexec-tools_configure:
	make -f Makefile kexec-tools/Makefile

kexec-tools_compile:
	make -f Makefile kexec-tools/build/sbin/kexec

kexec-tools_install:
	make -f Makefile packages-initramfs/kexec-tools/usr/sbin/kexec

kexec-tools_clean::
	-make -C kexec-tools clean
	rm -f install-initramfs/kexec-tools.tgz

kexec-tools_cleanall:: kexec-tools_clean
	-make -C kexec-tools distclean
	rm -Rf packages-initramfs/kexec-tools/*

reallyclean:: kexec-tools_clean

mrproper:: kexec-tools_cleanall
