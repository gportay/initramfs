.PHONY:: kexec-tools

kexec-tools:: kexec-tools/build/sbin/kexec

kexec-tools/Makefile: kexec-tools/configure
	@echo -e "\e[1mConfiguring kexec-tools...\e[0m"
	( cd kexec-tools && ./configure --prefix=$(prefix) --host=$(host) )

kexec-tools/build/sbin/kexec: kexec-tools/Makefile
	@echo -e "\e[1mCompiling kexec-tools...\e[0m"
	make -C kexec-tools
	touch $@

packages-initramfs/kexec-tools/usr/sbin/kexec: kexec-tools/build/sbin/kexec
	@echo -e "\e[1mInstalling kexec-tools...\e[0m"
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
