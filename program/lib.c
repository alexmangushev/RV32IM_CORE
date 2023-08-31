#include "lib.h"

int gcd(int a, int b)
{
    int temp;
    while (b != 0)
    {
        temp = a % b;
        a = b;
        b = temp;
    }
    return a;
}

int binpow (int a, int n) 
{
	int res = 1;
	while (n)
		if (n & 1) 
        {
			res *= a;
			--n;
		}
		else 
        {
			a *= a;
			n >>= 1;
		}
	return res;
}