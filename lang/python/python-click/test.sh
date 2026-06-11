#!/bin/sh

[ "$1" = python3-click ] || exit 0

python3 -c 'import click'
