#define LEN	16777216

void merge_sort(int *a, int l, int r)
{
	static int b[LEN];	/* scrap buf. */
	if (l < r) {
		int m = (l & r) + ((l ^ r) >> 1);

		merge_sort(a, l, m);
		merge_sort(a, m + 1, r);
		{
			int i = m - l;
			do {
				b[r - i] = a[m + 1 + i];	/* odd num. elements: one read-step beyond */
				b[l + i] = a[l + i];
				i--;
			} while (i >= 0);
		}
		a += l;
		do {
			if (b[l] <= b[r])
				*a++ = b[l++];
			else
				*a++ = b[r--];
		} while (l <= r);
	}
}

#define SWAP(x, y)	(x) ^= (y), (y) ^= (x), (x) ^= (y)
void radix_sort(int a[], int l, int r, int b)
{
	if (l < r) {
		int l0 = l, r0 = r;

		for(;;) {
L0:
			if (a[l0] & 1 << b) {
				do {
					if (~a[r0] & 1 << b) {
						SWAP(a[l0], a[r0]);
						l0++, r0--;
						if (r0 < l0)
							goto L1;
						goto L0;
					}
					r0--;
					if (r0 < l0)
						goto L1;
				} while (1);
			}
			l0++;
			if (r0 < l0)
				break;
		}
L1:
		if (b) {
			radix_sort(a, l, r0, b - 1);
			radix_sort(a, r0 + 1, r, b - 1);
		}
	}
}

/* heap */
#define F(i)	((i) - 1 >> 1)
#define CH(i)	(((i) << 1) + 1)
#define R(i)	(CH(i) + ((unsigned)(h[CH(i)+1] - h[CH(i)]) >> 31))

int h[LEN], l;
void push(int x)
{
	int i = l;
	h[l] = x;
	while (i) {
		if (x < h[F(i)]) {
			SWAP(h[i], h[F(i)]);
			i = F(i);
		} else
			break;
	}
	l++;
}

/* l > 0, non-empty heap */
int pop()
{
	int i, j, a = h[0];
	l--;
	h[0] = h[l];
	h[l] = (1 << 31)-1;	/* so that, below R(i) does not return an out-of-bound index */
	for (i = 0; CH(i) < l; i = j) {
		j = R(i);
		if (h[j] < h[i])
			SWAP(h[j], h[i]);
		else
			break;
	}
	return a;
}

#include <stdlib.h>
#include <stdio.h>

int a[LEN];

int main(int argc, char* argv[])
{
	if (argc > 1) {
		int i, n;

		if (n = atoi(argv[1])) {
			i = n - 1;
			/* heap-sort */
			do {
				push(rand());
			} while (i--);
			i = 0;
			do {
				a[i] = pop();
			} while (++i < n);
			/*
			do {
				a[i] = rand();
			} while (i--);
			merge_sort(a, 0, n - 1);
			radix_sort(a, 0, n - 1, 31); */
			i = 0;
			do {	/* print sorted a */
				printf("%d ", a[i]);
			} while (++i < n);
		}
	}

	return 0;
}
