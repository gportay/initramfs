.PHONY:: kconfig-frontends

kconfig-frontends/Makefile: kconfig-frontends/configure
	( cd $(@D) && ./configure --prefix=/ --enable-config-prefix=CONFIG_ --enable-frontends=conf,mconf,nconf LDFLAGS= )
	( cd $(@D) && make )

kconfig-frontends/configure: kconfig-frontends/configure.ac
	( cd kconfig-frontends && autoreconf -vif )

kconfig-frontends_%:
	make -C kconfig-frontends $*

kconfig-frontends:: kconfig-frontends_all

kconfig-frontends_configure::
	make -f Makefile kconfig-frontends/Makefile

kconfig-frontends_install:: kconfig-frontends/Makefile
	make -C kconfig-frontends install

kconfig-frontends_uninstall::
	-make -C kconfig-frontends uninstall

kconfig-frontends_cleanall::
	-make -f Makefile kconfig-frontends_clean

kconfig-frontends_mrproper::
	-make -f Makefile kconfig-frontends_distclean
	rm -f kconfig-frontends/configure

reallyclean::
	-make -f Makefile kconfig-frontends_cleanall

mrproper::
	-make -f Makefile kconfig-frontends_mrproper
