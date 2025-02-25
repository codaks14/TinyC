%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void yyerror(const char *s);
    int yylex();

    typedef struct node_
    {
        char * data;
        struct list_ * child;
    }node;

    typedef struct list_
    {
        struct node_ * head;
        struct list_ * next;
    }list;

    node * create_node(char * data);
    list * add_to_list(list * head, node * child);
    void add_child(node * parent, node * child);
    void add_leaf(node * parent, char * data);
    void make_root(node * root);
    void print_tree(node * root);

%}

%union{
    // needed for parse table construction
    node * nodeptr;
}

%start program

%token IDENTIFIER CONSTANT STRING_LITERAL PARENTHESIS_OPEN PARENTHESIS_CLOSE SQUARE_OPEN SQUARE_CLOSE DOT PTR_ARR INC DEC BRACE_OPEN BRACE_CLOSE COMMA SIZEOF
%token ADD_OP SUB_OP MUL_OP DIV_OP MOD_OP LEFT_OP RIGHT_OP LESS_THAN_OP GREATER_THAN_OP LESS_THAN_EQUAL_OP GREATER_THAN_EQUAL_OP EQUAL_OP NOT_EQUAL_OP AND_OP XOR_OP OR_OP BITWISE_AND BITWISE_OR EXCLAMATION_OP TILDE_OP
%token QUESTION_MARK COLON EQUAL MUL_EQUAL DIV_EQUAL MOD_EQUAL ADD_EQUAL SUB_EQUAL LEFT_OP_EQUAL RIGHT_OP_EQUAL AND_EQUAL XOR_EQUAL OR_EQUAL EXTERN STATIC AUTO REGISTER VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED BOOL COMPLEX IMAGINARY CONST RESTRICT VOLATILE INLINE ELLIPSIS
%token CASE DEFAULT SEMICOLON IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN ENUM STRUCT UNION TYPEDEF HASH CMT ERROR
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

// expressions
%type <nodeptr> primary_expression postfix_expression argument_expression_list unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression AND_expression exclusive_OR_expression inclusive_OR_expression logical_AND_expression logical_OR_expression conditional_expression assignment_expression assignment_operator expression constant_expression
// declarations
%type <nodeptr> declaration declaration_specifiers init_declarator_list init_declarator storage_class_specifier type_specifier specifier_qualifier_list type_qualifier function_specifier declarator direct_declarator pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name initializer initializer_list designation designator_list designator
// statements
%type <nodeptr> statement labeled_statement compound_statement block_item_list block_item expression_statement selection_statement iteration_statement jump_statement
// external definitions
%type <nodeptr> translation_unit external_declaration function_definition declaration_list
// optional
%type <nodeptr> init_declarator_list_opt expression_opt declaration_specifiers_opt specifier_qualifier_list_opt pointer_opt type_qualifier_list_opt assignment_expression_opt identifier_list_opt designation_opt argument_expression_list_opt block_item_list_opt declaration_list_opt
%%

program:translation_unit { make_root($1); }
        ;

primary_expression:IDENTIFIER {$$=create_node("primary-expression");add_leaf($$,"identifier");}
                   | CONSTANT {$$=create_node("primary-expression");add_leaf($$,"constant");}
                   | STRING_LITERAL {$$=create_node("primary-expression");add_leaf($$,"string-literal");}
                   | PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {$$=create_node("primary-expression");add_leaf($$,"("); add_child($$,$2);add_leaf($$,")");}
                   ;

