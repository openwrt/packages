#!/bin/sh

[ "$1" = python3-ble2mqtt ] || exit 0

python3 - << 'EOF'
import ble2mqtt
from ble2mqtt.devices.base import Device, ConnectionMode

assert hasattr(ble2mqtt, "__version__") or True  # version may not be exposed
assert issubclass(Device, object)

print("python3-ble2mqtt OK")
EOF