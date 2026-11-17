#!/bin/sh

[ "$1" = python3-pymysql ] || exit 0

python3 -c '
import pymysql

# Verify version
assert pymysql.__version__

# Verify core exports
assert hasattr(pymysql, "connect")
assert hasattr(pymysql, "connections")
assert hasattr(pymysql, "cursors")

# Verify cursor types are importable
from pymysql.cursors import Cursor, DictCursor, SSCursor, SSDictCursor

# Verify exception classes are importable
from pymysql import (
    err,
    MySQLError,
    OperationalError,
    InterfaceError,
    DatabaseError,
    IntegrityError,
    DataError,
)

# Verify connections.Connection class exists
from pymysql import connections
assert connections.Connection is not None

# Verify callable cursor classes
assert callable(Cursor)
assert callable(DictCursor)
assert callable(SSCursor)
assert callable(SSDictCursor)

# Verify constants module
import pymysql.constants as constants
assert hasattr(constants, "CR")
assert hasattr(constants, "ER")

print("pymysql OK")
'
