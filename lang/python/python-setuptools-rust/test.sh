#!/bin/sh
[ "$1" = python3-setuptools-rust ] || exit 0
python3 - << 'EOF'
import setuptools_rust
assert setuptools_rust.__version__, "setuptools_rust version is empty"
from setuptools_rust import RustExtension, RustBin, Binding
ext = RustExtension("mymod", binding=Binding.PyO3)
assert ext.name == "mymod"
EOF
