#!/bin/sh

[ "$1" = python3-awscli ] || exit 0

python3 - << 'EOF'
from awscli.clidriver import create_clidriver

# Verify CLI driver can be created
driver = create_clidriver()
assert driver is not None

# Verify help text is available for s3 command
import awscli.topics
assert hasattr(awscli.topics, "TOPIC_TAGS")
EOF

# Verify the aws binary runs --version
aws --version 2>&1 | grep -q "aws-cli" || {
    echo "ERROR: 'aws --version' did not produce expected output"
    exit 1
}
