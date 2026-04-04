#!/bin/sh
[ "$1" = python3-pathspec ] || exit 0
python3 - << 'EOF'
import pathspec
assert pathspec.__version__, "pathspec version is empty"

spec = pathspec.PathSpec.from_lines("gitwildmatch", ["*.py", "!test_*.py", "build/"])
assert spec.match_file("foo.py")
assert not spec.match_file("test_foo.py")
assert spec.match_file("build/output.txt")
assert not spec.match_file("foo.txt")
EOF
