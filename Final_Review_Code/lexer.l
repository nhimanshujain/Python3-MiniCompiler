%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#define DEBUG 1
	#include "y.tab.h"
	#include "indent.h"

	//yylloc = {1,1,1,1};

	//yylloc.first_column=yylloc.last_column=0;
	stack tab_stack = {.stack_pointer = -1};

	void push(stack *tab_stack,int element )
	{
		if(tab_stack->stack_pointer < stack_size)
		{
			tab_stack->arr[++tab_stack->stack_pointer] = element;
		}
		else
		{
			printf("STACK OVERFLOW..........\n");
			exit(0);
		}
	}

	void pop(stack *tab_stack)
	{
		//printf("SP VALUE : %d\n",tab_stack->stack_pointer);
		if(tab_stack->stack_pointer > -1)
		{
			tab_stack->arr[tab_stack->stack_pointer] = 0;
			tab_stack->stack_pointer-- ;
		}
		else
		{
			printf("STCK UNDERFLOW !!!!! IDENTATION ERROR\n");
			exit(0);
		}
	}


	int top(stack *tab_stack)
	{
		if(tab_stack->stack_pointer > -1)
		{
			return tab_stack->arr[tab_stack->stack_pointer];
		}
		else
		{
			return -1;
		}
	}



	void display_stack()
	{
		
		for(int index = 0; index <= tab_stack.stack_pointer ;index++)
		{
			printf(" %d,",tab_stack.arr[index]);
		}
		
	}

	void update(char *token_name)
	{

			strcpy(yylval.val,yytext);


			if(strcmp(token_name,"Nl")==0)
			{
				yylloc.first_column=yylloc.last_column=1;
				printf("\nT_%s  ",token_name);
				return;
			}
			else if(yylineno  == 1){
				yylloc.first_column = yylloc.last_column;
				yylloc.last_column = yylloc.last_column+yyleng;
			}
			else{
				yylloc.first_column = yylloc.last_column+1;
				yylloc.last_column = yylloc.last_column+yyleng;
			}
		    if(strcmp("ID",token_name)!=0)
			{
				printf("T_%s ",token_name);
			}
	}

	void identifier_check(char *token)
	{
			//printf("called here %d \n",yyleng);

			if(yylineno == 1)
			{
				yylloc.first_column = yylloc.last_column;
				yylloc.last_column = yylloc.last_column+yyleng;
			}
			else
			{
				yylloc.first_column = yylloc.last_column+1;
				yylloc.last_column = yylloc.last_column+yyleng;
			}

			if(yyleng > 31)
			{
				strncpy(yylval.val,yytext,31);
				printf("WARNING : length of Identifier %s greater than 31 characters  truncating upto 31 Chars -- %s\n\n",yytext,yylval.val);

			}
			else{
				strcpy(yylval.val,yytext);
			}
			printf("T_Id ");
	}

	int Indent_update()
	{   
		
		//display_stack();

		//called only when identation tabs appear

		//("current_depth : %d\n",yyleng);

		int peek = top(&tab_stack);

		if (yyleng > peek)
		{
			//identation it is 
			yylval.ID_depth = yyleng;
			push(&tab_stack , yyleng);
			printf("T_ID ");
			return T_ID;
		}
		else if(yyleng == peek)
		{
			//NO new identation , or identation level remains same
			yylval.ID_depth = yyleng;
			//push(&tab_stack , yyleng);
			printf("T_ND ");
			return T_ND;
		}
		else{
			//Dedent it is 
			yylval.ID_depth = yyleng;
			while(top(&tab_stack)!=yyleng)
			{
				pop(&tab_stack);
			}
			//push(&tab_stack , yyleng);
			printf("T_DD ");
			return T_DD;
		}
	}
%}
%option yylineno
number [0-9]
letter	[a-zA-Z]
whitespace [ ]
identifier	(_|{letter})(_|{letter}|{number})*
package		(math|re)
multiline_comment	\'\'\'(.|"\n")+\'\'\'"\n"|\"\"\"(.|"\n")+\"\"\""\n"

%%
#.*"\n"					{}
{multiline_comment}	{}
"from"				{update("From");return T_From;}
"as"				{update("As");return T_As;}
"if"				{update("If");return T_If;}
"elif"				{update("Elif");return T_Elif;}
"else"				{update("Else");return T_Else;}
"while"				{update("While");return T_While;}
"for"				{update("For");return T_For;}
"import"			{update("Import");return T_Import;}
"print"				{update("Print");return T_Print;}
"list"				{update("List");return T_List;}
"tuple"				{update("Tuple");return T_Tuple;}
"def"				{update("Def");return T_Def;}
"False"				{update("False");return T_False;}
"True"				{update("True");return T_True;}
"class"				{update("Class");return T_Class;}
"continue"			{update("Continue");return T_Continue;}
"break"				{update("Break");return T_break;}
"in"				{update("In");return T_In;}
"pass"				{update("Pass");return T_Pass;}
"return"			{update("Return");return T_Return;}
"not"				{update("Not");return T_Not;}
"or"				{update("Or");return T_Or;}
"and"				{update("And");return T_And;}
"range"				{update("Range");return T_Range;}
":"					{update("Colon");return T_Colon;}
"+"					{update("Plus");return T_Add;}
"-"					{update("Minus");return T_Minus;}
"/"					{update("Div");return T_Div;}
"%"					{update("Mod");return T_Mod;}
"<"					{update("Lt");return T_Lt;}
"<="				{update("Lte");return T_Lte;}
">"					{update("Gt");return T_Gt;}
">="				{update("Gte");return T_Gte;}
"="					{update("Asgn");return T_Asgn;}
"!="				{update("Neq");return T_Neq;}
"&"					{update("Band");return T_Ba;}
"|"					{update("Bor");return T_Bor;}
"^"					{update("Xor");return T_Xor;}
"~"					{update("Neg");return T_Neg;}
">>"				{update("Rs");return T_Rs;}
"<<"				{update("Ls");return T_Ls;}
"=="				{update("Eq");return T_Eq;}
"**"				{update("Exp");return T_Exp;}
"*"					{update("Mul");return T_Mul;}
","					{update("Comma");return T_Comma;}
"["					{update("Osb");return T_Osb;}
"]"					{update("Csb");return T_Csb;}
"[]"				{update("Elist");return T_Elist;}
"("					{update("Op");return T_Op;}
")"					{update("Cp");return T_Cp;}
"{"					{update("Lbrace");return T_Lbrace;}
"}"					{update("Rbrace");return T_Rbrace;}
"{}"				{update("T_Edict");return T_Edict;}
"()"				{update("T_Etuple");return T_Etuple;}
"\n"+				{update("Nl");return T_Nl;}
"\t"+			    {update("ID");int result = Indent_update();return result;}
{package}	    	{update("Package");return T_Package;}
{identifier}		{identifier_check(yytext);return T_Id;}
{number}+			{update("Num");return T_Num;}
{whitespace}+		{}
\"([^\n\"])*\"		{update("string");return T_String;}
\'([^\n\'])*\'		{update("String");return T_String;}
<<EOF>>				{update("EOF"); return T_EOF;}
.				{	yylloc.first_column+=1;
						printf("Unknown symbol %s found at line %d column %d\n",yytext,yylineno,yylloc.first_column);}
[^a-zA-Z0-9:)}/+/-/*///%\<"<=">">="="=="\'\]]"\n" 	{ int temp = yylloc.first_column+1;
															yylloc.first_column=1;
															printf("Unknown symbol %s found at line %d column %d\n",yytext,yylineno-1,temp);}
