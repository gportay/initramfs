image			?= $(CONFIG_IMAGE)
IMAGE			?= $(if $(image),$(image),zImage)

%.dtb: linux/arch/$(arch)/boot/dts/%.dts
	@echo "Building $@ for $(ARCH)..."
	make -C linux $@
	cp linux/arch/$(arch)/boot/dts/$@ .

linux_%s:
	make -C linux $*

linux/.config:
	@echo "You need to provide your own kernel sources into the ./linux directory!"
	@echo "Have a look at https://www.kernel.org!"
	@exit 1

linux/arch/$(arch)/boot/$(IMAGE): initramfs.cpio linux/.config
	@echo "Building $(IMAGE) for $(ARCH)..."
	make -C linux $(@F) CONFIG_INITRAMFS_SOURCE=../$<

$(IMAGE): linux/arch/$(arch)/boot/$(IMAGE)
	cp linux/arch/$(arch)/boot/$@ $@

kernel: $(IMAGE)

clean::
	rm -f $(IMAGE)

reallyclean::
	rm -f *Image *.dtb
