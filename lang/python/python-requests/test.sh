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

# --- charset-normalizer backend (replaces chardet) ---
# requests now pulls in charset-normalizer instead of chardet for content
# charset detection. Verify both the standalone library and the path that
# requests actually exercises (Response.apparent_encoding).
import charset_normalizer
from charset_normalizer import from_bytes

sample = 'Bсеки човек има право на образование.'
encoded = sample.encode('cp1251')

# Standalone detection + decode round-trip.
best = from_bytes(encoded).best()
assert best is not None
assert str(best) == sample

# chardet-compatible detect() shim — this is the exact call requests makes.
detected = charset_normalizer.detect(encoded)
assert detected['encoding'] is not None

# requests routes content charset detection through charset-normalizer.
resp = requests.models.Response()
resp._content = encoded
enc = resp.apparent_encoding
assert enc, "apparent_encoding should be resolved via charset-normalizer"
resp.encoding = enc
assert 'образование' in resp.text

print("requests + charset-normalizer OK")
EOF
