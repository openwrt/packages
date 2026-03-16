#!/bin/sh

[ "$1" = python3-constantly ] || exit 0

python3 - << 'EOF'

from constantly import NamedConstant, Names
class Letters(Names):
    a = NamedConstant()
    b = NamedConstant()
    c = NamedConstant()

assert Letters.lookupByName('a') is Letters.a
assert Letters.a < Letters.b
assert Letters.b < Letters.c
assert Letters.a < Letters.c

from constantly import ValueConstant, Values
class STATUS(Values):
    OK = ValueConstant('200')
    FOUND = ValueConstant('302')
    NOT_FOUND = ValueConstant('404')

assert STATUS.OK.value == '200'
assert STATUS.lookupByValue('404') == STATUS.NOT_FOUND

EOF
