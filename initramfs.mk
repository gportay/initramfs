tgz-$(CONFIG_RC_LOCAL)		+= install-initramfs/rc.local.tgz
tgz-$(CONFIG_NETWORKING)	+= install-initramfs/networking.tgz
tgz-$(CONFIG_INET)		+= install-initramfs/inetd.tgz
tgz-$(CONFIG_BUSYBOX)		+= install-initramfs/busybox.tgz
tgz-$(CONFIG_TOYBOX)		+= install-initramfs/toybox.tgz
tgz-$(CONFIG_INPUT_EVENTD)	+= install-initramfs/input-eventd.tgz
tgz-$(CONFIG_PWM_LED)		+= install-initramfs/led.tgz
tgz-$(CONFIG_KEXEC_TOOLS)	+= install-initramfs/kexec-tools.tgz
tgz-$(CONFIG_PROFILE)		+= install-initramfs/profile.tgz
tgz-$(CONFIG_DROPBEAR)		+= install-initramfs/dropbear.tgz

include busybox.mk
include toybox.mk
include input-eventd.mk
include kexec-tools.mk
include dropbear.mk
