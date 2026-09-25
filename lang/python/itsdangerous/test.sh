#!/bin/sh

[ "$1" = python3-itsdangerous ] || exit 0

python3 - << 'EOF'
from itsdangerous import URLSafeSerializer, URLSafeTimedSerializer, BadSignature

s = URLSafeSerializer("secret-key")
token = s.dumps({"user_id": 42, "role": "admin"})
assert isinstance(token, str)
data = s.loads(token)
assert data["user_id"] == 42
assert data["role"] == "admin"

# Test that tampered tokens are rejected
try:
    s.loads(token + "tampered")
    assert False, "should have raised BadSignature"
except BadSignature:
    pass

# Test timed serializer
ts = URLSafeTimedSerializer("another-secret")
timed_token = ts.dumps("payload")
assert ts.loads(timed_token) == "payload"

print("python3-itsdangerous OK")
EOF
