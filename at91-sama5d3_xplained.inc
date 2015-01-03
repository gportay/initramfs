include at91.inc

extradir	+= install-at91-sama5d3_xplained
packages	+= install-at91-sama5d3_xplained/led.tgz

ifneq (0,${RC_LOCAL})
ifneq (0,${NETWORKING})
packages	+= install-at91-sama5d3_xplained/networking.tgz
endif
endif

ifneq (0,${OVERLAY})
packages	+= install-at91/persistant.tgz install-initramfs/overlay.tgz
endif

install-at91-sama5d3_xplained/%.tgz:
	@echo -e "\e[1mBuilding package $*...\e[0m"
	install -d ${@D}
	( cd packages-at91-sama5d3_xplained/$* && tar czf ../../$@ --exclude=.gitignore * )

