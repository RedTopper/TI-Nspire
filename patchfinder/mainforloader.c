#define put_word(A,B)   *(volatile unsigned int *)(A) = (B)
#define NOP 0xE1A00000

void _start() {
	#include "patches.h"
}
