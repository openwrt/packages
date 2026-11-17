#!/bin/sh

[ "$1" = "python3-pygments" ] || exit 0

python3 - << EOF
import sys
import pygments
from pygments import highlight
from pygments.lexers import PythonLexer, get_lexer_by_name
from pygments.formatters import HtmlFormatter, NullFormatter

if pygments.__version__ != "$2":
    print("Wrong version: " + pygments.__version__)
    sys.exit(1)

code = "def hello(name):\n    print('Hello, ' + name)\n"

# Test basic highlighting to HTML
formatter = HtmlFormatter()
result = highlight(code, PythonLexer(), formatter)
assert '<span' in result, "Expected HTML span tags in output"
assert 'hello' in result, "Expected function name in output"

# Test getting lexer by name
lexer = get_lexer_by_name("python")
assert lexer is not None, "Expected to get Python lexer by name"

# Test highlighting to plain text (NullFormatter strips markup)
plain = highlight(code, PythonLexer(), NullFormatter())
assert 'hello' in plain, "Expected function name in plain output"

# Test CSS generation
css = formatter.get_style_defs('.highlight')
assert '.highlight' in css, "Expected CSS class in style defs"

sys.exit(0)
EOF
