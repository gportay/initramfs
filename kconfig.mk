KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

-include $(KCONFIG_CONFIG)

ifdef KBUILD_KCONFIG
Kconfig := $(KBUILD_KCONFIG)
else
Kconfig := Kconfig
endif

include kconfig-frontends.mk

obj := bin

menuconfig: $(obj)/mconf
	$< $(Kconfig)

config: $(obj)/conf
	$< --oldaskconfig $(Kconfig)

nconfig: $(obj)/nconf
	$< $(Kconfig)

oldconfig: $(obj)/conf
	$< --$@ $(Kconfig)

silentoldconfig: $(obj)/conf
	$< --$@ $(Kconfig)

.PRECIOUS:: $(obj)/kconfig-%

$(obj)/kconfig-%: kconfig-frontends/Makefile
	make -C kconfig-frontends install-exec DESTDIR=$(CURDIR)

$(obj)/%: $(obj)/kconfig-%
	echo -e '#!/bin/sh\nLD_LIBRARY_PATH=$(CURDIR)/lib $(CURDIR)/$< $$*' >$@
	chmod a+x $@

kconfig:: $(obj)/conf $(obj)/mconf $(obj)/nconf
	make -C kconfig-frontends install-exec DESTDIR=$(CURDIR)

kconfig_cleanall::
	for bin in bin/*; do if test -x $$bin && grep -qE kconfig- $$bin; then rm $$bin; fi; done
	-make -C kconfig-frontends uninstall DESTDIR=$(CURDIR)

cleanall::
	-make -f Makefile kconfig_cleanall

mrproper::
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
