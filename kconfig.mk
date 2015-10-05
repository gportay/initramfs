#!/usr/bin/gmake -rf
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Gaël PORTAY <gael.portay@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

all::

KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

-include $(KCONFIG_CONFIG)

ifdef KBUILD_KCONFIG
Kconfig := $(KBUILD_KCONFIG)
else
Kconfig := Kconfig
endif

ifeq ($(firstword $(MAKEFILE_LIST)),kconfig.mk)
all:: menuconfig
else
ifeq ($(CONFIG_HAVE_DOT_CONFIG),)
all:: menuconfig
endif
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

reallyclean::
	-make -f Makefile kconfig_cleanall

mrproper::
	rm -f $(KCONFIG_CONFIG)
