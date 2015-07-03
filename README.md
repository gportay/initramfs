initramfs
=========
**[initramfs](https://github.com/gazoo74/initramfs)** is a *tiny-rootfs* that can be either appended as a *initramfs* for [linux kernel](https://github.com/torvalds/linux) or used an *initrd*. It is based on a *statically-linked* [busybox](http://git.busybox.net/busybox/) and few *home-made* scripts. Do not forget to provide your own *cross-compiler*.
Prerequisites...
-------------------
Clone the repository...

    $ git clone git@github.com:gazoo74/initramfs.git && cd initramfs
... *init* and *update* recursively project *submodules*:

    $ git submodule update --init --recursive
Optionally, to build a *kernel* image with its appended *initramfs*, you may fetch [linux](https://github.com/torvalds/linux) sources into the *linux* directory either by cloning one of the multiple git repository...

    $ git clone git@github.com:torvalds/linux.git linux
... or by getting and unarchiving a [kernel](https://www.kernel.org/) archive, pick up a version above 4.1:

    $ wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.1.tar.xz && tar xJf linux-4.1.tar.xz && ln -sf linux-4.1 linux
...Ready to go!
--------------
Your are now ready to build an *initramfs* image...

    $ make
... or a *kernel* with its appended *initramfs*...

    $ make kernel
... or build an *initrd* image:

    $ make initrd.cpio
    $ make initrd.squashfs
Enjoy!
