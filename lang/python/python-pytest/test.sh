#!/bin/sh

[ "$1" = python3-pytest ] || exit 0

# Verify version
python3 - << EOF
import importlib.metadata, sys
version = importlib.metadata.version("pytest")
if version != "$2":
    print("Wrong version: " + version)
    sys.exit(1)
EOF
[ $? -eq 0 ] || exit 1

# Run pytest against a temporary suite that exercises core features
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cat > "$TMPDIR/test_suite.py" << 'PYEOF'
import pytest

# --- basic pass/fail ---

def test_passing():
    assert 1 + 1 == 2

# --- pytest.raises ---

def test_raises():
    with pytest.raises(ZeroDivisionError):
        1 / 0

def test_raises_match():
    with pytest.raises(ValueError, match="invalid"):
        raise ValueError("invalid literal")

# --- parametrize ---

@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert a + b == expected

# --- fixtures ---

@pytest.fixture
def sample_list():
    return [1, 2, 3]

def test_fixture_used(sample_list):
    assert len(sample_list) == 3
    assert sum(sample_list) == 6

@pytest.fixture
def doubled(sample_list):
    return [x * 2 for x in sample_list]

def test_fixture_chaining(doubled):
    assert doubled == [2, 4, 6]

# --- skip / xfail ---

@pytest.mark.skip(reason="intentional skip")
def test_skipped():
    assert False  # never runs

@pytest.mark.xfail(reason="expected failure")
def test_xfail():
    assert False

@pytest.mark.xfail(reason="unexpectedly passes")
def test_xpass():
    assert True

# --- capsys fixture ---

def test_capsys(capsys):
    print("hello pytest")
    out, err = capsys.readouterr()
    assert out == "hello pytest\n"
    assert err == ""

# --- tmp_path fixture ---

def test_tmp_path(tmp_path):
    f = tmp_path / "hello.txt"
    f.write_text("world")
    assert f.read_text() == "world"

# --- monkeypatch fixture ---

def get_value():
    return 42

def test_monkeypatch(monkeypatch):
    import test_suite
    monkeypatch.setattr(test_suite, "get_value", lambda: 99)
    assert get_value() == 99

PYEOF

# Run pytest: expect all to pass (xpass counts as pass by default)
python3 -m pytest "$TMPDIR/test_suite.py" -v --tb=short 2>&1
STATUS=$?

# xpass (test_xpass) causes exit code 0 by default — that's fine
[ $STATUS -eq 0 ] || exit 1
