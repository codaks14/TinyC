%{
    #include "y.tab.c"
%}

spaces                  [ \t\r\n]+
line_comment            "//".*
block_comment           "/*"([^\*]|[^\/])*"*/"
comments                {line_comment}|{block_comment}
digit                   [0-9]
identifier_nondigit     [_a-zA-Z]
identifier              {identifier_nondigit}({identifier_nondigit}|{digit})*
integer_constant        {digit}+
sign                    [\+\-]
constant                {integer_constant}|{floating_constant}|{char_constant}
exponent_part           [eE]{sign}?{digit_sequence}
fractional_constant     {digit_sequence}?\.{digit_sequence}|{digit_sequence}\.
floating_constant       {fractional_constant}{exponent_part}?|{digit_sequence}{exponent_part}
digit_sequence          {digit}+
char_constant           \'{c_char}\'
c_char                  [^\'\n\\]|{escape_sequence}
escape_sequence         \\[abfnrtv\'\"\?\\]
string_literal          \"{s_char_sequence}?\"
s_char_sequence         {s_char}+
s_char                  [^\"\n\\]|{escape_sequence}
errors                  .

%%

{comments}           { }
{spaces}             { }

"auto"                          { return AUTO; }
"break"                         { return BREAK; }
"case"                          { return CASE; }
"char"                          { return CHAR; }
"const"                         { return CONST; }
"continue"                      { return CONTINUE; }
"default"                       { return DEFAULT; }
"do"                            { return DO; }
"double"                        { return DOUBLE; }
"else"                          { return ELSE; }
"enum"                          { return ENUM; }             
"extern"                        { return EXTERN; }
"float"                         { return FLOAT; }
"for"                           { return FOR; }
"goto"                          { return GOTO; }
"if"                            { return IF; }
"inline"                        { return INLINE; }
"int"                           { return INT; }
"long"                          { return LONG; }
"register"                      { return REGISTER; }
"restrict"                      { return RESTRICT; }
"return"                        { return RETURN; }
"short"                         { return SHORT; }
"signed"                        { return SIGNED; }
"sizeof"                        { return SIZEOF; }
"static"                        { return STATIC; }
"struct"                        { return STRUCT; }
"switch"                        { return SWITCH; }
"typedef"                       { return TYPEDEF; }
"union"                         { return UNION; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOID; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return BOOL; }
"_Complex"                      { return COMPLEX; }
"_Imaginary"                    { return IMAGINARY; }
"["                   {return SQUARE_OPEN;}
"]"                   {return SQUARE_CLOSE;}
"("                   {return PARENTHESIS_OPEN;}
")"                   {return PARENTHESIS_CLOSE;}
"{"                   {return BRACE_OPEN;}
"}"                   {return BRACE_CLOSE;}
"."                   {return DOT;}
"->"                  {return PTR_ARR;}
"++"                  {return INC;}
"--"                  {return DEC;}
"&"                   {return AND_OP;}
"*"                   {return MUL_OP;}
"+"                   {return ADD_OP;}
"-"                   {return SUB_OP;}
"~"                   {return TILDE_OP;}
"!"                   {return EXCLAMATION_OP;}
"/"                   {return DIV_OP;}
"%"                   {return MOD_OP;}
"<<"                  {return LEFT_OP;}
">>"                  {return RIGHT_OP;}
"<"                   {return LESS_THAN_OP;}
">"                   {return GREATER_THAN_OP;}
"<="                  {return LESS_THAN_EQUAL_OP;}
">="                  {return GREATER_THAN_EQUAL_OP;}
"=="                  {return EQUAL_OP;}
"!="                  {return NOT_EQUAL_OP;}
"^"                   {return XOR_OP;}
"|"                   {return OR_OP;}
"&&"                  {return BITWISE_AND;}
"||"                  {return BITWISE_OR;}
"?"                   {return QUESTION_MARK;}
":"                   {return COLON;}
";"                   {return SEMICOLON;}
"..."                 {return ELLIPSIS;}
"="                   {return EQUAL;}
"*="                  {return MUL_EQUAL;}
"/="                  {return DIV_EQUAL;}
"%="                  {return MOD_EQUAL;}
"+="                  {return ADD_EQUAL;}
"-="                  {return SUB_EQUAL;}
"<<="                 {return LEFT_OP_EQUAL;}
">>="                 {return RIGHT_OP_EQUAL;}
"&="                  {return AND_EQUAL;}
"^="                  {return XOR_EQUAL;}
"|="                  {return OR_EQUAL;}
","                   {return COMMA;}
"#"                   {return HASH;}

{identifier}         { return IDENTIFIER; }
{constant}           { return CONSTANT; }
{string_literal}     { return STRING_LITERAL; }
{errors}             { return ERROR; }




%%

int yywrap() {
    return 1;
}
