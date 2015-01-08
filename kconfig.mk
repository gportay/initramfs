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

oldconfig silentoldconfig: $(obj)/conf
	$< --$@ $(Kconfig)

allnoconfig allyesconfig allmodconfig alldefconfig randconfig: $(obj)/conf
	$< --$@ $(Kconfig)

help::
	@echo  'Configuration targets:'
	@echo  '  config	  - Update current config utilising a line-oriented program'
	@echo  '  nconfig         - Update current config utilising a ncurses menu based'
	@echo  '                    program'
	@echo  '  menuconfig	  - Update current config utilising a menu based program'
	@echo  '  oldconfig	  - Update current config utilising a provided .config as base'
	@echo  '  silentoldconfig - Same as oldconfig, but quietly, additionally update deps'
	@echo  '  allnoconfig	  - New config where all options are answered with no'
	@echo  '  allyesconfig	  - New config where all options are accepted with yes'
	@echo  '  allmodconfig	  - New config selecting modules when possible'
	@echo  '  alldefconfig    - New config with all symbols set to default'
	@echo  '  randconfig	  - New config with random answer to all options'
	@echo  ''

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

reallyclean::
	-make -f Makefile kconfig_cleanall

mrproper::
	rm -f $(KCONFIG_CONFIG)
