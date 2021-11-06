%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include "indent.h"
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

	typedef struct Quadraple{
		char Operator[10];
		char Arg1[10];
		char Arg2[10];
		char Result[100];
		struct Quadraple *next;	
	}Q;

	typedef struct imports{

		char module[20];
		int usage_count ;
		int node_number;

	}imports;

	Q* delete_node(Q* head , int node_number)
	{
		if(head==NULL)
		{
			return NULL;
		}

		if(node_number == 1)
		{
			head = head->next ;
			return head;
		}

		int stopper = 1;

		Q* temp = head;

		while(stopper < node_number - 1)
		{
			temp = temp->next;
		}

		temp->next = temp->next->next;
		return head;

	}


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
	    printf("\t NAME\t   DATATYPE\t VALUE\t\t LINENO\n\n");
	    for(i = 0; i<SIZE; i++)
	    {
	        if(symTable[i] != NULL)
	        {
	            printf("\t %s\t   %s\t\t %s      ",symTable[i]->name,symTable[i]->datatype,symTable[i]->value);
	            disp_line(symTable[i]->line);
	        }
	    }

	    printf("\nNote : The line number of temporaries is wrt 3AC\n");
	    printf("\n");
	}

	Q *first=NULL;
	int t = 1, label = 1, p = -1, q = -1, st[100];


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

	void Pop_Tabspaces()
	{
		while(top(&tab_stack)!=-1)
		{
			pop(&tab_stack);
		}
	}

	void Pop_Tabspaces_and_DD()
	{
		if(top(&tab_stack)!=-1)
		{
			p = p + 1;
			st[p] = 1;
		}
		else
		{
			p = p + 1;
			st[p] = 0;
		}
		Pop_Tabspaces();
	}

	
	Q *Insert_into_Q(char *Op, char *arg1, char *arg2, char *res)
	{
		Q *temp = (Q *)malloc(sizeof(Q));
		strcpy(temp->Operator, Op);
		strcpy(temp->Arg1, arg1);
		strcpy(temp->Arg2, arg2);
		strcpy(temp->Result, res);
		temp->next = NULL;
		return temp;
	}

	void TAC_display(Q* first)
	{
		Q *temp = first;
		
		int i = 1;
		printf("\n\n-------------Three Address Code in Quadraple Format-------------\n");
		printf("\n\t\tOp\tArg1\tArg2\tRes\n");
		while(temp!=NULL)
		{
			printf("\t%d\t%s\t%s\t%s\t%s\n", i, temp->Operator, temp->Arg1, temp->Arg2, temp->Result);
			temp = temp->next;
			i = i + 1;
		}

		

		printf("\n");
	}

	char *return_Temp()
	{
		char buf[3] = "t";
		char store[5];
		sprintf(store, "%d", t);
		strcat(buf, store);
		char *l = buf;
		t = t + 1;
		return (char *)l;	
	}

	char *return_Label()
	{
		char buf[3] = "L";
		char store[5];
		sprintf(store, "%d", label);
		strcat(buf, store);
		char *l = buf;
		label = label + 1;
		return (char *)l;	
	}

	Q *build_TAC(Q* t1, Q* t2, Q* t4)
	{
		Q *temp;
		if(t1 != NULL && t2 != NULL)
		{
			temp = t1;
			while (temp->next!= NULL)
				temp = temp->next;
			temp -> next = t2;
			temp = t2;
			while (temp->next!= NULL)
				temp = temp->next;
			temp -> next = t4;
			return t1;
		}
		else if(t1 != NULL)
		{
			temp = t1;
			while (temp->next!= NULL)
				temp = temp->next;
			temp -> next = t4;
			return t1;
		}
		else if(t2 != NULL)
		{
			temp = t2;
			while (temp->next!= NULL)
				temp = temp->next;
			temp -> next = t4;
			return t2;
		}
		else
		{
			return t4;
		}
	}

	int multiply(int m , int n)
	{
		int answer = 0, counter = 0;
	    while (m)
	    {
	        // check for set bit and left
	        // shift n, count times
	        if (m % 2 == 1)             
	            answer += n << counter;
	 
	        // increment of place value (count)
	        counter++;
	        //divide m by 2 , aka right shift 
	        m >>= 1;
	    }
	    return answer;

	}
	Q* import_code_eliminate(imports import[] ,int length , Q* head)
	{
		int deletion_node_numbers[10];int i = 0;

		for(int index = 0; index < length; index++)
		{
			if(import[index].usage_count == 0)
			{
				deletion_node_numbers[i++] = import[index].node_number;

				//printf("YEAH HEI INDEX -----%i------",index);
			}
		}

		for(int index = 0; index < i ; index++)
		{
			head = delete_node(head , deletion_node_numbers[index] - index);
		}


		//TAC_display(head);

		return head;



	}

	Q* unreachable_code_eliminate(Q *first)
	{
		Q *temp = first ;
		Q *new_head = temp; 

		while(temp !=NULL)
		{

			if(temp->next && strcmp(temp->next->Operator , "break") == 0 ||strcmp(temp->Operator , "continue")==0 )
			{
					Q* begin = temp->next;

					while (begin && strcmp(begin->Operator,"goto")!=0 )
					{
						begin = begin -> next;
					}

					temp->next = begin;
			}

			temp = temp->next;
		}

		//TAC_display(new_head);

		return new_head;
	}

	Q* loop_skip(Q* head)
	{

		Q *temp = head;
		Q *new_head = temp;

		while(temp)
		{

			//printf("%s\n" , temp->Operator);

			if(temp->next && strcmp(temp->next->Operator , "iffalse") == 0)
			{

				Q* decision_line = temp->next;

				SymbolTable *entry = search(decision_line->Arg1);

				if(strcmp(entry->value , "0") == 0)
				{
					while(decision_line -> next && (strcmp(decision_line->next->Operator,"label")+ strcmp(decision_line->next->Result,temp->next->Result)!=0 ))
					{

						decision_line = decision_line->next;
					}

					temp->next = decision_line->next;
				}
			}

			temp = temp->next;
		}

		return new_head;
	}
	 


	void dead_code_eliminate()
	{
		Q* temp = first;

		imports import[10];
		int imports_count = 0;


		int i = 1;

		while(temp!=NULL)
		{
			//printf("\t%d\t%s\t%s\t%s\t%s\n", i, temp->Operator, temp->Arg1, temp->Arg2, temp->Result);

			if( strcmp(temp->Operator , "import") == 0){

				strcpy(import[imports_count].module , temp->Result);
				import[imports_count].usage_count = 0;
				import[imports_count++].node_number = i;

			}

			for(int import_index = 0; import_index < imports_count; import_index++)
			{


				if( strcmp(temp->Operator , import[import_index].module) == 0)
				{
					import[import_index].usage_count +=1;
				}


			}




			temp = temp->next;
			i = i + 1;


		}

		printf("\n-------------Post Dead Code Elimination -------------\n");

		first = import_code_eliminate(import ,imports_count, first);

		first = unreachable_code_eliminate(first);

		first = loop_skip(first);

		TAC_display(first);


	}



