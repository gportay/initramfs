VERSION		 = 0
PATCHLEVEL	 = 0
SUBLEVEL	 = 0
EXTRAVERSION	 = .0
NAME		 = I am Charlie

INITRAMFSVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)
SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))

export INITRAMFSVERSION

all::
	@echo $(INITRAMFSVERSION)

include dir.mk
include autotools.mk
include kconfig.mk

###ifeq ($(KBUILD_SRC),)
###        # building in the source tree
###        srctree := .
###else
###        ifeq ($(KBUILD_SRC)/,$(dir $(CURDIR)))
###                # building in a subdirectory of the source tree
###                srctree := ..
###        else
###                srctree := $(KBUILD_SRC)
###        endif
###endif
srctree		:= $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
TOPDIR		:= $(srctree)
# FIXME - TOPDIR is obsolete, use srctree/objtree
objtree		:= $(CURDIR)
src		:= $(srctree)
obj		:= $(objtree)

VPATH		:= $(srctree)$(if $(KBUILD_EXTMOD),:$(KBUILD_EXTMOD))

export srctree objtree VPATH TOPDIR

# Cross compiling and selecting different set of gcc/bin-utils
# ---------------------------------------------------------------------------
#
# When performing cross compilation for other architectures ARCH shall be set
# to the target architecture. (See arch/* for the possibilities).
# ARCH can be set during invocation of make:
# make ARCH=ia64
# Another way is to have ARCH set in the environment.
# The default ARCH is the host where make is executed.

# CROSS_COMPILE specify the prefix used for all executables used
# during compilation. Only gcc and related bin-utils executables
# are prefixed with $(CROSS_COMPILE).
# CROSS_COMPILE can be set on the command line
# make CROSS_COMPILE=ia64-linux-
# Alternatively CROSS_COMPILE can be set in the environment.
# Default value for CROSS_COMPILE is not to prefix executables
# Note: Some architectures assign CROSS_COMPILE in their arch/*/Makefile

