#ifndef __MML_AST_RETURN_NODE_H__
#define __MML_AST_RETURN_NODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/basic_node.h>

namespace mml {
  /**
   * Class for describing Return nodes.
   */
  class return_node: public cdk::basic_node {
    cdk::expression_node * _returnExp;

  public:
    inline return_node(int lineno, cdk::expression_node * returnExp) :
        cdk::basic_node(lineno) , _returnExp(returnExp){
        }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_return_node(this, level);
    }

  };

} // mml

#endif