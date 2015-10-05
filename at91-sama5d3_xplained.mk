include at91.mk

extradir	+= install-at91-sama5d3_xplained
packages	+= install-at91-sama5d3_xplained/led.tgz

ifeq (y,$(CONFIG_RC_LOCAL))
tgz-$(CONFIG_NETWORKING)	+= install-at91-sama5d3_xplained/networking.tgz
endif

tgz-$(CONFIG_OVERLAY_FS)	+= install-at91/persistant.tgz
tgz-$(CONFIG_OVERLAY_FS)	+= install-initramfs/overlay.tgz

install-at91-sama5d3_xplained/%.tgz:
	@echo "Building package $*..."
	install -d $(@D)
	( cd packages-at91-sama5d3_xplained/$* && tar czf ../../$@ --exclude=.gitignore * )

