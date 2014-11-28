ifneq (0,${RC_LOCAL})
packages	+= install-initramfs/rc.local.tgz
endif

ifneq (0,${NETWORKING})
packages	+= install-initramfs/networking.tgz
endif

