#!/bin/sh

[ "$1" = python3-flask ] || exit 0

python3 - <<EOF
import sys
import flask

if flask.__version__ != "$2":
    print("Wrong version: " + flask.__version__)
    sys.exit(1)

app = flask.Flask(__name__)
app.config["TESTING"] = True
app.config["SECRET_KEY"] = "test-secret"

@app.route("/")
def index():
    return "Hello, OpenWrt!"

@app.route("/greet/<name>")
def greet(name):
    return flask.jsonify(message=f"Hello, {name}!")

@app.route("/session-test")
def session_test():
    flask.session["key"] = "value"
    return "ok"

with app.test_client() as client:
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.data == b"Hello, OpenWrt!"

    resp = client.get("/greet/World")
    assert resp.status_code == 200
    data = flask.json.loads(resp.data)
    assert data["message"] == "Hello, World!"

    resp = client.get("/session-test")
    assert resp.status_code == 200

print("python-flask OK")
EOF
