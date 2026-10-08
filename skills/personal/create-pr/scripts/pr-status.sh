#!/usr/bin/env bash
# Print repo, branch, and PR/MR context for the create-pr skill.
# Usage: pr-status.sh [gh|gl] [repo-path]   (args may also arrive on stdin)
# Always exits 0, because a failing injection command aborts the whole skill.

args="$*"
[ -z "$args" ] && [ ! -t 0 ] && args="$(cat)"

set -f
hint="" path=""
for word in $args; do
  case "$word" in
    gh|gl) [ -z "$hint" ] && hint="$word" ;;
    /*|\~*|./*|../*|.|..) [ -z "$path" ] && path="$word" ;;
  esac
done
set +f
case "$path" in
  \~) path="$HOME" ;;
  \~/*) path="$HOME/${path#\~/}" ;;
esac

echo "- VCS hint: ${hint:-(none)}"
echo "- Repo path argument: ${path:-(none, using session cwd)}"

root="$(git -C "${path:-.}" rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$root" ]; then
  echo
  echo "ERROR: ${path:-$PWD} is not a git repository. Stop and report this error. Do not fall back to another repo."
  exit 0
fi
g() { git -C "$root" "$@" 2>/dev/null; }

remote="$(g remote get-url origin)"
hosts="$HOME/.config/dgokcin-skills/gitlab-hosts"
is_gitlab_remote() {
  echo "$remote" | grep -q gitlab || { [ -f "$hosts" ] && echo "$remote" | grep -qFf "$hosts"; }
}
if [ "$hint" = gl ] || { [ -z "$hint" ] && is_gitlab_remote; }; then
  vcs=gitlab
else
  vcs=github
fi

# owner/name (or group/sub/name) from https://host/x/y.git or git@host:x/y.git
slug="$(echo "$remote" | sed -E 's#^[a-z+]+://[^/]+/##; s#^[^@]+@[^:]+:##; s#\.git$##')"
branch="$(g branch --show-current)"
base="$(g symbolic-ref --short refs/remotes/origin/HEAD)"
base="${base#origin/}"

echo "- Worktree root: $root"
echo "- Git dir: $(g rev-parse --git-dir)"
echo "- Remote URL: ${remote:-(none)}"
echo "- VCS: $vcs"
echo "- Repo slug: ${slug:-(unknown)}"
echo "- Current branch: ${branch:-(detached)}"
echo "- Base branch: ${base:-(unknown)}"
echo "- Tracking branch: $(g rev-parse --abbrev-ref --symbolic-full-name '@{u}' || echo none)"
echo "- Worktree list:"
g worktree list | head -5 | sed 's/^/  /'

echo
echo "### PR/MR Status"
echo
if [ "$vcs" = gitlab ]; then
  glab mr view "$branch" -R "$slug" -F json 2>/dev/null && echo "MODE: UPDATE (MR exists)" || echo "MODE: CREATE (no existing MR)"
else
  gh pr view "$branch" -R "$slug" --json number,title,state,url 2>/dev/null && echo "MODE: UPDATE (PR exists)" || echo "MODE: CREATE (no existing PR)"
fi

echo
echo "### Uncommitted Changes"
echo
changes="$(g status --short)"
echo "${changes:-(clean)}"

range="-10"
[ -n "$base" ] && range="origin/$base..HEAD"
echo
echo "### Commits on Branch"
echo
g log --format='%h %s%n%b' "$range" | sed '/^$/d'

if [ -n "$base" ]; then
  echo
  echo "### Diff vs origin/$base (first 400 lines)"
  echo
  g diff --stat "origin/$base...HEAD"
  echo
  g diff "origin/$base...HEAD" | head -400
fi
exit 0
