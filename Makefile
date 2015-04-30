VERSION		 = 0
PATCHLEVEL	 = 0
SUBLEVEL	 = 0
EXTRAVERSION	 = .1
NAME		 = I am Charlie

all::

include dir.mk
include autotools.mk

PREFIX ?= /usr
TMPDIR ?= /tmp
tmpdir := $(shell mktemp -d $(TMPDIR)/initramfs-XXXXXX)

prefix := $(PREFIX)

export LDFLAGS ?= -static
ifdef CROSS_COMPILE
CC = $(CROSS_COMPILE)gcc
host := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-$$,,')
arch := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-.*$$,,1')
endif

IMAGE		?= zImage
arch		?= $(shell uname -m)
export ARCH = $(arch)

all:: initramfs.cpio

packages ?= install-initramfs/ramfs.tgz
PACKAGES += initramfs.mk
include $(PACKAGES)

.SILENT:: initramfs.cpio

.PHONY:: all clean

install-initramfs/%.tgz:
	@echo "Building package $*..."
	( cd packages-initramfs/$* && tar czf ../../$@ --exclude=.gitignore * )

initramfs.cpio: $(packages)
	@echo "Generating $@..."
	@for pkg in $(packages); do echo " - $${pkg##*/}"; done
	install -d $(tmpdir)/ramfs
	for dir in install-initramfs $(extradir); do find $$dir/ -name "*.tgz" -exec tar xzf {} -C $(tmpdir)/ramfs \;; done
	if ! test -e $(tmpdir)/ramfs/init; then ln -sf etc/init $(tmpdir)/ramfs/init; fi
	if ! test -e $(tmpdir)/ramfs/dev/console; then fakeroot -- mknod -m 622 $(tmpdir)/ramfs/dev/console c 5 1; fi
	( cd $(tmpdir)/ramfs/ && find . | cpio -H newc -o >../$@ ) && cp $(tmpdir)/$@ .
	rm -Rf $(tmpdir)

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
	rm -f install-*/*.tgz initramfs.cpio $(IMAGE)

reallyclean:: clean

mrproper:: reallyclean
	rm -f *Image *.dtb
