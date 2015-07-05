.PHONY:: busybox

busybox:: busybox/busybox

busybox/.config: busybox_defconfig
	@echo "Configuring busybox..."
	cp $< $@
	yes "" | make -C busybox oldconfig

busybox/busybox: busybox/.config
	@echo "Compiling busybox..."
	make -C busybox

packages-initramfs/busybox/bin/busybox: busybox/busybox
	@echo "Installing busybox..."
	make -C busybox install CONFIG_PREFIX=$(CURDIR)/packages-initramfs/busybox

install-initramfs/busybox.tgz: packages-initramfs/busybox/bin/busybox

busybox_%::
	make -C busybox $*

busybox:: busybox_all

busybox_menuconfig:

busybox_configure:
	make -f Makefile busybox/.config

busybox_compile:
	make -f Makefile busybox/busybox

busybox_install:
	make -f Makefile packages-initramfs/busybox/bin/busybox

busybox_clean:
	-make -C busybox clean
	rm -f install-initramfs/busybox.tgz

busybox_cleanall:
	-make -C busybox mrproper
	rm -Rf packages-initramfs/busybox/*

reallyclean::
	-make -f Makefile busybox_clean

mrpoper::
	-make -f Makefile busybox_cleanall