%}

%locations

%union{ struct{char value[1024]; char type[3]; int numval; struct Quadraple *code; struct Quadraple *out; struct Quadraple *out1[10]; char addr[15]; char false[10]; char next[10]; }ctype; char val[1024]; int ID_depth;}; 

%token <ctype> T_From T_EOF T_As T_Lbrace T_Rbrace T_If T_Elif T_Else T_While T_For T_Import T_Print T_List T_Tuple T_Def T_False T_True T_Class T_Continue T_break T_In T_Pass T_Return T_Not T_Or T_And T_Range T_Colon T_Add T_Minus T_Div T_Mod T_Lt T_Lte T_Gt T_Gte T_Asgn T_Neq T_Ba T_Bor T_Xor T_Neg T_Rs T_Ls T_Eq T_Exp T_Mul T_Comma T_Id T_Osb T_Csb T_Elist T_Op T_Cp T_Edict T_Etuple T_Nl T_Num T_String T_Package T_ID T_ND T_DD T_WS

%type <ctype> Variable Arithmetic_Exp Arithmetic_Term Arithmetic_Factor Term Constant Range List_Index List_Initialisation List_elements Boolean_Exp Boolean_Term Boolean_Next Prog Parsing Statements Basic_Stmt Compound_Stmt Expression_Stmt Assignment_Stmt Pass_Stmt Print_Stmt Break_Stmt Return_Stmt If_Stmt While_Stmt For_Stmt Import_Stmt Suite Elif Else Iterable



%left '+' '-'
%left '*' '/'

%right Only_Compound Only_Basic T_Nl
%right No_Else_In_For Lambda T_Else T_Elif
%right No_stmt Basic_Nl
%right Only_Id T_Cp
%right Temp T_DD For_without_T_DD While_without_T_DD Else_without_T_DD
%%

Prog	:	Parsing T_EOF
			{
				printf("\nVALID\n");
				first = $1.code;
				printf("\n\t\t\t SYMBOL TABLE\n\n");
				YYACCEPT;
			}
		;
Parsing	:	T_Nl Parsing {$$.code = $2.code;}
		|	Statements	{$$.code = $1.code;}
		|				{$$.code = NULL;}
		;
