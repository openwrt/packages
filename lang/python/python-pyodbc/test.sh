#!/bin/sh

[ "$1" = python3-pyodbc ] || exit 0

python3 -c 'import pyodbc'
