#include <stdio.h>
//Akshat Pandey 22CS10005
//Sahil Asawa 22CS10065
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"

typedef struct _node
{
    char *name;
    struct _node *next;
    int count;
} node;
typedef node *symboltable;

symboltable addtbl(symboltable T, char *id)
{
    node *p;

    p = T;
    while (p)
    {
        if (!strcmp(p->name, id))
        {
            return T;
        }
        p = p->next;
    }
    p = (node *)malloc(sizeof(node));
    p->name = (char *)malloc((strlen(id) + 1) * sizeof(char));
    strcpy(p->name, id);
    p->next = T;
    return p;
}

void print_table(symboltable T)
{
    node *p;
    p = T;
    while (p)
    {
        printf("\t\t\t\t\t\t\t\t\t\t\t\t%s\n", p->name);
        p = p->next;
    }
}
int main()
{
    int nextok;
    symboltable Identifier_table = NULL;
    symboltable Constant_table = NULL;
    symboltable String_table = NULL;
    symboltable punctuations_table = NULL;
    
    while ((nextok = yylex()))
    {
        switch (nextok)
        {
        case KW:
            printf("< keyword , %s >\n", yytext);
            break;
        case ID:
            printf("< identifier , %s >\n", yytext);
            Identifier_table = addtbl(Identifier_table, yytext);
            break;
        case CONS:
            printf("< constant , %s >\n", yytext);
            Constant_table = addtbl(Constant_table, yytext);
            break;
        case STR:
            printf("< string , %s >\n", yytext);
            String_table = addtbl(String_table, yytext);
            break;
        case PUNC:
            printf("< punctuation , %s >\n", yytext);
            punctuations_table = addtbl(punctuations_table, yytext);
            break;
        case CMT:
            printf("< comment , %s >\n", yytext);
            break;
        default:
            printf("Unknown token!!!!: %s\n", yytext);
        }
    }
    printf("\n");
    printf(".----------------------------------------------------------------------------------------------------------.\n");
    printf("\t\t\t\t\t\t\t\t\t\t\tIdentifier Table\n");
    printf(".----------------------------------------------------------------------------------------------------------.\n");
    print_table(Identifier_table);
    printf("\n");

    printf(".----------------------------------------------------------------------------------------------------------.\n");
    printf("\t\t\t\t\t\t\t\t\t\t\tConstant Table\n");
    printf(".----------------------------------------------------------------------------------------------------------.\n");
    print_table(Constant_table);
    printf("\n");

    printf(".----------------------------------------------------------------------------------------------------------.\n");
    printf("\t\t\t\t\t\t\t\t\t\t\tString Table\n");
    printf(".----------------------------------------------------------------------------------------------------------.\n");
    print_table(String_table);
    printf("\n");

    printf(".----------------------------------------------------------------------------------------------------------.\n");
    printf("\t\t\t\t\t\t\t\t\t\t\tPunctuations Table\n");
    printf(".----------------------------------------------------------------------------------------------------------.\n");
    print_table(punctuations_table);
    printf("\n");


    



    exit(0);
}