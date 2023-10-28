#!/bin/bash
if test -f kernel.elf; then
	echo removing kernel.elf
fi

if test -f kernel.img; then
	echo removing kernel.img
fi

if test -f kernel.map; then
	echo removing kernel.map
fi

if test -f boot.o; then
	echo removing boot.o
fi

arm-linux-gnueabi-as -march=armv7-a  -g -c boot.s -o boot.o
arm-linux-gnueabi-ld -g -T linker.ld -o kernel.elf boot.o -Map kernel.map
arm-linux-gnueabi-objcopy -O binary kernel.elf kernel.img
echo build completed!

exit 0
