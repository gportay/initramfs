include at91.mk

extradir	+= install-at91-sama5d3_xplained
packages	+= install-at91-sama5d3_xplained/led.tgz

ifeq (y,$(CONFIG_RC_LOCAL))
tgz-$(CONFIG_NETWORKING)	+= install-at91-sama5d3_xplained/networking.tgz
endif

tgz-$(CONFIG_OVERLAY_FS)	+= install-at91/persistent.tgz
tgz-$(CONFIG_OVERLAY_FS)	+= install-initramfs/overlay.tgz
tgz-y				+= install-at91-sama5d3_xplained/ubi.tgz

install-at91-sama5d3_xplained/%.tgz:
	@echo "Building package $*..."
	install -d $(@D)
	( cd packages-at91-sama5d3_xplained/$* && fakeroot -- tar czf ../../$@ --exclude=.gitignore * )

