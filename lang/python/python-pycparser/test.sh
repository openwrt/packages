#!/bin/sh

[ "$1" = "python3-pycparser" ] || exit 0

python3 - << EOF
import sys
import pycparser

# aardelean: yes, it's hardcoded here, hopefully we don't get too many;
#            but for version 3.0 on pypi.org, pycparser reports 3.00
if "3.0" == "$2" and pycparser.__version__ == "3.00":
    pass
elif pycparser.__version__ != "$2":
    print("Wrong version: " + pycparser.__version__)
    sys.exit(1)

# Test basic parsing of a simple C snippet
parser = pycparser.CParser()
ast = parser.parse("int x = 5;", filename='<none>')
assert ast is not None, "Failed to parse simple C code"

# Verify the AST contains a FileAST node
assert isinstance(ast, pycparser.c_ast.FileAST), \
    f"Expected FileAST, got {type(ast)}"

# Test parsing a function declaration
ast2 = parser.parse("int foo(int a, int b) { return a + b; }", filename='<none>')
assert ast2 is not None, "Failed to parse function declaration"

sys.exit(0)
EOF
