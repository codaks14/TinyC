/* TinyC Assignment */
// Tokenization

#define MAXI 100000

typedef struct node_
{
    enum
    {
        INT,
        FLOAT
    } type;
    union
    {
        int a;
        float b;
    } val;
} node;

extern short int errno;
static int res = 0;

inline void add(int a, int b, ...)
{
    /* Check */
    return;
}

int main()
{
    volatile int v = 20;

    signed int arr1[] = {0, +125, -216, 500};
    int n = sizeof(arr1) / sizeof(int);
    const double arr2[] = {1.1e-5, +12E3, -2.16, 500.};
    char arr3[] = {'-', 'b', '\t', '\n'};
    char *restrict ch = arr3;
    char arr4[] = "CSE\t";
    auto i = 0;
    unsigned long b = 1;
    double _Complex c = 1.0 + 2.0 * i;
    float _Imaginary d = 3.0f + 4.0f * i;
    for (i = 0; i < 4; i++)
    {
        switch (arr1[i])
        {
        case 0:
            b++;
            b %= 2;
            b--;
            b *= 1;
            b /= 1;
        case 125:
            b <<= 1;
            b >>= 1;
            b += (1 << 1);
            b -= (1 << 1);
            b |= 1;
            b &= 1;
            b ^= 1;
        case -216:
            b = 1 * b;
            b = b / 1;
            b = b % 130;
            b = b + 1;
            b = b - 1;
        case 500:
            b = (b >> 1);
            b = (2 | 1);
            b = (2 & 1);
            b = (2 ^ 1);
        default:
            goto jump;
            break;
        }
    }

    jump:
        add(1, 2);

    _Bool a = 0, c = 1;
    do
    {
        a = (a) ? 0 : 1;
        a = (~a);
        a = (a && c);
        a = (a || c);
        if (b < 2)
            b = 2;
        else if (b > 2)
            b = 3;
        else if (b == 2)
            continue;
        else if (b != 2)
            break;
        else if (b <= 3)
            b = 4;
        else if (b >= 3)
            b = 5;
        if (a)
            b = 6;
        else
            b = 7;
    } while (!a);

    node *ptr;
    int p = (ptr->val.a);
    register int *q = &i;

    return 1;
}