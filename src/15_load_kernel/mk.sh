
#!/bin/bash

KERNEL_FILE="kernel.s"
BOOT_FILE="boot.s"

if	[ -e $KERNEL_FILE ] ;	then
	echo "[*]kernel file exist"

	nasm boot.s -o boot.bin -l boot.lst;
	nasm kernel.s -o kernel.bin -l kernel.lst;
	cat	 boot.bin kernel.bin > boot.img

else
	nasm boot.s -o boot.img -l boot.lst
fi
