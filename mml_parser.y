%{
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <algorithm>
#include <memory>
#include <cstring>
#include <cdk/compiler.h>
#include <cdk/types/types.h>
#include ".auto/all_nodes.h"
#define LINE                         compiler->scanner()->lineno()
#define yylex()                      compiler->scanner()->scan()
#define yyerror(compiler, s)         compiler->scanner()->error(s)
//-- don't change *any* of these --- END!
%}

%parse-param {std::shared_ptr<cdk::compiler> compiler}

%union {
  //--- don't change *any* of these: if you do, you'll break the compiler.
  YYSTYPE() : type(cdk::primitive_type::create(0, cdk::TYPE_VOID)) {}
  ~YYSTYPE() {}
  YYSTYPE(const YYSTYPE &other) { *this = other; }
  YYSTYPE& operator=(const YYSTYPE &other) { type = other.type; return *this; }

  std::shared_ptr<cdk::basic_type> type;        /* expression type */
  //-- don't change *any* of these --- END!

  int                   i;	/* integer value */
  double                d;    /* double value */
  std::string          *s;	/* symbol name or string literal */
  cdk::basic_node      *node;	/* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
  std::shared_ptr<cdk::primitive_type>  types;
  std::vector<std::shared_ptr<cdk::basic_type>> *typelist;
  mml::block_node      *block;
};

%token <i> tINTEGER
%token <d> tDOUBLE
%token <s> tIDENTIFIER tSTRING
%token tWHILE tIF tPRINT tREAD tBEGIN tEND tAUTO tFOREIGN tFORWARD tPUBLIC tNEXT tRETURN tNULL
tSIZEOF tTYPEINT tTYPEDOUBLE tTYPESTRING tTYPEVOID tPRINTLN tSTOP

%nonassoc tIFX 
%nonassoc tELSE tELIF
%right '=' 
%left tOR
%left tAND 
%left tEQ tNE 
%left tGE tLE '>' '<'
%left '+' '-' '~'
%left '*' '/' '%'
%nonassoc '('
%nonassoc '['
%nonassoc tUNARY



%type<node> decl var instr ifs //funcvar
%type<block> block main_program
%type<sequence> instrs exprs vars decls file //assigment
%type<expression> expr funcdef funcall
%type<s> string
%type<type> type functional_type
%type <typelist> type_list
%type<types> auto
%type<lvalue> lval

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

file   : decls                      { compiler->ast($$ = $1); }
       | decls main_program         {compiler->ast($$ = new cdk::sequence_node(LINE, $2, $1));}
       | main_program              {compiler->ast( $$ = new cdk::sequence_node(LINE, $1));}
       ;

main_program  : tBEGIN decls instrs tEND          { $$ = new mml::block_node(LINE, $2, $3); }
              | tBEGIN decls tEND               { $$ = new mml::block_node(LINE, $2, new cdk::sequence_node(LINE));}
              | tBEGIN instrs tEND               { $$ = new mml::block_node(LINE, new cdk::sequence_node(LINE), $2);}
              ;

decl   : var ';'                   { $$ = $1;}
       //| funcvar  ';'              { $$ = $1;}
       ;

decls  : decl                { $$ = new cdk::sequence_node(LINE, $1); }
       | decls decl         { $$ = new cdk::sequence_node(LINE, $2, $1); }
       ;

vars : var                                                       { $$ = new cdk::sequence_node(LINE, $1);}
     | vars ',' var                                              { $$ = new cdk::sequence_node(LINE, $3, $1);}
    /*| funcvar                                                    { $$ = new cdk::sequence_node(LINE, $1);}
     | vars ',' funcvar                                           { $$ = new cdk::sequence_node(LINE, $3, $1);}*/
     ; 

var    : type tIDENTIFIER                                          { $$ = new mml::var_declaration_node(LINE, false, false, false, $1->name()==cdk::TYPE_FUNCTIONAL, $1, nullptr, $2);}
       | type tIDENTIFIER '=' expr                                 { $$ = new mml::var_declaration_node(LINE, false, false, false, $1->name()==cdk::TYPE_FUNCTIONAL, $1, $4, $2); }
       | tPUBLIC type tIDENTIFIER                                  { $$ = new mml::var_declaration_node(LINE, true, false, false, $2->name()==cdk::TYPE_FUNCTIONAL, $2, nullptr, $3);}
       | tPUBLIC type tIDENTIFIER '=' expr                         { $$ = new mml::var_declaration_node(LINE, true, false, false, $2->name()==cdk::TYPE_FUNCTIONAL, $2, $5, $3);}
       
       | tFORWARD functional_type tIDENTIFIER                       { $$ = new mml::var_declaration_node(LINE, false, true, false, true, $2, nullptr, $3);}
       | tFOREIGN functional_type tIDENTIFIER                                { $$ = new mml::var_declaration_node(LINE, false, false, true, true, $2, nullptr, $3);}
       | tPUBLIC tIDENTIFIER '=' expr                             { $$ = new mml::var_declaration_node(LINE, true, false, false, true, $4->type(), $4, $2);}
       
       | auto tIDENTIFIER '=' expr                                { if (dynamic_cast<mml::function_defs_node*>($4)) {
                                                                      // expr is a funcdef
                                                                      $$ = new mml::var_declaration_node(LINE, false, false, false, true, $4->type(), $4, $2);
                                                                      } else {
                                                                      // expr is not a funcdef
                                                                      $$ = new mml::var_declaration_node(LINE, false, false, true, false, $1, $4, $2);
                                                                      }}
       | tPUBLIC auto tIDENTIFIER '=' expr                        { if (dynamic_cast<mml::function_defs_node*>($5)) {
                                                                      // expr is a funcdef
                                                                      $$ = new mml::var_declaration_node(LINE, true, false, false, true, $5->type(), $5, $3);
                                                                      } else {
                                                                      // expr is not a funcdef
                                                                      $$ = new mml::var_declaration_node(LINE, true, false, true, false, $2, $5, $3);
                                                                      }}    
       ;
      
auto : tAUTO  { $$ = cdk::primitive_type::create(4,cdk::TYPE_STRUCT); }
    ;

type   : tTYPEINT                         { $$ = cdk::primitive_type::create(4, cdk::TYPE_INT); }
       | tTYPEDOUBLE                      { $$ = cdk::primitive_type::create(4, cdk::TYPE_DOUBLE); }
       | tTYPESTRING                      { $$ = cdk::primitive_type::create(4, cdk::TYPE_STRING); }
       | tTYPEVOID                        { $$ = cdk::primitive_type::create(4, cdk::TYPE_VOID); }
       | '[' type ']'                     { $$ = cdk::primitive_type::create(4, cdk::TYPE_POINTER); }
       | functional_type                  { $$ = cdk::primitive_type::create(4, cdk::TYPE_FUNCTIONAL); }
       ;

functional_type : type '<' type_list '>'                {$$ = cdk::functional_type::create(*$3, $1);}
              | type '<' '>'                            {$$ = cdk::functional_type::create($1);}
              ;

type_list : type                                 { $$ = new std::vector<std::shared_ptr<cdk::basic_type>>(); $$->push_back($1); }
          | type_list ',' type                   { $$ = $1; $$->push_back($3); }
          ;

funcdef   : '(' vars ')' '-' '>' type '{' block '}'          { $$ = new mml::function_defs_node(LINE, $2, $6, $8);}
          | '(' ')' '-' '>' type '{' block '}'          { $$ = new mml::function_defs_node(LINE, new cdk::sequence_node(LINE), $5, $7);}
          ;

expr   : '-' expr %prec tUNARY     { $$ = new cdk::neg_node(LINE, $2); }
       | '+' expr %prec tUNARY     { $$ = new mml::identity_node(LINE, $2); } 
       | expr '+' expr             { $$ = new cdk::add_node(LINE, $1, $3); }
       | expr '-' expr             { $$ = new cdk::sub_node(LINE, $1, $3); }
       | expr '*' expr             { $$ = new cdk::mul_node(LINE, $1, $3); }
       | expr '/' expr             { $$ = new cdk::div_node(LINE, $1, $3); }
       | expr '%' expr             { $$ = new cdk::mod_node(LINE, $1, $3); }
       | expr '<' expr             { $$ = new cdk::lt_node(LINE, $1, $3); }
       | expr '>' expr             { $$ = new cdk::gt_node(LINE, $1, $3); }
       | expr tGE expr             { $$ = new cdk::ge_node(LINE, $1, $3); }
       | expr tLE expr             { $$ = new cdk::le_node(LINE, $1, $3); }
       | expr tNE expr             { $$ = new cdk::ne_node(LINE, $1, $3); }
       | expr tEQ expr             { $$ = new cdk::eq_node(LINE, $1, $3); }
       | expr tOR expr             { $$ = new cdk::or_node(LINE, $1, $3); }
       | expr tAND  expr           { $$ = new cdk::and_node(LINE, $1, $3); }
       | '~' expr                  { $$ = new cdk::not_node(LINE, $2); }
       | tREAD                     { $$ = new mml::read_node(LINE); }
       | tINTEGER                  { $$ = new cdk::integer_node(LINE, $1); }
       | tDOUBLE                   { $$ = new cdk::double_node(LINE, $1); }
       | string                    { $$ = new cdk::string_node(LINE, $1);}
       | tNULL                     { $$ = new mml::null_node(LINE);}
       | lval                      { $$ = new cdk::rvalue_node(LINE, $1); }
       | '(' expr ')'              { $$ = $2; }
       | lval '=' expr             { $$ = new cdk::assignment_node(LINE, $1, $3); }
       | '[' expr ']'              { $$ = new mml::mem_alloc_node(LINE, $2); }
       | lval '?'                  { $$ = new mml::addressof_node(LINE, $1); }
       | tSIZEOF '(' expr ')'      { $$ = new mml::sizeof_node(LINE, $3); }
       | funcall                   { $$ = $1;}
       | funcdef                   { $$ = $1;}
       ;

string : tSTRING            {$$ = $1;}
       | string tSTRING     {$$ = new std::string(*$1 + *$2); delete $1; delete $2;}
       ;

exprs  : expr                                                         { $$ = new cdk::sequence_node(LINE, $1);}
       | expr ',' exprs                                               { $$ = new cdk::sequence_node(LINE, $1, $3);}
       ;

funcall : expr '(' ')'       { $$ = new mml::function_call_node(LINE, $1, new cdk::sequence_node(LINE)); }
        | expr '(' exprs ')' { $$ = new mml::function_call_node(LINE, $1, $3); }
        | '@' '(' ')'       { $$ = new mml::function_call_node(LINE, nullptr, new cdk::sequence_node(LINE)); }
        | '@' '(' exprs ')' { $$ = new mml::function_call_node(LINE, nullptr, $3); }
        ;

lval : tIDENTIFIER                        { $$ = new cdk::variable_node(LINE, $1); }
     | expr '[' expr ']'                  { $$ = new mml::index_node(LINE, $1, $3);}
     ;

instrs : instr                                                        { $$ = new cdk::sequence_node(LINE, $1);}
       | instrs instr                                                 { $$ = new cdk::sequence_node(LINE, $2, $1);}
       ;


instr  : expr ';'                                                     { $$ = new mml::evaluation_node(LINE, $1);}
       | tSTOP ';'                                                       { $$ = new mml::stop_node(LINE,1);}
       | tSTOP tINTEGER  ';'                                             { $$ = new mml::stop_node(LINE,$2);}
       | exprs tPRINT                                                { $$ = new mml::print_node(LINE, $1, false);}
       | exprs tPRINTLN                                              { $$ = new mml::print_node(LINE, $1, true);}
       | tRETURN ';'                                                          { $$ = new mml::return_node(LINE, nullptr);}
       | tRETURN expr';'                                               { $$ = new mml::return_node(LINE, $2);}
       | tNEXT ';'                                                         { $$ = new mml::next_node(LINE, 1);}
       | tNEXT tINTEGER ';'                                             { $$ = new mml::next_node(LINE, $2);}
       | tWHILE '(' expr ')' instr                                    { $$ = new mml::while_node(LINE, $3, $5); }
       | tIF ifs                                                      { $$ = $2;}
       | '{' block '}'                                                        { $$ = $2;}
       ;

ifs   : '(' expr ')' instr %prec tIFX                                      { $$ = new mml::if_node(LINE, $2, $4);}
       |'(' expr ')' instr tELSE instr                               { $$ = new mml::if_else_node(LINE, $2, $4, $6);}
       | '(' expr ')' instr tELIF ifs                               { $$ = new mml::if_else_node(LINE, $2, $4, $6);}
       ;

block  :                                                       { $$ = new mml::block_node(LINE, new cdk::sequence_node(LINE), new cdk::sequence_node(LINE));}
       | decls                                               { $$ = new mml::block_node(LINE, $1, new cdk::sequence_node(LINE));}
       | instrs                                                { $$ = new mml::block_node(LINE, new cdk::sequence_node(LINE), $1);}
       | decls instrs                                       { $$ = new mml::block_node(LINE, $1, $2);}
       ;
/*block  : "{" "}"                                                      { $$ = new mml::block_node(LINE, new cdk::sequence_node(LINE), new cdk::sequence_node(LINE));}
       | "{" decls "}"                                                { $$ = new mml::block_node(LINE, $2, new cdk::sequence_node(LINE));}
       | "{" instrs "}"                                               { $$ = new mml::block_node(LINE, new cdk::sequence_node(LINE), $2);}
       | "{" decls instrs "}"                                         { $$ = new mml::block_node(LINE, $2, $3);}
       ;*/

%%
