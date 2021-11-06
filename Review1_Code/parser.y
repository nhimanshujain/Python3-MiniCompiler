%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#define SIZE 20

	int yylex();
	void yyerror(char *s);

	extern int yylineno;

	typedef struct list
	{
	    int lineno;
	    struct list* next;
	}list;

	typedef struct SymbolTable
	{	// a = 10
	    char* name;  		// a
	    char* datatype;		// INT
	    char* value;		// 10
	    list* line;			// 1
	}SymbolTable;

	SymbolTable* symTable[SIZE];

	// Retrieve hash index into the table
	int tableIndex(char* name)
	{
	    return strlen(name) % SIZE;
	}

	// Traversing list (Singly Linked List)
	void disp_line(list *l)
	{
	    list* p=l;
	    printf("\t [%d",l->lineno);
	    while(p->next!=NULL)
	    {
	        p=p->next;
	        printf(",%d",p->lineno);
	    }
	    printf("]\n");
	    return;
	}

	// Display the symbol table
	void display()
	{
	    int i = 0;
	    printf("\t NAME\t DATATYPE\t VALUE\t LINENO\n\n");
	    for(i = 0; i<SIZE; i++)
	    {
	        if(symTable[i] != NULL)
	        {
	            printf("\t %s\t %s\t\t %s ",symTable[i]->name,symTable[i]->datatype,symTable[i]->value);
	            disp_line(symTable[i]->line);
	        }
	    }
	    printf("\n");
	}


	// Search if the ST contains the name
	SymbolTable *search(char* name)
	{
	    int index = tableIndex(name);
	    while(symTable[index] != NULL)
	    {
	        if(!strcmp(symTable[index]->name,name))
	            return symTable[index];

	        // Not found -> Increment
	        ++index;
	        index %= SIZE;
	    }
	    return NULL;
	}

	// Line -> Create a node
	list* line_init(int line)
	{
	    list *item = (list*)malloc(sizeof(list));
	    item->lineno=line;
	    item->next=NULL;
	    return item;
	}

	char* string_init(char* str)
	{
	    if(str==NULL)
	        return NULL;
	    char* new = (char*)malloc(sizeof(strlen(str)+1));
	    strcpy(new,str);
	    return new;
	}

	void line_insert(list* l, int line)
	{
	    list* p=l;
	    while(p->next!=NULL)
	    {
	        p=p->next;
	    }
	    p->next=line_init(line);
	    return;
	}

	void insert_exist(SymbolTable* item, char* datatype, char* value, int lineno)
	{
	    char* name=string_init(item->name);
	    int index = tableIndex(name);
	    while(symTable[index] != NULL)
	    {
	        if(!strcmp(symTable[index]->name,name))
	        {

	        	// Value

	        	// Replace the old value
	        	if(symTable[index]->value!=NULL && value!=NULL)
	            	strcpy(symTable[index]->value,value);

	            // Value is not defined
	            else if(value==NULL)
	            {
	                free(symTable[index]->value);
	                symTable[index]->value = NULL;
	            }

	            // Make an Entry of new value
	            else
	            {
	                symTable[index]->value = string_init(value);
	            }

	            // Datatype
	            if(symTable[index]->datatype!=NULL && datatype!=NULL)
	            	strcpy(symTable[index]->datatype,datatype);
	            else if(datatype==NULL)
	            {
	                free(symTable[index]->datatype);
	                symTable[index]->datatype = NULL;
	            }
	            else
	            {
	                symTable[index]->datatype = string_init(datatype);
	            }

	            if(lineno!=-1)
	                line_insert(item->line,lineno);
	            return;
	        }
	        ++index;
	        index %= SIZE;
	    }
	}

	void insert(char* name, char* datatype, char* value, int lineno)
	{
	    SymbolTable* seek = search(name);

	    // Update the table
	    if(seek!=NULL)
	    {
	        insert_exist(seek,datatype,value,lineno);
	        return;
	    }

	    // Make a new entry
	    SymbolTable *item = (SymbolTable*) malloc(sizeof(SymbolTable));
	    item->name=string_init(name);
	    item->datatype=string_init(datatype);
	    item->value=string_init(value);
	    item->line=line_init(lineno);


	    int index = tableIndex(name);

	    // Check for collision
	    while(symTable[index] != NULL && symTable[index]->name != NULL)
	    {
	        ++index;
	        index %= SIZE;
	    }
	    symTable[index] = item;
	}

%}

%locations

%union{ struct{char value[1024]; int type;}ctype; char val[1024];};

%token <ctype> T_From T_EOF T_As T_Lbrace T_Rbrace T_If T_Elif T_Else T_While T_For T_Import T_Print T_List T_Tuple T_Def T_False T_True T_Class T_Continue T_break T_In T_Pass T_Return T_Not T_Or T_And T_Range T_Colon T_Add T_Minus T_Div T_Mod T_Lt T_Lte T_Gt T_Gte T_Asgn T_Neq T_Ba T_Bor T_Xor T_Neg T_Rs T_Ls T_Eq T_Exp T_Mul T_Comma T_Id T_Osb T_Csb T_Elist T_Op T_Cp T_Edict T_Etuple T_Nl T_Num T_String T_Package T_ID T_DD T_WS
%type <ctype> Variable Arithmetic_Exp Arithmetic_Term Arithmetic_Factor Term Constant Range List_Index List_Initialisation List_elements

