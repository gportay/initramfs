#.SILENT:: $(KCONFIG_CONFIG)

lastword = $(if $(firstword $1),$(word $(words $1)),$1)
SELFDIR := $(dir $(call lastword,$(MAKEFILE_LIST)))

KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

-include $(KCONFIG_CONFIG)

#$(KCONFIG_CONFIG):
#	echo "Please run make menuconfig first!"
#	exit 1

#$(KCONFIG_CONFIG): ;
#	@echo "run make menuconfig"
#	@exit 1

###PHONY += oldconfig xconfig gconfig menuconfig config silentoldconfig update-po-config \
###	localmodconfig localyesconfig

PHONY += oldconfig menuconfig nconfig config silentoldconfig
PHONY += allnoconfig allyesconfig allmodconfig alldefconfig randconfig

ifdef KBUILD_KCONFIG
Kconfig := $(KBUILD_KCONFIG)
else
Kconfig := Kconfig
endif

obj		:= bin
include kconfig-frontends.mk

#### Read in dependencies to all Kconfig* files, make sure to run
#### oldconfig if changes are detected.
###-include include/config/auto.conf.cmd
###
#### To avoid any implicit rule to kick in, define an empty command
###$(KCONFIG_CONFIG) include/config/auto.conf.cmd: ;
###
# If .config is newer than include/config/auto.conf, someone tinkered
# with it and forgot to run make oldconfig.
# if auto.conf.cmd is missing then we are probably in a cleaned tree so
# we execute the config step to be sure to catch updated Kconfig files
###include/config/%.conf: $(KCONFIG_CONFIG) include/config/auto.conf.cmd

#ALL += include/conf/auto.conf

#$(KCONFIG_CONFIG): menuconfig

###include/config/auto.conf: $(KCONFIG_CONFIG)
###	@echo ">>> $@..."
###	echo $(MAKE) -f $(srctree)/Makefile silentoldconfig
###	$(Q)$(MAKE) -f $(srctree)/Makefile silentoldconfig
###	@echo "<<< $@!"
###	@echo ""

menuconfig: $(obj)/mconf
	$< $(Kconfig)

config: $(obj)/conf
	$< --oldaskconfig $(Kconfig)

nconfig: $(obj)/nconf
	$< $(Kconfig)

oldconfig: $(obj)/conf
	$< --$@ $(Kconfig)

silentoldconfig: $(obj)/conf
	$(Q)mkdir -p include/config include/generated
	$< --$@ $(Kconfig)

allnoconfig allyesconfig allmodconfig alldefconfig randconfig: $(obj)/conf
	$< --$@ $(Kconfig)

.PRECIOUS:: $(obj)/kconfig-%

$(obj)/kconfig-%: kconfig-frontends/Makefile
	make -C kconfig-frontends install-exec DESTDIR=$(PWD)

$(obj)/%: $(obj)/kconfig-%
	echo -e '#!/bin/sh\nLD_LIBRARY_PATH=$(PWD)/lib $(PWD)/$< $$*' >$@
	chmod a+x $@

kconfig:: $(obj)/conf $(obj)/mconf $(obj)/nconf
	make -C kconfig-frontends install-exec DESTDIR=$(PWD)

kconfig_cleanall::
	for bin in bin/*; do if test -x $$bin && grep -qE kconfig- $$bin; then rm $$bin; fi; done
	-make -C kconfig-frontends uninstall DESTDIR=$(PWD)

mrproper::
	-make kconfig-frontends_cleanall
	rm -f $(KCONFIG_CONFIG)

debug::
	@echo ">>> $(SELFDIR).$@:"
	@echo "  - SELFDIR=$(SELFDIR)"
	@echo "  - word=$(word)"
	@echo "  - words=$(words)"
	@echo "  - lastword=$(lastword)"
	@echo "  - 0=$(0)"
	@echo "  - 1=$(1)"
	@echo "  - KBUILD_SRC=$(KBUILD_SRC)"
	@echo "  - CURDIR=$(CURDIR)"
	@echo "  - srctree=$(srctree)"
	@echo "  - TOPDIR=$(TOPDIR)"
	@echo "  - objtree=$(objtree)"
	@echo "  - src=$(src)"
	@echo "  - objtree=$(objtree)"
	@echo "  - obj=$(obj)"
	@echo "  - CONFIG_CROSS_COMPILER_PREFIX=$(CONFIG_CROSS_COMPILER_PREFIX)"
	@echo "  - CONFIG_BUSYBOX=$(CONFIG_BUSYBOX)"
	@echo "  - CONFIG_NETWORKING=$(CONFIG_NETWORKING)"
	@echo "  - CONFIG_RC_LOCAL=$(CONFIG_RC_LOCAL)"
	@echo "  - CONFIG_PROFILE=$(CONFIG_PROFILE)"
	@echo "  - CONFIG_OVERLAY_FS=$(CONFIG_OVERLAY_FS)"
	@echo "  - CONFIG_KEXEC_TOOLS=$(CONFIG_KEXEC_TOOLS)"
	@echo "  - CONFIG_INPUT_EVENTD=$(CONFIG_INPUT_EVENTD)"
	@echo "<<< $@"
