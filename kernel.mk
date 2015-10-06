kimage		?= $(CONFIG_IMAGE)
KIMAGE		?= $(if $(kimage),$(kimage),zImage)

%.dtb: linux/arch/$(arch)/boot/dts/%.dts
	@echo "Building $@ for $(ARCH)..."
	make -C linux $@
	cp linux/arch/$(arch)/boot/dts/$@ .

kernel_% linux_%:
	make -C linux $*

kernel_menuconfig linux_menuconfig:

linux/.config:
	@echo "You need to provide your own kernel sources into the ./linux directory!"
	@echo "Have a look at https://www.kernel.org!"
	@exit 1

linux/arch/$(arch)/boot/$(KIMAGE): initramfs.cpio linux/.config
	@echo "Building $(KIMAGE) for $(ARCH)..."
	make -C linux $(@F) CONFIG_INITRAMFS_SOURCE=../$<

$(KIMAGE): linux/arch/$(arch)/boot/$(KIMAGE)
	cp linux/arch/$(arch)/boot/$@ $@

kernel: $(KIMAGE)

clean::
	rm -f $(KIMAGE)

mrproper::
	rm -f *Image *.dtb
