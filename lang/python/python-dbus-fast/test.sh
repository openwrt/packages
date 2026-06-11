#!/bin/sh

[ "$1" = python3-dbus-fast ] || exit 0

PKG_VERSION="$2"

python3 - "$PKG_VERSION" << 'EOF'
import sys
from dbus_fast.message import Message
from dbus_fast.constants import MessageType
from dbus_fast.signature import Variant
from dbus_fast.__version__ import __version__

assert __version__ == sys.argv[1], f"expected {sys.argv[1]}, got {__version__}"

msg = Message(
    message_type=MessageType.METHOD_CALL,
    path="/org/example/Test",
    interface="org.example.Test",
    member="TestMethod",
)
assert msg.path == "/org/example/Test"
assert msg.interface == "org.example.Test"
assert msg.member == "TestMethod"

v = Variant("s", "hello")
assert v.type.token == "s"
assert v.value == "hello"

print("python3-dbus-fast OK")
EOF
