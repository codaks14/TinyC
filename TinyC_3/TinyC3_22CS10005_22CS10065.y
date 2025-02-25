%{
    /**
    *  Akshat Pandey - 22CS10005
    *  Sahil Asawa - 22CS10065
    *  TinyC3 Assignment
    *  YACC Design
    */
    #include "TinyC3_22CS10005_22CS10065_translator.h"
    void yyerror(const char *s);
    int yylex();
    int yyparse();
%}

%union{
    int val; // integer value
    char * c; // character string value
    Statement * stmt; // statement
    Expression * expr; // expression
    Symbol_Type* point; // Symbol Type
    Symbol *symb; // Symbol
    int instr; // instruction
    int paramCnt; // parameter count
    int temp; // temporary
    char unaryOperator; // unary operator
    Array* arr; // Array
}

%start program

%token PARENTHESIS_OPEN PARENTHESIS_CLOSE SQUARE_OPEN SQUARE_CLOSE DOT PTR_ARR INC DEC BRACE_OPEN BRACE_CLOSE COMMA SIZEOF
%token ADD_OP SUB_OP MUL_OP DIV_OP MOD_OP LEFT_OP RIGHT_OP LESS_THAN_OP GREATER_THAN_OP LESS_THAN_EQUAL_OP GREATER_THAN_EQUAL_OP EQUAL_OP NOT_EQUAL_OP AND_OP XOR_OP OR_OP BITWISE_AND BITWISE_OR EXCLAMATION_OP TILDE_OP
%token QUESTION_MARK COLON EQUAL MUL_EQUAL DIV_EQUAL MOD_EQUAL ADD_EQUAL SUB_EQUAL LEFT_OP_EQUAL RIGHT_OP_EQUAL AND_EQUAL XOR_EQUAL OR_EQUAL EXTERN STATIC AUTO REGISTER VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED BOOL COMPLEX IMAGINARY CONST RESTRICT VOLATILE INLINE ELLIPSIS
%token CASE DEFAULT SEMICOLON IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN ENUM STRUCT UNION TYPEDEF HASH CMT ERROR
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
// Identifiers  are of type symbol*
%token <symb> IDENTIFIER

// Integer_constant is of type int
%token <val> INTEGER_CONSTANT 
// Floating constant is of type char *
%token <c> FLOATING_CONSTANT CHAR_CONSTANT STRING_LITERAL

// M is of type int
%type <instr> M
// N is of type stmt*
%type <stmt> N  
// Below are of the type symbol*
%type <symb> designation_opt type_qualifier_list_opt specifier_qualifier_list_opt declaration_specifiers_opt declaration declaration_specifiers init_declarator_list init_declarator storage_class_specifier type_specifier specifier_qualifier_list type_qualifier function_specifier declarator direct_declarator type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name initializer initializer_list designation designator_list designator
// Below are of the type expr*
%type <expr>  expression_statement primary_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression AND_expression exclusive_OR_expression inclusive_OR_expression logical_AND_expression logical_OR_expression conditional_expression assignment_expression assignment_operator expression constant_expression
// Below are of the type statement*
%type <stmt> block_item_list_opt statement labeled_statement compound_statement block_item_list block_item selection_statement iteration_statement jump_statement loop_statement
// Below are of the type int
%type <temp> translation_unit external_declaration function_definition declaration_list change_table 
// Below are of the type int 
%type <paramCnt> argument_expression_list_opt argument_expression_list
// Below are of the type Array*
%type <arr> postfix_expression unary_expression cast_expression
// Below are of the type char
%type <unaryOperator> unary_operator
// Below are of the type Symbol_Type*
%type <point> pointer
%%

program:translation_unit {
    /* No Operation */}
        ;

primary_expression:IDENTIFIER 
                    {
                        $$ = new Expression(); // Create new expression
                        $$->memloc= $1; 
                        $$->type="non_bool"; // Set type
                    }
                   | INTEGER_CONSTANT {
                        $$ = new Expression(); // Create new expression
                        $$->memloc= SymbolTable::gentemp(new Symbol_Type("int"),to_string($1)); // Generate temporary
                        emit("=",$$->memloc->name,$1);
                   }
                   | FLOATING_CONSTANT {
                        $$ = new Expression(); // Create new expression
                        $$->memloc= SymbolTable::gentemp(new Symbol_Type("float"),string($1)); // Generate temporary
                        emit("=",$$->memloc->name,string($1));
                   }
                   | CHAR_CONSTANT {
                        $$ = new Expression(); // Create new expression
                        $$->memloc= SymbolTable::gentemp(new Symbol_Type("char"),string($1)); // Generate temporary
                        emit("=",$$->memloc->name,string($1));
                   }
                   | STRING_LITERAL {
                        $$ = new Expression(); // Create new expression
                        $$->memloc = SymbolTable::gentemp(new Symbol_Type("ptr"),$1); // Generate temporary
                        $$->memloc->type->array_type = new Symbol_Type("char");
                   }
                   | PARENTHESIS_OPEN expression PARENTHESIS_CLOSE {
                    
                        $$=$2;
                   }
                   ;

