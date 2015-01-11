initramfs
=========

Initramfs is pretty fast initramfs builder powered by busybox.

It is based on a statically compiled busybox and few extra scripts of my own and thats all!

This small root FS simply opens a sulogin on the kernel console, setup the network and start the famous inetd daemon and you will almost 

Because this project intends to remain simple, it does not build any toolchain.
Thus you will need one, and the most appropriate and easy to get is the one provided by your favorite distribution.

For example, on Ubuntu and for an ARM based target, you would type-in the following command:
$ sudo apt-get install gcc-arm-linux-gnueabi

After 


FAQ

* I get that message from the Kernel... What is wrong ?

Freeing unused kernel memory: 776K (c0584000 - c0646000)
Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000100

---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000100

It seem's that init, the first process (and the parent of all the others processes) has exited! The exit code logged by the kernel is the one of init.
Init must not returned or it leads to a kernel panic!

In the example above, the returend exit code is 0x[000001][00].

Remember in shell, 0 exit code is success (no error).

0			Success (cf. EXIT_SUCCESS macro from stdlib.h)
Non-zero		Failure
1			General error (cf. EXIT_FAILURE macro from stdlib.h)
2 			Incorrect usage
126 			Not an executable
127 			Command not found
128+signum		Signal terminated
129 (SIGHUP	1)	Hangup (POSIX)
130 (SIGINT	2)	Interrupt (ANSI)
131 (SIGQUIT	3)	Quit (POSIX)
132 (SIGILL	4)	Illegal instruction (ANSI)
133 (SIGTRAP	5)	Trace trap (POSIX)
134 (SIGABRT	6)	Abort (ANSI)
135 (SIGBUS	7)	BUS error (4.2 BSD)
136 (SIGFPE	8)	Floating-point exception (ANSI)
137 (SIGKILL	9)	Kill, unblockable (POSIX)
138 (SIGUSR1	10)	User-defined signal 1 (POSIX)
139 (SIGSEGV	11)	Segmentation violation (ANSI)
140 (SIGUSR2	12)	User-defined signal 2 (POSIX)
141 (SIGPIPE	13)	Broken pipe (POSIX)
142 (SIGALRM	14)	Alarm clock (POSIX)
143 (SIGTERM	15)	Termination (ANSI)
144 (SIGSTKFLT	16)	Stack fault
145 (SIGCHLD	17)	Child status has changed (POSIX)
146 (SIGCONT	18)	Continue (POSIX)
147 (SIGSTOP	19)	Stop, unblockable (POSIX)
148 (SIGTSTP	20)	Keyboard stop (POSIX)
149 (SIGTTIN	21)	Background read from tty (POSIX)
150 (SIGTTOU	22)	Background write to tty (POSIX)
151 (SIGURG	23)	Urgent condition on socket (4.2 BSD)
152 (SIGXCPU	24)	CPU limit exceeded (4.2 BSD)
153 (SIGXFSZ	25)	File size limit exceeded (4.2 BSD)
154 (SIGVTALRM	26)	Virtual alarm clock (4.2 BSD)
155 (SIGPROF	27)	Profiling alarm clock (4.2 BSD)
156 (SIGWINCH	28)	Window size change (4.3 BSD, Sun)
157 (SIGIO	29)	I/O now possible (4.2 BSD)
158 (SIGPWR	30)	Power failure restart (System V)
159 (SIGSYS	31)	Bad system call
256		128)	


$ mkdir -p cpio && cd cpio
$ cat ../initramfs.cpio | cpio -i
$ file bin/busybox
bin/busybox: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

Busybox must be compiled for the target architecture. In my case, my device is powared by an ARM CPU.
Furthermore, Busybox sould be statically linked unless you bring the support for a dynamically linked OS.

Kernel has log the warning below...

Warning: unable to open an initial console.

Unfortunalty, you need to create the console device into the cpio archive.
$ mkdir -p cpio && cd cpio
$ cat ../initramfs.cpio | cpio -i
$ file dev/console

Kernel arguments:

root=/dev/ram0 rootfstype=ramfs are not required.
Simply append

console=ttyS0,115200 earlyprintk mtdparts=atmel_nand:128k(at91bootstrap),-(ubi) ubi.mtd=ubi

-s

CONFIG_LINUX_KERNEL_ARG_STRING="console=ttyS0,115200 earlyprintk mtdparts=atmel_nand:128k(at91bootstrap),-(ubi) ubi.mtd=ubi"