postfix_expression:primary_expression
                   { $$=create_node("postfix-expression");add_child($$,$1);}
                   | postfix_expression SQUARE_OPEN expression SQUARE_CLOSE
                   { $$=create_node("postfix-expression");add_child($$,$1);add_leaf($$,"[");add_child($$,$3);add_leaf($$,"]");}
                   | postfix_expression PARENTHESIS_OPEN argument_expression_list_opt PARENTHESIS_CLOSE
                   { $$=create_node("postfix-expression");add_child($$,$1);add_leaf($$,"(");add_child($$,$3);add_leaf($$,")");}
                   | postfix_expression DOT IDENTIFIER
                   { $$=create_node("postfix-expression");add_child($$,$1);add_leaf($$,".");add_leaf($$,"identifier");}
                   | postfix_expression PTR_ARR IDENTIFIER
                   { $$=create_node("postfix-expression");add_child($$,$1);add_leaf($$,"->");add_leaf($$,"identifier");}
                   | postfix_expression INC
                   { $$=create_node("postfix-expression");add_child($$,$1);add_leaf($$,"++");}
                   | postfix_expression DEC
                   { $$=create_node("postfix-expression");add_child($$,$1);add_leaf($$,"--");}
                   | PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE BRACE_OPEN initializer_list BRACE_CLOSE
                   { $$=create_node("postfix-expression");add_leaf($$,"(");add_child($$,$2);add_leaf($$,")");add_leaf($$,"{");add_child($$,$5);add_leaf($$,"}");}
                   | PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE BRACE_OPEN initializer_list COMMA BRACE_CLOSE
                   { $$=create_node("postfix-expression");add_leaf($$,"(");add_child($$,$2);add_leaf($$,")");add_leaf($$,"{");add_child($$,$5);add_leaf($$,",");add_leaf($$,"}");}
                   ;

argument_expression_list:assignment_expression
                         {$$=create_node("argument-expression-list");add_child($$,$1);}
                         | argument_expression_list COMMA assignment_expression
                         {$$=create_node("argument-expression-list");add_child($$,$1);add_leaf($$,",");add_child($$,$3);}
                         ;

unary_expression:postfix_expression
                {$$=create_node("unary-expression");add_child($$,$1);}
                | INC unary_expression
                {$$=create_node("unary-expression");add_leaf($$,"++");add_child($$,$2);}
                | DEC unary_expression
                {$$=create_node("unary-expression");add_leaf($$,"--");add_child($$,$2);}
                | unary_operator cast_expression
                {$$=create_node("unary-expression");add_child($$,$1);add_child($$,$2);}
                | SIZEOF unary_expression
                {$$=create_node("unary-expression");add_leaf($$,"sizeof");add_child($$,$2);}
                | SIZEOF PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE
                {$$=create_node("unary-expression");add_leaf($$,"sizeof");add_leaf($$,"(");add_child($$,$3);add_leaf($$,")");}
                ;

unary_operator:AND_OP
                {$$=create_node("unary-operator");add_leaf($$,"&");}
                | MUL_OP
                {$$=create_node("unary-operator");add_leaf($$,"*");}
                | ADD_OP
                {$$=create_node("unary-operator");add_leaf($$,"+");}
                | SUB_OP
                {$$=create_node("unary-operator");add_leaf($$,"-");}
                | TILDE_OP
                {$$=create_node("unary-operator");add_leaf($$,"~");}
                | EXCLAMATION_OP
                {$$=create_node("unary-operator");add_leaf($$,"!");}
                ;

cast_expression:unary_expression
                {$$=create_node("cast-expression");add_child($$,$1);}
                | PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE cast_expression
                {$$=create_node("cast-expression");add_leaf($$,"(");add_child($$,$2);add_leaf($$,")");add_child($$,$4);}
                ;

multiplicative_expression:cast_expression
                          {$$=create_node("multiplicative-expression");add_child($$,$1);}
                          | multiplicative_expression MUL_OP cast_expression
                          {$$=create_node("multiplicative-expression");add_child($$,$1);add_leaf($$,"*");add_child($$,$3);}
                          | multiplicative_expression DIV_OP cast_expression
                          {$$=create_node("multiplicative-expression");add_child($$,$1);add_leaf($$,"/");add_child($$,$3);}
                          | multiplicative_expression MOD_OP cast_expression
                          { $$=create_node("multiplicative-expression");add_child($$,$1);add_leaf($$,"%");add_child($$,$3);}
                          ;

additive_expression:multiplicative_expression
                    {$$=create_node("additive-expression");add_child($$,$1);}
                    | additive_expression ADD_OP multiplicative_expression
                    {$$=create_node("additive-expression");add_child($$,$1);add_leaf($$,"+");add_child($$,$3);}
                    | additive_expression SUB_OP multiplicative_expression
                    {$$=create_node("additive-expression");add_child($$,$1);add_leaf($$,"-");add_child($$,$3);}
                    ;

shift_expression:additive_expression
                { $$=create_node("shift-expression");add_child($$,$1);}
                | shift_expression LEFT_OP additive_expression
                { $$=create_node("shift-expression");add_child($$,$1);add_leaf($$,"<<");add_child($$,$3);}
                | shift_expression RIGHT_OP additive_expression
                { $$=create_node("shift-expression");add_child($$,$1);add_leaf($$,">>");add_child($$,$3);}
                ;

