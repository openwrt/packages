#!/bin/sh

[ "$1" = python3-boto3 ] || exit 0

python3 - << 'EOF'
import boto3
from botocore.stub import Stubber

# Test client creation (no real AWS credentials needed)
client = boto3.client("s3", region_name="us-east-1")
assert client is not None

# Test with stubber (no network)
stubber = Stubber(client)
stubber.add_response(
    "list_buckets",
    {"Buckets": [{"Name": "my-bucket", "CreationDate": __import__("datetime").datetime.now()}]},
)
with stubber:
    response = client.list_buckets()
    assert len(response["Buckets"]) == 1
    assert response["Buckets"][0]["Name"] == "my-bucket"
EOF
