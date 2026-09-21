#!/usr/bin/env bash
# Stop hook installed by verify-setup: keeps Claude from finishing a turn while the fast
# checks fail on uncommitted work. Exit 2 blocks the stop and sends stderr back to Claude.
set -u

# Replaced during setup with the project's fast checks (no e2e or slow builds).
FAST_CHECK='npm run lint && npm run typecheck && npm test'

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
cat >/dev/null  # hook input is not needed

# Nothing changed since the last commit, so there is nothing new to verify.
if git diff --quiet HEAD -- 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
  exit 0
fi

if output=$(bash -c "$FAST_CHECK" 2>&1); then
  exit 0
fi

{
  echo "Fast checks failed on uncommitted changes. Fix the root cause before finishing"
  echo "(don't skip or weaken tests). Command: $FAST_CHECK"
  echo "$output" | tail -n 40
} >&2
exit 2
