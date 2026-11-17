[ "$1" = python3-fnv-hash-fast ] || exit 0

python3 - << 'EOF'
from fnv_hash_fast import fnv1a_32

# FNV-1a 32-bit hash of empty string is 0x811c9dc5
result = fnv1a_32(b"")
assert result == 0x811c9dc5, f"Expected 0x811c9dc5, got {hex(result)}"

# FNV-1a 32-bit hash of "hello"
result2 = fnv1a_32(b"hello")
assert result2 != result

print("python3-fnv-hash-fast OK")
EOF
