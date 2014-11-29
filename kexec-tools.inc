kexec-tools/configure:
	@echo -e "\e[1mConfiguring kexec-tools...\e[0m"
	( cd kexec-tools && autoreconf -vif && ./configure --prefix=$(prefix) --host=$(host) )

kexec-tools/build/sbin/kexec: kexec-tools/configure
	@echo -e "\e[1mCompiling kexec-tools...\e[0m"
	( cd kexec-tools && make kexec )
	@echo -e "\e[1mInstalling kexec-tools...\e[0m"
	make -C kexec-tools install DESTDIR=$(PWD)/$@
	$(CROSS_COMPILE)strip -s $@/usr/sbin/kexec
	rm $@/usr/sbin/kdump $@/usr/sbin/vmcore-dmesg
	rm -Rf $@/usr/share

packages-initramfs/kexec-tools: kexec-tools/build/sbin/kexec

install-initramfs/kexec-tools.tgz: packages-initramfs/kexec-tools

kexec-tools_clean:
	rm -f install-initramfs/kexec-tools.tgz

kexec-tools_mrproper: kexec-tools_clean
	make -C kexec-tools distclean
	rm -Rf packages-initramfs/kexec-tools/*