Constant	:	T_Num			
				{
					strcpy($$.type, "INT"); $$.numval = atoi($1.value);
					strcpy($$.addr, $1.value); $$.code = NULL;
				}
			|	T_String		
				{
					strcpy($$.type, "STR"); strcpy($$.value, $1.value);
					strcpy($$.addr, $1.value); $$.code = NULL;
				}
			;
Variable	:	T_Id  %prec Only_Id			
				{
					// a = 10; b = a (Get the value of a)
					SymbolTable* s = search($1.value);
					if(s!=NULL)
					{
						if(strcmp(s->datatype, "STR") == 0)
							strcpy($$.value, s->value);

						$$.numval = atoi(s->value);
						strcpy($$.type, s->datatype);
					}

					strcpy($$.addr, $1.value); $$.code = NULL;
				}
			;
List_Index	:	T_Id T_Osb Term T_Csb	{ char *temp = return_Temp();
										  char c[3];
										  strcpy(c, temp);
										  Q *t = Insert_into_Q("*", "INT", $3.addr, temp);
										  char *temp1 = return_Temp();
										  Q *t1 = Insert_into_Q("[]", $1.value, c, temp1);
										  t->next = t1;
										  $$.code = t;
										  strcpy($$.addr, temp);
										}
			;
List_Initialisation	:	T_Osb List_elements T_Csb	
						{
							strcpy($$.type, "LST");
							strcpy($$.addr, "lstele"); $$.code =NULL;
						}
					| T_List T_Etuple				
						{
							strcpy($$.type, "LST");
							strcpy($$.addr, "list()"); $$.code = NULL;
						}
					| T_Elist						
						{
							strcpy($$.type, "LST");
							strcpy($$.addr, "[]"); $$.code = NULL;
						}
					;
List_elements	:	Constant T_Comma List_elements
				|	T_Id T_Comma List_elements
				|	List_Initialisation T_Comma List_elements
				|	Constant
				|	T_Id
				|	List_Initialisation
				;
Range	:	T_Range T_Op T_Num T_Cp	{ char *temp = return_Temp();
									  Q *t = Insert_into_Q($1.value, $3.value, "NULL", temp);
									  $$.code = t;
									  strcpy($$.addr, temp);
									}
		|	T_Range T_Op T_Num T_Comma T_Num T_Cp	{ char *temp = return_Temp();
									  				  Q *t = Insert_into_Q($1.value, $3.value, $5.value, temp);
									  				  $$.code = t;
									  				  strcpy($$.addr, temp);
													}
		|	T_Range T_Op T_Num T_Comma T_Num T_Comma T_Num T_Cp	{ char *temp = return_Temp();
									  				  			  Q *t = Insert_into_Q($1.value, $3.value, $5.value, temp);
									  				  			  $$.code = t;
									  				  			  strcpy($$.addr, temp);
																}
		;
Iterable	:	T_Id	{strcpy($$.addr, $1.value); $$.code = NULL;}
			|	Range	{strcpy($$.addr, $1.addr); $$.code = $1.code;}
			;
Term	:	Variable	{$$.numval = $1.numval; strcpy($$.addr, $1.addr); $$.code = NULL;}
		|	Constant	{$$.numval = $1.numval; strcpy($$.addr, $1.addr); $$.code = NULL;}
		|	List_Index	{strcpy($$.addr, $1.addr); $$.code = $1.code;}
		|	Range		{strcpy($$.addr, $1.addr); $$.code = $1.code;}
		;
Boolean_Exp	:	Boolean_Term T_And Boolean_Term		
				{
					strcpy($$.type, "BLN");
					
					if(!$1.numval)
					{
						$$.numval = 0;
					} 
					else
					{
						$$.numval = $3.numval;
					}

				
					char *temp = return_Temp();
					Q *t = Insert_into_Q("and", $1.addr, $3.addr, temp);
					$$.code = build_TAC($1.code, $3.code, t);
					strcpy($$.addr, temp);

					sprintf($$.value, "%d", $$.numval);
					insert($$.addr, "BLR", $$.value, yylineno-1);
				}
			|	Boolean_Term T_Or Boolean_Term		
				{
					strcpy($$.type, "BLN"); 
					

					if($1.numval)
					{
						$$.numval = $1.numval;
					} 
					else
					{
						$$.numval = $3.numval;
					}

					char *temp = return_Temp();
					Q *t = Insert_into_Q("or", $1.addr, $3.addr, temp);
					$$.code = build_TAC($1.code, $3.code, t);
					strcpy($$.addr, temp);

					sprintf($$.value, "%d", $$.numval);
					insert($$.addr, "BLR", $$.value, yylineno-1);
				}
			|	Boolean_Term						
				{
					strcpy($$.type, "BLN"); $$.numval = $1.numval;
					strcpy($$.addr, $1.addr); $$.code = $1.code;
				}
			;
