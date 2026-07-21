#!/bin/sh

[ "$1" = "python3-pexpect" ] || exit 0

# current installed version from python metadata
installed_version="$(python3 -c 'import pexpect; print(pexpect.__version__)')"

# use expected version from package metadata/environment
expected_version="${PKG_VERSION}"

if [ "$installed_version" != "$expected_version" ]; then
    echo "Wrong version: $installed_version (expected $expected_version)"
    exit 1
fi

python3 - << 'EOF'
import pexpect

pattern = "pexpect-test"
child = pexpect.spawn('sh', ['-c', 'printf "%s\\n" "pexpect-test"'], encoding='utf-8')
child.expect_exact(pattern)
child.expect(pexpect.EOF)
child.close()
assert child.exitstatus == 0, f"child exited {child.exitstatus}"

print("python3-pexpect OK")
EOF
