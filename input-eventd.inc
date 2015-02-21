input-eventd/input-eventd: input-eventd/input-eventd.c
	@echo -e "\e[1mCompiling input-eventd...\e[0m"
	make -C input-eventd input-eventd

packages-initramfs/input-eventd/usr/sbin/input-eventd: input-eventd/input-eventd input-eventd/input-event.action input-eventd/log.script input-eventd/input-eventd.init input-eventd/dev-input-event.init
	@echo -e "\e[1mInstalling input-eventd...\e[0m"
	install -d $(@D)
	install -m 755 $< $@
	install -d packages-initramfs/input-eventd/usr/share/input-eventd/
	install -m 755 input-eventd/input-event.action packages-initramfs/input-eventd/usr/share/
	install -m 755 input-eventd/log.script packages-initramfs/input-eventd/usr/share/input-eventd/log
	install -d packages-initramfs/input-eventd/etc/init.d
	install -m 755 input-eventd/input-eventd.init packages-initramfs/input-eventd/etc/init.d/input-eventd
	install -m 755 input-eventd/dev-input-event.init packages-initramfs/input-eventd/etc/init.d/dev-input-event
	install -d packages-initramfs/input-eventd/usr/share/init.d/
	ln -sf start-stop-daemon.init packages-initramfs/input-eventd/usr/share/init.d/input-eventd

install-initramfs/input-eventd.tgz: packages-initramfs/input-eventd/usr/sbin/input-eventd

input-eventd:: input-eventd/input-eventd

input-eventd_compile:
	make -f Makefile input-eventd/input-eventd

input-eventd_install:
	make -f Makefile packages-initramfs/input-eventd/usr/sbin/input-eventd

input-eventd_clean:
	rm -f install-initramfs/input-eventd.tgz

input-eventd_cleanall: input-eventd_clean
	rm -f input-eventd/*.o input-eventd/input-eventd
	rm -Rf packages-initramfs/input-eventd/*

reallyclean::
	-make -f Makefile input-eventd_clean

mrproper::
	-make -f Makefile input-eventd_cleanall
