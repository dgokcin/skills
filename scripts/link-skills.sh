#!/usr/bin/env bash
set -euo pipefail

# Links this repo into every local agent harness:
#   skills/<bucket>/<name>  -> ~/.claude/skills, ~/.agents/skills (Codex, Cursor, ...)
#                              (skills/archived/ is never linked)
#   agents/*.md             -> ~/.claude/agents, ~/.cursor/agents
#   output-styles/*.md      -> ~/.claude/output-styles
#   local/                  -> ~/.config/dgokcin-skills (private config skills read)
#
# Every entry is a symlink, so a `git pull` or a local edit applies immediately.
# Dangling symlinks left in a destination by renamed or removed entries are
# pruned. Pass --unlink to remove everything this script links.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")
AGENT_DESTS=("$HOME/.claude/agents" "$HOME/.cursor/agents")
STYLE_DESTS=("$HOME/.claude/output-styles")
LOCAL_LINK="$HOME/.config/dgokcin-skills"

mode="link"
[ "${1:-}" = "--unlink" ] && mode="unlink"

# link SRC DEST_DIR: symlink SRC into DEST_DIR, replacing a real dir/file of the same name.
link() {
  local src="$1" target
  target="$2/$(basename "$1")"
  if [ "$mode" = unlink ]; then
    [ -L "$target" ] && rm "$target"
    return 0
  fi
  if [ -e "$target" ] && [ ! -L "$target" ]; then rm -rf "$target"; fi
  ln -sfn "$src" "$target"
}

# prune DEST_DIR: drop dangling symlinks so removed entries don't linger.
prune() {
  find "$1" -maxdepth 1 -type l ! -exec test -e {} \; -print -delete | sed 's/^/pruned /'
}

prepare() {
  local dest="$1"
  if [ -L "$dest" ]; then
    case "$(readlink -f "$dest")" in
      "$REPO"|"$REPO"/*)
        echo "error: $dest is a symlink into this repo. Remove it and re-run." >&2
        exit 1 ;;
    esac
  fi
  mkdir -p "$dest"
}

skills=()
while IFS= read -r -d '' skill_md; do
  skills+=("$(dirname "$skill_md")")
done < <(find "$REPO/skills" -mindepth 3 -maxdepth 3 -name SKILL.md -not -path "$REPO/skills/archived/*" -print0)

for dest in "${SKILL_DESTS[@]}"; do
  prepare "$dest"
  for src in "${skills[@]}"; do link "$src" "$dest"; done
  prune "$dest"
done

for dest in "${AGENT_DESTS[@]}"; do
  prepare "$dest"
  for src in "$REPO"/agents/*.md; do link "$src" "$dest"; done
  prune "$dest"
done

for dest in "${STYLE_DESTS[@]}"; do
  prepare "$dest"
  for src in "$REPO"/output-styles/*.md; do link "$src" "$dest"; done
  prune "$dest"
done

if [ "$mode" = unlink ]; then
  [ -L "$LOCAL_LINK" ] && rm "$LOCAL_LINK"
  echo "unlinked ${#skills[@]} skills, agents, and output styles"
  exit 0
fi

if [ ! -d "$REPO/local" ]; then
  cp -R "$REPO/local.example" "$REPO/local"
  rm -f "$REPO/local/README.md"
  echo "created local/ from local.example/; fill in real values"
fi
mkdir -p "$(dirname "$LOCAL_LINK")"
ln -sfn "$REPO/local" "$LOCAL_LINK"

agents=("$REPO"/agents/*.md)
styles=("$REPO"/output-styles/*.md)
echo "linked ${#skills[@]} skills, ${#agents[@]} agents, ${#styles[@]} output styles"
