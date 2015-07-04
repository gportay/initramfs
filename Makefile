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

KIMAGE		?= zImage
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

$(tmpdir)/ramfs: $(packages)
	@for pkg in $(packages); do echo " - $${pkg##*/}"; done
	install -d $@
	for dir in install-initramfs $(extradir); do find $$dir/ -name "*.tgz" -exec tar xzf {} -C $@ \;; done

$(tmpdir)/ramfs/init $(tmpdir)/ramfs/linuxrc:
	ln -sf etc/init $@

$(tmpdir)/ramfs/initrd:
	install -d $@

$(tmpdir)/ramfs/dev/initrd:
	fakeroot -- mknod -m 400 $@ b 1 250

$(tmpdir)/ramfs/dev/console:
	fakeroot -- mknod -m 622 $@ c 5 1

initramfs.cpio: $(tmpdir)/ramfs $(tmpdir)/ramfs/init $(tmpdir)/ramfs/dev/console

initrd.cpio initrd.squashfs: $(tmpdir)/ramfs $(tmpdir)/ramfs/initrd $(tmpdir)/ramfs/dev/initrd

%.cpio:
	cd $< && find . | cpio -H newc -o >$(CURDIR)/$@
	rm -Rf $<

%.squashfs:
	mksquashfs $< $@ -all-root
	rm -Rf $<

clean::
	rm -f install-*/*.tgz initramfs.cpio initrd.cpio initrd.squashfs

reallyclean:: clean

mrproper:: reallyclean
