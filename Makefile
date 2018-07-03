#define uECC_arch_other 0
#define uECC_x86        1
#define uECC_x86_64     2
#define uECC_arm        3
#define uECC_arm_thumb  4
#define uECC_arm_thumb2 5
#define uECC_arm64      6
#define uECC_avr        7

platform=2

src = $(wildcard *.c) $(wildcard crypto/*.c) crypto/tiny-AES-c/aes.c
obj = $(src:.c=.o) uECC.o

LDFLAGS = -Wl,--gc-sections ./tinycbor/lib/libtinycbor.a
CFLAGS = -O2 -fdata-sections -ffunction-sections -I./tinycbor/src -I./crypto -I./crypto/micro-ecc/ -Icrypto/tiny-AES-c/ -I.

name = main

all: main

test: testgcm

efm8prog:
	flashefm8.exe -part EFM8UB10F8G -sn 440105518 -upload '.\efm8\Keil 8051 v9.53 - Debug\efm8.hex'

efm32prog:
	commander flash '.\efm32\GNU ARM v7.2.1 - Debug\EFM32.hex' -s 440121060

$(name):  $(obj)
	$(CC) $(LDFLAGS) -o $@ $(obj) $(LDFLAGS)

testgcm: $(obj)
	$(CC) -c main.c $(CFLAGS) -DTEST -o main.o
	$(CC) -c crypto/aes_gcm.c $(CFLAGS) -DTEST -o crypto/aes_gcm.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDFLAGS)

uECC.o: ./crypto/micro-ecc/uECC.c
	$(CC) -c -o $@ $^ -O2 -fdata-sections -ffunction-sections -DuECC_PLATFORM=$(platform) -I./crypto/micro-ecc/

clean:
	rm -f *.o main.exe main crypto/tiny-AES-c/*.o crypto/*.o crypto/micro-ecc/*.o