postfix_expression:primary_expression
                   {
                    
                        $$=new Array(); // Create new array
                        $$->arr=$1->memloc; // Assign array
                        $$->type=$1->memloc->type; // Assign type
                        $$->memloc=$$->arr; // Assign memory location
                   }
                   | postfix_expression SQUARE_OPEN expression SQUARE_CLOSE
                   {
                        $$=new Array(); // Create new array
                        $$->type=$1->type->array_type; // Assign type
                        $$->arr=$1->arr;
                        $$->memloc=SymbolTable::gentemp(new Symbol_Type("int"));  // Generate temporary
                        $$->isptr="arr"; // Set isptr

                        if($1->isptr=="arr")
                        {
                            Symbol* symb=SymbolTable::gentemp(new Symbol_Type("int")); // Create new symbol
                            int sz=sizeOfType($$->type); // Get size
                            emit("*",symb->name,$3->memloc->name,to_string(sz)); // Emit code
                            emit("+",$$->memloc->name,$1->memloc->name,symb->name); // Emit code
                        }
                        else
                        {
                            int sz=sizeOfType($$->type); // Get size
                            emit("*",$$->memloc->name,$3->memloc->name,to_string(sz)); // Emit code
                        }
                   }
                   | postfix_expression PARENTHESIS_OPEN argument_expression_list_opt PARENTHESIS_CLOSE
                   { 
                    
                        $$=new Array(); // Create new array
                        $$->arr = SymbolTable::gentemp($1->type); // Generate temporary
                        emit("call",$$->arr->name,$1->arr->name,to_string($3)); // Emit code
                   }
                   | postfix_expression DOT IDENTIFIER
                   {
                    
                        /* No Operation */
                   }
                   | postfix_expression PTR_ARR IDENTIFIER
                   {
                        /* No Operation */
                 }
                   | postfix_expression INC
                   {
                        $$=new Array(); // Create new array
                        $$->arr = SymbolTable::gentemp($1->arr->type); // Generate temporary
                        emit("=",$$->arr->name,$1->arr->name); // Emit code
                        emit("+",$1->arr->name,$1->arr->name,"1"); // Emit code

                   }
                   | postfix_expression DEC
                   {
                        $$=new Array(); // Create new array
                        $$->arr=SymbolTable::gentemp($1->arr->type); // Generate temporary
                        emit("=",$$->arr->name,$1->arr->name); // Emit code
                        emit("-",$1->arr->name,$1->arr->name,"1"); // Emit code
                    }
                   | PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE BRACE_OPEN initializer_list BRACE_CLOSE
                   {
                        /* No Operation */
                     /* No Operation */
                 }
                   | PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE BRACE_OPEN initializer_list COMMA BRACE_CLOSE
                   { 
                        /* No Operation */
                   }
                   ;

argument_expression_list:assignment_expression
                         { 
                              $$ = 1;
                              emit("param",$1->memloc->name);
                         }
                         | argument_expression_list COMMA assignment_expression
                         { 
                              $$ = $1 + 1;
                              emit("param",$3->memloc->name);
                         }
                         ;

unary_expression:postfix_expression
                { 
                    $$ = $1;
                }
                | INC unary_expression
                { 
                    emit("+",$2->arr->name,$2->arr->name,"1"); // Emit code
                    $$ = $2;
                }
                | DEC unary_expression
                { 
                    emit("-",$2->arr->name,$2->arr->name,"1"); // Emit code
                    $$ = $2;
                }
                | unary_operator cast_expression
                { 
                    $$=new Array(); // Create new array
                    if($1=='&')
                    {
                        $$->arr=SymbolTable::gentemp(new Symbol_Type("ptr")); // Generate temporary
                        $$->arr->type->array_type=$2->arr->type; // Assign type
                        emit("=&",$$->arr->name,$2->arr->name); // Emit code
                    }
                    else if($1=='*')
                    { 
                        $$->isptr="ptr"; // Set isptr
                        $$->memloc=SymbolTable::gentemp($2->arr->type->array_type); // Generate temporary
                        $$->arr=$2->arr; 
                        emit("=*",$$->memloc->name,$2->arr->name); // Emit code
                    }
                    else if($1=='+')
                    {
                        $$=$2;
                    }
                    else if($1=='-')
                    {
                        $$->arr=SymbolTable::gentemp(new Symbol_Type($2->arr->type->type)); // Generate temporary
                        emit("=-",$$->arr->name,$2->arr->name); // Emit code
                    }
                    else if($1=='~')
                    {
                        $$->arr=SymbolTable::gentemp(new Symbol_Type($2->arr->type->type)); // Generate temporary
                        emit("=~",$$->arr->name,$2->arr->name); // Emit code
                    }
                    else if($1=='!')
                    {
                        $$->arr=SymbolTable::gentemp(new Symbol_Type($2->arr->type->type)); // Generate temporary
                        emit("=!",$$->arr->name,$2->arr->name); // Emit code
                    }

                }
                | SIZEOF unary_expression
                { /* No Operation */ }
                | SIZEOF PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE
                { /* No Operation */ }
                ;

unary_operator:AND_OP
                { 
                $$ = '&'; }
                | MUL_OP
                { 
                $$ = '*'; }
                | ADD_OP
                { 
                    $$ = '+'; 
                }
                | SUB_OP
                { 
                    
                    $$ = '-'; 
                }
                | TILDE_OP
                { 
                    $$ = '~'; 
                }
                | EXCLAMATION_OP
                { 
                    
                    $$ = '!'; 
                }
                ;

cast_expression:unary_expression
                {
                    
                    $$ = $1;
                }
                | PARENTHESIS_OPEN type_name PARENTHESIS_CLOSE cast_expression
                {
                    $$=new Array(); // Create new array
                    $$->arr=convertType($4->arr,currVarType); // Convert type
                }
                ;

