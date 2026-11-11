#!/usr/bin/env ash
# lib/chandler.sh: C compiled bin handler
BIN_DIR="/usr/lib/nss-switch/bin"
LIB_DIR="/usr/lib/nss-switch/lib"
HAS_CT_DUMP="no"
if [ -f "$BIN_DIR/nss-ct-dump" ] && [ -x "$BIN_DIR/nss-ct-dump" ]; then
    HAS_CT_DUMP="yes"
    CT_DUMP_BIN="$BIN_DIR/nss-ct-dump"
fi
export HAS_CT_DUMP
export BIN_DIR
export LIB_DIR
export CT_DUMP_BIN