Warning: unable to access early userspace /init.
VFS: Cannot open root device "(null)" or unknown-block(0,0): error -6
Please append a correct "root=" boot option; here are the available partitions:
1f00             128 mtdblock0  (driver?)
1f01          262016 mtdblock1  (driver?)
1f02              30 mtdblock2  (driver?)
1f03              30 mtdblock3  (driver?)
1f04            3629 mtdblock4  (driver?)
1f05            3629 mtdblock5  (driver?)
1f06          240684 mtdblock6  (driver?)
Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)

It seems you don't have 





VFS: Mounted root (ramfs filesystem) readonly on device 0:13.
devtmpfs: error mounting -2
Freeing unused kernel memory: 768K (c0584000 - c0644000)
Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.

root=/dev/ram0 rootfstype=ramfs






Uncompressing Linux... done, booting the kernel.

You probably do not have any console.
Please append the console kernel argument to the dbgu/uart console
LINUX_CMDLINE= console=ttyS0,115220...
$ sed -e '/CONFIG_LINUX_KERNEL_ARG_STRING=/s,=","console=ttyS0,115220 ,' -i at91bootstrap/.config


Uncompressing Linux... done, booting the kernel.
(...)
Console: colour dummy device 80x30
console [tty0] enabled
bootconsole [earlycon0] disabled

$ sed -e '/CONFIG_LINUX_KERNEL_ARG_STRING=/s/="/="earlyprintk=ttyS0,115220 /' -i at91bootstrap/.config



linux-stable/init/main.c
static noinline void __init kernel_init_freeable(void)
{
	// (...)
	if (sys_open((const char __user *) "/dev/console", O_RDWR, 0) < 0)
		pr_err("Warning: unable to open an initial console.\n");

	(void) sys_dup(0);
	(void) sys_dup(0);
	// (...)
}

The first sys_dup(0) call opens the STDOUT_FILENO (1), while the second
sys_dup(0) call opens the STDERR_FILENO (2).

lrwx------    1 root     root            64 Jan  1 03:57 0 -> /dev/console <- sys_open(... "/dev/console"...) ???
l-wx------    1 root     root            64 Jan  1 03:57 1 -> /dev/ttyS0 <- ???
lr-x------    1 root     root            64 Jan  1 03:57 10 -> /init <- /init -> "#!/bin/sh" 
lrwx------    1 root     root            64 Jan  1 03:57 11 -> /dev/console <- sys_open(... "/dev/console"...) ???
lrwx------    1 root     root            64 Jan  1 03:57 2 -> /dev/console <- second (void) sys_dup(0)



1 - test >/dev/console
1 - test >/dev/ttyS0
total 0
lrwx------    1 root     root            64 Jan  1 03:57 0 -> /dev/console
l-wx------    1 root     root            64 Jan  1 03:57 1 -> /dev/ttyS0
lr-x------    1 root     root            64 Jan  1 03:57 10 -> /init
lrwx------    1 root     root            64 Jan  1 03:57 11 -> /dev/console
lrwx------    1 root     root            64 Jan  1 03:57 2 -> /dev/console

$ if [ -e /dev/console ]; then
$ 	exec >/dev/console
$ 	exec 2>/dev/console
$ fi
2 - test
2 - test >/dev/console
2 - test >/dev/ttyS0
total 0
lrwx------    1 root     root            64 Jan  1 03:57 0 -> /dev/console
l-wx------    1 root     root            64 Jan  1 03:57 1 -> /dev/ttyS0
lr-x------    1 root     root            64 Jan  1 03:57 10 -> /init
l-wx------    1 root     root            64 Jan  1 03:57 11 -> /dev/console
l-wx------    1 root     root            64 Jan  1 03:57 2 -> /dev/console

$ if [ ! -e /dev/console ]; then
$ 	exec >/dev/$CONSOLE
$ 	exec 2>/dev/$CONSOLE
$ fi
3 - test
3 - test >/dev/console
3 - test >/dev/ttyS0
total 0
lrwx------    1 root     root            64 Jan  1 03:57 0 -> /dev/console
l-wx------    1 root     root            64 Jan  1 03:57 1 -> /dev/ttyS0
lr-x------    1 root     root            64 Jan  1 03:57 10 -> /init
l-wx------    1 root     root            64 Jan  1 03:57 11 -> /dev/console
l-wx------    1 root     root            64 Jan  1 03:57 2 -> /dev/console

