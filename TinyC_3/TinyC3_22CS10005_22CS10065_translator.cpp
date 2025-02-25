/**
*  Akshat Pandey - 22CS10005
*  Sahil Asawa - 22CS10065
*  TinyC3 Assignment
*  CXX File
*/

#include "lex.yy.c"
#include <iomanip>

/**
*  Constructor for Symbol class
*/
Symbol::Symbol(string name_, string value_, Symbol_Type *type_, int offset_) : name(name_), value("-"), nested(NULL), offset(0)
{
    type = new Symbol_Type(value_, type_, offset_);
    size = sizeOfType(type);
}

/**
*  Constructor for SymbolTable class
*/
SymbolTable::SymbolTable(string name)
{
    this->name = name;
    this->parent = NULL;
    this->symbolTableCount = 0;
}

/**
*  Constructor for Symbol_Type class
*/
Symbol_Type::Symbol_Type(string type, Symbol_Type *array_type, int width)
{
    this->type = type;
    this->array_type = array_type;
    this->width = width;
}

/**
*  Update the Symbol
*/
Symbol *Symbol::update(Symbol_Type *t)
{
    type = t;
    size = sizeOfType(t);
    return this;
}

/**
*  Update the SymbolTable with new offset values
*/
void SymbolTable::update()
{
    vector<SymbolTable *> newTable;
    int currOffSet = 0;
    for (int i = 0; i < table.size(); i++)
    {
        if (i == 0)
        {
            table[i]->offset = 0;
            currOffSet = table[i]->size;
        }
        else
        {
            table[i]->offset = currOffSet;
            currOffSet = table[i]->offset + table[i]->size;
        }
        if (table[i]->nested != NULL)
        {
            newTable.push_back(table[i]->nested);
        }
    }
    for (SymbolTable *&it : newTable)
    {
        it->update();
    }
}

/** 
*  Lookup for a Symbol in the SymbolTable
*/
Symbol *SymbolTable::lookup(string name)
{
    for (Symbol *sym : table)
    {
        if (sym->name == name)
        {
            return sym;
        }
    }
    Symbol *s = NULL;
    if (this->parent != NULL)
    {
        s = this->parent->lookup(name);
    }
    if (currentSymbolTable == this && s == NULL)
    {
        Symbol *tmp = new Symbol(name);
        table.push_back(tmp);
        return (table.back());
    }
    else if (s != NULL)
    {
        return s;
    }
    return NULL;
}

/**
*  Constructor for quad_element class
*/
quad_element::quad_element(string res_, string arg1_, string op_, string arg2_)
{
    this->result = res_;
    this->arg1 = arg1_;
    this->op = op_;
    this->arg2 = arg2_;
    this->operation = determine_op_type(op_);
}

/**
*  Determine the type of operation in the 3-ADDRESS CODE
*/
quad_element::OperationType quad_element::determine_op_type(string& operation) {
    if (operation == "=") return ASSIGN;
    if (operation == "*=") return DEREF_ASSIGN;
    if (operation == "[]=") return ARRAY_ASSIGN;
    if (operation == "=[]") return ASSIGN_ARRAY;
    if (operation == "goto") return GOTO1;
    if (operation == "param") return PARAM;
    if (operation == "return") return RETURN1;
    if (operation == "call") return CALL;
    if (operation == "label") return LABEL;
    if (operation == "+" || operation == "-" || operation == "*" || operation == "/" ||
        operation == "%" || operation == "^" || operation == "|" || operation == "&" ||
        operation == "<<" || operation == ">>") return BINARY_OP;
    if (operation == "==" || operation == "!=" || operation == "<" || operation == ">" ||
        operation == "<=" || operation == ">=") return REL_OP;
    if (operation == "=&" || operation == "=*" || operation == "=-" || operation == "=~" || 
        operation == "=!") return UNARY_OP;

    return UNKNOWN;
}

/** 
*  Print the quad_element
*/
void quad_element::print_quad() {
    switch (operation) {
        case ASSIGN:
        case DEREF_ASSIGN:
        case ARRAY_ASSIGN:
        case ASSIGN_ARRAY:
            print_assignment();
            break;
        case GOTO1:
            cout << "goto " << result;
            break;
        case PARAM:
            cout << "param " << result;
            break;
        case RETURN1:
            cout << "return " << result;
            break;
        case CALL:
            cout << result << " = call " << arg1 << ", " << arg2;
            break;
        case LABEL:
            cout << result << ": ";
            break;
        case BINARY_OP:
            print_binary_operation();
            break;
        case REL_OP:
            print_relational_operation();
            break;
        case UNARY_OP:
            print_unary_operation();
            break;
        default:
            cout << "Unknown Operator";
            break;
    }
}

