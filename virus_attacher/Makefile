all: program

program: main.o util.o start.o
	ld -m elf_i386 -nostdlib -e _start -o program start.o main.o util.o

main.o: main.c util.h
	gcc -m32 -Wall -nostdlib -fno-stack-protector -c main.c -o main.o

util.o: util.c util.h
	gcc -m32 -Wall -ansi -nostdlib -fno-stack-protector -c util.c -o util.o

start.o: start.s
	nasm -f elf32 start.s -o start.o

.PHONY: clean

clean:
	rm -f *.o program
