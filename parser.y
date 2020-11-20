/* Compiler Theory and Design
   Duane J. Jarc */

%{

#include <iostream>
#include <string>
#include <vector>
#include <deque>
#include <map>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);

Symbols<double> symbols;
deque<double> params;

double result;

%}

%define parse.error verbose

%union
{
	CharPtr iden;
	Operators oper;
	double value;
}

%token <iden> IDENTIFIER
%token <value> INT_LITERAL BOOL_LITERAL REAL_LITERAL

%token <oper> ADDOP MULOP RELOP ANDOP EXPOP

%token ARROW

%token CASE
%token ELSE
%token ENDCASE
%token ENDIF
%token IF
%token OTHERS
%token REAL
%token THEN
%token WHEN
%token OROP
%token NOTOP

%token BEGIN_ BOOLEAN END ENDREDUCE FUNCTION INTEGER IS REDUCE RETURNS

%type <value> body statement_ statement reductions expression relation term
	factor power primary
%type <oper> operator

%%

function:	
	function_header optional_variable body {result = $3;} ;
	
function_header:	
	FUNCTION IDENTIFIER parameters RETURNS type ';' ;

parameters:
	  parameter |
	  parameter ',' parameters;

parameter:
	IDENTIFIER ':' type {symbols.insert($1, params.front()); params.pop_front(); } ;

optional_variable:
	variable |
	variable optional_variable ;

variable:
	IDENTIFIER ':' type IS statement_ {symbols.insert($1, $5);} |
        ;

type:
	INTEGER |
	REAL |
	BOOLEAN ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;
    
statement_:
	statement ';' {$$ = $1;} |
	error ';' {$$ = 0;} ;
	
statement:
	expression |
	IF expression THEN expression ';' ELSE expression ';' ENDIF { $$ = $2?$4:$7; } |
	REDUCE operator reductions ENDREDUCE {$$ = $3;} ;

operator:
	ADDOP |
	MULOP ;

reductions:
	reductions statement_ {$$ = evaluateReduction($<oper>0, $1, $2);} |
	{$$ = $<oper>0 == ADD ? 0 : 1;} ;

expression:
	NOTOP expression {$$ = ! $2;} |
	expression ANDOP relation {$$ = $1 && $3;} |
	expression OROP relation {$$ = $1 || $3;} |
	relation ;

relation:
	relation RELOP term {$$ = evaluateRelational($1, $2, $3);} |
	term ;

term:
	term ADDOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
        power |
	factor ;
      
factor:
	factor MULOP power {$$ = evaluateArithmetic($1, $2, $3);} |
	power ;

power:
        primary EXPOP power {$$ = evaluateArithmetic($1, $2, $3);} | 
        primary ;

primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL {$$ = $1;} |
	REAL_LITERAL {$$ = $1;} |
	BOOL_LITERAL {$$ = $1;} |
	IDENTIFIER {if (!symbols.find($1, $$)) appendError(UNDECLARED, $1);} ;

%%

void yyerror(const char* message)
{
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[])    
{
	for(int ii=1; ii<argc; ii++) {
	  params.push_back(atof(argv[ii]));
	}
	firstLine();
	yyparse();
	if (lastLine() == 0)
		cout << "Result = " << result << endl;
	return 0;
} 
