#!/bin/sh

[ "$1" = python3-pyfuse3 ] || exit 0

python3 - << 'EOF'
import pyfuse3

# Verify key attributes are accessible
assert hasattr(pyfuse3, "Operations")
assert hasattr(pyfuse3, "EntryAttributes")
assert hasattr(pyfuse3, "FUSEError")
assert hasattr(pyfuse3, "ROOT_INODE")
assert pyfuse3.ROOT_INODE == 1

# Verify EntryAttributes can be instantiated
attrs = pyfuse3.EntryAttributes()
assert attrs is not None

# Verify FUSEError can be raised
import errno
try:
    raise pyfuse3.FUSEError(errno.ENOENT)
except pyfuse3.FUSEError as e:
    assert e.errno == errno.ENOENT

from pyfuse3 import Operations, EntryAttributes, FUSEError, FileInfo, StatvfsData

# Verify key constants
assert isinstance(pyfuse3.ROOT_INODE, int), "ROOT_INODE should be an int"

# Verify exception hierarchy
assert issubclass(FUSEError, Exception)
e = FUSEError(2)  # ENOENT
assert e.errno == 2

# Verify EntryAttributes can be instantiated and fields set
attr = EntryAttributes()
attr.st_ino = 1
attr.st_size = 0
attr.st_mode = 0o755 | 0o040000  # S_IFDIR
assert attr.st_ino == 1

# Verify a minimal Operations subclass can be defined
class MinimalFS(Operations):
    pass

fs = MinimalFS()
assert isinstance(fs, Operations)

print("python3-pyfuse3 OK")
EOF