Boolean_Term	:	T_False					
					{
						$$.numval = 0;
						strcpy($$.addr, $1.value); $$.code = NULL;
					}
				|	T_True					
					{
						$$.numval = 1;
						strcpy($$.addr, $1.value); $$.code = NULL;
					}
				|	Arithmetic_Exp T_In Iterable
					{
						char *temp = return_Temp();
						Q *t = Insert_into_Q("in", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);
					}

				|	Arithmetic_Exp T_Lt Arithmetic_Exp
					{
						if($1.numval < $3.numval)
							$$.numval = 1;
						else
							$$.numval = 0;


						char *temp = return_Temp();
						Q *t = Insert_into_Q("<", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);
					}

				|	Arithmetic_Exp T_Lte Arithmetic_Exp
					{
						if($1.numval <= $3.numval)
							$$.numval = 1;
						else
							$$.numval = 0;


						char *temp = return_Temp();
						Q *t = Insert_into_Q("<=", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);
					}

				|	Arithmetic_Exp T_Gt Arithmetic_Exp
					{
						if($1.numval > $3.numval)
							$$.numval = 1;
						else
							$$.numval = 0;


						char *temp = return_Temp();
						Q *t = Insert_into_Q(">", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);			

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);			

					}

				|	Arithmetic_Exp T_Gte Arithmetic_Exp
					{
						if($1.numval >= $3.numval)
							$$.numval = 1;
						else
							$$.numval = 0;


						char *temp = return_Temp();
						Q *t = Insert_into_Q(">=", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);		

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);					
					}

				|	Arithmetic_Exp T_Neq Arithmetic_Exp
					{
						if($1.numval != $3.numval)
							$$.numval = 1;
						else
							$$.numval = 0;


						char *temp = return_Temp();
						Q *t = Insert_into_Q("!=", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);		

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);					
					}

				|	Arithmetic_Exp T_Eq Arithmetic_Exp
					{
						if($1.numval == $3.numval)
							$$.numval = 1;
						else
							$$.numval = 0;


						char *temp = return_Temp();
						Q *t = Insert_into_Q("==", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);			

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);			
					}

				|	Boolean_Next	{strcpy($$.addr, $1.addr); $$.code = $1.code;}
				;
Boolean_Next	:	T_Not Boolean_Term
					{
						if($1.numval == 1)
							$$.numval = 0;
						else
							$$.numval = 1;


						char *temp = return_Temp();
						Q *t = Insert_into_Q("not", $2.addr, "NULL", temp);
						$$.code = build_TAC($2.code, NULL, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);
					}

				|	T_Op Boolean_Exp T_Cp	
					{
						$$.numval = $2.numval;
						$$.code = $2.code; strcpy($$.addr, $2.addr);
					}

				|	T_Op T_Id T_Cp
					{
						SymbolTable* s = search($2.value);

						if(s!=NULL)
						{
							$$.numval = atoi(s->value);
							if($$.numval != 0)
								$$.numval = 1;
						}
						else
						{
							// a = (b) (b is not defined)
							printf("\n\n");
							printf("%s is not defined",$2.value);
							printf("\n\n");
						}

						$$.code = NULL; strcpy($$.addr, $2.value);
					}
				|	T_Op T_Not T_Id T_Cp
					{
						SymbolTable* s = search($3.value);
						if(s!=NULL)
						{
							$$.numval = atoi(s->value);
							if($$.numval == 0)
								$$.numval = 1;
							else
								$$.numval = 0;
						}
						else
						{
							// a = (not b) (b is not defined)
							printf("\n\n");
							printf("%s is not defined",$3.value);
							printf("\n\n");
						}

						char *temp = return_Temp();
						Q *t = Insert_into_Q("not", $3.value, "NULL", temp);
						$$.code = build_TAC(NULL, NULL, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "BLR", $$.value, yylineno-1);
					}
				;
Arithmetic_Exp	:	Arithmetic_Exp T_Add Arithmetic_Term	
					{
						strcpy($$.type, $3.type);
						$$.numval = $1.numval + $3.numval;

						char *temp = return_Temp();
						Q *t = Insert_into_Q("+", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "INT", $$.value, yylineno-1);

					}

				|	Arithmetic_Exp T_Minus Arithmetic_Term	
					{
						strcpy($$.type, $3.type);
						$$.numval = $1.numval - $3.numval;

						char *temp = return_Temp();
						Q *t = Insert_into_Q("-", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "INT", $$.value, yylineno-1);
					}
				
				|	Arithmetic_Term							
					{
						strcpy($$.type, $1.type);
						$$.numval = $1.numval;

						strcpy($$.addr, $1.addr); $$.code = $1.code;

					}
				;
