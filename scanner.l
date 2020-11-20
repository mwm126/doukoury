/* Compiler Theory and Design
   Duane J. Jarc */

/* This file contains flex input file */

%{
#include <cstdio>
#include <string>

using namespace std;

#include "values.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap

ws		[ \t\r]+
comment	\-\-.*\n
commentx	\/\/.*\n
line		[\n]
id		[A-Za-z]([_]?[A-Za-z0-9])*
digit		[0-9]
int		{digit}+
punc		[\(\),:;]
real_literal	[0-9]+\.[0-9]*([eE][-+]?[0-9]+)?
bool_literal	"true"|"false"
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine();}
{commentx}	{ ECHO; nextLine();}
{line}		{ ECHO; nextLine();}
{bool_literal}	{ ECHO; yylval.value = (bool)strcmp(yytext, "false"); return(BOOL_LITERAL); }
{real_literal}	{ ECHO; yylval.value = atof(yytext); return(REAL_LITERAL); }
"<"		{ ECHO; yylval.oper = LESS; return(RELOP); }
"="		{ ECHO; yylval.oper = EQUAL; return(RELOP); }
"/="		{ ECHO; yylval.oper = NOTEQUAL; return(RELOP); }
">"		{ ECHO; yylval.oper = GREATER; return(RELOP); }
">="		{ ECHO; yylval.oper = EGREATER; return(RELOP); }
"<="		{ ECHO; yylval.oper = ELESS; return(RELOP); }
"+"		{ ECHO; yylval.oper = ADD; return(ADDOP); }
"-"		{ ECHO; yylval.oper = SUBTRACT; return(ADDOP); }
"*"		{ ECHO; yylval.oper = MULTIPLY; return(MULOP); }
"/"		{ ECHO; yylval.oper = DIVIDE; return(MULOP); }
"=>"		{ ECHO; return(ARROW); }
rem		{ ECHO; yylval.oper = REMAINDER; return(MULOP); }
"**"		{ ECHO; yylval.oper = EXPONENT; return(EXPOP); }
begin		{ ECHO; return(BEGIN_); }
boolean		{ ECHO; return(BOOLEAN); }
end		{ ECHO; return(END); }
endreduce	{ ECHO; return(ENDREDUCE); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
reduce		{ ECHO; return REDUCE; }
returns		{ ECHO; return(RETURNS); }
and		{ ECHO; return(ANDOP); }
case		{ ECHO; return(CASE); }
else		{ ECHO; return(ELSE); }
endcase		{ ECHO; return(ENDCASE); }
endif		{ ECHO; return(ENDIF); }
if		{ ECHO; return(IF); }
others		{ ECHO; return(OTHERS); }
real		{ ECHO; return(REAL); }
then		{ ECHO; return(THEN); }
when		{ ECHO; return(WHEN); }
or		{ ECHO; return(OROP); }
not		{ ECHO; return(NOTOP); }
{id}            { ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1);
                        strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{int}		{ ECHO; yylval.value = atoi(yytext); return(INT_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
.		{ ECHO; appendError(LEXICAL, yytext); }
%%

int main2()
{
	firstLine();
	
	FILE *file = fopen("lexemes.txt", "wa"); 
	int token = yylex();
	while (token)
	{
		fprintf(file, "%d %s\n", token, yytext);
		token = yylex();
	}
	lastLine();
	fclose(file);
	return 0;
}
