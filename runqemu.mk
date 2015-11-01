#!/usr/bin/gmake -rf
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Gaël PORTAY <gael.portay@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

all::

KIMAGE		?= bzImage
QEMUOPTS	+= -netdev tap,id=net0,helper=qemu-bridge-helper -device virtio-net-pci,netdev=net0,id=nic1
QEMUOPT_APPEND	?= console=ttyS0 earlyprintk

ifeq ($(firstword $(MAKEFILE_LIST)),runqemu.mk)
all:: runqemu

help::
	@echo  'Usage: runqemu.mk [KIMAGE=zImage] [QEMUOPT_APPEND="console=ttyS0 earlyprintk"] [QEMUOPTS=-nographic]'
else
include kernel.mk
KEXTRADEFCONFIG	+= qemu-console.cfg
endif

.PHONY:: runqemu

QEMUGROUP	:= qemu

check_qemu:
		@err=0; \
		if ! grep -qE "^$(QEMUGROUP):" /etc/group; then \
			echo "Add a group named $(QEMUGROUP):"; \
			echo "$$ sudo groupadd $(QEMUGROUP)"; \
			echo ; \
			err=$$((err+1)); \
		fi; \
		if ! id -Gn | grep -q "$(QEMUGROUP)"; then \
			echo "Add yourself to a group $(QEMUGROUP):"; \
			echo "$$ sudo useradd -G $(QEMUGROUP) $$USER"; \
			echo ; \
			err=$$((err+1)); \
		fi; \
		if gidn="$$(stat -c %G /usr/libexec/qemu-bridge-helper)" && [ "$$gidn" != "$(QEMUGROUP)" ]; then \
			echo "Set $(QEMUGROUP) group to /usr/libexec/qemu-bridge-helper:"; \
			echo "$$ sudo chgrp $(QEMUGROUP) /usr/libexec/qemu-bridge-helper"; \
			echo ; \
			err=$$((err+1)); \
		fi; \
		if perm="$$(stat -c %A /usr/libexec/qemu-bridge-helper)" && [ "$${perm:3:1}" != "s" ]; then \
			echo "Set setuid bit to /usr/libexec/qemu-bridge-helper:"; \
			echo "$$ sudo chown u+s /usr/libexec/qemu-bridge-helper"; \
			echo ; \
			err=$$((err+1)); \
		fi; \
		if gidn="$$(stat -c %G /dev/net/tun)" && [ "$$gidn" != "$(QEMUGROUP)" ]; then \
			echo "Set $(QEMUGROUP) group to /dev/net/tun:"; \
			echo "$$ sudo chgrp $(QEMUGROUP) /dev/net/tun"; \
			echo ; \
			if [ -d /etc/udev/rules.d/ ]; then \
				echo "You may also add the udev rule to automatically set qemu group to tun network device:"; \
				echo "$$ sudo sh -c \"echo 'KERNEL==\"tun\", GROUP=\"$(QEMUGROUP)\", MODE=\"0660\"' >>/etc/udev/rules.d/90-qemu.rules\""; \
				echo ; \
			fi ; \
			err=$$((err+1)); \
		fi; \
		if [ "$$err" != 0 ]; then \
			false; \
		fi

runqemu: $(KIMAGE)
	@if [ ! -e "$(KIMAGE)" ]; then \
		echo "Error: $(KIMAGE): No such image!" >&2; \
		echo "Run $$ make kernel first!" >&2; \
		false; \
	fi
	@ttysave=$$(stty -g); \
	if ! qemu-system-$(shell uname -m) -kernel $(KIMAGE) -append "$(QEMUOPT_APPEND)" -serial stdio $(QEMUOPTS); then \
		if ! make -f runqemu.mk check_qemu; then \
			echo "Error: Fix ownerships above if you want to run qemu without root privileges!"; \
		fi >&2; \
	fi; \
	stty $$ttysave