Arithmetic_Term	:	Arithmetic_Term T_Mul Arithmetic_Factor		
					{

						if($1.numval > 0 && $2.numval > 0){

							$$.numval = $1.numval * $3.numval;
						}
						
						else{

							$$.numval = multiply($1.numval , $3.numval);

						}

						strcpy($$.type, $3.type);

						


						char *temp = return_Temp();
						Q *t = Insert_into_Q("*", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						// sprintf is used to convert int to str
						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "INT", $$.value, yylineno-1);

					}
				|	Arithmetic_Term T_Div Arithmetic_Factor	
					{
						if($3.numval == 0)
						{
							printf("\nCannot Divide by zero\n");
							return 0;
						}

						if ($3.numval == 2)
						{
							$$.numval = $1.numval >> 1;
						}
						else{
							$$.numval = $1.numval / $3.numval;
						}
						

						strcpy($$.type, $3.type);

						

						char *temp = return_Temp();
						Q *t = Insert_into_Q("/", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "INT", $$.value, yylineno-1);

					}
				|	Arithmetic_Term T_Mod Arithmetic_Factor		
					{
						strcpy($$.type, $3.type);
						$$.numval = $1.numval % $3.numval;

						

						char *temp = return_Temp();
						Q *t = Insert_into_Q("%", $1.addr, $3.addr, temp);
						$$.code = build_TAC($1.code, $3.code, t);
						strcpy($$.addr, temp);

						sprintf($$.value, "%d", $$.numval);
						insert($$.addr, "INT", $$.value, yylineno-1);

					}
				|	Arithmetic_Factor							
					{
						strcpy($$.type, $1.type);
						$$.numval = $1.numval; strcpy($$.addr, $1.addr); $$.code = $1.code;
					}
				;
Arithmetic_Factor	:	Term 						
						{
							strcpy($$.type, $1.type);
							$$.numval = $1.numval;
							strcpy($$.addr, $1.addr); $$.code = $1.code;
						}
					|	T_Op Arithmetic_Exp T_Cp 	
						{
							strcpy($$.type, $2.type); $$.numval = $2.numval;
							$$.code = $2.code; strcpy($$.addr, $2.addr);
						}
					;

Assignment_Stmt	:	Variable T_Asgn Arithmetic_Exp	
					{
						
						char buff[3]="";
  						sprintf(buff,"%s",$3.type);

  						SymbolTable* s = search($3.value);
						if(s==NULL && strcmp($3.type, "INT") && strcmp($3.type, "STR"))
						{
							// a = b (b is not defined)
							printf("\n\n");
							printf("%s is not defined\n",$3.value);
							printf("\n\n");
							
						}
  						
						if(strcmp($3.type, "INT") == 0)
  							sprintf($3.value, "%d", $3.numval);

  						else if(strcmp($3.type, "BLN") == 0)
  							sprintf($3.value, "%d", $3.numval);

						insert($1.value,buff,$3.value,yylineno - 1);


						Q *t = Insert_into_Q("=", $3.addr, "NULL", $1.addr);
						$$.code = build_TAC($1.code, $3.code, t);
					}

					|

					Variable T_Asgn Boolean_Exp	
					{
						char buff[3]="";
  						sprintf(buff,"%s",$3.type);
  						sprintf($3.value, "%d", $3.numval);
  						insert($1.value,buff,$3.value,yylineno - 1);

  						Q *t = Insert_into_Q("=", $3.addr, "NULL", $1.addr);
						$$.code = build_TAC($1.code, $3.code, t);

					}
				
					|
					
					Variable T_Asgn List_Initialisation	
					{
						char buff[3]="";
  						sprintf(buff,"%s",$3.type);
  						strcpy($3.value, "----");
						insert($1.value,buff,$3.value,yylineno - 1);

						Q *t = Insert_into_Q("=", $3.addr, "NULL", $1.addr);
						$$.code = build_TAC($1.code, $3.code, t);
					}

				|	List_Index T_Asgn Term				{
															Q *t = Insert_into_Q("=", $3.addr, "NULL", $1.addr);
															$$.code = build_TAC($1.code, $3.code, t);
														}					
					
					;

Pass_Stmt	: T_Pass	{ Q *t = Insert_into_Q("pass", "NULL", "NULL", "NULL");
						  $$.code = t;}
			;
Import_Stmt	:	T_Import T_Package	{ Q *t = Insert_into_Q("import", "NULL", "NULL", $2.value);
						  			  $$.code = t;}
			;
