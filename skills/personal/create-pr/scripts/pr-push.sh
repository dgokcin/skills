#!/usr/bin/env bash
# Push the current branch of a repo to origin with upstream tracking.
# Usage: pr-push.sh <repo-path>
set -euo pipefail

root="$(git -C "${1:?usage: pr-push.sh <repo-path>}" rev-parse --show-toplevel)"
branch="$(git -C "$root" branch --show-current)"
base="$(git -C "$root" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"

[ -n "$branch" ] || { echo "error: $root is on a detached HEAD" >&2; exit 1; }
[ "$branch" != "${base#origin/}" ] || { echo "error: refusing to push the base branch $branch" >&2; exit 1; }

git -C "$root" push -u origin HEAD
