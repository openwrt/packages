#!/bin/sh

[ "$1" = python3-pytest ] || exit 0

python3 -c 'import pytest'
