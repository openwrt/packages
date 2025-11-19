#!/bin/sh

# Tries to run csi to check if the version is the same that
# we believe is being built.
csi -version 2>1 | grep -F "$2"

if [ $? -ne 0 ]
then
	echo "csi version different from expected"
	return 1
fi

# Tries to compile silent.scm. If it fails, then csc is not
# suitable for packaging. We just send an S-expression to its
# standard input. If this fails, csc is not working.
echo "(+ 2 3)" | csc -

if [ $? -ne 0 ]; then
	echo "csc cannot compile a s-expression from standard input"
	return 2
fi