relational_expression:shift_expression
                      {$$=create_node("relational-expression");add_child($$,$1);}
                      | relational_expression LESS_THAN_OP shift_expression
                      {$$=create_node("relational-expression");add_child($$,$1);add_leaf($$,"<");add_child($$,$3);}
                      | relational_expression GREATER_THAN_OP shift_expression
                      {$$=create_node("relational-expression");add_child($$,$1);add_leaf($$,">");add_child($$,$3);}
                      | relational_expression LESS_THAN_EQUAL_OP shift_expression
                      {$$=create_node("relational-expression");add_child($$,$1);add_leaf($$,"<=");add_child($$,$3);}
                      | relational_expression GREATER_THAN_EQUAL_OP shift_expression
                      {$$=create_node("relational-expression");add_child($$,$1);add_leaf($$,">=");add_child($$,$3);}
                      ;

equality_expression:relational_expression
                    { $$=create_node("equality-expression");add_child($$,$1);}
                    | equality_expression EQUAL_OP relational_expression
                    { $$=create_node("equality-expression");add_child($$,$1);add_leaf($$,"==");add_child($$,$3);}
                    | equality_expression NOT_EQUAL_OP relational_expression
                    { $$=create_node("equality-expression");add_child($$,$1);add_leaf($$,"!=");add_child($$,$3);}
                    ;

AND_expression:equality_expression
                { $$=create_node("AND-expression");add_child($$,$1);}
                | AND_expression AND_OP equality_expression
                { $$=create_node("AND-expression");add_child($$,$1);add_leaf($$,"&&");add_child($$,$3);}
                ;

exclusive_OR_expression:AND_expression
                        {$$=create_node("exclusive-OR-expression");add_child($$,$1);}
                        | exclusive_OR_expression XOR_OP AND_expression
                        {$$=create_node("exclusive-OR-expression");add_child($$,$1);add_leaf($$,"^");add_child($$,$3);}
                        ;

inclusive_OR_expression:exclusive_OR_expression
                        { $$=create_node("inclusive-OR-expression");add_child($$,$1);}
                        | inclusive_OR_expression OR_OP exclusive_OR_expression
                        { $$=create_node("inclusive-OR-expression");add_child($$,$1);add_leaf($$,"|");add_child($$,$3);}
                        ;

logical_AND_expression:inclusive_OR_expression
                        { $$=create_node("logical-AND-expression");add_child($$,$1);}
                        | logical_AND_expression BITWISE_AND inclusive_OR_expression
                        { $$=create_node("logical-AND-expression");add_child($$,$1);add_leaf($$,"&");add_child($$,$3);}
                        ;

logical_OR_expression:logical_AND_expression
                        { $$=create_node("logical-OR-expression");add_child($$,$1);}
                        | logical_OR_expression BITWISE_OR logical_AND_expression
                        { $$=create_node("logical-OR-expression");add_child($$,$1);add_leaf($$,"|");add_child($$,$3);}
                        ;

conditional_expression:logical_OR_expression
                        { $$=create_node("conditional-expression");add_child($$,$1);}
                        | logical_OR_expression QUESTION_MARK expression COLON conditional_expression
                        { $$=create_node("conditional-expression");add_child($$,$1);add_leaf($$,"?");add_child($$,$3);add_leaf($$,":");add_child($$,$5);}
                        ;

assignment_expression:conditional_expression
                        { $$=create_node("assignment-expression");add_child($$,$1);}
                        | unary_expression assignment_operator assignment_expression
                        { $$=create_node("assignment-expression");add_child($$,$1);add_child($$,$2);add_child($$,$3);}
                        ;

assignment_operator:EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"=");}
                    | MUL_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"*=");}
                    | DIV_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"/=");}
                    | MOD_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"%=");}
                    | ADD_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"+=");}
                    | SUB_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"-=");}
                    | LEFT_OP_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"<<=");}
                    | RIGHT_OP_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,">>=");}
                    | AND_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"&=");}
                    | XOR_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"^=");}
                    | OR_EQUAL
                    { $$=create_node("assignment-operator");add_leaf($$,"|=");}
                    ;

expression:assignment_expression
            { $$=create_node("expression");add_child($$,$1);}
            | expression COMMA assignment_expression
            { $$=create_node("expression");add_child($$,$1);add_leaf($$,",");add_child($$,$3);}
            ;

