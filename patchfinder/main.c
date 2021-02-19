#define put_word(A,B)   *(volatile unsigned int *)(A) = (B)
#define NOP 0xE1A00000

void _start() {
	if (*(volatile unsigned int *)0x10000020 != OS_VALUE_CHECK) {
		// red screen, thanks geekpersonman
		volatile unsigned char *scr_base = (*(void**)0xC0000010);
		volatile unsigned char *ptr;
		unsigned scr_size = 320*240*2;
		for (ptr = scr_base; ptr < scr_base + scr_size; ptr += 2) {
			*(volatile unsigned short*)ptr = 0b1111100000000000;
		}
		// delay
		for(volatile int i = 0; i < 10000000; i++) { }
		return;
	}
	#include "patches.h"
	unsigned dummy;
	__asm volatile(
		"0: mrc p15, 0, r15, c7, c10, 3 @ test and clean DCache \n"
		" bne 0b \n"
		" mov %0, #0 \n"
		" mcr p15, 0, %0, c7, c7, 0 @ invalidate ICache and DCache \n" : "=r" (dummy));
}