multiplicative_expression:cast_expression
                          {
                            $$=new Expression(); // Create new expression
                            if($1->isptr=="arr")
                            {
                                $$->memloc=SymbolTable::gentemp($1->memloc->type); // Generate temporary
                                emit("=[]",$$->memloc->name,$1->arr->name,$1->memloc->name); // Emit code
                            }
                            else if($1->isptr=="ptr")
                            {
                                $$->memloc=$1->memloc;
                            }
                            else
                            {
                                $$->memloc=$1->arr;
                            }
                          }
                          | multiplicative_expression MUL_OP cast_expression
                          {
                            if(typecheck($1->memloc,$3->arr)){ //checktype
                                $$=new Expression(); // Create new expression
                                $$->memloc=SymbolTable::gentemp(new Symbol_Type($1->memloc->type->type)); // Generate temporary
                                emit("*",$1->memloc->name,$1->memloc->name,$3->arr->name); // Emit code
                            }
                            else
                            {
                               yyerror("Type mismatch");
                            }
                          }
                          | multiplicative_expression DIV_OP cast_expression
                          {
                            if(typecheck($1->memloc,$3->arr)){ //checktype
                                $$=new Expression(); // Create new expression
                                $$->memloc=SymbolTable::gentemp(new Symbol_Type($1->memloc->type->type)); // Generate temporary
                                emit("/",$1->memloc->name,$1->memloc->name,$3->arr->name); // Emit code
                            }
                            else
                            {
                                yyerror("Type mismatch");
                            }
                          }
                          | multiplicative_expression MOD_OP cast_expression
                          {
                            if(typecheck($1->memloc,$3->arr)){ //checktype
                                $$=new Expression(); // Create new expression
                                $$->memloc=SymbolTable::gentemp(new Symbol_Type($1->memloc->type->type)); // Generate temporary
                                emit("%",$1->memloc->name,$1->memloc->name,$3->arr->name); // Emit code
                            }
                            else
                            {
                               yyerror("Type mismatch");
                            }
                          }
                          ;

