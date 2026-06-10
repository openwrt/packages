#!/bin/sh

[ "$1" = "python3-iniconfig" ] || exit 0

python3 - << EOF
import sys
import iniconfig
import tempfile, os

# Write a simple INI file and parse it
ini = "[section1]\nkey1 = value1\nkey2 = 42\n\n[section2]\nflag = true\n"
with tempfile.NamedTemporaryFile(mode="w", suffix=".ini", delete=False) as f:
    f.write(ini)
    tmp = f.name

try:
    cfg = iniconfig.IniConfig(tmp)
    assert cfg["section1"]["key1"] == "value1", "key1 mismatch"
    assert cfg["section1"]["key2"] == "42", "key2 mismatch"
    assert cfg["section2"]["flag"] == "true", "flag mismatch"
    assert "section1" in cfg, "section1 not found"
    assert "missing" not in cfg, "missing section should not exist"
finally:
    os.unlink(tmp)

sys.exit(0)
EOF
