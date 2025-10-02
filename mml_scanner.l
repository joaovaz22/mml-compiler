%option c++ prefix="mml_scanner_" outfile="mml_scanner.cpp"
%option stack noyywrap yylineno 8bit debug
%{ 
// make relevant includes before including the parser's tab file
#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include "mml_parser.tab.h"

// don't change this
#define yyerror LexerError
%}
%x X_STRING X_OPCOMMENT X_STRING_IGNORE X_STRING_SEQ_ESP
IDENTIFIER 					[_a-zA-Z][0-9a-zA-Z_]*
SYMBOL							[-%\]{}()<>!*/~+&|[;?,:=@]
SPACE      					[ \t\n\r]+

DIGIT							  [0-9]
EXPONENT          	[eE][-+]?{DIGIT}+
REAL							  {DIGIT}+{EXPONENT}|({DIGIT}+"."{DIGIT}*|{DIGIT}*"."{DIGIT}+){EXPONENT}?
OCTA             		[0-7]
B8_INT							0{OCTA}+
B10_INT							[1-9]{DIGIT}*|0

%%
  yydebug=1; set_debug(1);


"//".*$                       	{ ; /* ignore comments */}

"public"			   			return tPUBLIC;
"forward"             return tFORWARD;
"foreign"             return tFOREIGN;
"auto"                return tAUTO;
"while"               return tWHILE;

"next"				        return tNEXT;
"stop"                return tSTOP;
"return"			   			return tRETURN;
"input"					   	  return tREAD;
"null"				   			return tNULL;
"sizeof"              return tSIZEOF;

"if"                  return tIF;
"elif"                return tELIF;
"else"                return tELSE;

"int"				   		    return tTYPEINT;		   
"double"				   		return tTYPEDOUBLE;
"string"			   			return tTYPESTRING;
"void"			   			  return tTYPEVOID;

"!"                   return tPRINT;
"!!"				   			  return tPRINTLN;

">="                  return tGE; 
"<="                  return tLE; 
"=="                  return tEQ; 
"!="                  return tNE; 
"&&"                  return tAND;
"||"                  return tOR;

"begin"               return tBEGIN; 
"end"                 return tEND; 

"/*"                            { yy_push_state(X_OPCOMMENT);}
<X_OPCOMMENT>"/*"               { yy_push_state(X_OPCOMMENT);}
<X_OPCOMMENT>"*/"               { yy_pop_state();}
<X_OPCOMMENT>.|\n               { ;}

{IDENTIFIER}                    { yylval.s = new std::string(yytext); return tIDENTIFIER;}
{REAL}               		 	      { yylval.d = strtod(yytext, nullptr);		if(errno == ERANGE) yyerror("overflow detected"); return tDOUBLE;}
{B8_INT}			  		 	          { yylval.i = strtol(yytext, nullptr, 8);	if(errno == ERANGE) yyerror("overflow detected"); return tINTEGER;}
{B10_INT}               		    { yylval.i = strtol(yytext, nullptr, 10);	if(errno == ERANGE) yyerror("overflow detected"); return tINTEGER;} 

\"                     		  	  { yy_push_state(X_STRING); yylval.s = new std::string("");}
<X_STRING,X_STRING_IGNORE>\"    { yy_pop_state(); 	return tSTRING;}
<X_STRING>\\		   		  	      { yy_push_state(X_STRING_SEQ_ESP);}
<X_STRING>.|\n         		  	  { *yylval.s += yytext; }

<X_STRING_SEQ_ESP>0             { yy_pop_state(); yy_pop_state(); yy_push_state(X_STRING_IGNORE);}
<X_STRING_SEQ_ESP>00            { yy_pop_state(); yy_pop_state(); yy_push_state(X_STRING_IGNORE);}
<X_STRING_SEQ_ESP>t		          { *yylval.s += "\t"; yy_pop_state();}
<X_STRING_SEQ_ESP>n				      { *yylval.s += "\n"; yy_pop_state();}
<X_STRING_SEQ_ESP>r		          { *yylval.s += "\r"; yy_pop_state();}
<X_STRING_SEQ_ESP>\"         	  { *yylval.s += "\""; yy_pop_state();}
<X_STRING_SEQ_ESP>\\			      { *yylval.s += "\\"; yy_pop_state();}
<X_STRING_SEQ_ESP>{OCTA}{OCTA}{0,2} { *yylval.s += std::string(1, strtol(yytext, nullptr, 8)); yy_pop_state();}

<X_STRING_IGNORE>.|\n 	     	{ ;}
<X_STRING_IGNORE>\\\"         { ;}
<X_STRING_IGNORE>\\\\         { ;}


{SYMBOL}						  { return *yytext;}
{SPACE}               ; /* ignore whitespace */

.                      yyerror("Unknown character");

%%