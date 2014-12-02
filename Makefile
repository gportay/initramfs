PREFIX ?= /usr
TMPDIR ?= /tmp
tmpdir := $(shell mktemp -d $(TMPDIR)/initramfs-XXXXXX)

prefix := $(PREFIX)

export LDFLAGS ?= -static
ifdef CROSS_COMPILE
export CC = $(CROSS_COMPILE)gcc
host := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-$$,,')
arch := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-.*$$,,1')
endif

LINUXDIR	?= linux
IMAGE		?= zImage
arch		?= $(shell uname -m)
export ARCH = $(arch)

.SILENT: initramfs.cpio

.PHONY: all initramfs.cpio clean

all: initramfs.cpio

packages	?= install-initramfs/ramfs.tgz

ifneq (0,${PROFILE})
packages	+= install-initramfs/profile.tgz
endif

ifneq (0,${RC_LOCAL})
packages	+= install-initramfs/rc.local.tgz
endif

ifneq (0,${NETWORKING})
packages	+= install-initramfs/networking.tgz
ifneq (0,${INET})
packages	+= install-initramfs/inetd.tgz
endif
endif

ifneq (0,${BUSYBOX})
packages	+= install-initramfs/busybox.tgz
clean		+= busybox_clean
mrproper	+= busybox_mrproper
include busybox.inc
endif

ifeq (1,${INPUT_EVENTD})
packages	+= install-initramfs/input-eventd.tgz
clean		+= input-eventd_clean
mrproper	+= input-eventd_mrproper
endif

ifeq (1,${KEXEC_TOOLS})
packages	+= install-initramfs/kexec-tools.tgz
clean		+= kexec-tools_clean
mrproper	+= kexec-tools_mrproper
endif

install-initramfs/%.tgz:
	@echo -e "\e[1mBuilding package $*...\e[0m"
	( cd packages-initramfs/$* && tar czf ../../$@ --exclude=.gitignore * )

initramfs.cpio: $(packages)
	@echo -e "\e[1mGenerating $@...\e[0m"
	@for pkg in $(packages); do echo " - $${pkg##*/}"; done
	install -d $(tmpdir)/ramfs
	for dir in initramfs $(EXTRA); do find install-$$dir/ -name "*.tgz" -exec tar xzf {} -C $(tmpdir)/ramfs \;; done
	( cd $(tmpdir)/ramfs/ && find . | cpio -H newc -o >../$@ ) && cp $(tmpdir)/$@ .
	rm -Rf $(tmpdir)

$(IMAGE): initramfs.cpio
	@echo -e "\e[1mBuilding $@ for $(ARCH)...\e[0m"
	make -C $(LINUXDIR) $@ CONFIG_INITRAMFS_SOURCE=$(PWD)/$<
	cp $(LINUXDIR)/arch/$(arch)/boot/$@ $@

kernel: $(IMAGE)

clean:
	rm -Rf initramfs.cpio

mrproper: clean
	rm -f *Image
	rm -Rf install-initramfs/*
