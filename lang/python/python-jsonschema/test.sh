#!/bin/sh

[ "$1" = python3-jsonschema ] || exit 0

python3 - << 'EOF'

from jsonschema import validate

# A sample schema, like what we'd get from json.load()
schema = {
    "type" : "object",
    "properties" : {
        "price" : {"type" : "number"},
        "name" : {"type" : "string"},
    },
}

# If no exception is raised by validate(), the instance is valid.
validate(instance={"name" : "Eggs", "price" : 34.99}, schema=schema)

EOF
