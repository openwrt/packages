[ "$1" = python3-bleak ] || exit 0

python3 - << 'EOF'
import bleak
from bleak import BleakScanner, BleakClient
from bleak.backends.device import BLEDevice
from bleak.backends.scanner import AdvertisementData

assert bleak.__author__ is not None
assert BleakScanner is not None
assert BleakClient is not None
assert BLEDevice is not None
assert AdvertisementData is not None

print("python3-bleak OK")
EOF
