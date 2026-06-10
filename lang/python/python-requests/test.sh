#!/bin/sh

[ "$1" = python3-requests ] || exit 0

python3 - << 'EOF'
import requests

# Verify version and key attributes
assert requests.__version__

# Verify core API is present
assert hasattr(requests, 'get')
assert hasattr(requests, 'post')
assert hasattr(requests, 'put')
assert hasattr(requests, 'delete')
assert hasattr(requests, 'head')
assert hasattr(requests, 'Session')
assert hasattr(requests, 'Request')
assert hasattr(requests, 'Response')
assert hasattr(requests, 'PreparedRequest')

# Test Session creation and basic functionality
s = requests.Session()
assert s is not None

# Test that Request object can be created and prepared
req = requests.Request('GET', 'http://example.com', headers={'User-Agent': 'test'})
prepared = req.prepare()
assert prepared.method == 'GET'
assert prepared.url == 'http://example.com/'
assert prepared.headers['User-Agent'] == 'test'

# Test exceptions are importable
from requests.exceptions import (
    RequestException, ConnectionError, HTTPError, URLRequired,
    TooManyRedirects, Timeout, ConnectTimeout, ReadTimeout
)

print("requests OK")
EOF
