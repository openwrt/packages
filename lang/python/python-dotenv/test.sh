#!/bin/sh

[ "$1" = python3-dotenv ] || exit 0

python3 - << 'EOF'
import os
import tempfile
from dotenv import dotenv_values, load_dotenv, set_key, get_key

# Write a temp .env file and parse it
with tempfile.NamedTemporaryFile(mode='w', suffix='.env', delete=False) as f:
    f.write('FOO=bar\n')
    f.write('BAZ=123\n')
    f.write('QUOTED="hello world"\n')
    env_path = f.name

try:
    values = dotenv_values(env_path)
    assert values['FOO'] == 'bar', f"got FOO={values['FOO']}"
    assert values['BAZ'] == '123', f"got BAZ={values['BAZ']}"
    assert values['QUOTED'] == 'hello world', f"got QUOTED={values['QUOTED']}"

    # Test load_dotenv sets environment variables
    load_dotenv(env_path, override=True)
    assert os.environ.get('FOO') == 'bar'
    assert os.environ.get('BAZ') == '123'
finally:
    os.unlink(env_path)

print("python-dotenv OK")
EOF
