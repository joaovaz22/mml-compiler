#ifndef __MML_AST_FUNCTIONDEFSNODE_H__
#define __MML_AST_FUNCTIONDEFSNODE_H__

#include <cdk/ast/basic_node.h>
#include <cdk/ast/sequence_node.h>
#include <cdk/types/basic_type.h>

namespace mml {
  /**
   * Class for describing Function Definitions nodes.
   */
  class function_defs_node: public cdk::expression_node {
    cdk::sequence_node * _parameters;
    std::shared_ptr<cdk::basic_type> _type;
    block_node * _block;

  public:
    inline function_defs_node(int lineno, cdk::sequence_node* parameters, std::shared_ptr<cdk::basic_type> type, block_node* block) :
        cdk::expression_node(lineno), _parameters(parameters), 
        _type(type), _block(block) {
        }

  public:

    inline std::shared_ptr<cdk::basic_type> type(){
      return _type;
    }
    
    inline cdk::sequence_node* parameters() {
      return _parameters;
    }

    inline block_node* block() {
      return _block;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_defs_node(this, level);
    }

  };

} // mml

#endif