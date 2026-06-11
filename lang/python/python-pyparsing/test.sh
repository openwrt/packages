#!/bin/sh

[ "$1" = python3-pyparsing ] || exit 0

python3 - << 'EOF'

import pyparsing as pp

# Basic word and integer parsing
word = pp.Word(pp.alphas)
integer = pp.Word(pp.nums)

result = word.parse_string("hello")
assert result[0] == "hello"

result = integer.parse_string("42")
assert result[0] == "42"

# Combined expression
greeting = word + pp.Literal(",") + word
result = greeting.parse_string("Hello, World")
assert result[0] == "Hello"
assert result[2] == "World"

# OneOf
colors = pp.one_of("red green blue")
result = colors.parse_string("green")
assert result[0] == "green"

EOF
