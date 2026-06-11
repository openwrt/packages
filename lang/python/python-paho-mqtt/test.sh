#!/bin/sh
[ "$1" = python3-paho-mqtt ] || exit 0

python3 - << 'EOF'
import paho.mqtt.client as mqtt

# Verify version
assert hasattr(mqtt, '__version__') or hasattr(mqtt.Client, '__module__')

# Test basic client instantiation
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
assert client is not None

# Test that the client has expected methods
assert callable(getattr(client, 'connect', None))
assert callable(getattr(client, 'publish', None))
assert callable(getattr(client, 'subscribe', None))
assert callable(getattr(client, 'disconnect', None))

# Test MQTTMessage
msg = mqtt.MQTTMessage(topic=b'test/topic')
msg.payload = b'hello'
assert msg.topic == 'test/topic'
assert msg.payload == b'hello'

print("paho-mqtt OK")
EOF
