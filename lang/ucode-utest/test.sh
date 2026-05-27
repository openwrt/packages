#!/bin/sh
case "$1" in
    "ucode-utest")
        tmpdir=$(mktemp -d)
        trap 'rm -rf "$tmpdir"' EXIT
        cat > "$tmpdir/smoke_test.uc" <<'EOF'
import { describe, it, assert } from 'utest';
describe("smoke", () => {
    it("framework is installed correctly", () => {
        assert.equal(1 + 1, 2);
    });
});
EOF
        utest "$tmpdir/smoke_test.uc"
        ;;
esac
