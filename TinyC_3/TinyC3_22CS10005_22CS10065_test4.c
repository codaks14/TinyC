
// Test Case to check multidimensional arrays and recursion
int DP(int i, int j, int ** dp)
{
    if(i == 0 || j == 0)
        return 1;
    if(dp[i][j] != -1) return dp[i][j];
    dp[i][j] = recur(i-1, j, dp) + recur(i, j-1, dp);
    return dp[i][j];
}

int recur(int i, int j, int dp[][10])
{
    if(i == 0 || j == 0)
        return 1;
    return dp[i][j] = recur(i-1, j, dp) + recur(i, j-1, dp);
}

int main()
{
    int dp[10][10];
    for(int i = 0; i < 10; i++)
        for(int j = 0; j < 10; j++)
            dp[i][j] = -1;

    int ans = DP(6, 6, dp);
    int ans1 = recur(8, 8, dp);
}