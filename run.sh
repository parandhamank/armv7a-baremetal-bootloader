#!/bin/bash
qemu-system-arm -machine virt,secure=on -cpu cortex-a7 -kernel kernel.img -smp 4 -m 1024M -s -S &
gdb-multiarch kernel.elf
pkill qemu-system-arm
exit 0
