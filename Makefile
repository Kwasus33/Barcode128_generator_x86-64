CC=gcc
ASMBIN=nasm

imgt : image_test.o image.o _code128_generation.o

_code128_generation.o : _code128_generation.s
	$(ASMBIN) -o _code128_generation.o -f elf64 -g -F dwarf _code128_generation.s

image.o : image.h image.c
	$(CC) -m64 -c -g -O0 image.c

image_test.o : image.h image_test.c
	$(CC) -m64 -c -g -O0 image_test.c

imgt : image_test.o image.o _code128_generation.o
	$(CC) -no-pie -m64 -g -o imgt image_test.o image.o _code128_generation.o

clean :
	rm *.o
	rm imgt
