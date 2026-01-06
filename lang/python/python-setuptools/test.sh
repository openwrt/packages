#!/bin/sh

[ "$1" = python3-setuptools ] || exit 0

python3 -c 'from setuptools import setup'
