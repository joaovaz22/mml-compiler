#ifndef MML_AST_NEXT_H
#define MML_AST_NEXT_H

#include <cdk/ast/basic_node.h>

namespace mml {
  /**
   * Class for describing Next nodes.
   */

  class next_node: public cdk::basic_node {
    int _level;

  public:
    inline next_node(int lineno, int level = 1) :
        cdk::basic_node(lineno), _level(level) {
    }

  public:
    int level() const {
      return _level;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_next_node(this, level);
    }

  };

} // mml

#endif