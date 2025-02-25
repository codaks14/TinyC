// Checking while loop and bitmasking
int main()
{
    int arr[5];
    for(int i = 0; i < 5; i++) arr[i] = i + 1;
    
    int lo = 0, hi = 4;
    int temp = -1;
    while(hi >= lo)
    {
        int mid = ((lo + hi)>>1);
        if(arr[mid] > 3)
        {
            temp = mid;
            lo = mid + 1;
        }
        else
        {
            hi = mid - 1;
        }
    }
}