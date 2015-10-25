kimage		?= $(CONFIG_IMAGE)
KIMAGE		?= $(if $(kimage),$(kimage),zImage)

%.dtb: linux/arch/$(karch)/boot/dts/%.dts
	@echo "Building $@ for $(karch)..."
	make -C linux $@
	cp linux/arch/$(karch)/boot/dts/$@ .

kernel_% linux_%:
	make -C linux $*

kernel_menuconfig linux_menuconfig:

linux/Makefile:
	@echo "You need to provide your own kernel sources into the ./linux directory!" >&2
	@echo "Have a look at https://www.kernel.org!" >&2
	@exit 1

linux/.config: linux/Makefile
	@echo "You need to configure your kernel using a defconfig file!" >&2
	@exit 1

linux/arch/$(karch)/boot/$(KIMAGE): initramfs.cpio linux/.config
	@echo "Building $(KIMAGE) for $(karch)..."
	make -C linux $(@F) CONFIG_INITRAMFS_SOURCE=../$<

$(KIMAGE): linux/arch/$(karch)/boot/$(KIMAGE)
	cp linux/arch/$(karch)/boot/$@ $@

kernel: $(KIMAGE)

clean::
	rm -f $(KIMAGE)

mrproper::
	rm -f *Image *.dtb
