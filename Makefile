VERSION		 = 0
PATCHLEVEL	 = 0
SUBLEVEL	 = 0
EXTRAVERSION	 = .1
NAME		 = I am Charlie

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
export CROSS_COMPILE
endif

IMAGE		?= zImage
arch		?= $(shell uname -m)
export ARCH = $(arch)

ifeq ($(CONFIG_HAVE_DOT_CONFIG),y)
all:: initramfs.cpio
else
all:: silentoldconfig
endif

tgz-y		?= install-initramfs/ramfs.tgz
include initramfs.mk

.SILENT:: initramfs.cpio

.PHONY:: all clean

.PRECIOUS::

install-initramfs/%.tgz:
	@echo "Building package $*..."
	( cd packages-initramfs/$* && tar czf ../../$@ --exclude=.gitignore * )

initramfs.cpio: $(tgz-y)
	@echo "Generating $@..."
	@for tgz in $(tgz-y); do echo " - $${tgz##*/}"; done
	install -d $(tmpdir)/ramfs
	for dir in install-initramfs $(extradir); do find $$dir/ -name "*.tgz" -exec tar xzf {} -C $(tmpdir)/ramfs \;; done
	if ! test -e $(tmpdir)/ramfs/init; then ln -sf etc/init $(tmpdir)/ramfs/init; fi
	if ! test -e $(tmpdir)/ramfs/dev/console; then fakeroot -- mknod -m 622 $(tmpdir)/ramfs/dev/console c 5 1; fi
	( cd $(tmpdir)/ramfs/ && find . | cpio -H newc -o >../$@ ) && cp $(tmpdir)/$@ .
	rm -Rf $(tmpdir)

clean::
	rm -f install-*/*.tgz initramfs.cpio

reallyclean:: clean

mrproper:: reallyclean
