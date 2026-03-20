#!/bin/sh

[ "$1" = python3-zipp ] || exit 0

python3 - <<'EOF'
import io
import zipfile
import zipp

# Create an in-memory zip with a nested structure
buf = io.BytesIO()
with zipfile.ZipFile(buf, "w") as zf:
    zf.writestr("a/b/c.txt", "hello")
    zf.writestr("a/d.txt", "world")
buf.seek(0)

zf = zipfile.ZipFile(buf)
root = zipp.Path(zf)

# Navigate and read
c = root / "a" / "b" / "c.txt"
assert c.read_text() == "hello", f"unexpected content: {c.read_text()!r}"

d = root / "a" / "d.txt"
assert d.read_text() == "world", f"unexpected content: {d.read_text()!r}"

# Test iterdir
names = {p.name for p in (root / "a").iterdir()}
assert names == {"b", "d.txt"}, f"unexpected names: {names}"

# Test is_file / is_dir
assert c.is_file()
assert (root / "a" / "b").is_dir()
EOF
