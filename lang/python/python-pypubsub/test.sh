#!/bin/sh

[ "$1" = python3-pypubsub ] || exit 0

python3 - << 'EOF'
from pubsub import pub

received = []

def on_message(msg):
    received.append(msg)

pub.subscribe(on_message, "test.topic")
pub.sendMessage("test.topic", msg="hello")

assert received == ["hello"], f"Expected ['hello'], got {received}"

pub.unsubscribe(on_message, "test.topic")
pub.sendMessage("test.topic", msg="world")
assert received == ["hello"], "Unsubscribed listener should not receive messages"

print("python3-pypubsub OK")
EOF
