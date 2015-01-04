.PHONY:: kconfig-frontends

kconfig-frontends/Makefile: kconfig-frontends/configure
	( cd $(@D) && ./configure --prefix=/ --enable-config-prefix=CONFIG_ --enable-frontends=conf,mconf,nconf LDFLAGS= )
	( cd $(@D) && make )

kconfig-frontends_%:
	make -C kconfig-frontends $*

kconfig-frontends:: kconfig-frontends_all

kconfig-frontends_cleanall::
	-make -f Makefile kconfig-frontends_clean

mrproper::
	-make -f Makefile kconfig-frontends_cleanall
	rm -f kconfig-frontends/configure
