#!/bin/sh

[ "$1" = "git-lfs" ] || exit 0

# Verify git-lfs registers itself as a git extension and core commands work
git lfs help 2>&1 | grep -q "track"

# Verify git-lfs env shows it is wired into git
git lfs env 2>&1 | grep -qi "git\|lfs\|endpoint"

# Verify key subcommands are available
git lfs help track 2>&1 | grep -qi "track"
git lfs help push  2>&1 | grep -qi "push"
git lfs help pull  2>&1 | grep -qi "pull"