CROSS_COMPILE ?=
# bbox: we may have CONFIG_CROSS_COMPILER_PREFIX in .config,
# and it has not been included yet... thus using an awkward syntax.
ifeq ($(CROSS_COMPILE),)
CROSS_COMPILE := $(shell grep ^CONFIG_CROSS_COMPILER_PREFIX .config 2>/dev/null)
CROSS_COMPILE := $(subst CONFIG_CROSS_COMPILER_PREFIX=,,$(CROSS_COMPILE))
CROSS_COMPILE := $(subst ",,$(CROSS_COMPILE))
#")
endif

# SUBARCH tells the usermode build what the underlying arch is.  That is set
# first, and if a usermode build is happening, the "ARCH=um" on the command
# line overrides the setting of ARCH below.  If a native build is happening,
# then ARCH is assigned, getting whatever value it gets normally, and
# SUBARCH is subsequently ignored.

ifneq ($(CROSS_COMPILE),)
SUBARCH := $(shell echo $(CROSS_COMPILE) | cut -d- -f1)
else
SUBARCH := $(shell uname -m)
endif
SUBARCH := $(shell echo $(SUBARCH) | sed -e s/i.86/x86/ -e s/x86_64/x86/ \
					 -e s/sun4u/sparc64/ \
					 -e s/arm.*/arm/ -e s/sa110/arm/ \
					 -e s/s390x/s390/ -e s/parisc64/parisc/ \
					 -e s/ppc.*/powerpc/ -e s/mips.*/mips/ \
					 -e s/sh[234].*/sh/ -e s/aarch64.*/arm64/ )

ARCH ?= $(SUBARCH)

# Architecture as present in compile.h
UTS_MACHINE := $(ARCH)

CROSS_COMPILE	?= arm-atmel-linux-musleabi-
BOARD		?= at91-sama5d3_xplained

PREFIX ?= /usr
TMPDIR ?= /tmp
tmpdir := $(shell mktemp -d $(TMPDIR)/initramfs-XXXXXX)

prefix := $(PREFIX)

export LDFLAGS = -static
ifdef CROSS_COMPILE
BUILD_CC  = gcc
CC        = $(CROSS_COMPILE)gcc
CXX       = $(CROSS_COMPILE)g++
AR        = $(CROSS_COMPILE)ar
RANLIB    = $(CROSS_COMPILE)-ranlib
AS		= $(CROSS_COMPILE)as
CC		= $(CROSS_COMPILE)gcc
LD		= $(CC) -nostdlib
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
PKG_CONFIG	?= $(CROSS_COMPILE)pkg-config
build   := $(shell uname -m | sed -e 's,_,-,' -e 's,$$,-linux-gnu,')
host    := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-$$,,')
arch    := $(shell echo "$(CROSS_COMPILE)" | sed -e 's,-.*$$,,1')
sysroot := $(shell $(CC) -print-sysroot)
endif

linux_defconfig	?= $(CONFIG_LINUX_DEFCONFIG)
LINUX_DEFCONFIG	?= $(if $(linux_defconfig),$(linux_defconfig),at91_dt_defconfig)
linuxdir	?= $(CONFIG_LINUXDIR)
LINUXDIR	?= $(if $(linuxdir),$(linuxdir),linux)
image		?= $(CONFIG_IMAGE)
IMAGE		?= $(if $(image),$(image),zImage)
arch		?= $(shell uname -m)
export ARCH = $(arch)

all:: initramfs.cpio

packages ?= install-initramfs/ramfs.tgz
PACKAGES += initramfs.inc
include $(PACKAGES)

#.SILENT:: initramfs.cpio

#.PHONY:: all clean kernel-headers

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

kernel-headers:
	make -C $@ install prefix=$(prefix) DESTDIR=$(PWD)/sysroot

libc:
	mkdir -p eglibc/$(CROSS_COMPILE)libc
	cd eglibc/$(CROSS_COMPILE)libc && ../libc/configure --prefix=/usr --with-headers=$(sysroot)/usr/include --build=$(build) --host=$(host) --disable-profile --without-gd --without-cvs --enable-add-ons
	make
	echo make install install_root=$sysroot

clean::
	rm -f install-*/*.tgz initramfs.cpio $(IMAGE)

reallyclean:: clean

mrproper:: reallyclean
	rm -f *Image *.dtb

debug-dir/%.tgz:
	@echo " @=$@"
	@echo "@D=${@D}"
	@echo "@F=${@F}"
	@echo " *=$*"
	@echo "*D=${*D}"
	@echo "*F=${*F}"
	@echo " %=$%"
	@echo "%D=${%D}"
	@echo "%F=${%F}"
	@echo " <=$<"
	@echo "<D=${<D}"
	@echo "<F=${<F}"
	@echo " ^=$^"
	@echo "^D=${^D}"
	@echo "^F=${^F}"
	@echo " +=$+"
	@echo "+D=${+D}"
	@echo "+F=${+F}"
	@echo " ?=$?"
	@echo "?D=${?D}"
	@echo "?F=${?F}"

debug::
	@echo ">>> $(SELFDIR).$@:"
	@echo "  - MAKEFILE_LIST=$(MAKEFILE_LIST)"
	@echo "  - SELFDIR=$(SELFDIR)"
	@echo "  - CURDIR=$(CURDIR)"
	@echo "  - BUILD_CC=$(BUILD_CC)"
	@echo "  - CC=$(CC)"
	@echo "  - CXX=$(CXX)"
	@echo "  - AR=$(AR)"
	@echo "  - RANLIB=$(RANLIB)"
	@echo "  - AS=$(AS)"
	@echo "  - CC=$(CC)"
	@echo "  - LD=$(LD)"
	@echo "  - CPP=$(CPP)"
	@echo "  - AR=$(AR)"
	@echo "  - NM=$(NM)"
	@echo "  - STRIP=$(STRIP)"
	@echo "  - OBJCOPY=$(OBJCOPY)"
	@echo "  - OBJDUMP=$(OBJDUMP)"
	@echo "  - PKG_CONFIG=$(PKG_CONFIG)"
	@echo "  - ARCH=$(ARCH)"
	@echo "  - SUBARCH=$(SUBARCH)"
	@echo "  - build=$(build)"
	@echo "  - host=$(host)"
	@echo "  - target=$(target)"
	@echo "  - arch=$(arch)"
	@echo "  - sysroot=$(sysroot)"
	@echo "<<< $(SELFDIR).$@"
