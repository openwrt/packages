#!/bin/sh

[ "$1" = python3-influxdb ] || exit 0

python3 - << 'EOF'
from influxdb import DataFrameClient, InfluxDBClient
from influxdb.line_protocol import make_lines

# Test line protocol generation (no server needed)
data = [
    {
        "measurement": "cpu",
        "tags": {"host": "server01"},
        "fields": {"value": 0.64},
    }
]
line = make_lines({"points": data}).strip()
assert line.startswith("cpu,host=server01"), f"Unexpected line: {line}"
assert "value=0.64" in line

# Test client instantiation (no connection)
client = InfluxDBClient(host="localhost", port=8086, database="testdb")
assert client._host == "localhost"
assert client._port == 8086
EOF