/** 
*  Helper functions for specific types of operations
*/
void quad_element::print_assignment() {
    if (operation == ASSIGN) {
        cout << result << " = " << arg1;
    } else if (operation == DEREF_ASSIGN) {
        cout << "*" << result << " = " << arg1;
    } else if (operation == ARRAY_ASSIGN) {
        cout << result << "[" << arg1 << "] = " << arg2;
    } else if (operation == ASSIGN_ARRAY) {
        cout << result << " = " << arg1 << "[" << arg2 << "]";
    }
}

/**
*  Different types of 3-ADDRESS CODE operations helper functions
*/
void quad_element::print_binary_operation() {
    cout << result << " = " << arg1 << " " << op << " " << arg2;
}

void quad_element::print_relational_operation() {
    cout << "if " << arg1 << " " << op << " " << arg2 << " goto " << result;
}

void quad_element::print_unary_operation() {
    cout << result << " " << op << arg1;
}

vector<int> makeList(int val)
{
    vector<int> v(1, val);
    return v;
}

vector<int> merge(vector<int> a, vector<int> b)
{
    for (int x : b)
        a.push_back(x);
    return a;
}

/** 
*  Backpatch the 3-ADDRESS CODE
*/
void backpatch(vector<int> l, int address)
{
    string s = to_string(address);
    for (int x : l)
    {
        QuadList.quads[x].result = s;
    }
}

/**
*  Size of the different types of variables in the Symbol Table
*/
int sizeOfType(Symbol_Type *node)
{
    if (node->type == "void")
    {
        return VOID_SIZE;
    }
    else if (node->type == "char")
    {
        return CHAR_SIZE;
    }
    else if (node->type == "int")
    {
        return INT_SIZE;
    }
    else if (node->type == "float")
    {
        return FLOAT_SIZE;
    }
    else if (node->type == "arr")
    {
        return (node->width) * sizeOfType(node->array_type);
    }
    else if (node->type == "ptr")
    {
        return PTR_SIZE;
    }
    else if (node->type == "func")
    {
        return FUNC_SIZE;
    }
    return 0;
}

/**
*  Generate a temporary variable in the Symbol Table
*/
Symbol *SymbolTable::gentemp(Symbol_Type *type, string value)
{
    string Name = "t" + to_string(currentSymbolTable->symbolTableCount++);
    Symbol *symb = new Symbol(Name);
    symb->type = type;
    symb->value = value;
    symb->size = sizeOfType(type);
    currentSymbolTable->table.push_back(symb);
    return (currentSymbolTable->table.back());
}

/**
 * Convert the type of the Symbol. Takes the Symbol and the type to be converted to as input and returns the converted Symbol.
 */
Symbol *convertType(Symbol *s, string t)
{
    Symbol *tmp = SymbolTable::gentemp(new Symbol_Type(t));
    if (s->type->type == "float")
    {
        if (t == "int")
        {
            emit("=", tmp->name, "float2int(" + s->name + ")");
            return tmp;
        }
        else if (t == "char")
        {
            emit("=", tmp->name, "float2char(" + s->name + ")");
            return tmp;
        }
        return s;
    }
    if (s->type->type == "int")
    {
        if (t == "float")
        {
            emit("=", tmp->name, "int2float(" + s->name + ")");
            return tmp;
        }
        else if (t == "char")
        {
            emit("=", tmp->name, "int2char(" + s->name + ")");
            return tmp;
        }
        return s;
    }
    if (s->type->type == "char")
    {
        if (t == "float")
        {
            emit("=", tmp->name, "char2float(" + s->name + ")");
            return tmp;
        }
        else if (t == "int")
        {
            emit("=", tmp->name, "char2int(" + s->name + ")");
            return tmp;
        }
        return s;
    }
    return s;
}

/**
 * Returns the next instruction number in the 3-ADDRESS CODE
 */
int nextInstr()
{
    return QuadList.quads.size();
}

/**
 * Check if the types of two Symbol_Type are same or not
 */
bool typecheck(Symbol_Type *t1, Symbol_Type *t2)
{
    if (t1 == NULL && t2 == NULL)
    {
        return true;
    }
    else if (t1 == NULL || t2 == NULL)
    {
        return false;
    }
    else if (t1->type != t2->type)
        return false;
    return typecheck(t1->array_type, t2->array_type);
}

/**
 * Check if the types of two Symbol are same or not
 */
