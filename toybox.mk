.PHONY:: toybox

toybox:: toybox/toybox

toybox/.config: toybox_defconfig
	@echo "Configuring toybox..."
	cp $< $@
	yes "" | make -C toybox oldconfig

toybox/toybox: toybox/.config
	@echo "Compiling toybox..."
	make -C toybox

packages-initramfs/toybox/bin/toybox: toybox/toybox
	@echo "Installing toybox..."
	make -C toybox install PREFIX=$(CURDIR)/packages-initramfs/toybox

install-initramfs/toybox.tgz: packages-initramfs/toybox/bin/toybox

toybox_%::
	make -C toybox $*

toybox:: toybox_all

toybox_configure:
	make -f Makefile toybox/.config

toybox_compile:
	make -f Makefile toybox/toybox

toybox_install:
	make -f Makefile packages-initramfs/toybox/bin/toybox

toybox_clean:
	-make -C toybox clean
	rm -f install-initramfs/toybox.tgz

toybox_cleanall:
	-make -C toybox mrproper
	rm -Rf packages-initramfs/toybox/*

reallyclean::
	-make -f Makefile toybox_clean

mrpoper::
	-make -f Makefile toybox_distclean
