#!/usr/bin/env bash
# Check CIRCLE_COMPARE_URL first and if its not set, check for diff with target branch.

set -o pipefail

source $BASH_ENV

if [[ ! -z "$CIRCLE_COMPARE_URL" ]]; then
    # CIRCLE_COMPARE_URL is not empty, use it to get the diff
    if [[ $CIRCLE_COMPARE_URL = *"commit"* ]]; then
        commit_range=$(echo $CIRCLE_COMPARE_URL | sed 's:^.*/commit/::g')~1
    else
        commit_range=$(echo $CIRCLE_COMPARE_URL | sed 's:^.*/compare/::g')
    fi
    echo_blue "Diff: $commit_range"
    changes="$(git diff $commit_range --name-only)"
else
    # CIRCLE_COMPARE_URL is not set, diff with $BRANCH/HEAD
    commit_range="origin/$BRANCH..$CIRCLE_SHA1"
    echo_blue "Diff: $commit_range"
    changes="$(git diff-tree --no-commit-id --name-only -r $commit_range)"
fi

echo_blue "Changes in this build:"
echo_blue $changes
echo
# Return commit range
echo "export COMMIT_RANGE=$commit_range" >> $BASH_ENV
