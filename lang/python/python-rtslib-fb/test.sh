#!/bin/sh

[ "$1" = "python3-rtslib-fb" ] || exit 0

python3 - << EOF
import sys

# Verify key classes and exceptions are importable
from rtslib_fb import (
    RTSLibError,
    RTSLibNotInCFSError,
    FabricModule,
    RTSRoot,
    Target,
    TPG,
    LUN,
    NetworkPortal,
    NodeACL,
    BlockStorageObject,
    FileIOStorageObject,
    RDMCPStorageObject,
)

# Test pure utility functions (no kernel/configfs required)
from rtslib_fb.utils import colonize, generate_wwn, normalize_wwn

# colonize: inserts colons every 2 hex characters
assert colonize("aabbccdd") == "aa:bb:cc:dd", f"Unexpected: {colonize('aabbccdd')}"
assert colonize("112233445566") == "11:22:33:44:55:66"
assert colonize("ab") == "ab"

# generate_wwn: returns correctly formatted WWNs
import re

iqn = generate_wwn("iqn")
assert iqn.startswith("iqn."), f"IQN should start with 'iqn.': {iqn}"
assert re.match(r"iqn\.\d{4}-\d{2}\.", iqn), f"IQN format invalid: {iqn}"

naa = generate_wwn("naa")
assert naa.startswith("naa."), f"NAA should start with 'naa.': {naa}"

serial = generate_wwn("unit_serial")
assert re.match(r"[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$", serial), \
    f"unit_serial format invalid: {serial}"

# normalize_wwn: accepts various representations and normalizes them
wwn, wwn_type = normalize_wwn(["naa"], "naa.5000c50012345678")
assert wwn_type == "naa", f"Expected naa, got {wwn_type}"
assert wwn == "naa.5000c50012345678", f"Unexpected: {wwn}"

# NAA without prefix gets one added
wwn2, _ = normalize_wwn(["naa"], "5000c50012345678")
assert wwn2 == "naa.5000c50012345678", f"Unexpected: {wwn2}"

# RTSLibError is a proper exception
try:
    raise RTSLibError("test error")
except RTSLibError as e:
    assert str(e) == "test error"

# RTSLibNotInCFSError is a subclass of RTSLibError
assert issubclass(RTSLibNotInCFSError, RTSLibError)

sys.exit(0)
EOF
