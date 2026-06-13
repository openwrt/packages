#!/bin/sh
case "$1" in
    "ucode-utest")
        tmpdir=$(mktemp -d)
        trap 'rm -rf "$tmpdir"' EXIT
        cat > "$tmpdir/smoke_test.uc" <<'EOF'
import { describe, it, assert } from 'utest';
describe("smoke", () => {
    it("framework is installed correctly", () => {
        assert.match(2, 1 + 1);
    });
});
EOF
        utest "$tmpdir/smoke_test.uc"
        ;;
esac
