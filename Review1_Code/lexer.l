%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#define DEBUG 1
	#include "y.tab.h"

	//yylloc = {1,1,1,1};

	//yylloc.first_column=yylloc.last_column=0;

	void update(char *token_name)
	{

			strcpy(yylval.val,yytext);


			if(strcmp(token_name,"Nl")==0)
			{
				yylloc.first_column=yylloc.last_column=1;
				printf("T_%s at line %d column %d\n\n",token_name,yylineno,yylloc.first_column);
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

			printf("T_%s at line %d column %d and value %s\n\n",token_name,yylineno,yylloc.first_column,yylval.val);
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
			printf("T_Id at line %d column %d and value %s\n\n",yylineno,yylloc.first_column,yylval.val);
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
"\t"+			    {update("ID"); return T_ID;}
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
