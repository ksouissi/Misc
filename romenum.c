#include <stdio.h>

void romenum(unsigned n)
{
	if (n/1000 <= 3) {
		int i, j = 1000;
		char *k[] = { "I",
					  "IV", "V", "IX", "X",
					  "XL", "L", "XC", "C",
					  "CD", "D", "CM", "M" },
			 **p = &k[12];	/* VC 6.0: k not l-value */

		for (;;) {
			for (i = n/j; i--; )
				printf(*p);
			if (p == k)
				break;
			n %= j;
			if (n >= j - j/10) {
				printf(*(p-1));
				n -= j - j/10;
			} else {
				if (n >= j/2) {
					printf(*(p-2));
					n -= j/2;
				} else if (n >= j/2 - j/10) {
					printf (*(p-3));
					n -= j/2 - j/10;
				}
			}
			j /= 10, p -= 4;
		}
	} else {
		printf("["), romenum(n/1000%5 <= 3 ? n/1000 - n/1000%5 : n/1000), printf("]");
		romenum(n/1000%5 <= 3 ? n%1000 + n/1000%5*1000 : n%1000);
	}
}

#include <stdlib.h>

int main(int argc, char *argv[])
{
	if (argc > 1)
		romenum(atoi(argv[1]));
	else
		printf("Usage: rosenum.exe <unsigned int [32-bit]>\n[<roman numeral>] = <roman numeral> * 1000");
	return 0;
}
