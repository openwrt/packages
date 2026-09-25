#!/bin/sh

[ "$1" = python3-sentry-sdk ] || exit 0

python3 - << 'EOF'
import sentry_sdk
from sentry_sdk import capture_message, capture_exception
from sentry_sdk.transport import Transport

class NoopTransport(Transport):
    def __init__(self):
        self.events = []
    def capture_envelope(self, envelope):
        self.events.append(envelope)

transport = NoopTransport()
sentry_sdk.init(dsn="", transport=transport)

# capture_message should not raise
capture_message("test message")

# capture_exception should not raise
try:
    raise ValueError("test error")
except ValueError:
    capture_exception()

sentry_sdk.flush()
EOF
