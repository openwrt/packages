#!/bin/sh

[ "$1" = python3-ubus ] || exit 0

python3 - << 'EOF'
import ubus

# Constants must be present
assert hasattr(ubus, "BLOBMSG_TYPE_STRING"), "missing BLOBMSG_TYPE_STRING"
assert hasattr(ubus, "BLOBMSG_TYPE_BOOL"),   "missing BLOBMSG_TYPE_BOOL"
assert hasattr(ubus, "BLOBMSG_TYPE_INT32"),  "missing BLOBMSG_TYPE_INT32"

# Not connected by default
assert ubus.get_connected() is False, "should not be connected on import"
assert ubus.get_socket_path() is None, "socket path should be None when not connected"

# Connecting to a non-existent socket must raise IOError
try:
    ubus.connect(socket_path="/non/existing/ubus.sock")
    raise AssertionError("expected IOError for missing socket")
except IOError:
    pass

# Operations that require a connection must raise RuntimeError when disconnected
for fn, args in [
    (ubus.disconnect, ()),
    (ubus.send,       ("event", {})),
    (ubus.loop,       (1,)),
    (ubus.objects,    ()),
]:
    try:
        fn(*args)
        raise AssertionError(f"{fn.__name__} should raise RuntimeError when not connected")
    except RuntimeError:
        pass
EOF
