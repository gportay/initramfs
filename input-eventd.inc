input-eventd/input-eventd: input-eventd/input-eventd.c
	@echo -e "\e[1mCompiling input-eventd...\e[0m"
	make -C input-eventd input-eventd

packages-initramfs/input-eventd/usr/sbin/input-eventd: input-eventd/input-eventd input-eventd/input-event.action
	@echo -e "\e[1mInstalling input-eventd...\e[0m"
	install -d $(@D)
	install -m 755 $< $@
	install -d packages-initramfs/input-eventd/usr/share/input-eventd/
	install -m 755 input-eventd/input-event.action packages-initramfs/input-eventd/usr/share/

install-initramfs/input-eventd.tgz: packages-initramfs/input-eventd/usr/sbin/input-eventd

input-eventd_clean:
	rm -f install-initramfs/input-eventd.tgz

input-eventd_cleanall: input-eventd_clean
	rm -f input-eventd/*.o input-eventd/input-eventd
	rm -Rf packages-initramfs/input-eventd/*

clean::
	-make -f Makefile input-eventd_clean

mrproper::
	-make -f Makefile input-eventd_cleanall
