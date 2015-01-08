ifeq (y,$(CONFIG_RC_LOCAL))
packages	+= install-initramfs/rc.local.tgz
endif

ifeq (y,$(CONFIG_NETWORKING))
packages	+= install-initramfs/networking.tgz
ifeq (y,$(CONFIG_INET))
packages	+= install-initramfs/inetd.tgz
endif
endif

ifeq (y,$(CONFIG_BUSYBOX))
packages	+= install-initramfs/busybox.tgz
clean		+= busybox_clean
mrproper	+= busybox_mrproper
include busybox.inc
endif

ifeq (y,$(CONFIG_INPUT_EVENTD))
packages	+= install-initramfs/input-eventd.tgz
clean		+= input-eventd_clean
mrproper	+= input-eventd_mrproper
endif

ifeq (y,$(CONFIG_KEXEC_TOOLS))
packages	+= install-initramfs/kexec-tools.tgz
clean		+= kexec-tools_clean
mrproper	+= kexec-tools_mrproper
endif

ifeq (y,$(CONFIG_PROFILE))
packages	+= install-initramfs/profile.tgz
endif

