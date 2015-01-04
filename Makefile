VERSION		 = 0
PATCHLEVEL	 = 0
SUBLEVEL	 = 0
EXTRAVERSION	 = .0
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

LINUXDIR	?= linux
IMAGE		?= zImage
arch		?= $(shell uname -m)
export ARCH = $(arch)

all:: initramfs.cpio

packages ?= install-initramfs/ramfs.tgz
PACKAGES += initramfs.inc
include $(PACKAGES)

.SILENT:: initramfs.cpio

.PHONY:: all clean

.PRECIOUS::

install-initramfs/%.tgz:
	@echo -e "\e[1mBuilding package $*...\e[0m"
	( cd packages-initramfs/$* && tar czf ../../$@ --exclude=.gitignore * )

initramfs.cpio: $(packages)
	@echo -e "\e[1mGenerating $@...\e[0m"
	@for pkg in $(packages); do echo " - $${pkg##*/}"; done
	install -d $(tmpdir)/ramfs
	for dir in install-initramfs $(extradir); do find $$dir/ -name "*.tgz" -exec tar xzf {} -C $(tmpdir)/ramfs \;; done
	if ! test -e $(tmpdir)/ramfs/init; then ln -sf etc/init $(tmpdir)/ramfs/init; fi
	if ! test -e $(tmpdir)/ramfs/dev/console; then fakeroot -- mknod -m 622 $(tmpdir)/ramfs/dev/console c 5 1; fi
	( cd $(tmpdir)/ramfs/ && find . | cpio -H newc -o >../$@ ) && cp $(tmpdir)/$@ .
	rm -Rf $(tmpdir)

%.dtb: $(LINUXDIR)/arch/$(arch)/boot/dts/%.dts
	@echo -e "\e[1mBuilding $@ for $(ARCH)...\e[0m"
	make -C $(LINUXDIR) $@
	cp $(LINUXDIR)/arch/$(arch)/boot/dts/$@ .

$(LINUXDIR)_%s:
	make -C $(LINUXDIR) $*

$(LINUXDIR)/.config:
	@echo -e "\e[1mConfiguring kernel for $(ARCH) using $(LINUX_DEFCONFIG)...\e[0m"
	if test -e $(LINUX_DEFCONFIG); then cp $(LINUX_DEFCONFIG) $(LINUXDIR)/.config; else make -C $(LINUXDIR) $(LINUX_DEFCONFIG); fi

$(LINUXDIR)/arch/$(arch)/boot/$(IMAGE): initramfs.cpio $(LINUXDIR)/.config
	@echo -e "\e[1mBuilding $(IMAGE) for $(ARCH)...\e[0m"
	make -C $(LINUXDIR) ${@F} CONFIG_INITRAMFS_SOURCE=../$<

$(IMAGE): $(LINUXDIR)/arch/$(arch)/boot/$(IMAGE)
	cp $(LINUXDIR)/arch/$(arch)/boot/$@ $@

kernel: $(IMAGE)

clean::
	rm -f install-*/*.tgz initramfs.cpio $(IMAGE)

reallyclean:: clean

mrproper:: reallyclean
	rm -f *Image *.dtb