constant_expression:conditional_expression
                    { $$=create_node("constant-expression");add_child($$,$1);};
                   

// declarations

declaration:declaration_specifiers init_declarator_list_opt SEMICOLON 
            { $$=create_node("declaration");add_child($$,$1);add_child($$,$2);add_leaf($$,";");}
            ;

declaration_specifiers:storage_class_specifier declaration_specifiers_opt { $$=create_node("declaration-specifiers");add_child($$,$1);add_child($$,$2); }
                        |type_specifier declaration_specifiers_opt { $$=create_node("declaration-specifiers");add_child($$,$1);add_child($$,$2); }
                        |type_qualifier declaration_specifiers_opt { $$=create_node("declaration-specifiers");add_child($$,$1);add_child($$,$2); }
                        |function_specifier declaration_specifiers_opt { $$=create_node("declaration-specifiers");add_child($$,$1);add_child($$,$2); }
                        ;

init_declarator_list:init_declarator { $$=create_node("init-declarator-list");add_child($$,$1); }
                    |init_declarator_list COMMA init_declarator { $$=create_node("init-declarator-list");add_child($$,$1);add_leaf($$,",");add_child($$,$3); }
                    ;

init_declarator:declarator { $$=create_node("init-declarator");add_child($$,$1); }   
                |declarator EQUAL initializer { $$=create_node("init-declarator");add_child($$,$1);add_leaf($$,"=");add_child($$,$3); }
                ;

storage_class_specifier:EXTERN { $$=create_node("storage-class-specifier");add_leaf($$,"extern"); }
                        |STATIC { $$=create_node("storage-class-specifier");add_leaf($$,"static"); }
                        |AUTO { $$=create_node("storage-class-specifier");add_leaf($$,"auto"); }
                        |REGISTER { $$=create_node("storage-class-specifier");add_leaf($$,"register"); }
                        ;

type_specifier:VOID { $$=create_node("type-specifier");add_leaf($$,"void"); }
                |CHAR { $$=create_node("type-specifier");add_leaf($$,"char"); }
                |SHORT { $$=create_node("type-specifier");add_leaf($$,"short"); }
                |INT { $$=create_node("type-specifier");add_leaf($$,"int"); }
                |LONG { $$=create_node("type-specifier");add_leaf($$,"long"); }
                |FLOAT { $$=create_node("type-specifier");add_leaf($$,"float"); }
                |DOUBLE { $$=create_node("type-specifier");add_leaf($$,"double"); }
                |SIGNED { $$=create_node("type-specifier");add_leaf($$,"signed"); }
                |UNSIGNED { $$=create_node("type-specifier");add_leaf($$,"unsigned"); }
                |BOOL { $$=create_node("type-specifier");add_leaf($$,"_Bool"); }
                |COMPLEX { $$=create_node("type-specifier");add_leaf($$,"_Complex"); }
                |IMAGINARY { $$=create_node("type-specifier");add_leaf($$,"_Imaginary"); }
                ;

specifier_qualifier_list:type_specifier specifier_qualifier_list_opt { $$=create_node("specifier-qualifier-list");add_child($$,$1);add_child($$,$2); }
                        |type_qualifier specifier_qualifier_list_opt { $$=create_node("specifier-qualifier-list");add_child($$,$1);add_child($$,$2); }
                        ;

type_qualifier:CONST { $$=create_node("type-qualifier");add_leaf($$,"const"); }
                |RESTRICT { $$=create_node("type-qualifier");add_leaf($$,"restrict"); }
                |VOLATILE { $$=create_node("type-qualifier");add_leaf($$,"volatile"); }
                ;

function_specifier:INLINE { $$=create_node("function-specifier");add_leaf($$,"inline"); }
                ;

declarator:pointer_opt direct_declarator { $$=create_node("declarator");add_child($$,$1);add_child($$,$2); }
                ;

