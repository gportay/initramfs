LOCALVERSION	?=

$(LINUXDIR)/modules.builtin: $(KOUTPUT)/.config
	@echo "Building modules..."
	make -C linux O=$(CURDIR)/$(KOUTPUT) modules

packages-initramfs/modules/lib/modules: $(LINUXDIR)/modules.builtin
	@echo "Installing modules..."
	make -C linux O=$(CURDIR)/$(KOUTPUT) modules_install INSTALL_MOD_PATH=$(CURDIR)/packages-initramfs/modules/

clean::
	rm install-initramfs/modules.tgz
	rm -Rf packages-initramfs/modules/lib/*

