#!/bin/sh

case "$1" in
python3-sepolgen)
	python3 - <<'EOF'
import sepolgen.interfaces as iface
import sepolgen.policygen as pg
import sepolgen.access as access

# Verify core classes are importable
assert hasattr(iface, 'InterfaceSet'), "InterfaceSet missing"
assert hasattr(pg, 'PolicyGenerator'), "PolicyGenerator missing"
assert hasattr(access, 'AccessVector'), "AccessVector missing"

# Basic AccessVector construction
av = access.AccessVector()
av.src_type = "httpd_t"
av.tgt_type = "var_log_t"
av.obj_class = "file"
av.perms.add("write")
assert "write" in av.perms

print("python3-sepolgen OK")
EOF
	;;
python3-seobject)
	python3 - <<'EOF'
import seobject

# Verify key record types are available (no SELinux system required)
assert hasattr(seobject, 'portRecords'), "portRecords missing"
assert hasattr(seobject, 'fcontextRecords'), "fcontextRecords missing"
assert hasattr(seobject, 'booleanRecords'), "booleanRecords missing"
assert hasattr(seobject, 'seluserRecords'), "seluserRecords missing"

print("python3-seobject OK")
EOF
	;;
*)
	exit 0
	;;
esac
