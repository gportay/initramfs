kexec-tools: kexec-tools/build/sbin/kexec

kexec-tools/Makefile: kexec-tools/configure
	@echo -e "\e[1mConfiguring $(@D)...\e[0m"
	( cd kexec-tools && ./configure --prefix=$(prefix) --host=$(host) )

kexec-tools/build/sbin/kexec: kexec-tools/Makefile
	@echo -e "\e[1mCompiling kexec-tools...\e[0m"
	( cd kexec-tools && make kexec )

packages-initramfs/kexec-tools: kexec-tools/build/sbin/kexec
	@echo -e "\e[1mInstalling kexec-tools...\e[0m"
	make -C kexec-tools install DESTDIR=$(PWD)/$@
	$(CROSS_COMPILE)strip -s $@/usr/sbin/kexec
	rm $@/usr/sbin/kdump $@/usr/sbin/vmcore-dmesg
	rm -Rf $@/usr/share

install-initramfs/kexec-tools.tgz: packages-initramfs/kexec-tools

kexec-tools_%::
	make -C kexec-tools $*

kexec-tools_clean::
	-make -C kexec-tools clean
	rm -f install-initramfs/kexec-tools.tgz

kexec-tools_cleanall:: kexec-tools_clean
	-make -C kexec-tools distclean
	rm -Rf packages-initramfs/kexec-tools/*

clean:: kexec-tools_clean

mrproper:: kexec-tools_cleanall
