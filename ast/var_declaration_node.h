#ifndef __MML_AST_VARDECLARATIONNODE_H__
#define __MML_AST_VARDECLARATIONNODE_H__

#include <cdk/ast/expression_node.h>

namespace mml {
  /**
   * Class for describing Variable Declarations nodes.
   */
  class var_declaration_node: public cdk::basic_node {
    bool _is_public;
    bool _is_forward;
    bool _is_foreign;
    bool _is_function;
    std::shared_ptr<cdk::basic_type> _type;
    cdk::expression_node * _exp;
    std::string _id;
    
  public:
    inline var_declaration_node(int lineno, bool is_public, bool is_forward, bool is_foreign, bool is_function, std::shared_ptr<cdk::basic_type> type,
    cdk::expression_node * exp, std::string * id):
      cdk::basic_node(lineno), _is_public(is_public), _is_forward(is_forward), _is_foreign(is_foreign), _is_function(is_function),
      _type(type), _exp(exp), _id(*id) {
      }

  public:
    inline std::shared_ptr<cdk::basic_type> type(){
      return _type;
    }

    inline bool is_public() {
      return _is_public;
    }

    inline bool is_forward() {
      return _is_forward;
    }

    inline bool is_foreign(){
      return _is_foreign;
    }

    inline bool is_function() {
      return _is_function;
    }

    inline std::string qualifier() {
      if (is_public()) {
          return "public";
      } else if (is_forward()) {
          return "forward";
      } else if (is_foreign()) {
          return "foreign";
      } else {
          return "";  // Handle the case when no qualifier is present or provide a default value
      }
    }

    inline cdk::expression_node * exp() {
      return _exp;
    }
    
    inline std::string id() {
      return _id;
    }
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_var_declaration_node(this, level);
    }

  };

} // mml

#endif


