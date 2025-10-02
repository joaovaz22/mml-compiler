#ifndef __MML_AST_FUNCTIONCALLNODE_H__
#define __MML_AST_FUNCTIONCALLNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/sequence_node.h>

namespace mml {
  /**
   * Class for describing Function Call nodes.
   */
  class function_call_node: public cdk::expression_node {
      cdk::expression_node *_ptr;
      cdk::sequence_node * _arguments;

  public:
      inline function_call_node (int lineno, cdk::expression_node *ptr, cdk::sequence_node * arguments):
        cdk::expression_node(lineno), _ptr(ptr),_arguments(arguments) {
        }

  public:
    inline cdk::sequence_node* arguments() {
      return _arguments;
    }

    inline cdk::expression_node* ptr(){
      return _ptr;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_call_node(this, level);
    }

  };

} // mml

#endif