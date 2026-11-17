#!/bin/sh

[ "$1" = "python3-sqlparse" ] || exit 0

python3 - << EOF
import sys
import sqlparse

if sqlparse.__version__ != "$2":
    print("Wrong version: " + sqlparse.__version__)
    sys.exit(1)

# Format: uppercase keywords
formatted = sqlparse.format("select id, name from users where id=1", keyword_case="upper")
assert "SELECT" in formatted
assert "FROM" in formatted
assert "WHERE" in formatted

# Split multiple statements
stmts = sqlparse.split("SELECT 1; SELECT 2; SELECT 3")
assert len(stmts) == 3

# Parse: token inspection
parsed = sqlparse.parse("SELECT a, b FROM t")[0]
assert parsed.get_type() == "SELECT"

# Format with indentation
sql = "select a,b from t where x=1 and y=2"
out = sqlparse.format(sql, reindent=True, keyword_case="upper")
assert "SELECT" in out
assert "WHERE" in out

sys.exit(0)
EOF
