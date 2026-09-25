#!/bin/sh

[ "$1" = python3-selinux ] || exit 0

python3 - <<'EOF'
import selinux

# Verify key functions are available from the C extension
assert hasattr(selinux, 'is_selinux_enabled'), "is_selinux_enabled missing"
assert hasattr(selinux, 'getfilecon'), "getfilecon missing"
assert hasattr(selinux, 'matchpathcon'), "matchpathcon missing"
assert hasattr(selinux, 'selinux_getenforcemode'), "selinux_getenforcemode missing"
assert hasattr(selinux, 'security_check_context'), "security_check_context missing"
assert hasattr(selinux, 'context_new'), "context_new missing"

# Validate context parsing (works without a running SELinux system)
ctx = selinux.context_new("system_u:object_r:bin_t:s0")
assert ctx is not None, "context_new returned None"
assert selinux.context_type_get(ctx) == "bin_t"
assert selinux.context_role_get(ctx) == "object_r"
assert selinux.context_user_get(ctx) == "system_u"
assert selinux.context_range_get(ctx) == "s0"

print("python3-selinux OK")
EOF
