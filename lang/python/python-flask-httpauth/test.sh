#!/bin/sh

[ "$1" = python3-flask-httpauth ] || exit 0

python3 - << 'EOF'
from flask import Flask
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
auth = HTTPBasicAuth()

users = {"alice": "secret"}

@auth.verify_password
def verify_password(username, password):
    return users.get(username) == password

@app.route("/protected")
@auth.login_required
def protected():
    return f"Hello, {auth.current_user()}!"

with app.test_client() as client:
    # No auth -> 401
    resp = client.get("/protected")
    assert resp.status_code == 401, f"Expected 401, got {resp.status_code}"

    # Wrong password -> 401
    import base64
    bad = base64.b64encode(b"alice:wrong").decode()
    resp = client.get("/protected", headers={"Authorization": f"Basic {bad}"})
    assert resp.status_code == 401, f"Expected 401, got {resp.status_code}"

    # Correct credentials -> 200
    good = base64.b64encode(b"alice:secret").decode()
    resp = client.get("/protected", headers={"Authorization": f"Basic {good}"})
    assert resp.status_code == 200, f"Expected 200, got {resp.status_code}"
    assert b"Hello, alice" in resp.data
EOF
