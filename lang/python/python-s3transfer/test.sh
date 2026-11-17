#!/bin/sh

[ "$1" = python3-s3transfer ] || exit 0

python3 - << 'EOF'
import botocore.session
from botocore.stub import Stubber
from s3transfer.manager import TransferManager, TransferConfig

session = botocore.session.get_session()
client = session.create_client("s3", region_name="us-east-1")

# Verify TransferConfig defaults
config = TransferConfig()
assert config.multipart_threshold > 0
assert config.max_request_concurrency > 0
assert config.max_submission_concurrency > 0

# Verify manager can be instantiated
manager = TransferManager(client, config)
assert manager is not None
manager.__exit__(None, None, None)
EOF
