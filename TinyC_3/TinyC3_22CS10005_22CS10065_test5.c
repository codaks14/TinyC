// Checking arithmetic expressions and typecasting
// Checking multiple datatypes operations on strings, arrays, pointers

int a = 1.2, b = 2,d = 3;
char c = 'a';
float var = 1.0;

void swap(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}

void main()
{
    var = a / (b * 1.0);
    c = 'a' + a;
    while(a < 10)
    {
        a *= b;
        c -= 20;
        c /= ((++a) + (b++));
    }
    var *= 2.0;
    swap(&a, &b);
    int arr[a];
    int ind = 0;
    while(ind < a)
    {
        arr[ind] = ind++;
    }
    char string_val[] = "sahil";
    char *ptr = "akshat";
}