ifneq (0,${RC_LOCAL})
packages	+= install-initramfs/rc.local.tgz
endif

ifneq (0,${NETWORKING})
packages	+= install-initramfs/networking.tgz
ifneq (0,${INET})
packages	+= install-initramfs/inetd.tgz
endif
endif

ifneq (0,${BUSYBOX})
packages	+= install-initramfs/busybox.tgz
endif
include busybox.inc

ifeq (1,${INPUT_EVENTD})
packages	+= install-initramfs/input-eventd.tgz
endif
include input-eventd.inc

ifneq (0,${PWM_LED})
packages	+= install-initramfs/led.tgz
endif

ifeq (1,${KEXEC_TOOLS})
packages	+= install-initramfs/kexec-tools.tgz
endif
include kexec-tools.inc

ifneq (0,${PROFILE})
packages	+= install-initramfs/profile.tgz
endif

