#!/bin/sh

[ "$1" = python3-drf-nested-routers ] || exit 0

python3 - << 'EOF'
import django
from django.conf import settings
settings.configure(
    INSTALLED_APPS=['rest_framework'],
    DATABASES={},
)

from rest_framework_nested import routers

router = routers.SimpleRouter()
assert router is not None

# Verify NestedSimpleRouter is importable
from rest_framework_nested.routers import NestedSimpleRouter
assert NestedSimpleRouter is not None

print("python3-drf-nested-routers OK")
EOF