additive_expression:multiplicative_expression
                    {
                                                $$=$1;
                    }
                    | additive_expression ADD_OP multiplicative_expression
                    {
                        if(typecheck($1->memloc,$3->memloc)) //checks type
                        {
                            $$=new Expression(); // Create new expression
                            $$->memloc=SymbolTable::gentemp(new Symbol_Type($1->memloc->type->type)); // Generate temporary
                            emit("+",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                    }
                    | additive_expression SUB_OP multiplicative_expression
                    {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            $$=new Expression(); // Create new expression
                            $$->memloc=SymbolTable::gentemp(new Symbol_Type($1->memloc->type->type)); // Generate temporary
                            emit("-",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                    }
                    ;

shift_expression:additive_expression
                { 
                    $$ =$1;
                }
                | shift_expression LEFT_OP additive_expression
                {
                    if($3->memloc->type->type=="int") // Check type
                    {
                        $$=new Expression(); // Create new expression
                        $$->memloc=SymbolTable::gentemp(new Symbol_Type("int")); // Generate temporary
                        emit("<<",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                    }
                    else
                    {
                        yyerror("Type mismatch");
                    }
                }
                | shift_expression RIGHT_OP additive_expression
                {
                    if($3->memloc->type->type=="int") // Check type
                    {
                        $$=new Expression(); // Create new expression
                        $$->memloc=SymbolTable::gentemp(new Symbol_Type("int")); // Generate temporary
                        emit(">>",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                    }
                    else
                    {
                        yyerror("Type mismatch");
                    }
                }
                ;

relational_expression:shift_expression
                      {
                        $$=$1;
                      }
                      | relational_expression LESS_THAN_OP shift_expression
                      {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            $$=new Expression(); // Create new expression
                            $$->type = "bool"; // Set type
                            $$->truelist=makeList(nextInstr()); // Make truelist
                            $$->falselist=makeList(nextInstr()+1); // Make falselist
                            emit("<","",$1->memloc->name,$3->memloc->name); // Emit code
                            emit("goto",""); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                      }
                      | relational_expression GREATER_THAN_OP shift_expression
                      {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            $$=new Expression(); // Create new expression
                            $$->type = "bool"; // Set type
                            $$->truelist=makeList(nextInstr()); // Make truelist
                            $$->falselist=makeList(nextInstr()+1); // Make falselist
                            emit(">","",$1->memloc->name,$3->memloc->name); // Emit code
                            emit("goto",""); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                      }
                      | relational_expression LESS_THAN_EQUAL_OP shift_expression
                      {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            $$=new Expression(); // Create new expression
                            $$->type = "bool"; // Set type
                            $$->truelist=makeList(nextInstr()); // Make truelist
                            $$->falselist=makeList(nextInstr()+1); // Make falselist
                            emit("<=","",$1->memloc->name,$3->memloc->name); // Emit code
                            emit("goto",""); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                      }
                      | relational_expression GREATER_THAN_EQUAL_OP shift_expression
                      {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            $$=new Expression(); // Create new expression
                            $$->type = "bool"; // Set type
                            $$->truelist=makeList(nextInstr()); // Make truelist
                            $$->falselist=makeList(nextInstr()+1); // Make falselist
                            emit(">=","",$1->memloc->name,$3->memloc->name); // Emit code
                            emit("goto",""); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                      }
                      ;

equality_expression:relational_expression
                    {
                        $$=$1;
                    }
                    | equality_expression EQUAL_OP relational_expression
                    {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            BoolToInt($1); // Convert to int
                            BoolToInt($3); // Convert to int
                            $$=new Expression(); // Create new expression
                            $$->type = "bool"; // Set type
                            $$->truelist=makeList(nextInstr()); // Make truelist
                            $$->falselist=makeList(nextInstr()+1); // Make falselist
                            emit("==","",$1->memloc->name,$3->memloc->name); // Emit code
                            emit("goto",""); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }
                    }
                    | equality_expression NOT_EQUAL_OP relational_expression
                    {
                        if(typecheck($1->memloc,$3->memloc)) // Check type
                        {
                            BoolToInt($1); // Convert to int
                            BoolToInt($3);  // Convert to int
                            $$=new Expression(); // Create new expression
                            $$->type = "bool"; // Set type
                            $$->truelist=makeList(nextInstr()); // Make truelist
                            $$->falselist=makeList(nextInstr()+1); // Make falselist
                            emit("!=","",$1->memloc->name,$3->memloc->name); // Emit code
                            emit("goto",""); // Emit code
                        }
                        else
                        {
                            yyerror("Type mismatch");
                        }

                    }
                    ;

AND_expression:equality_expression
                { 
                    $$=$1;
                }
                | AND_expression AND_OP equality_expression
                {
                    if(typecheck($1->memloc, $3->memloc)) // Check type
                    {
                        BoolToInt($1); // Convert to int
                        BoolToInt($3); // Convert to int
                        $$=new Expression(); // Create new expression
                        $$->type="not_bool"; // Set type
                        $$->memloc=SymbolTable::gentemp(new Symbol_Type("int")); // Generate temporary
                        emit("&",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                    }
                    else
                    {
                        yyerror("Type mismatch");
                    }
                }
                ;

exclusive_OR_expression:AND_expression
                        {
                            $$=$1;
                        }
                        | exclusive_OR_expression XOR_OP AND_expression
                        {
                            if(typecheck($1->memloc, $3->memloc)) // Check Type
                            {
                                BoolToInt($1); // Convert to int
                                BoolToInt($3); // Convert to int
                                $$=new Expression(); // Create new expression
                                $$->type="not_bool"; // Set type
                                $$->memloc=SymbolTable::gentemp(new Symbol_Type("int")); // Generate temporary
                                emit("^",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                            }
                            else
                            {
                                yyerror("Type mismatch");
                            }
                        }
                        ;

inclusive_OR_expression:exclusive_OR_expression
                        {
                            $$=$1;
                        }
                        | inclusive_OR_expression OR_OP exclusive_OR_expression
                        {
                            if(typecheck($1->memloc, $3->memloc)) //Check type
                            {
                                BoolToInt($1); // Convert to int
                                BoolToInt($3); // Convert to int
                                $$=new Expression(); // Create new expression
                                $$->type="not_bool"; // Set type
                                $$->memloc=SymbolTable::gentemp(new Symbol_Type("int")); // Generate temporary
                                emit("|",$$->memloc->name,$1->memloc->name,$3->memloc->name); // Emit code
                            }
                            else
                            {
                                yyerror("Type mismatch");
                            }
                         }
                        ;

logical_AND_expression:inclusive_OR_expression
                        { 
                            $$=$1;
                        }
                        | logical_AND_expression BITWISE_AND M inclusive_OR_expression
                        {
                          IntToBool($1); // Convert to bool
                          IntToBool($4);  // Convert to bool
                          $$=new Expression(); // Create new expression
                          $$->type="bool"; // Set type
                          backpatch($1->truelist,$3); // Backpatch
                          $$->truelist=$4->truelist; // Set truelist
                          $$->falselist=merge($1->falselist,$4->falselist); // Merge falselist
                          
                        }
                        ;

logical_OR_expression:logical_AND_expression
                        {
                            $$=$1;
                        }
                        | logical_OR_expression BITWISE_OR M logical_AND_expression
                        {
                            IntToBool($1); // Convert to bool
                            IntToBool($4); // Convert to bool
                            $$=new Expression(); // Create new expression
                            $$->type="bool"; // Set type
                            backpatch($1->falselist,$3); // Backpatch
                            $$->falselist=$4->falselist; // Set falselist
                            $$->truelist=merge($1->truelist,$4->truelist); // Merge truelist
                        }
                        ;

conditional_expression:logical_OR_expression
                        { 
                            $$=$1;
                        }
                        | logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression
                        { 
                            $$->memloc=SymbolTable::gentemp($5->memloc->type); // Generate temporary
                            $$->memloc->update($5->memloc->type); // Update type
                            emit("=", $$->memloc->name, $9->memloc->name); // Emit code
                            vector<int> list1=makeList(nextInstr()); // Make list
                            emit("goto",""); // Emit code
                            backpatch($6->nextlist,nextInstr()); // Backpatch
                            emit("=", $$->memloc->name, $5->memloc->name); // Emit code
                            vector<int> list2=makeList(nextInstr()); // Make list
                            list1=merge(list1,list2); // Merge list
                            emit("goto",""); // Emit code
                            backpatch($2->nextlist,nextInstr()); // Backpatch
                            IntToBool($1); // Convert to bool
                            backpatch($1->truelist,$4); // Backpatch
                            backpatch($1->falselist,$8); // Backpatch
                            backpatch(list1,nextInstr()); // Backpatch
                        }
                        ;

M : 
        {
            $$=nextInstr(); // Get next instruction

        }

N : 
        {
            $$=new Statement(); // Create new statement
            $$->nextlist=makeList(nextInstr()); // Make nextlist
            emit("goto",""); // Emit code
        }

assignment_expression:conditional_expression
                        { 
                            $$=$1;
                        }
                        | unary_expression assignment_operator assignment_expression
                        {
                            if($1->isptr=="arr") // Check Type
                            {
                                $3->memloc=convertType($3->memloc,$1->type->type); // Convert type
                                emit("[]=",$1->arr->name,$1->memloc->name,$3->memloc->name); // Emit code
                            }
                            else if($1->isptr=="ptr")
                            {
                                emit("*=",$1->arr->name,$3->memloc->name); // Emit code
                            }
                            else
                            {
                                $3->memloc=convertType($3->memloc,$1->arr->type->type); // Convert type
                                emit("=",$1->arr->name,$3->memloc->name); // Emit code
                            }
                            $$=$3;
                        }
                        ;

assignment_operator:EQUAL
                    { 
                        /* No Operation */
                    }
                    | MUL_EQUAL
                    { 
                        /* No Operation */
                    }
                    | DIV_EQUAL
                    { 
                        /* No Operation */
                    }
                    | MOD_EQUAL
                    { 
                        /* No Operation */
                    }
                    | ADD_EQUAL
                    { 
                        /* No Operation */
                    }
                    | SUB_EQUAL
                    { 
                        /* No Operation */
                    }
                    | LEFT_OP_EQUAL
                    { 
                        /* No Operation */
                    }
                    | RIGHT_OP_EQUAL
                    { 
                        /* No Operation */
                    }
                    | AND_EQUAL
                    { 
                        /* No Operation */
                    }
                    | XOR_EQUAL
                    { 
                        /* No Operation */
                    }
                    | OR_EQUAL
                    { 
                        /* No Operation */
                    }
                    ;

expression:assignment_expression
            {
                $$=$1;
            }
            | expression COMMA assignment_expression
            { 
                /* No Operation */
            }
            ;

constant_expression:conditional_expression
                    { 
                        /* No Operation */
                    };
                   

// declarations

declaration:declaration_specifiers init_declarator_list SEMICOLON 
            { 
                /* No Operation */ }
            |declaration_specifiers SEMICOLON {
                /* No Operation */ 
            }
            ;

declaration_specifiers:storage_class_specifier declaration_specifiers_opt { 
    /* No Operation */ }
                        |type_specifier declaration_specifiers { 
                             /* No Operation */ 
                            }
                        |type_specifier { 
                             /* No Operation */ }
                        |type_qualifier declaration_specifiers_opt {
                            
                             /* No Operation */ }
                        |function_specifier declaration_specifiers_opt { 
                             /* No Operation */ }
                        ;

init_declarator_list:init_declarator {  /* No Operation */ }
                    |init_declarator_list COMMA init_declarator {
                     /* No Operation */ }
                    ;

init_declarator:declarator { 
                    $$ = $1;
                }   
                |declarator EQUAL initializer { 
                    if($3->value != "")
                    {
                        $1->value = $3->value;
                    }
                    emit("=", $1->name, $3->name); // Emit code
                }
                ;

storage_class_specifier:EXTERN { 
    /* No Operation */ }
                        |STATIC { 
                            /* No Operation */ 
                            }
                        |AUTO { 
                            /* No Operation */ }
                        |REGISTER { 
                            /* No Operation */ }
                        ;

type_specifier:VOID { 
    currVarType = "void"; }
                |CHAR { 
                    currVarType = "char"; }
                |SHORT { 
                    /* No Operation */ }
                |INT {  currVarType = "int"; }
                |LONG { 
                    /* No Operation */ }
                |FLOAT { 
                    currVarType = "float"; }
                |DOUBLE { 
                    /* No Operation */ }
                |SIGNED { 
                    /* No Operation */ }
                |UNSIGNED { 
                    /* No Operation */ }
                |BOOL { 
                    /* No Operation */ }
                |COMPLEX { 
                    /* No Operation */ }
                |IMAGINARY { 
                    /* No Operation */ }
                ;

specifier_qualifier_list:type_specifier specifier_qualifier_list_opt {
/* No Operation */ }
                        |type_qualifier specifier_qualifier_list_opt { 
                            /* No Operation */ }
                        ;

type_qualifier:CONST { 
/* No Operation */ }
                |RESTRICT { 
                /* No Operation */ }
                |VOLATILE {
                 /* No Operation */ }
                ;

function_specifier:INLINE { 
/* No Operation */ }
                ;

declarator:pointer direct_declarator { 
                Symbol_Type* tmp = $1;
                while(tmp->array_type != NULL)
                {
                    tmp = tmp->array_type;
                }
                tmp->array_type = $2->type; // Set array type
                $$=$2->update($1); // Update
            }
            | direct_declarator {
                /* No Operation */
            }
            ;

direct_declarator:IDENTIFIER { 
                    $$ = $1->update(new Symbol_Type(currVarType)); // Update
                    currentSymbol=$$;  // Set current symbol
                }
                |PARENTHESIS_OPEN declarator PARENTHESIS_CLOSE { 
                    $$ = $2; }
                |direct_declarator SQUARE_OPEN type_qualifier_list assignment_expression SQUARE_CLOSE{
                    /* No Operation */
                }
                |direct_declarator SQUARE_OPEN type_qualifier_list SQUARE_CLOSE{
                    /* No Operation */
                }
                |direct_declarator SQUARE_OPEN assignment_expression SQUARE_CLOSE{
                    Symbol_Type* t = $1->type; // Get type
                    Symbol_Type* prev = NULL;
                    while(t->type == "arr")
                    {
                        prev = t;
                        t = t->array_type;
                    }
                    if(prev == NULL)
                    {
                        int tmp = atoi($3->memloc->value.c_str()); // Get value
                        Symbol_Type* tp = new Symbol_Type("arr", $1->type, tmp); // Create new symbol type
                        $$ = $1->update(tp); // Update
                    }
                    else
                    {
                        int tmp = atoi($3->memloc->value.c_str()); // Get value
                        prev->array_type = new Symbol_Type("arr", t, tmp); // Create new symbol type
                        $$ = $1->update($1->type); // Update
                    }
                }
                |direct_declarator SQUARE_OPEN SQUARE_CLOSE{ 
                    Symbol_Type* t = $1->type, *prev = NULL;
                    while(t->type == "arr")
                    {
                        prev = t;
                        t = t->array_type;
                    }
                    if(prev == NULL)
                    {
                        Symbol_Type* tp = new Symbol_Type("arr", $1->type, 0); // Create new symbol type
                        $$ = $1->update(tp); // Update
                    }
                    else
                    {
                        prev->array_type = new Symbol_Type("arr", t, 0); // Create new symbol type
                        $$ = $1->update($1->type); // Update
                    }
                }
                |direct_declarator SQUARE_OPEN STATIC type_qualifier_list assignment_expression SQUARE_CLOSE{
                    /* No Operation */
                }
                |direct_declarator SQUARE_OPEN STATIC assignment_expression SQUARE_CLOSE{
                    /* No Operation */
                }
                |direct_declarator SQUARE_OPEN type_qualifier_list STATIC assignment_expression SQUARE_CLOSE { 
                    /* No Operation */
                }
                |direct_declarator SQUARE_OPEN type_qualifier_list MUL_OP SQUARE_CLOSE { 
                    /* No Operation */
                }
                |direct_declarator SQUARE_OPEN MUL_OP SQUARE_CLOSE { 
                    /* No Operation */
                }
                |direct_declarator PARENTHESIS_OPEN change_table parameter_type_list PARENTHESIS_CLOSE {  
                    currentSymbolTable->name = $1->name; // Set name
                    if($1->type->type != "void") // Check type
                    {
                        Symbol* s = currentSymbolTable->lookup("return"); // Lookup
                        s->update($1->type); // Update
                    }
                    $1->nested = currentSymbolTable; // Set nested
                    currentSymbolTable->parent = globalSymbolTable; // Set parent
                    switchTable(globalSymbolTable); // Switch table
                    currentSymbol = $$; // Set current symbol
                }
                |direct_declarator PARENTHESIS_OPEN identifier_list PARENTHESIS_CLOSE {  
                    /* No Operation */
                }
                |direct_declarator PARENTHESIS_OPEN change_table PARENTHESIS_CLOSE {  
                    currentSymbolTable->name = $1->name; // Set name
                    if($1->type->type != "void") // Check type
                    {
                        Symbol* s = currentSymbolTable->lookup("return"); // Lookup
                        s->update($1->type); // Update
                    }
                    $1->nested = currentSymbolTable; // Set nested
                    currentSymbolTable->parent = globalSymbolTable; // Set parent
                    switchTable(globalSymbolTable); // Switch table
                    currentSymbol = $$; // Set current symbol
                }
                ;

pointer:MUL_OP type_qualifier_list_opt 
        { 
            $$ = new Symbol_Type("ptr"); // Create new symbol type
        }
        |MUL_OP type_qualifier_list_opt pointer 
        { 
            $$ = new Symbol_Type("ptr",$3); // Create new symbol type
        }
        ;

type_qualifier_list:type_qualifier 
                    { 
                        /* No Operation */
                    }
                    |type_qualifier_list type_qualifier 
                    { 
                        /* No Operation */
                    }
                    ;

parameter_type_list:parameter_list 
                    { 
                        /* No Operation */
                    }
                    |parameter_list COMMA ELLIPSIS 
                    { 
                        /* No Operation */
                    }
                    ;

parameter_list:parameter_declaration 
                { 
                    /* No Operation */
                }
                |parameter_list COMMA parameter_declaration 
                {  
                    /* No Operation */
                }
                ;

parameter_declaration:declaration_specifiers declarator 
                        { 
                            /* No Operation */
                        }
                    |declaration_specifiers 
                    { 
                        /* No Operation */
                    }
                    ;

identifier_list:IDENTIFIER 
                { 
                    /* No Operation */
                }
                |identifier_list COMMA IDENTIFIER 
                { 
                    /* No Operation */
                }
                ;

type_name:specifier_qualifier_list 
            { 
                /* No Operation */
            }
            ;

initializer:assignment_expression 
            { 
                $$ = $1->memloc; // Assignment
            }
            |BRACE_OPEN initializer_list BRACE_CLOSE 
            { 
                /* No Operation */
            }
            |BRACE_OPEN initializer_list COMMA BRACE_CLOSE 
            { 
                /* No Operation */
            }
            ;

initializer_list:designation_opt initializer 
                { 
                    /* No Operation */
                }
                |initializer_list COMMA designation_opt initializer 
                { 
                    /* No Operation */
                }
                ;

designation:designator_list EQUAL 
            { 
                /* No Operation */
            }
            ;

designator_list:designator 
            {   
                /* No Operation */
            }
            |designator_list designator 
            { 
                /* No Operation */
            }
            ;

designator: SQUARE_OPEN INTEGER_CONSTANT expression SQUARE_CLOSE 
            { 
                /* No Operation */
            }
            | SQUARE_OPEN FLOATING_CONSTANT expression SQUARE_CLOSE 
            { 
                /* No Operation */
            }
            | SQUARE_OPEN CHAR_CONSTANT expression SQUARE_CLOSE 
            { 
                /* No Operation */
            }
            | DOT IDENTIFIER 
            { 
                /* No Operation */
            }
            ;


// statements
statement: labeled_statement
            { 
                /* No Operation */
            }
            | compound_statement
            { 
                $$=$1; // Simple assignment
            }
            | expression_statement
            { 
                $$ = new Statement(); // Create new statement
                $$->nextlist = $1->nextlist; // Assign nextlist
            }
            | selection_statement
            { 
                $$=$1; // Simple assignment
            }
            | iteration_statement
            { 
                $$=$1; // Simple assignment
            }
            | jump_statement
            {   
                $$=$1; // Simple assignment
            }
            ;

loop_statement:
        labeled_statement
        { /* No Operation */ }
        | expression_statement
        {
            $$ = new Statement();           // Create new statement
            $$->nextlist = $1->nextlist;    // Assign same nextlist
        }
        | selection_statement
        {
            $$ = $1; // Simple assignment
        }
        | iteration_statement
        {
            $$ = $1; // Simple assignment
        }
        | jump_statement
        {
            $$ = $1; // Simple assignment
        }
        ;

labeled_statement:IDENTIFIER COLON statement
                    { 
                        /* No Operation */ }
                    | CASE constant_expression COLON statement
                    { 
                        /* No Operation */ }
                    | DEFAULT COLON statement
                    {   
                        /* No Operation */ }
                    ;

compound_statement:BRACE_OPEN X change_table block_item_list_opt BRACE_CLOSE
                    { 
                        $$=$4; // Simple assignment
                        switchTable(currentSymbolTable->parent); // Switch table
                    }
                    ;

block_item_list:block_item
                { 
                    $$ = $1; // Simple assignment
                }
                | block_item_list M block_item
                { 
                    $$=$3; // Simple assignment
                    backpatch($1->nextlist,$2); // Backpatch nextlist
                }
                ;

block_item:declaration
            { 
                $$ = new Statement(); // Create new statement
            }
            | statement
            { 
                $$ = $1; // Simple assignment
            }
            ;

expression_statement:expression SEMICOLON
                    { 
                        $$=$1; // Simple assignment
                    }
                    |SEMICOLON
                    {
                        $$ = new Expression(); // Create new expression
                    }
                    ;

selection_statement:IF PARENTHESIS_OPEN expression N PARENTHESIS_CLOSE M statement N %prec LOWER_THAN_ELSE
                    {
                        backpatch($4->nextlist,nextInstr()); // Backpatch nextlist
                        IntToBool($3); // Convert to bool
                        $$=new Statement(); // Create new statement
                        backpatch($3->truelist,$6); // Backpatch truelist
                        vector<int> temp=merge($3->falselist,$7->nextlist); // Merge nextlist
                        $$->nextlist=merge($8->nextlist,temp); // Merge nextlist
                    }
                    | IF PARENTHESIS_OPEN expression N PARENTHESIS_CLOSE M statement N ELSE M statement
                    { 
                        backpatch($4->nextlist,$6); // Backpatch
                        IntToBool($3); // Convert to bool
                        $$=new Statement(); // Create new statement
                        backpatch($3->truelist,$6); // Backpatch truelist
                        backpatch($3->falselist,$10); // Backpatch falselist
                        vector<int> temp=merge($7->nextlist,$8->nextlist); // Merge nextlist
                        $$->nextlist=merge($11->nextlist,temp); // Merge nextlist
                    }
                    | SWITCH PARENTHESIS_OPEN expression PARENTHESIS_CLOSE statement
                    { 
                        /* No Operation */
                    }
                    ;
                    
iteration_statement:WHILE W PARENTHESIS_OPEN X change_table M expression PARENTHESIS_CLOSE M loop_statement
                    { 
                        $$=new Statement(); // Create new statement
                        IntToBool($7); // Convert to bool
                        backpatch($10->nextlist,$6); // Backpatch nextlist
                        backpatch($7->truelist,$9); // Backpatch truelist
                        $$->nextlist=$7->falselist; // Set nextlist
                        emit("goto",to_string($6)); // Emit code
                        blockname=""; // Set blockname
                        switchTable(currentSymbolTable->parent); // Switch table

                    }
                    |WHILE W PARENTHESIS_OPEN X change_table M expression PARENTHESIS_CLOSE BRACE_OPEN M block_item_list_opt BRACE_CLOSE
                    {
                        $$ = new Statement(); // Create new statement
                        IntToBool($7); // Convert to bool
                        backpatch($11->nextlist,$6); // Backpatch nextlist
                        backpatch($7->truelist,$10); // Backpatch truelist
                        $$->nextlist=$7->falselist; // Set nextlist
                        emit("goto",to_string($6)); // Emit code
                        blockname=""; // Set blockname
                        switchTable(currentSymbolTable->parent); // Switch table
                    }
                    | DO D M loop_statement M WHILE PARENTHESIS_OPEN expression PARENTHESIS_CLOSE SEMICOLON
                    { 
                        $$=new Statement(); // Create new statement
                        IntToBool($8); // Convert to bool
                        backpatch($8->truelist,$3); // Backpatch truelist
                        backpatch($4->nextlist,$5); // Backpatch nextlist
                        $$->nextlist=$8->falselist; // Set nextlist
                        blockname=""; // Set blockname
                    }
                    |DO D BRACE_OPEN M block_item_list_opt BRACE_CLOSE M WHILE PARENTHESIS_OPEN expression PARENTHESIS_CLOSE SEMICOLON
                    {
                        $$ = new Statement(); // Create new statement
                        IntToBool($10); // Convert to bool
                        backpatch($10->truelist,$4); // Backpatch truelist
                        backpatch($5->nextlist,$7); // Backpatch nextlist
                        $$->nextlist=$10->falselist; // Set nextlist
                        blockname=""; // Set blockname
                    }
                    |FOR F PARENTHESIS_OPEN X change_table declaration M expression_statement M expression N PARENTHESIS_CLOSE M loop_statement
                    {
                        $$=new Statement(); // Create new statement
                        IntToBool($8); // Convert to bool
                        backpatch($8->truelist,$13); // Backpatch truelist
                        backpatch($11->nextlist,$7); // Backpatch nextlist
                        backpatch($14->nextlist,$9); // Backpatch nextlist
                        emit("goto",to_string($9)); // Emit code
                        $$->nextlist=$8->falselist; // Set nextlist to falselist
                        blockname=""; // Set blockname
                        switchTable(currentSymbolTable->parent); // Set parent 
                    }
                    |FOR F PARENTHESIS_OPEN X change_table expression_statement M expression_statement M expression N PARENTHESIS_CLOSE M loop_statement
                    {
                        $$=new Statement(); // Create new statement
                        IntToBool($8); // Convert to bool
                        backpatch($8->truelist,$13); // Backpatch truelist
                        backpatch($11->nextlist,$7); // Backpatch nextlist
                        backpatch($14->nextlist,$9); // Backpatch nextlist
                        emit("goto",to_string($9)); // Emit code
                        $$->nextlist=$8->falselist; // Set nextlist to falselist
                        blockname=""; // Set blockname
                        switchTable(currentSymbolTable->parent); // Set parent
                    }
                    |FOR F PARENTHESIS_OPEN X change_table declaration M expression_statement M expression N PARENTHESIS_CLOSE M BRACE_OPEN block_item_list_opt BRACE_CLOSE
                    {
                        $$ = new Statement(); // Create new statement
                        IntToBool($8); // Convert to bool
                        backpatch($8->truelist,$13); // Backpatch truelist
                        backpatch($11->nextlist,$7); // Backpatch nextlist
                        backpatch($15->nextlist,$9); // Backpatch nextlist
                        emit("goto",to_string($9)); // Emit code
                        $$->nextlist=$8->falselist; // Set nextlist to falselist
                        blockname=""; // Set blockname
                        switchTable(currentSymbolTable->parent); // Set parent
                    }
                    |FOR F PARENTHESIS_OPEN X change_table expression_statement M expression_statement M expression N PARENTHESIS_CLOSE M BRACE_OPEN block_item_list_opt BRACE_CLOSE
                    {
                        $$ = new Statement(); // Create new statement
                        IntToBool($8); // Convert to bool
                        backpatch($8->truelist,$13); // Backpatch truelist
                        backpatch($11->nextlist,$7); // Backpatch nextlist
                        backpatch($15->nextlist,$9); // Backpatch nextlist
                        emit("goto",to_string($9)); // Emit code
                        $$->nextlist=$8->falselist; // Set nextlist
                        blockname=""; // Set blockname
                        switchTable(currentSymbolTable->parent); // Set parent
                    }
                    ;

F: 
    {
        blockname = "FOR"; // Set blockname to FOR
    }
    ;

W: 
    {
        blockname = "WHILE"; // Set blockname to WHILE
    }
    ;

D: 
    {
        blockname = "DO_WHILE"; // Set blockname to DO_WHILE
    }
    ;

X: 
    {
        string newSt=currentSymbolTable->name + "." + blockname + "$" + to_string(blockcount++); // Create new string
        Symbol* symb=currentSymbolTable->lookup(newSt); // Lookup
        symb->nested=new SymbolTable(newSt); // Create new symbol table
        symb->name=newSt; // Set name
        symb->nested->parent=currentSymbolTable; // Set parent
        symb->type=new Symbol_Type("block"); // Set type
        currentSymbol=symb; // Set current symbol
    }

change_table: 
    {
        if(currentSymbol->nested != NULL)
        {
            switchTable(currentSymbol->nested); // Switch table
            emit("label", currentSymbolTable->name); // Emit code
        }
        else
        {
            switchTable(new SymbolTable("")); // Switch table
        }
    }

jump_statement:GOTO IDENTIFIER SEMICOLON
                { 
                    /* No Operation */ 
                }
                | CONTINUE SEMICOLON
                { 
                    $$ = new Statement(); // Create new statement
                }
                | BREAK SEMICOLON
                { 
                    $$ = new Statement(); // Create new statement
                }
                | RETURN expression SEMICOLON
                { 
                    $$ = new Statement(); // Create new statement
                    emit("return",$2->memloc->name); // Emit code
                }
                | RETURN SEMICOLON 
                { 
                    $$ = new Statement(); // Create new statement
                    emit("return",""); // Emit code
                }
                ;

translation_unit:external_declaration { 
                    /* No Operation */ 
                }
                |translation_unit external_declaration { 
                    /* No Operation */ 
                }
                ;

external_declaration:function_definition { 
                        /* No Operation */ 
                    }
                    |declaration { 
                        /* No Operation */ 
                    }
                    ;

function_definition:declaration_specifiers declarator declaration_list change_table BRACE_OPEN block_item_list_opt BRACE_CLOSE { 
                        currentSymbolTable->parent = globalSymbolTable; // Set parent
                        blockcount = 0; // Reset blockcount
                        switchTable(globalSymbolTable); // Switch table
                    }
                    |declaration_specifiers declarator change_table BRACE_OPEN block_item_list_opt BRACE_CLOSE {
                        currentSymbolTable->parent = globalSymbolTable; // Set parent
                        blockcount = 0; // Reset blockcount
                        switchTable(globalSymbolTable); // Switch table
                    }
                    ;
                    
declaration_list:declaration { 
                    /* No Operation */ 
                }
                |declaration_list declaration { 
                    /* No Operation */ 
                }
                ;


designation_opt: { 
                    /* No Operation */
                }
                |designation { 
                    /* No Operation */
                }
                ;

type_qualifier_list_opt: { 
                            /* No Operation */
                        }
                        |type_qualifier_list { 
                            /* No Operation */
                        }
                        ;



declaration_specifiers_opt: { 
                                /* No Operation */
                            }
                            |declaration_specifiers { 
                                /* No Operation */
                            }
                            ;


specifier_qualifier_list_opt: { 
                                /* No Operation */
                            }
                            |specifier_qualifier_list { 
                                /* No Operation */
                            }
                            ;

argument_expression_list_opt: { 
                                /* No Operation */
                            }
                            |argument_expression_list { 
                                /* No Operation */
                            }
                            ;

block_item_list_opt: { 
                        $$ = new Statement();
                     }
                    |block_item_list 
                    { 
                        $$ = $1;
                    }
                    ;

%%
void yyerror(const char *s)
{
    fprintf(stderr, "%s parsing %s at %d!\n", s, yytext, yylineno);
}