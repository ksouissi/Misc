/*
decimal		binary		weapon
0			00			rock
1			01			paper
2			10			scissors

n = bitwise_or(shift_right(P0_input, 2), P1_input)

decimal		binary		winner
0			0000		draw
5			0101		draw
10			1010		draw

1			0001		P1
8			1000 		P1
6			0110		P1

4			0100		P0
2			0010		P0
9			1001		P0

P1 wins when n%5 = 1 or 3 that is: (n%5)&0x1 = 1
P0 wins when n%5 = 4 or 2 i.e.: (n%5)&0x1 = 0
*/

#include <stdio.h>	/* getchar, printf prototypes */

int main()
{
	int p[2] = { 0 },	/* score */
		n;	/* = bitwise_or(shift_right(P0_input, 2), P1_input) */

	printf("ROCK-PAPER-SCISSORS\n0: rock\n1: paper\n2: scissors\n");
	for (;;) {	/* gameloop */
		printf("\nSCORE\nP1: %d vs. P2: %d\n", p[0], p[1]);

		printf("\nP0?\n");	/* P0's turn */
		n = getchar() - 48 << 2;	/* "<<" is shift_right
						ascii code of character '0' = 48, '1' = 49, '2' = 50 */
		getchar();	/* consume linefeed character */

		printf("P1?\n");	/* P1's turn */
		n |= getchar() - 48;	/* '|' is bitwise_or */
		n%5 && p[n%5&0x1]++;	/* only touch score if n%5 != 0 */
		getchar();	/* consume linefeed character */
	}

	return 0;
}
