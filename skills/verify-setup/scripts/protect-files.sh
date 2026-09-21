#!/usr/bin/env bash
# PreToolUse hook installed by verify-setup: blocks edits to secrets (.env files) and to
# migrations that are already committed. Exit 2 blocks the edit and sends stderr to Claude.
set -u

# Replaced during setup with the project's migration folders (space-separated).
MIGRATION_DIRS='migrations db/migrations drizzle prisma/migrations supabase/migrations'

input=$(cat)
file=$(printf '%s' "$input" | python3 -c 'import json, sys; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))' 2>/dev/null)
[ -n "$file" ] || exit 0

root="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$root" || exit 0
rel="${file#"$root"/}"

case "$(basename "$rel")" in
  .env.example | .env.sample | .env.template) ;;
  .env | .env.*)
    echo "Blocked: $rel holds secrets. Ask the user to make this change themselves." >&2
    exit 2
    ;;
esac

for dir in $MIGRATION_DIRS; do
  case "$rel" in
    "$dir"/*)
      if git ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then
        echo "Blocked: $rel is a committed migration that may already have run. Add a new migration instead of editing it." >&2
        exit 2
      fi
      ;;
  esac
done
exit 0
