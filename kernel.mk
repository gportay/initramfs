OUTPUTDIR	?= output

kimage		?= $(CONFIG_IMAGE)
KDEFCONFIG	?= tinyconfig
KIMAGE		?= $(if $(kimage),$(kimage),$(archimage))
KOUTPUT		?= $(OUTPUTDIR)/linux-$(karch)
KEXTRADEFCONFIG	+= initramfs.cfg

ifneq (,$(KEXTRACFG))
KEXTRADEFCONFIG	+= local-$(karch).cfg

local-$(karch).cfg:
	echo "# Automatically generated file." >local-$(karch).cfg
	for cfg in $(KEXTRACFG); do echo $$cfg >>local-$(karch).cfg; done
endif

linux/Makefile:
	@echo "You need to provide your own kernel sources into the $(CURDIR)/$(@D) directory!" >&2
	@echo "Have a look at https://www.kernel.org! or run one of the commands below:" >&2
	@echo "$$ git clone git@github.com:torvalds/linux.git $(CURDIR)/$(@D)" >&2
	@echo "or" >&2
	@echo "$$ make $(@D)_download" >&2
	@exit 1

ifeq (,$(CROSS_COMPILE))
$(KOUTPUT)/.config: linux/Makefile $(KEXTRADEFCONFIG)
	@echo "Configuring linux using $(KDEFCONFIG) and extra $(KEXTRADEFCONFIG)..."
	install -d $(@D)
	make -C linux O=$(CURDIR)/$(KOUTPUT) $(KDEFCONFIG)
	cd linux && scripts/kconfig/merge_config.sh -O $(CURDIR)/$(KOUTPUT) $(CURDIR)/$@ $(patsubst %,$(CURDIR)/%,$(KEXTRADEFCONFIG))
else
$(KOUTPUT)/.config: linux/Makefile
	@echo "You need to configure your kernel using a defconfig file!" >&2
	@echo "Run one of the commands below:" >&2
	@echo "$$ make -C linux O=$(CURDIR)/$(@D) ARCH=$(karch) menuconfig" >&2
	@echo "or" >&2
	@echo "$$ make -C linux O=$(CURDIR)/$(@D) ARCH=$(karch) tinyconfig" >&2
	@exit 1
endif

ifneq (,$(findstring $(karch),arc arm arm64 c6x h8300 metag microblaze nios2 openrisc powerpc sparc))
$(KOUTPUT)/arch/arm/boot/dts/%.dtb:
	@echo "Compiling linux ($(@F))..."
	make -C linux O=$(CURDIR)/$(KOUTPUT) $(@F)

%.dtb: $(KOUTPUT)/arch/$(karch)/boot/dts/%.dtb
	cp $< .

dtbs: linux_dtbs
endif

$(KOUTPUT)/arch/$(karch)/boot/$(KIMAGE): initramfs.cpio $(KOUTPUT)/.config
	@echo "Compiling linux ($(@F))..."
	make -C linux O=$(CURDIR)/$(KOUTPUT) CONFIG_INITRAMFS_SOURCE=$(CURDIR)/$< $(@F)

$(KIMAGE): $(KOUTPUT)/arch/$(karch)/boot/$(KIMAGE)
	cp $< $@

kernel: $(KIMAGE)

kernel_% linux_%:
	make -C linux O=$(CURDIR)/$(KOUTPUT) $*

kernel_menuconfig linux_menuconfig:

kernel_download linux_download:
	wget -qO- https://www.kernel.org/index.html | sed -n '/<td id="latest_link"/,/<\/td>/s,.*<a.*href="\(.*\)">\(.*\)</a>.*,wget -qO- \1 | tar xvJ \&\& ln -sf linux-\2 linux,p' | sh

kernel_configure linux_configure:
	make -f Makefile $(KOUTPUT)/.config

kernel_compile linux_compile:
	make -f Makefile $(KOUTPUT)/arch/$(karch)/boot/$(KIMAGE)

kernel_clean linux_clean:
	make -C linux mrproper

clean::
	rm -f $(KIMAGE)

cleanall::
	rm -rf $(KOUTPUT)/

mrproper::
	rm -f *Image *.dtb
	rm -rf $(OUTPUTDIR)/linux-*/