direct_declarator:IDENTIFIER { $$=create_node("direct-declarator");add_leaf($$,"identifier"); }
                |PARENTHESIS_OPEN declarator PARENTHESIS_CLOSE { $$=create_node("direct-declarator");add_leaf($$,"(");add_child($$,$2);add_leaf($$,")"); }
                |direct_declarator SQUARE_OPEN type_qualifier_list_opt assignment_expression_opt SQUARE_CLOSE { $$=create_node("direct-declarator");add_child($$,$1);add_leaf($$,"[");add_child($$,$3);add_child($$,$4);add_leaf($$,"]"); }
                |direct_declarator SQUARE_OPEN STATIC type_qualifier_list_opt assignment_expression SQUARE_CLOSE { $$=create_node("direct-declarator");add_child($$,$1);add_leaf($$,"[");add_leaf($$,"static");add_child($$,$4);add_child($$,$5);add_leaf($$,"]"); }
                |direct_declarator SQUARE_OPEN type_qualifier_list STATIC assignment_expression SQUARE_CLOSE { $$=create_node("direct-declarator");add_child($$,$1);add_leaf($$,"[");add_child($$,$3);add_leaf($$,"static");add_child($$,$5);add_leaf($$,"]"); }
                |direct_declarator SQUARE_OPEN type_qualifier_list_opt MUL_OP SQUARE_CLOSE { $$=create_node("direct-declarator");add_child($$,$1);add_leaf($$,"[");add_child($$,$3);add_leaf($$,"*");add_leaf($$,"]"); }
                |direct_declarator PARENTHESIS_OPEN parameter_type_list PARENTHESIS_CLOSE { $$=create_node("direct-declarator");add_child($$,$1);add_leaf($$,"(");add_child($$,$3);add_leaf($$,")"); }
                |direct_declarator PARENTHESIS_OPEN identifier_list_opt PARENTHESIS_CLOSE { $$=create_node("direct-declarator");add_child($$,$1);add_leaf($$,"(");add_child($$,$3);add_leaf($$,")"); }
                ;

pointer:MUL_OP type_qualifier_list_opt { $$=create_node("pointer");add_leaf($$,"*");add_child($$,$2); }
        |MUL_OP type_qualifier_list_opt pointer { $$=create_node("pointer");add_leaf($$,"*");add_child($$,$2); }
        ;

type_qualifier_list:type_qualifier { $$=create_node("type-qualifier-list");add_child($$,$1); }
                    |type_qualifier_list type_qualifier { $$=create_node("type-qualifier-list");add_child($$,$1);add_child($$,$2); }
                    ;

parameter_type_list:parameter_list { $$=create_node("parameter-type-list");add_child($$,$1); }
                    |parameter_list COMMA ELLIPSIS { $$=create_node("parameter-type-list");add_child($$,$1);add_leaf($$,"..."); }
                    ;

parameter_list:parameter_declaration { $$=create_node("parameter-list");add_child($$,$1); }
                |parameter_list COMMA parameter_declaration { $$=create_node("parameter-list");add_child($$,$1);add_leaf($$,",");add_child($$,$3); }
                ;

parameter_declaration:declaration_specifiers declarator { $$=create_node("parameter-declaration");add_child($$,$1);add_child($$,$2); }
                    |declaration_specifiers { $$=create_node("parameter-declaration");add_child($$,$1); }
                    ;

identifier_list:IDENTIFIER { $$=create_node("identifier-list");add_leaf($$,"identifier"); }
                |identifier_list COMMA IDENTIFIER { $$=create_node("identifier-list");add_child($$,$1);add_leaf($$,",");add_leaf($$,"identifier"); }
                ;

type_name:specifier_qualifier_list { $$=create_node("type-name");add_child($$,$1); }
            ;

initializer:assignment_expression { $$=create_node("initializer");add_child($$,$1); }
            |BRACE_OPEN initializer_list BRACE_CLOSE { $$=create_node("initializer");add_leaf($$,"{");add_child($$,$2);add_leaf($$,"}"); }
            |BRACE_OPEN initializer_list COMMA BRACE_CLOSE { $$=create_node("initializer");add_leaf($$,"{");add_child($$,$2);add_leaf($$,",");add_leaf($$,"}"); }
            ;

initializer_list:designation_opt initializer { $$=create_node("initializer-list");add_child($$,$1);add_child($$,$2); }
                |initializer_list COMMA designation_opt initializer { $$=create_node("initializer-list");add_child($$,$1);add_leaf($$,",");add_child($$,$3);add_child($$,$4); }
                ;

designation:designator_list EQUAL { $$=create_node("designation");add_child($$,$1);add_leaf($$,"=");}
            ;