Print_Stmt	:	T_Print T_Op Term T_Cp	{ Q *t = Insert_into_Q("print", "NULL", "NULL", $3.addr);
						  				  $$.code = t;}
			;
Break_Stmt	: T_break	{ Q *t = Insert_into_Q("break", "NULL", "NULL", "NULL");
						  $$.code = t;}
			;
Return_Stmt	: T_Return Term { Q *t = Insert_into_Q("return", $2.addr, "NULL", "NULL");
						 $$.code = t;}
			;
Expression_Stmt	: Boolean_Exp	{$$.code = $1.code; }
				|	Arithmetic_Exp	{$$.code = $1.code;}
				;
Basic_Stmt	:	Expression_Stmt	{$$.code = $1.code;}
			|	Assignment_Stmt	{$$.code = $1.code;}
			|	Pass_Stmt	{$$.code = $1.code;}
			|	Print_Stmt	{$$.code = $1.code;}
			|	Break_Stmt	{$$.code = $1.code;}
			|	Return_Stmt	{$$.code = $1.code;}
			|	Import_Stmt	{$$.code = $1.code;}
			;

Suite	:	T_Nl T_ID Statements	{
									 if(st[p]==1){
									 $$.code = $3.code;
									 $$.out = $3.out;
									 if(q>-1)
									 {
										int x = q;
										while(x>-1)
										{
											$$.out1[x] = $3.out1[x];
											x = x - 1;
										}
									 }
									}
									 else{
									 $$.code = $3.code;
									 } 
									}
		;
Statements	:	Basic_Stmt T_Nl T_ND Statements	{
													if(st[p]==1){
													$$.code = build_TAC($1.code, $4.code, NULL);
													$$.out = $4.out;
													if(q>-1)
									 				{
														int x = q;
														while(x>-1)
														{
															$$.out1[x] = $4.out1[x];
															x = x - 1;
														}
									 				}
													}
													else{
													$$.code = build_TAC($1.code, $4.code, NULL);
													}
												}
			|	Compound_Stmt T_Nl T_ND Statements	{
													if(st[p]==1){
													$$.code = build_TAC($1.code, $4.code, NULL);
													$$.out = $4.out;
													}
													else{
													$$.code = build_TAC($1.code, $4.code, NULL);
 													}}
 			|	Basic_Stmt T_Nl {Pop_Tabspaces_and_DD();} Statements {
 																if(st[p]==1){
 																$$.code = $1.code;
																$$.out = $4.code;
																}
																else{
																$$.code = build_TAC($1.code, $4.code, NULL);
																p = p - 1;
																}
															  }
			|	Basic_Stmt T_Nl T_DD Statements	{
												  $$.code = $1.code;
												  $$.out = $4.code;
												  q = q + 1;
												  $$.out1[q] = $4.out;
												  int x = q - 1;
												  while(x>-1)
												  {
												  	$$.out1[x] = $4.out1[x];
													x = x - 1;
												  }
												  p = p + 1;
												  st[p] = 1;
												}
			|	Compound_Stmt T_Nl T_DD Statements	{
												  $$.code = $1.code;
												  $$.out = $4.code;
												  q = q + 1;
												  $$.out1[q] = $4.out;
												  int x = q - 1;
												  while(x>-1)
												  {
												  	$$.out1[x] = $4.out1[x];
													x = x - 1;
												  }
												  p = p + 1;
												  st[p] = 1;
												}
			|	Compound_Stmt T_Nl {Pop_Tabspaces_and_DD();} Statements	{
																		if(st[p]==1){
																		$$.code = $1.code;
																		$$.out = $4.code;
																		}
																		else{
																		$$.code = build_TAC($1.code, $4.code, NULL);
																		p = p - 1;
																}
																	}
			|	Basic_Stmt T_Nl		%prec Basic_Nl	{$$.code = $1.code;}
			|	Compound_Stmt		%prec Only_Compound	{$$.code = $1.code; $$.out = $1.out; 
														if(q>-1)
														{
															int x = q;
															while(x>-1)
															{
																$$.out1[x] = $1.out1[x];
																x = x - 1;
															}
														}
													}
			;
Compound_Stmt	:	If_Stmt	{$$.code = $1.code;
							if(q>-1)
								 {
								 	int x = q;
									while(x>-1)
									{
										$$.out1[x] = $1.out1[x];
										x = x - 1;
									}
								}
							}
				|	While_Stmt	{$$.code = $1.code; $$.out = $1.out;
								 if(q>-1)
								 {
								 	int x = q;
									while(x>-1)
									{
										$$.out1[x] = $1.out1[x];
										x = x - 1;
									}
								}
								}
				|	For_Stmt	{$$.code = $1.code;}
				;
