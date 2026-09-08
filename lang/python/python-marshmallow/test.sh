#!/bin/sh

[ "$1" = python3-marshmallow ] || exit 0

python3 - << 'EOF'

from marshmallow import Schema, fields, ValidationError

# Round-trip a schema: dump a dict, load and type-coerce it back, then confirm
# a missing required field is rejected with ValidationError.
class UserSchema(Schema):
    name = fields.Str(required=True)
    age = fields.Int()

s = UserSchema()
assert s.dump({"name": "ow", "age": 3}) == {"name": "ow", "age": 3}
assert s.load({"name": "ow", "age": "5"}) == {"name": "ow", "age": 5}
try:
    s.load({"age": 1})
    raise SystemExit("required field not enforced")
except ValidationError:
    pass

EOF
