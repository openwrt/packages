#!/bin/sh

[ "$1" = python3-trove-classifiers ] || exit 0

python3 - << 'EOF'

from trove_classifiers import classifiers, sorted_classifiers

# Check that the classifiers set is non-empty
assert len(classifiers) > 0

# Check a few well-known classifiers exist
assert "Programming Language :: Python :: 3" in classifiers
assert "License :: OSI Approved :: MIT License" in classifiers
assert "Operating System :: OS Independent" in classifiers

# sorted_classifiers should be a sorted list
assert sorted_classifiers == sorted(classifiers)

EOF