bool typecheck(Symbol *a, Symbol *b)
{
    Symbol_Type *t1 = a->type, *t2 = b->type;
    if (typecheck(t1, t2))
    {
        return true;
    }
    else if (a = convertType(a, t2->type))
    {
        return true;
    }
    else if (b = convertType(b, t1->type))
    {
        return true;
    }
    return false;
}

/**
 * Convert an integer to a boolean expression
 */
Expression *IntToBool(Expression *exp)
{
   
    if (exp->type != "bool")
    {
        exp->falselist = makeList(nextInstr());
        emit("==", "", exp->memloc->name, "0");
        exp->truelist = makeList(nextInstr());
        emit("goto", "");
    }
    return exp;
}

/**
 * Convert a boolean to an integer expression
 */
Expression *BoolToInt(Expression *exp)
{
    if (exp->type == "bool")
    {
        exp->memloc = SymbolTable::gentemp(new Symbol_Type("int"));
        backpatch(exp->truelist, nextInstr());
        emit("=", exp->memloc->name, "true");
        emit("goto", to_string(nextInstr() + 1));
        backpatch(exp->falselist, nextInstr());
        emit("=", exp->memloc->name, "false");
    }
    return exp;
}

/**
 * Switch the current Symbol Table
 */
void switchTable(SymbolTable *Table)
{
    currentSymbolTable = Table;
}

/**
 * Check the type of the Symbol_Type
 */
string CheckType(Symbol_Type *t)
{
    if (t == NULL)
    {
        return "null";
    }
    if (t->type == "void" || t->type == "char" || t->type == "int" || t->type == "float" || t->type == "block" || t->type == "func")
    {
        return t->type;
    }
    if (t->type == "ptr")
    {
        return "ptr(" + CheckType(t->array_type) + ")";
    }
    if (t->type == "arr")
    {
        return "arr(" + to_string(t->width) + "," + CheckType(t->array_type) + ")";
    }
    return "unknown";
}

/**
 * Print the Symbol Table
 */
void SymbolTable::print_symbol_table()
{
    cout << endl;
    cout << "Symbol Table: " << name << endl;

    // Header with fixed-width columns
    cout << left << setw(25) << "Name"
         << setw(15) << "Value"
         << setw(20) << "Type"
         << setw(10) << "Size"
         << setw(10) << "Offset"
         << setw(25) << "Nested" << endl;

    cout << string(75, '-') << endl;

    // Print each symbol with proper alignment
    for (Symbol *s : table)
    {
        cout << left << setw(25) << s->name
             << setw(15) << ((s->value == "") ? "-" : s->value)
             << setw(20) << CheckType(s->type)
             << setw(10) << s->size
             << setw(10) << s->offset;

        if (s->nested != NULL)
        {
            cout << setw(25) << s->nested->name << endl;
        }
        else
        {
            cout << setw(25) << "NULL" << endl;
        }
    }

    cout << endl;

    // Recursively print nested symbol tables
    for (Symbol *s : table)
    {
        if (s->nested != nullptr)
        {
            s->nested->print_symbol_table();
        }
    }
}

/**
 * Takes arg1,arg2,result and op as input and creates a new quad_element and appends it to the quad array
 */
void emit(string op, string result, string arg1, string arg2)
{
    QuadList.quads.push_back(quad_element(result, arg1, op, arg2));
}

/**
 * Takes arg1,arg2,result and op as input and creates a new quad_element and appends it to the quad array
 */
void emit(string op, string result, int arg1, string arg2)
{
    QuadList.quads.push_back(quad_element(result, to_string(arg1), op, arg2));
}

/**
 * Takes arg1,arg2,result and op as input and creates a new quad_element and appends it to the quad array
 */
void emit(string op, string result, float arg1, string arg2)
{
    QuadList.quads.push_back(quad_element(result, to_string(arg1), op, arg2));
}

/**
 * Print the quad array
 */
void quad_array::print_quads()
{
    cout << "3-ADDRESS CODE" << endl;
    int count = 0;
    for (quad_element &x : quads)
    {
        if (x.op != "label")
        {
            cout << count << ": ";
            x.print_quad();
        }
        else
        {
            cout << endl
                 << count << " : ";
            x.print_quad();
        }
        cout << endl;
        ++count;
    }
}

int main()
{
    blockcount = 0;
    globalSymbolTable = new SymbolTable("Global");
    currentSymbolTable = globalSymbolTable;
    blockname = "";
    yyparse();
    globalSymbolTable->update();
    QuadList.print_quads();
    globalSymbolTable->print_symbol_table();
}
