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
include busybox.inc
endif

ifeq (y,$(CONFIG_INPUT_EVENTD))
packages	+= install-initramfs/input-eventd.tgz
include input-eventd.inc
endif

ifeq (y,$(CONFIG_KEXEC_TOOLS))
packages	+= install-initramfs/kexec-tools.tgz
include kexec-tools.inc
endif

ifeq (y,$(CONFIG_PROFILE))
packages	+= install-initramfs/profile.tgz
endif

