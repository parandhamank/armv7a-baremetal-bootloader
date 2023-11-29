#!/bin/bash
if test -f kernel.elf; then
	echo removing kernel.elf
	rm -rf kernel.elf
fi

if test -f kernel.img; then
	echo removing kernel.img
	rm -rf kernel.img
fi

if test -f kernel.map; then
	echo removing kernel.map
	rm -rf kernel.map
fi

if test -f boot.o; then
	echo removing boot.o
	rm -rf boot.o
fi

if test -f main.o; then
	echo removing main.o
	rm -rf main.o
fi

arm-linux-gnueabi-as -march=armv7-a  -g -c boot.s -o boot.o
arm-linux-gnueabi-gcc -march=armv7-a -g -c main.c -o main.o
arm-linux-gnueabi-ld -g -T linker.ld -o kernel.elf boot.o main.o -Map kernel.map
arm-linux-gnueabi-objcopy -O binary kernel.elf kernel.img
echo build completed!

exit 0
