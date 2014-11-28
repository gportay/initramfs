TMPDIR ?= /tmp
tmpdir := $(shell mktemp -d $(TMPDIR)/initramfs-XXXXXX)

export LDFLAGS ?= -static

all: initramfs.cpio

packages ?= install-initramfs/ramfs.tgz
PACKAGES += initramfs.inc
include $(PACKAGES)

.SILENT: initramfs.cpio

.PHONY: all clean

install-initramfs/%.tgz:
	@echo -e "\e[1mBuilding package $*...\e[0m"
	( cd packages-initramfs/$* && tar czf ../../$@ --exclude=.gitignore * )

initramfs.cpio: $(packages)
	@echo -e "\e[1mGenerating $@...\e[0m"
	@for pkg in $(packages); do echo " - $${pkg##*/}"; done
	install -d $(tmpdir)/ramfs
	for dir in install-initramfs $(extradir); do find $$dir/ -name "*.tgz" -exec tar xzf {} -C $(tmpdir)/ramfs \;; done
	( cd $(tmpdir)/ramfs/ && find . | cpio -H newc -o >../$@ ) && cp $(tmpdir)/$@ .
	rm -Rf $(tmpdir)

clean: $(clean)
	rm -f install-*/*.tgz initramfs.cpio

mrproper: clean $(mrproper)
