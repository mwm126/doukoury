/* Compiler Theory and Design
   Duane J. Jarc */

%{

#include <iostream>
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);

Symbols<double> symbols;

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

%token <oper> ADDOP MULOP RELOP ANDOP

%token ARROW
%token REMOP
%token EXPOP
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
	factor primary
%type <oper> operator

%%

function:	
	function_header optional_variable body {result = $3;} ;
	
function_header:	
	FUNCTION IDENTIFIER RETURNS type ';' ;

optional_variable:
	variable |
	;

variable:	
	IDENTIFIER ':' type IS statement_ {symbols.insert($1, $5);} ;

type:
	INTEGER |
	REAL |
	BOOLEAN ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;
    
statement_:
	statement ';' |
	error ';' {$$ = 0;} ;
	
statement:
	expression |
	REDUCE operator reductions ENDREDUCE {$$ = $3;} ;

operator:
	ADDOP |
	MULOP ;

reductions:
	reductions statement_ {$$ = evaluateReduction($<oper>0, $1, $2);} |
	{$$ = $<oper>0 == ADD ? 0 : 1;} ;

expression:
	expression ANDOP relation {$$ = $1 && $3;} |
	relation ;

relation:
	relation RELOP term {$$ = evaluateRelational($1, $2, $3);} |
	term ;

term:
	term ADDOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
	factor ;
      
factor:
	factor MULOP primary {$$ = evaluateArithmetic($1, $2, $3);} |
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
	firstLine();
	yyparse();
	if (lastLine() == 0)
		cout << "Result = " << result << endl;
	return 0;
} 
