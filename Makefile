LD  = arm-linux-gnueabi-ld
OBJ = arm-linux-gnueabi-objcopy
ASM = arm-linux-gnueabi-as
CC  = arm-linux-gnueabi-gcc

ASM_FLAGS = -march=armv7-a -g -c
CC_FLAGS  = -march=armv7-a -g -c #-c means generate object file
LD_FLAGS  = -g -T linker.ld

all: boot.o linker.ld main.o
	$(LD) $(LD_FLAGS) -o kernel.elf boot.o main.o -Map kernel.map
	$(OBJ) -O binary kernel.elf kernel.img

boot.o: boot.s
	$(ASM) $(ASM_FLAGS) boot.s -o boot.o

main.o: main.c
	$(CC) $(CC_FLAGS) main.c -o main.o

clean:
	rm -rf boot.o main.o kernel.elf kernel.map kernel.img