While_Stmt	:	T_While Boolean_Exp T_Colon Suite T_DD { char *lab = return_Label();
														 strcpy($2.false, lab); 
														 Q *t = Insert_into_Q("iffalse", $2.addr, "NULL", $2.false); 
														 $2.code = build_TAC($2.code, NULL, t);
														 char *lab1 = return_Label();
														 strcpy($4.next, lab1);
														 Q *t1 = Insert_into_Q("label", "NULL", "NULL", $4.next); 
														 Q *t2 = Insert_into_Q("goto", "NULL", "NULL", $4.next); 
														 $2.code = build_TAC(t1, $2.code, $4.code);
														 Q *t3 = Insert_into_Q("label", "NULL", "NULL", $2.false); 
														 $2.code = build_TAC($2.code, t2, t3);
														 if(st[p]==1)
														 {
															$2.code = build_TAC($2.code, NULL, $4.out);
															p = p - 1;
														 } 
														 if(q>-1)
														 {
															$$.out = $4.out1[q];
														 	q = q - 1;
															int x = q;
															while(x>-1)
															{
																$$.out1[x] = $4.out1[x];
																x = x - 1;
															}
														 }
														 $$.code = $2.code; }
			|	T_While Boolean_Exp T_Colon Suite { Pop_Tabspaces(); 
													char *lab = return_Label();
													strcpy($2.false, lab);
													Q *t = Insert_into_Q("iffalse", $2.addr, "NULL", $2.false); 
													$2.code = build_TAC($2.code, NULL, t); 
													char *lab1 = return_Label();
													strcpy($4.next, lab1);
													Q *t1 = Insert_into_Q("label", "NULL", "NULL", $4.next); 
													Q *t2 = Insert_into_Q("goto", "NULL", "NULL", $4.next); 
													$2.code = build_TAC(t1, $2.code, $4.code);
													Q *t3 = Insert_into_Q("label", "NULL", "NULL", $2.false); 
													$2.code = build_TAC($2.code, t2, t3);
													if(st[p]==1)
													{
														$2.code = build_TAC($2.code, NULL, $4.out);
														p = p - 1;
													} 
													if(q>-1)
													{
														$$.out = $4.out1[q];
														q = q - 1;
														int x = q;
														while(x>-1)
														{
															$$.out1[x] = $4.out1[x];
															x = x - 1;
														}
													}
													$$.code = $2.code; }	%prec While_without_T_DD
			;
If_Stmt	:	T_If Boolean_Exp T_Colon Suite T_DD {char *lab1 = return_Label(); strcpy($<ctype>$.next, lab1);} Elif	{ char *lab = return_Label();
														  strcpy($2.false, lab);
														  Q *t = Insert_into_Q("iffalse", $2.addr, "NULL", $2.false); 
														  $2.code = build_TAC($2.code, NULL, t); 
														  char *lab1 = return_Label();
														  strcpy($4.next, $7.next);
														  Q *t1 = Insert_into_Q("goto", "NULL", "NULL", $4.next); 
														  Q *t2 = Insert_into_Q("label", "NULL", "NULL", $2.false); 
														  Q *t3 = Insert_into_Q("label", "NULL", "NULL", $4.next); 
														  $2.code = build_TAC($2.code, $4.code, t1); 
														  $2.code = build_TAC($2.code, t2, $7.code);
														  $2.code = build_TAC($2.code, t3, $7.out);
														  if(st[p]==1)
														  {
															$2.code = build_TAC($2.code, NULL, $4.out);
															p = p - 1;
														  }
														  if(q>-1)
														  {
															$$.out = $4.out1[q];
														 	q = q - 1;
															int x = q;
															while(x>-1)
															{
																$$.out1[x] = $4.out1[x];
																x = x - 1;
															}
														  }
														  $$.code = $2.code;
														  }
		|	T_If Boolean_Exp T_Colon Suite TEMP {char *lab1 = return_Label(); strcpy($<ctype>$.next, lab1);} Elif	{ char *lab = return_Label();
														  strcpy($2.false, lab); 
														  Q *t = Insert_into_Q("iffalse", $2.addr, "NULL", $2.false); 
														  $2.code = build_TAC($2.code, NULL, t); 
														  strcpy($4.next, $7.next);
														  Q *t1 = Insert_into_Q("goto", "NULL", "NULL", $4.next); 
														  Q *t2 = Insert_into_Q("label", "NULL", "NULL", $2.false); 
														  Q *t3 = Insert_into_Q("label", "NULL", "NULL", $4.next); 
														  $2.code = build_TAC($2.code, $4.code, t1); 
														  $2.code = build_TAC($2.code, t2, $7.code);
														  $2.code = build_TAC($2.code, t3, $7.out);
														  if(st[p]==1)
														  {
															$2.code = build_TAC($2.code, NULL, $4.out);
															p = p - 1;
														  }
														  if(q>-1)
														  {
															$$.out = $4.out1[q];
														 	q = q - 1;
															int x = q;
															while(x>-1)
															{
																$$.out1[x] = $4.out1[x];
																x = x - 1;
															}
														  }
														  $$.code = $2.code;
														}
		;
