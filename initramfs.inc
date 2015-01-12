ifeq (y,$(CONFIG_RC_LOCAL))
packages	+= install-initramfs/rc.local.tgz
endif

ifeq (y,$(CONFIG_NETWORKING))
packages	+= install-initramfs/networking.tgz
ifneq (0,${CONFIG_INET})
packages	+= install-initramfs/inetd.tgz
endif
endif

ifeq (y,$(CONFIG_BUSYBOX))
packages	+= install-initramfs/busybox.tgz
endif
include busybox.inc

ifeq (y,$(CONFIG_INPUT_EVENTD))
packages	+= install-initramfs/input-eventd.tgz
endif
include input-eventd.inc

ifeq (y,$(CONFIG_KEXEC_TOOLS))
packages	+= install-initramfs/kexec-tools.tgz
endif
include kexec-tools.inc

ifeq (y,$(CONFIG_PROFILE))
packages	+= install-initramfs/profile.tgz
endif

