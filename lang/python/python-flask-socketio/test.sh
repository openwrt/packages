#!/bin/sh

[ "$1" = python3-flask-socketio ] || exit 0

python3 - <<EOF
import sys
from flask import Flask
from flask_socketio import SocketIO, emit

import flask_socketio
if flask_socketio.__version__ != "$2":
    print("Wrong version: " + flask_socketio.__version__)
    sys.exit(1)

app = Flask(__name__)
app.config["SECRET_KEY"] = "test-secret"
socketio = SocketIO(app)

@socketio.on("ping")
def handle_ping(data):
    emit("pong", {"msg": data["msg"]})

client = socketio.test_client(app)
assert client.is_connected()

client.emit("ping", {"msg": "hello"})
received = client.get_received()
assert len(received) == 1
assert received[0]["name"] == "pong"
assert received[0]["args"][0]["msg"] == "hello"

client.disconnect()
assert not client.is_connected()

print("python-flask-socketio OK")
EOF
