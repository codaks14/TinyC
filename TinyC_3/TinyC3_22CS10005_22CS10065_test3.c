// test case for checking iteration_statements and multidimensional arrays along with recursion
int adj[100][100];

void make_adj_list()
{
    for(int i = 0; i < 100; i++)
    {
        for(int j = i; j >= 0; j--)
        {
            if(j & i) adj[i][j] = 1;
        }
    }
}

void dfs(int curr_node, int* vis)
{
    vis[curr_node] = 1;
    for(int node = 0; node < 100; node++)
        if(adj[curr_node][node] && vis[node] == 0) 
            dfs(node,vis);
}

int main()
{
    make_adj_list();
    int vis[100];
    for(int i = 0; i < 100; i++)
    {
        if(vis[i] == 0) dfs(i,vis);
    }
}