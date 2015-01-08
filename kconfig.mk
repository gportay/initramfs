KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

-include $(KCONFIG_CONFIG)

ifdef KBUILD_KCONFIG
Kconfig := $(KBUILD_KCONFIG)
else
Kconfig := Kconfig
endif

obj := bin

include kconfig-frontends.mk

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