TEMP	:	{Pop_Tabspaces();}	%prec Temp
		;
Elif	:	T_Elif Boolean_Exp T_Colon Suite T_DD {strcpy($<ctype>$.next, $<ctype>0.next);} Elif	{ char *lab = return_Label();
														  strcpy($2.false, lab);
														  Q *t = Insert_into_Q("iffalse", $2.addr, "NULL", $2.false); 
														  $2.code = build_TAC($2.code, NULL, t); 
														  strcpy($4.next, $<ctype>0.next);
														  strcpy($$.next, $4.next);
														  Q *t1 = Insert_into_Q("goto", "NULL", "NULL", $4.next); 
														  $2.code = build_TAC($2.code, $4.code, t1);
														  Q *t2 = Insert_into_Q("label", "NULL", "NULL", $2.false); 
														  $2.code = build_TAC($2.code, t2, $7.code);
														  if(st[p]==1)
														  {
														  	$$.out = $7.out;
															if($4.out!=NULL)
																$$.out = $4.out;
														  }
														  if(q>-1)
														  {
															$$.out = $4.out1[q];
														 	q = q - 1;
															int x = q;
															while(x>-1)
															{
																$$.out1[x] = $4.out1[x];
																x = x - 1;
															}
														  }
														  $$.code = $2.code;
														}
		|	T_Elif Boolean_Exp T_Colon Suite TEMP {strcpy($<ctype>$.next, $<ctype>0.next);} Elif	{ char *lab = return_Label();
														  strcpy($2.false, lab);
														  Q *t = Insert_into_Q("iffalse", $2.addr, "NULL", $2.false); 
														  $2.code = build_TAC($2.code, NULL, t); 
														  strcpy($4.next, $<ctype>0.next);
														  strcpy($$.next, $4.next);
														  Q *t1 = Insert_into_Q("goto", "NULL", "NULL", $4.next); 
														  $2.code = build_TAC($2.code, $4.code, t1);
														  Q *t2 = Insert_into_Q("label", "NULL", "NULL", $2.false); 
														  $2.code = build_TAC($2.code, t2, $7.code);
														  if(st[p]==1)
														  {
															$$.out =  $7.out;
															if($4.out!=NULL)
																$$.out = $4.out;
														  }
														  if(q>-1)
														  {
															$$.out = $4.out1[q];
														 	q = q - 1;
															int x = q;
															while(x>-1)
															{
																$$.out1[x] = $4.out1[x];
																x = x - 1;
															}
														  }
														  $$.code = $2.code;
														}
		|	Else	{
						$$.code = $1.code;
						$$.out = $1.out;
						strcpy($$.next, $<ctype>0.next);
					}
		;
Else	: T_Else T_Colon Suite T_DD	{
										if(st[p] == 1)
										{
											$$.out = $3.out;
										}
										if(q>-1)
										{
										$$.out = $3.out1[q];
										q = q - 1;
										int x = q;
										while(x>-1)
										{
											$$.out1[x] = $3.out1[x];
											x = x - 1;
										}
										}
										$$.code = $3.code;
										strcpy($$.next, $<ctype>0.next);
									}
		| T_Else T_Colon Suite {Pop_Tabspaces();
								if(st[p]==1)
								{
									$$.out = $3.out;
								}
								if(q>-1)
								{
								$$.out = $3.out1[q];
								q = q - 1;
								int x = q;
								while(x>-1)
								{
									$$.out1[x] = $3.out1[x];
									x = x - 1;
								}
								}
								$$.code = $3.code;
								strcpy($$.next, $<ctype>0.next);
							   }	%prec Else_without_T_DD
		|		%prec Lambda	{$$.code = NULL;strcpy($$.next, $<ctype>0.next);}
		;
For_Stmt	:	T_For T_Id T_In Iterable T_Colon Suite T_DD  %prec No_Else_In_For
			|	T_For T_Id T_In Iterable T_Colon Suite {Pop_Tabspaces();} %prec For_without_T_DD
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
	TAC_display(first);
	dead_code_eliminate();
	return 0;
}