%right Only_Compound Only_Basic T_Nl
%right No_Else_In_For Lambda T_Else T_Elif
%right No_stmt Basic_Nl
%right Only_Id T_Cp
%%

Prog	: Parsing T_EOF
			{
				printf("VALID\n");
				printf("\n\t\t\t SYMBOL TABLE\n\n");
				YYACCEPT;
			}
			;
Parsing	: T_Nl Parsing
				| Statements
				|
				;
Constant	:	T_Num
					| T_String
					;
Variable	:	T_Id  %prec Only_Id
					;
List_Index	:	T_Id T_Osb Term T_Csb
						;
List_Initialisation	:	T_Osb List_elements T_Csb
										| T_List T_Etuple
										| T_Elist
										;
List_elements	: Constant T_Comma List_elements
							|	T_Id T_Comma List_elements
							| List_Initialisation T_Comma List_elements
							| Constant
							| T_Id
							| List_Initialisation
							;
Range	: T_Range T_Op T_Num T_Cp
			| T_Range T_Op T_Num T_Comma T_Num T_Cp
			| T_Range T_Op T_Num T_Comma T_Num T_Num T_Cp
			;
Iterable	: T_Id
					| Range
					;
Term	:	Variable
			| Constant
			| List_Index
			| Range
			;
Boolean_Exp	:	Boolean_Term T_And Boolean_Term
						| Boolean_Term T_Or Boolean_Term
						| Boolean_Term
						;
Boolean_Term	:	T_False
							|	T_True
							| Arithmetic_Exp T_In Iterable
							| Arithmetic_Exp T_Lt Arithmetic_Exp
							| Arithmetic_Exp T_Lte Arithmetic_Exp
							| Arithmetic_Exp T_Gt Arithmetic_Exp
							| Arithmetic_Exp T_Gte Arithmetic_Exp
							| Arithmetic_Exp T_Neq Arithmetic_Exp
							| Arithmetic_Exp T_Eq Arithmetic_Exp
							| Boolean_Next
							;
Boolean_Next	:	T_Not Boolean_Term
							|	T_Op Boolean_Exp T_Cp
							| T_Op T_Id T_Cp
							| T_Op T_Not T_Id T_Cp
							;
Arithmetic_Exp	: Arithmetic_Exp T_Add Arithmetic_Term
								| Arithmetic_Exp T_Minus Arithmetic_Term
								| Arithmetic_Term
								;
Arithmetic_Term	: Arithmetic_Term T_Mul Arithmetic_Factor
								|	Arithmetic_Term T_Div Arithmetic_Factor
								| Arithmetic_Term T_Mod Arithmetic_Factor
								| Arithmetic_Factor
								;
Arithmetic_Factor	: Term
									|	T_Op Arithmetic_Exp T_Cp
									;
Assignment_Stmt	:	Variable T_Asgn Arithmetic_Exp             {
																																	char buff[3]="INT";
																																	insert($1.value,buff,$3.value,yylineno - 1);
																															}
								|	Variable T_Asgn List_Initialisation					{
																																	char buff[4]="LIST";
																																	insert($1.value,buff,$3.value,yylineno - 1);
																															}
								;

Pass_Stmt	: T_Pass
					;
Import_Stmt	:	T_Import T_Package
						;
Print_Stmt	:	T_Print T_Op Term T_Cp
						;
Break_Stmt	: T_break
						;
Return_Stmt	: T_Return
						;
Expression_Stmt	: Boolean_Exp
								|	Arithmetic_Exp
								;
Basic_Stmt	:	Expression_Stmt
						|	Assignment_Stmt
						| Pass_Stmt
						| Print_Stmt
						| Break_Stmt
						| Return_Stmt
						| Import_Stmt
						;

Suite	: T_Nl T_ID Statements
			;
Statements	:	Basic_Stmt T_Nl T_ID Statements
						| Compound_Stmt T_Nl T_ID Statements
						|	Basic_Stmt T_Nl Statements
						| Compound_Stmt T_Nl Statements
						| Basic_Stmt T_Nl T_ID
						| Basic_Stmt T_Nl		%prec Basic_Nl
						| Compound_Stmt			%prec Only_Compound
						;
Compound_Stmt	: If_Stmt
							|	While_Stmt
							| For_Stmt
							;
While_Stmt	: T_While Boolean_Exp T_Colon Suite
						;
If_Stmt	:	T_If Boolean_Exp T_Colon Suite Elif
					;
Elif	:	T_Elif Boolean_Exp T_Colon Suite Elif
			|	Else
			;
Else	: T_Else T_Colon Suite
			|		%prec Lambda
			;
For_Stmt	: T_For T_Id T_In Iterable T_Colon Suite T_Else T_Colon Suite
					|	T_For T_Id T_In Iterable T_Colon Suite   %prec No_Else_In_For
					;

%%

void yyerror(char *s)
{
	printf("\nSyntax Error at Line %d, Column %d, Value %s\n",  yylineno, yylloc.last_column, yylval.val);
	exit(0);
}

int main()
{
	yyparse();
	display();
	return 0;
}
