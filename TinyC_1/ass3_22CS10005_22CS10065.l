%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR           1
#define ID              2
#define KW              3
#define CONS            4
#define STR             5
#define PUNC            6
#define CMT             7

%}

spaces                  [ \t\r\n]+
digit                   [0-9]
identifier_nondigit     [_a-zA-Z]
identifier              {identifier_nondigit}({identifier_nondigit}|{digit})*
keyword                 auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|inline|int|long|register|restrict|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|_Bool|_Complex|_Imaginary
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
punctuators             "["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"
comments                {line_comment}|{block_comment}
line_comment            \/\/{c_char}*
block_comment           "/*"{c_char}*?"*/"
errors                  .

%%
{spaces}             { }
{keyword}            { return KW; }
{identifier}         { return ID; }
{constant}           { return CONS; }
{string_literal}     { return STR; }
{punctuators}        { return PUNC; }
{comments}           { return CMT; }
{errors}             { return ERROR; }
%%

int yywrap() {
    return 1;
}