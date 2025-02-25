/**
*  Akshat Pandey - 22CS10005
*  Sahil Asawa - 22CS10065
*  TinyC3 Assignment
*  Header File
*/

#include <iostream>
#include <vector>
#include <string>

using namespace std;

/**
*  Forward Declaration of the classes
*  Symbol_Type - Class to store the type of the symbol in the Symbol Table
*  SymbolTable - Class to store the Symbol Table
*  Symbol - Class to store the Symbol in the Symbol Table
*  quad_element - Class to store the quad element
*  quad_array - Class to store the quad array
*/
class Symbol;
class SymbolTable;
class quad_element;
class quad_array;

/**
*  Size Declaration of different data types accomodated in the TinyC language
*  VOID_SIZE - 0
*  CHAR_SIZE - 1
*  INT_SIZE - 4
*  FLOAT_SIZE - 8
*  PTR_SIZE - 4
*  FUNC_SIZE - 0
*/
#define VOID_SIZE 0
#define CHAR_SIZE 1
#define INT_SIZE 4
#define FLOAT_SIZE 8
#define PTR_SIZE 4
#define FUNC_SIZE 0

/**
*  Symbol_Type Class - Class to store the type of the symbol in the Symbol Table
*  Members :
*  type - Type of the symbol
*  array_type - Pointer to the array if the symbol is an array
*  width - Width of the symbol if array else defaulted to 1
*  Functions : 
*  Symbol_Type - Constructor to initialize the type, array_type and width of the symbol
*/
class Symbol_Type
{
public:
    string type;
    Symbol_Type *array_type;
    int width;
    Symbol_Type(string type, Symbol_Type *array_type = NULL, int width = 1);
};

/**
*  SymbolTable Class - Class to store the Symbol Table  
*  Members :
*  head - Pointer to the head of the Symbol Table
*  name - Name of the Symbol Table
*  parent - Pointer to the parent of the Symbol Table
*  symbolTableCount - Count of the number of Symbols in Symbol Tables
*  table - Vector to store the Symbols in the Symbol Table
*  Functions :
*  SymbolTable - Constructor to initialize the name of the Symbol Table
*  lookup - Function to lookup the symbol in the Symbol Table
*  gentemp - Function to generate a temporary symbol
*  print_symbol_table - Function to print the Symbol Table
*  update - Function to update the some Symbol in the Symbol Table
*/
class SymbolTable
{
public:
    static Symbol *head;
    string name;
    SymbolTable *parent;
    int symbolTableCount;
    vector<Symbol*> table;
    SymbolTable(string s="NULL");
    Symbol* lookup(string name);
    static Symbol *gentemp(Symbol_Type* type, string value = "");
    void print_symbol_table();
    void update();
};

/**
*  Symbol Class - Class to store the Symbol in the Symbol Table
*  Members :
*  name - Name of the Symbol
*  type - Pointer to the type of the Symbol
*  value - Value of the Symbol
*  size - Size of the Symbol
*  offset - Offset of the Symbol
*  nested - Pointer to the nested Symbol Table incase of functions
*  Functions :
*  Symbol - Constructor to initialize the name, value, type and offset of the Symbol
*  update - Function to update the type of the Symbol
*/
class Symbol
{
public:
    string name;
    Symbol_Type *type;
    string value;
    int size;
    int offset;
    SymbolTable *nested;
    Symbol(string name="---",string value="int",Symbol_Type* type=NULL,int offset=0);
    Symbol* update(Symbol_Type *type);
};

