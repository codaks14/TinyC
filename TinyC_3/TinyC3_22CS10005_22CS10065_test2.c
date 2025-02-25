// Checking for multinline comments and single line comments
// Checking working of arithmetic and bitmask expressions

/* Iterative Function to calculate 
(x^y)%p in O(log y) */
int power(int x, int y, int p) 
{ 
    int res = 1;     // Initialize result 
    x = x % p; // Update x if it is more than or 
                // equal to p
    if (x == 0) return 0; // In case x is divisible by p;
    while (y > 0) { 
        // If y is odd, multiply x with result 
        if (y & 1) 
            res = (res*x) % p; 
        // y must be even now 
        y >>= 1; // y = y/2 
        x = (x*x) % p; 
    } 
    return res; 
} 

int main()
{
    int factinv[10];
    factinv[0] = 1;
    int p = 1e9 + 7;
    for(int i = 1; i < 10; i++)
    {
        factinv[i] *= factinv[i-1] % p;
    }
    for(int i = 0; i < 10; i++)
    {
        factinv[i] = power(factinv[i],p-2,p);
    }
}