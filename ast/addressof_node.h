#ifndef __MML_AST_ADDRESSOF_NODE_H__
#define __MML_AST_ADDRESSOF_NODE_H__

#include <cdk/ast/lvalue_node.h>
#include <cdk/ast/expression_node.h>

namespace mml {
  /**
   * Class for describing the memory Address node
   */
  class addressof_node: public cdk::expression_node {
      cdk::lvalue_node * _argument;
      
    public:
      inline addressof_node(int lineno, cdk::lvalue_node *argument) :
        cdk::expression_node(lineno), _argument(argument) {
        }

    public:
      inline cdk::lvalue_node *argument() {
        return _argument;
      }

      void accept(basic_ast_visitor *sp, int level) {
        sp->do_addressof_node(this, level);
      }

  };

} // mml

#endif