/**
*  quad_element Class - Class to store the quad element
*  Members :
*  OperationType - Enum to store the type of the operation, all mentioned in the enum
*  op - Operator of the quad element
*  arg1 - Argument 1 of the quad element
*  arg2 - Argument 2 of the quad element
*  result - Result of the quad element
*  operation - Type of the operation
*  Functions :
*  quad_element - Constructor to initialize the result, arg1, op and arg2 of the quad element
*  print_quad - Function to print the quad element as Three Address Code
*  determine_op_type - Function to determine the type of the operation
*  print_assignment - Function to print the assignment operation
*  print_binary_operation - Function to print the binary operation
*  print_relational_operation - Function to print the relational operation
*  print_unary_operation - Function to print the unary operation
*/
class quad_element
{
public:
    enum OperationType {
        ASSIGN,             // "="
        DEREF_ASSIGN,       // "*="
        ARRAY_ASSIGN,       // "[]="
        ASSIGN_ARRAY,       // "=[]"
        GOTO1,              // "goto"
        PARAM,              // "param"
        RETURN1,            // "return"
        CALL,               // "call"
        LABEL,              // "label"
        BINARY_OP,          // Binary Operators: "+", "-", "*", "/", etc.
        REL_OP,             // Relational Operators: "==", "!=", "<", ">", "<=", ">="
        UNARY_OP,           // Unary Operators: "=&", "=*", "=-", "=~", "=!"
        UNKNOWN             // Unknown operator
    };
    string op;
    string arg1;
    string arg2;
    string result;
    OperationType operation;
    quad_element(string res, string arg1, string op = "=", string arg2 = "");
    void print_quad();
    OperationType determine_op_type(string& operation);
    void print_assignment();
    void print_binary_operation();
    void print_relational_operation();
    void print_unary_operation();
};

/**
*  quad_array Class - Class to store the quad array
*  Members :
*  quads - Vector to store the quad elements in order of operations
*  Functions :
*  print_quads - Function to print the quad elements as Three Address Code
*/
class quad_array
{
public:
    vector<quad_element> quads;
    void print_quads();
};

/**
*  overloaded emit functions
*/
void emit(string op, string result, string arg1 = "", string arg2 = "");
void emit(string op, string result, int arg1, string arg2 = "");
void emit(string op, string result, float arg1, string arg2 = "");

/**
*  Expression Class - Class to store the Expressions in the Symbol Table
*  Members :
*  type - Type of the Expression
*  memloc - Pointer to the memory location of operands
*  truelist - List of true values for boolean expressions
*  falselist - List of false values for boolean expressions
*  nextlist - List of next values for statement expressions
*/
class Expression
{
public:
    string type;
    Symbol *memloc;
    vector<int> truelist;
    vector<int> falselist;
    vector<int> nextlist;
};

/**
*  Statement Class - Class to store the Statements in the Symbol Table
*  Members :
*  nextlist - List of next values for statement expressions
*/
class Statement
{
public:
    vector<int> nextlist;
};

/**
*  Array Class - Class to store the Arrays in the Symbol Table
*  Members :
*  isptr - Pointer if "ptr" else arraytype if "arr"
*  memloc - Pointer to the memory location of value
*  arr - Pointer to the array/ptr
*  type - type of array/ptr (specific to multidimensional arrays)
*/
class Array
{
public:
    string isptr;
    Symbol *memloc;
    Symbol *arr;
    Symbol_Type *type;
};

/**
*  Golbal Variables Declaration
*  currentSymbol - Pointer to the current Symbol
*  currentSymbolTable - Pointer to the current Symbol Table
*  globalSymbolTable - Pointer to the global Symbol Table
*  blockcount - Count of the number of blocks
*  QuadList - Pointer to the current quad array
*  blockname - Name of the block
*  currVarType - Type of the current variable
*/
Symbol* currentSymbol;
SymbolTable* currentSymbolTable;
SymbolTable* globalSymbolTable;
int blockcount;
quad_array QuadList;
string blockname;
string currVarType;

/**
*  Helper Functions Declarations
*/
int sizeOfType(Symbol_Type *node);
bool typecheck(Symbol_Type* t1, Symbol_Type* t2);
bool typecheck(Symbol* s1, Symbol* s2);
Symbol* convertType(Symbol* s, string t);
Expression* IntToBool(Expression* exp);
Expression* BoolToInt(Expression* exp);
int nextInstr();
void backpatch(vector<int> list, int instr);
vector<int> makeList(int val);
string CheckType(Symbol_Type * t);
void switchTable(SymbolTable* Table);
vector<int> merge(vector<int> a, vector<int> b);