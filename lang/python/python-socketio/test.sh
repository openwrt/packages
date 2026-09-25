#!/bin/sh

[ "$1" = python3-socketio ] || exit 0

python3 - <<'EOF'
import socketio

# Test server creation and event registration
sio = socketio.Server()

received = []

@sio.event
def connect(sid, environ):
    received.append(('connect', sid))

@sio.event
def message(sid, data):
    received.append(('message', data))

@sio.event
def disconnect(sid):
    received.append(('disconnect', sid))

# Verify the handlers are registered
assert 'connect' in sio.handlers['/']
assert 'message' in sio.handlers['/']
assert 'disconnect' in sio.handlers['/']

# Test namespace creation
ns = socketio.Namespace('/test')
sio.register_namespace(ns)
assert '/test' in sio.namespace_handlers

# Test AsyncServer exists
asio = socketio.AsyncServer()
assert asio is not None
EOF
