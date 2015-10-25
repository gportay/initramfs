kimage		?= $(CONFIG_IMAGE)
KIMAGE		?= $(if $(kimage),$(kimage),zImage)

%.dtb: linux/arch/$(karch)/boot/dts/%.dts
	@echo "Building $@ for $(karch)..."
	make -C linux $@
	cp linux/arch/$(karch)/boot/dts/$@ .

kernel_% linux_%:
	make -C linux $*

kernel_menuconfig linux_menuconfig:

kernel_download linux_download:
	wget -qO- https://www.kernel.org/index.html | sed -n '/<td id="latest_link"/,/<\/td>/s,.*<a.*href="\(.*\)">\(.*\)</a>.*,wget -qO- \1 | tar xvJ \&\& ln -sf linux-\2 linux,p' | sh

linux/Makefile:
	@echo "You need to provide your own kernel sources into the $(CURDIR)/$(@D) directory!" >&2
	@echo "Have a look at https://www.kernel.org! or run one of the commands below:" >&2
	@echo "$$ git clone git@github.com:torvalds/linux.git $(CURDIR)/$(@D)" >&2
	@echo "or" >&2
	@echo "$$ make $(@D)_download" >&2
	@exit 1

linux/.config: linux/Makefile
	@echo "You need to configure your kernel using a defconfig file!" >&2
	@echo "Run one of the commands below:" >&2
	@echo "$$ make -C $(@D) ARCH=$(karch) menuconfig" >&2
	@echo "or" >&2
	@echo "$$ make -C $(@D) ARCH=$(karch) tinyconfig" >&2
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
