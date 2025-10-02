#ifndef MML_AST_STOP_H
#define MML_AST_STOP_H

#include <cdk/ast/basic_node.h>

namespace mml {
  /**
   * Class for describing Stop nodes.
   */

  class stop_node: public cdk::basic_node {
    int _level;

  public:
    inline stop_node(int lineno, int level = 1) :
        cdk::basic_node(lineno), _level(level) {
    }

  public:
    int level() const {
      return _level;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_stop_node(this, level);
    }

  };

} // mml

#endif