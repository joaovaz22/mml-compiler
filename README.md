# MML Compiler (C++ with Flex & Bison) 
A compiler built with **C++**, **Flex**, and **Bison**.  
The project implements all major stages of compiler design: **lexical analysis**, **parsing**, **AST construction**, **semantic analysis**, and **code generation**. 

## ⚙️ Build Instructions

Requirements:
- g++ (C++ compiler)
- flex
- bison
- make

To build the compiler:
```bash
make
```

This generates the `mml` compiler executable.

---

## ▶️ Usage

Compile an MML program:
```bash
./mml tests/
```

Run parser tests:
```bash
./check-parser.sh
```

Validate output against expected results:
```bash
./check-expected.sh
```

---

## 📂 Project Structure

```
.
├── ast/                   # AST (Abstract Syntax Tree) node definitions
│   ├── addressof_node.h
│   ├── block_node.h
│   ├── evaluation_node.h
│   ├── function_call_node.h
│   ├── function_defs_node.h
│   ├── if_node.h
│   ├── if_else_node.h
│   ├── index_node.h
│   ├── identity_node.h
│   ├── mem_alloc_node.h
│   ├── next_node.h
│   ├── null_node.h
│   ├── print_node.h
│   ├── read_node.h
│   ├── return_node.h
│   ├── sizeof_node.h
│   ├── stop_node.h
│   ├── var_declaration_node.h
│   └── while_node.h
│
├── targets/               # Code generation and semantic analysis
│   ├── basic_ast_visitor.h
│   ├── postfix_target.{h,cpp,o}
│   ├── postfix_writer.{h,cpp,o}
│   ├── symbol.h
│   ├── type_checker.{h,cpp,o}
│   ├── xml_target.{h,cpp,o}
│   └── xml_writer.{h,cpp,o}
│
├── tests/                 # Example programs and validation
├── mml_scanner.l          # Lexer (Flex)
├── mml_parser.y           # Parser grammar (Bison/Yacc)
├── mml_parser.tab.*       # Generated parser files
├── factory.*              # AST factory
├── Makefile               # Build system
├── check-parser.sh        # Parser testing script
├── check-expected.sh      # Validation script
└── README.md              # Project documentation
```

---

## ✨ Features

- **Lexical Analysis**: Implemented using **Flex** (`mml_scanner.l`)
- **Parsing**: Implemented using **Bison** (`mml_parser.y`)
- **Abstract Syntax Tree (AST)**:  
  - Rich set of node types in `ast/`  
  - Includes control structures (`if`, `while`), function calls, memory allocation, variable declarations, printing, and more.
- **Semantic Analysis**:  
  - Type checking (`type_checker`)  
  - Symbol management (`symbol.h`)
- **Code Generation**:  
  - Postfix output (`postfix_writer`)  
  - XML representation (`xml_writer`) for debugging and visualization
- **Testing**:  
  - Scripts (`check-parser.sh`, `check-expected.sh`) to validate compiler stages
  - Example programs in `tests/`

---

## 🧩 Example Workflow

1. **Lexical Analysis**:  
   The scanner (`mml_scanner.l`) converts raw source into tokens.

2. **Parsing**:  
   The parser (`mml_parser.y`) builds an AST from the tokens.

3. **AST Processing**:  
   Node classes in `ast/` define the language constructs.  
   Visitors in `targets/` traverse and analyze these nodes.

4. **Semantic Checks**:  
   Type correctness and symbol resolution are validated.

5. **Code Generation**:  
   Output can be written in **Postfix assembly-like format** or **XML** for inspection.

---

## 📖 Notes

This project was originally developed as part of a university course on compiler construction.  
It has been cleaned and documented here for portfolio purposes.  

⚠️ **Disclaimer**: The project was graded **15/20**. While some advanced features may be incomplete, it demonstrates a strong implementation of a full compiler pipeline.

