#include "lex.yy.c"

node *root = NULL;

node *create_node(char *data) 
{
    node *temp = (node *)malloc(sizeof(node));
    temp->data = (char *)malloc(strlen(data) + 1);
    strcpy(temp->data, data);
    temp->child = NULL;
    return temp;
}

void add_child(node *parent, node *child_node) 
{
    list *curr = parent->child;
    list *temp = (list *)malloc(sizeof(list));
    temp->head = child_node;
    temp->next = NULL;
    if (parent->child == NULL)
    {
        parent->child = temp;
    }
    else 
    {
        while (curr->next != NULL)
        {
            curr = curr->next;
        }
        curr->next = temp;
    }
    return;
}

void add_leaf(node *parent, char *data) 
{
    node *temp = create_node(data);
    add_child(parent, temp);
    return;
}

void make_root(node *temp) 
{
    root = temp;
    return;
}

void print(node *root, int depth)
{
    if (root == NULL)
        return;
    for (int i = 0; i < depth; i++)
    {
        printf("\t");
    }
    printf("---> %s\n", root->data);
    list *temp = root->child;
    while (temp != NULL)
    {
        print(temp->head, depth + 1);
        temp = temp->next;
    }
    return;
}

int main()
{
    yyparse();
    fflush(stdout);
    print(root, 0);
    return 0;
}