designator_list:designator { $$=create_node("designator-list");add_child($$,$1); }
                |designator_list designator { $$=create_node("designator-list");add_child($$,$1);add_child($$,$2); }
                ;

designator: SQUARE_OPEN CONSTANT expression SQUARE_CLOSE { $$=create_node("designator");add_leaf($$,"[");add_leaf($$,"constant");add_child($$,$3);add_leaf($$,"]"); }
            | DOT IDENTIFIER { $$=create_node("designator");add_leaf($$,".");add_leaf($$,"identifier"); }
            ;


// statements
statement: labeled_statement
            { $$=create_node("statement");add_child($$,$1);}
            | compound_statement
            { $$=create_node("statement");add_child($$,$1);}
            | expression_statement
            { $$=create_node("statement");add_child($$,$1);}
            | selection_statement
            { $$=create_node("statement");add_child($$,$1);}
            | iteration_statement
            { $$=create_node("statement");add_child($$,$1);}
            | jump_statement
            { $$=create_node("statement");add_child($$,$1);}
            ;

labeled_statement:IDENTIFIER COLON statement
                    { $$=create_node("labeled-statement");add_leaf($$,"identifier");add_leaf($$,":");add_child($$,$3);}
                    | CASE constant_expression COLON statement
                    { $$=create_node("labeled-statement");add_leaf($$,"case");add_child($$,$2);add_leaf($$,":");add_child($$,$4);}
                    | DEFAULT COLON statement
                    { $$=create_node("labeled-statement");add_leaf($$,"default");add_leaf($$,":");add_child($$,$3);}
                    ;

compound_statement:BRACE_OPEN block_item_list_opt BRACE_CLOSE
                    { $$=create_node("compound-statement");add_leaf($$,"{");add_child($$,$2);add_leaf($$,"}");}
                    ;

block_item_list:block_item
                { $$=create_node("block-item-list");add_child($$,$1);}
                | block_item_list block_item
                { $$=create_node("block-item-list");add_child($$,$1);add_child($$,$2);}
                ;

block_item:declaration
            { $$=create_node("block-item");add_child($$,$1);}
            | statement
            { $$=create_node("block-item");add_child($$,$1);}
            ;

expression_statement:assignment_expression_opt SEMICOLON
                    { $$=create_node("expression-statement");add_child($$,$1);add_leaf($$,";");}
                    ;

selection_statement:IF PARENTHESIS_OPEN expression PARENTHESIS_CLOSE statement %prec LOWER_THAN_ELSE
                    { $$=create_node("selection-statement");add_leaf($$,"if");add_leaf($$,"(");add_child($$,$3);add_leaf($$,")");add_child($$,$5);}
                    | IF PARENTHESIS_OPEN expression PARENTHESIS_CLOSE statement ELSE statement
                    { $$=create_node("selection-statement");add_leaf($$,"if");add_leaf($$,"(");add_child($$,$3);add_leaf($$,")");add_child($$,$5);add_leaf($$,"else");add_child($$,$7);}
                    | SWITCH PARENTHESIS_OPEN expression PARENTHESIS_CLOSE statement
                    { $$=create_node("selection-statement");add_leaf($$,"switch");add_leaf($$,"(");add_child($$,$3);add_leaf($$,")");add_child($$,$5);}
                    ;
                    
iteration_statement:WHILE PARENTHESIS_OPEN expression PARENTHESIS_CLOSE statement
                    { $$=create_node("iteration-statement");add_leaf($$,"while");add_leaf($$,"(");add_child($$,$3);add_leaf($$,")");add_child($$,$5);}
                    | DO statement WHILE PARENTHESIS_OPEN expression PARENTHESIS_CLOSE SEMICOLON
                    { $$=create_node("iteration-statement");add_leaf($$,"do");add_child($$,$2);add_leaf($$,"while");add_leaf($$,"(");add_child($$,$5);add_leaf($$,")");add_leaf($$,";");}
                    | FOR PARENTHESIS_OPEN expression_opt SEMICOLON expression_opt SEMICOLON expression_opt PARENTHESIS_CLOSE statement
                    { $$=create_node("iteration-statement");add_leaf($$,"for");add_leaf($$,"(");add_child($$,$3);add_leaf($$,";");add_child($$,$5);add_leaf($$,";");add_child($$,$7);add_leaf($$,")");add_child($$,$9);}
                    | FOR PARENTHESIS_OPEN declaration expression_opt SEMICOLON expression_opt PARENTHESIS_CLOSE statement
                    { $$=create_node("iteration-statement");add_leaf($$,"for");add_leaf($$,"(");add_child($$,$3);add_child($$,$4);add_leaf($$,";");add_child($$,$6);add_leaf($$,")");add_child($$,$8);}
                    ;

