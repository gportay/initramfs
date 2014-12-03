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
clean		+= busybox_clean
mrproper	+= busybox_mrproper
include busybox.inc
endif

ifeq (1,${INPUT_EVENTD})
packages	+= install-initramfs/input-eventd.tgz
clean		+= input-eventd_clean
mrproper	+= input-eventd_mrproper
endif

ifeq (1,${KEXEC_TOOLS})
packages	+= install-initramfs/kexec-tools.tgz
clean		+= kexec-tools_clean
mrproper	+= kexec-tools_mrproper
endif

ifneq (0,${PROFILE})
packages	+= install-initramfs/profile.tgz
endif

