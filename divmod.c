/* Euclidean division */

/* out-of-range-prone */
#define ABS(x)	((x) >> 31 ^ (x) - ((unsigned)(x) >> 31))
int idiv(int a, int b)
{
	a -= a >> 31 & ABS(b) - 1;
	return a/b;
}

/* #define SIGN(x) ((x) >> 31 | 0x1) */
int idiv2(int a, int b)
{
	/* int c, d;

	int c = a/b, d = a-b*c;
	return c - (a >> 31 & -((unsigned)d >> 1 | d & (1 << 31) - 1) >> 31 & SIGN(b)); */
	__asm {
		mov		eax, a		; a/
		mov		ecx, b		; /b
		mov		ebx, eax
		cdq
		idiv	ecx
		sar		ecx, 31		; SIGN(
		sar		ebx, 31		; a >> 31
		or		ecx, 1		; b)
		and		ebx, ecx	; a >> 31 & SIGN(b)
		xor		ecx, ecx
		test	edx, edx
		setnz	cl			; a%b != 0?
		neg		ecx			; d = -!(a%b) = 0 or -1 = 0xffffffff
		and		ebx, ecx	; a >> 31 & d & SIGN(b)
		sub		eax, ebx	; c - (a >> 31 & d & SIGN(b))
	}
	/* return c - (a >> 31 & d & SIGN(b)); */
}

/* 0 <= mod(a, b) < b */
int mod(int a, int b)
{
	return a - idiv2(a, b)*b;
}

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	if (argc >= 3) {
		int a, b;
		a = atoi(argv[1]);
		b = atoi(argv[2]);
		printf("%d/%d = %d\n%d%%%d = %d", a, b, idiv2(a, b), a, b, mod(a, b));
	} else
		printf("Usage: divmod <integer> <non-zero-integer>");
	return 0;
}
