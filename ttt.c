#include <stdio.h>

int main()
{
	char i = 0, k, a[3] = { 0 },
		*b = (char *)"7\t8\t9\n4\t5\t6\n1\t2\t3\n";	/* board */

	printf("TIC-TAC-TOE\n%s", b);
	do {
		do {	
			printf("\n%c? ", 'A' + (i&0x1));
			k = getchar() - '1';
			getchar();
		} while (a[k/3] & 0x3 << k%3*2);	/* cell not empty: retry */

		b[(2 - k/3)*3 + k%3 << 1] = 'A' + (i&0x1);	/* update board */
		printf("%s", b);
		(a[k/3] |= (i&0x1) + 1 << k%3*2) &&	/* update state, check relevant row, column, diagonals */
			!(a[k/3]%21 &&	/* - */
			((a[0]&(0x3 << k%3*2)) | (a[1]&(0x3 << k%3*2)) << 2 | (a[2]&(0x3 << k%3*2)) << 4)%21 &&	/* | */
			(k&0x3 || (a[0]&0x3 | a[1]&0xc | a[2]&0x30)%21) &&	/* /: 0, 4, 8 */
			(!k || k&0x9 || (a[0]&0x30 | a[1]&0xc | a[2]&0x3)%21)) &&	/* \: 2, 4, 6 */
				(printf("\n%c wins!", 'A' + (i&0x1)), i = -1);
	} while (++i);

	return 0;
}
