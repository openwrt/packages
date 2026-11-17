#!/bin/sh

[ "$1" = python3-referencing ] || exit 0

python3 - << 'EOF'

from referencing import Registry, Resource
import referencing.jsonschema

schema = Resource.from_contents(  # Parse some contents into a 2020-12 JSON Schema
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "$id": "urn:example:a-202012-schema",
        "$defs": {
            "nonNegativeInteger": {
                "$anchor": "nonNegativeInteger",
                "type": "integer",
                "minimum": 0,
            },
        },
    }
)
registry = schema @ Registry()  # Add the resource to a new registry

# From here forward, this would usually be done within a library wrapping this one,
# like a JSON Schema implementation
resolver = registry.resolver()
resolved = resolver.lookup("urn:example:a-202012-schema#nonNegativeInteger")
assert resolved.contents == {
    "$anchor": "nonNegativeInteger",
    "type": "integer",
    "minimum": 0,
}

EOF