jump_statement:GOTO IDENTIFIER SEMICOLON
                { $$=create_node("jump-statement");add_leaf($$,"goto");add_leaf($$,"identifier");add_leaf($$,";");}
                | CONTINUE SEMICOLON
                { $$=create_node("jump-statement");add_leaf($$,"continue");add_leaf($$,";");}
                | BREAK SEMICOLON
                { $$=create_node("jump-statement");add_leaf($$,"break");add_leaf($$,";");}
                | RETURN expression_opt SEMICOLON
                { $$=create_node("jump-statement");add_leaf($$,"return");add_child($$,$2);add_leaf($$,";");}
                ;

// external definitions
translation_unit:external_declaration { $$=create_node("translation-unit");add_child($$,$1);}
                |translation_unit external_declaration { $$=create_node("translation-unit");add_child($$,$1);add_child($$,$2);}
                ;

external_declaration:function_definition { $$=create_node("external-declaration");add_child($$,$1);}
                    |declaration { $$=create_node("external-declaration");add_child($$,$1);}
                    ;

function_definition:declaration_specifiers declarator declaration_list_opt compound_statement { $$=create_node("function-definition");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);}
                    ;
declaration_list:declaration { $$=create_node("declaration-list");add_child($$,$1);}
                |declaration_list declaration { $$=create_node("declaration-list");add_child($$,$1);add_child($$,$2);}
                ;

// optional

init_declarator_list_opt: {$$=create_node("init-declarator-list-opt"); add_leaf($$,"epsilon");} 
                        |init_declarator_list { $$=create_node("init-declarator-list-opt");add_child($$,$1);}
                        ;

expression_opt: {$$=create_node("expression-opt"); add_leaf($$,"epsilon");}
                |expression { $$=create_node("expression-opt");add_child($$,$1);}
                ;

declaration_specifiers_opt: {$$=create_node("declaration-specifiers-opt"); add_leaf($$,"epsilon");}
                            |declaration_specifiers { $$=create_node("declaration-specifiers-opt");add_child($$,$1);}
                            ;
                            
specifier_qualifier_list_opt: {$$=create_node("specifier-qualifier-list-opt"); add_leaf($$,"epsilon");}
                            |specifier_qualifier_list { $$=create_node("specifier-qualifier-list-opt");add_child($$,$1);}
                            ;

pointer_opt: {$$=create_node("pointer-opt"); add_leaf($$,"epsilon");}
            |pointer { $$=create_node("pointer-opt");add_child($$,$1);}
            ;

type_qualifier_list_opt: {$$=create_node("type-qualifier-list-opt"); add_leaf($$,"epsilon");}
                        |type_qualifier_list { $$=create_node("type-qualifier-list-opt");add_child($$,$1);}
                        ;

assignment_expression_opt: {$$=create_node("assignment-expression-opt"); add_leaf($$,"epsilon");}
                        |assignment_expression { $$=create_node("assignment-expression-opt");add_child($$,$1);}
                        ;

identifier_list_opt: {$$=create_node("identifier-list-opt"); add_leaf($$,"epsilon");}
                    |identifier_list { $$=create_node("identifier-list-opt");add_child($$,$1);}
                    ;

designation_opt: {$$=create_node("designation-opt"); add_leaf($$,"epsilon");}
                |designation { $$=create_node("designation-opt");add_child($$,$1);}
                ;

argument_expression_list_opt: {$$=create_node("argument-expression-list-opt"); add_leaf($$,"epsilon");}
                            |argument_expression_list { $$=create_node("argument-expression-list-opt");add_child($$,$1);}
                            ;

block_item_list_opt: {$$=create_node("block-item-list-opt"); add_leaf($$,"epsilon");}
                    |block_item_list { $$=create_node("block-item-list-opt");add_child($$,$1);}
                    ;

declaration_list_opt: {$$=create_node("declaration-list-opt"); add_leaf($$,"epsilon");}
                    |declaration_list { $$=create_node("declaration-list-opt");add_child($$,$1);}
                    ;
%%

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n%s\n", s, yytext);
}