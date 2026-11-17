#!/bin/sh

[ "$1" = python3-protobuf ] || exit 0

python3 - << 'EOF'

from google.protobuf import struct_pb2, timestamp_pb2

# Well-known types exercise the descriptor pool, encoder and decoder without
# needing a compiled .proto: serialize a scalar message and a map-backed one,
# then parse the bytes back and confirm the fields survive the round-trip.
ts = timestamp_pb2.Timestamp(seconds=1710000000, nanos=123)
back = timestamp_pb2.Timestamp()
back.ParseFromString(ts.SerializeToString())
assert back.seconds == 1710000000 and back.nanos == 123

s = struct_pb2.Struct()
s["name"] = "openwrt"
s["count"] = 3
s2 = struct_pb2.Struct()
s2.ParseFromString(s.SerializeToString())
assert s2["name"] == "openwrt" and s2["count"] == 3

EOF
