busybox/.config: busybox.defconfig
	@echo -e "\e[1mConfiguring busybox...\e[0m"
	cp $< $@
	make -C busybox oldconfig

packages-initramfs/busybox/bin/busybox: busybox/.config
	@echo -e "\e[1mCompiling and installing busybox...\e[0m"
	make -C busybox install CONFIG_PREFIX=../$@
	touch $@

packages-initramfs/busybox: packages-initramfs/busybox/bin/busybox

install-initramfs/busybox.tgz: packages-initramfs/busybox

busybox_clean:
	rm -f install-initramfs/busybox.tgz

busybox_mrproper: busybox_clean
	make -C busybox mrproper
	rm -Rf packages-initramfs/busybox/*
