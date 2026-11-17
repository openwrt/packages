[ "$1" = python3-pycares ] || exit 0

python3 - << 'EOF'
import pycares

# Verify key classes and constants
assert hasattr(pycares, "Channel")
assert hasattr(pycares, "QUERY_TYPE_A")
assert hasattr(pycares, "QUERY_TYPE_AAAA")

# Verify version
assert hasattr(pycares, "__version__")
print(f"pycares version: {pycares.__version__}")

# Create a channel (without actually making DNS queries)
channel = pycares.Channel()
assert channel is not None

print("python3-pycares OK")
EOF
