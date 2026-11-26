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

# Regression test: mount_configfs() must expand the mount point in the command
# it runs. Version 2.2.4 passed a literal "{config_dir}" to mount because of a
# missing f-string, so RTSRoot() could never mount configfs on its own.
import subprocess
import rtslib_fb.utils as rtsutils

calls = []

def fake_run(cmdline, **kwargs):
    calls.append(cmdline)
    return subprocess.CompletedProcess(cmdline, 0, b"", b"")

orig_run = rtsutils.subprocess.run
orig_is_mount = rtsutils.Path.is_mount
rtsutils.subprocess.run = fake_run
rtsutils.Path.is_mount = lambda self: False
try:
    rtsutils.mount_configfs()
finally:
    rtsutils.subprocess.run = orig_run
    rtsutils.Path.is_mount = orig_is_mount

assert calls, "mount_configfs() did not try to mount configfs"
cmd = calls[0] if isinstance(calls[0], str) else " ".join(calls[0])
assert "{" not in cmd and "/sys/kernel/config" in cmd, f"Bad mount command: {cmd!r}"

# RTSRoot() needs /etc/target as its dbroot; the package creates it.
import os
assert os.path.isdir("/etc/target"), "/etc/target is missing"

sys.exit(0)
EOF
