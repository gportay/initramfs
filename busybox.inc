busybox: busybox/busybox

busybox/.config: busybox_defconfig
	@echo -e "\e[1mConfiguring busybox...\e[0m"
	cp $< $@
	make -C busybox oldconfig

busybox/busybox: busybox/.config
	@echo -e "\e[1mCompiling busybox...\e[0m"
	make -C busybox

packages-initramfs/busybox: busybox/busybox
	@echo -e "\e[1mInstalling busybox...\e[0m"
	make -C busybox install CONFIG_PREFIX=../$@
	touch $@

install-initramfs/busybox.tgz: packages-initramfs/busybox

busybox_clean:
	rm -f install-initramfs/busybox.tgz

busybox_mrproper: busybox_clean
	make -C busybox mrproper
	rm -Rf packages-initramfs/busybox/*
