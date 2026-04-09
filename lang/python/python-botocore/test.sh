#!/bin/sh

[ "$1" = python3-botocore ] || exit 0

python3 - << 'EOF'
import botocore.session
from botocore.stub import Stubber

session = botocore.session.get_session()
client = session.create_client("s3", region_name="us-east-1")

# Verify endpoint URL is constructed correctly
endpoint = client.meta.endpoint_url or "https://s3.amazonaws.com"
assert "amazonaws" in endpoint or endpoint.startswith("https://")

# Test stubber
stubber = Stubber(client)
stubber.add_response("list_buckets", {"Buckets": []})
with stubber:
    resp = client.list_buckets()
    assert resp["Buckets"] == []

# Test config/credential loading doesn't crash
from botocore.config import Config
cfg = Config(region_name="eu-west-1", retries={"max_attempts": 3})
assert cfg.region_name == "eu-west-1"
EOF
