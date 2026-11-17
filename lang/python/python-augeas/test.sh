#!/bin/sh

[ "$1" = python3-augeas ] || exit 0

python3 - <<'EOF'
import augeas

# Basic instantiation (in-memory, no files touched)
a = augeas.Augeas(root="/dev/null", loadpath=None,
                  flags=augeas.Augeas.NO_LOAD | augeas.Augeas.NO_MODL_AUTOLOAD)

# Set and get a value
a.set("/test/key", "value")
assert a.get("/test/key") == "value", "get after set failed"

# Match
a.set("/test/a", "1")
a.set("/test/b", "2")
matches = a.match("/test/*")
assert len(matches) == 3, f"Expected 3 matches, got {len(matches)}"

# Remove
a.remove("/test/key")
assert a.get("/test/key") is None, "Expected None after remove"

a.close()
print("python-augeas OK")
EOF
