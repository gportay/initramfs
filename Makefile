VERSION		 = 0
PATCHLEVEL	 = 0
SUBLEVEL	 = 1
EXTRAVERSION	 = 
NAME		 = I am Charlie
RELEASE		 = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

all::

include kconfig.mk
include dir.mk
include autotools.mk

PREFIX ?= /usr
TMPDIR ?= /tmp
tmpdir := $(shell mktemp -d $(TMPDIR)/initramfs-XXXXXX)

prefix := $(PREFIX)

export LDFLAGS ?= -static
CROSS_COMPILE	?= $(CONFIG_CROSS_COMPILE:"%"=%)
ifdef CROSS_COMPILE
CC = $(CROSS_COMPILE)gcc
host := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-$$,,')
arch := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-.*$$,,1')
endif

arch		?= $(shell uname -m)
export ARCH = $(arch)

ifeq ($(CONFIG_HAVE_DOT_CONFIG),y)
all:: initramfs.cpio
else
all:: menuconfig
endif

tgz-y		?= install-initramfs/ramfs.tgz
include initramfs.mk

.SILENT:: initramfs.cpio version help

.PHONY:: all clean

version:
	echo "$(RELEASE)"

help::
	echo -e "\$$ make version\t\t\t\tto display version."
	echo -e "\$$ make help\t\t\t\tto display this message."
	echo -e "\$$ make [initramfs.cpio]\t\t\tto build an Initial RAMFS archive."
	echo -e "\$$ make initrd.cpio\t\t\tto build an Initial RAM-Disk archive."
	echo -e "\$$ make initrd.squashfs\t\t\tto build an Initial RAM-Disk SquashFS image."
	echo -e "\$$ make kernel [KIMAGE=zImage]\t\tto build a kernel image with its appended initramfs."
	echo -e "\$$ make dtb|dtbs\t\t\t\tto build a dtb or all dbts images."
	echo -e "\$$ make kernel|linux_xxx\t\t\tto run linux kernel xxx rule."
	echo -e "\$$ make clean\t\t\t\tto clean workspace from outputs."
	echo -e "\$$ make reallyclean\t\t\tto clean workspace from all package outputs."
	echo -e "\$$ make mrproper\t\t\t\tto clean workspace from everything."
	echo -e ""
	echo -e "Extra variables:"
	echo -e "CROSS_COMPILE:                          Sets the cross-compiler (packages)."
	echo -e "KIMAGE:                                 Set kernel image type (kernel)."

install-initramfs/%.tgz:
	@echo "Building package $*..."
	( cd packages-initramfs/$* && tar czf ../../$@ --exclude=.gitignore * )

$(tmpdir)/ramfs: $(tgz-y)
	@for tgz in $(tgz-y); do echo " - $${tgz##*/}"; done
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

initramfs.cpio.gz initrd.cpio.gz:

initramfs.cpio: $(tmpdir)/ramfs $(tmpdir)/ramfs/init $(tmpdir)/ramfs/dev/console

initrd.cpio initrd.squashfs: $(tmpdir)/ramfs $(tmpdir)/ramfs/linuxrc $(tmpdir)/ramfs/initrd $(tmpdir)/ramfs/dev/initrd

%.cpio:
	cd $< && find . | cpio -H newc -o >$(CURDIR)/$@
	rm -Rf $(<D)

%.squashfs:
	mksquashfs $< $@ -all-root
	rm -Rf $(<D)

%.gz: %
	gzip -9 $*

clean::
	rm -f install-*/*.tgz initramfs.cpio initrd.cpio initrd.squashfs

reallyclean:: clean

mrproper:: reallyclean
