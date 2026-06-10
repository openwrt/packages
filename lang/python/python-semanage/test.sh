#!/bin/sh

[ "$1" = python3-semanage ] || exit 0

python3 - <<'EOF'
import semanage

# Verify the C extension loaded and key functions/constants are available
assert hasattr(semanage, 'semanage_handle_create'), "semanage_handle_create missing"
assert hasattr(semanage, 'SEMANAGE_CON_DIRECT'), "SEMANAGE_CON_DIRECT missing"
assert hasattr(semanage, 'SEMANAGE_CON_INVALID'), "SEMANAGE_CON_INVALID missing"
assert hasattr(semanage, 'SEMANAGE_FCONTEXT_ALL'), "SEMANAGE_FCONTEXT_ALL missing"
assert hasattr(semanage, 'SEMANAGE_FCONTEXT_REG'), "SEMANAGE_FCONTEXT_REG missing"

print("python3-semanage OK")
EOF
