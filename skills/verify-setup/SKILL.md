---
name: verify-setup
description: Make a repository ready for agent work where every change can be verified. Finds or defines one verify command, writes the CLAUDE.md commands and workflow rules, pre-approves safe commands, installs hooks that block finishing on failing checks and editing secrets or applied migrations, adds CI and a plan-reviewer subagent, then reports what's ready. Run once per project, before plan-verify-fix.
argument-hint: "[--check-only]"
disable-model-invocation: true
---

# Verify setup

**Input**: $ARGUMENTS

Make verification cheap before any feature work: one command that proves the project works, and guard rails so
agents can't skip it. With `--check-only`, stop after the readiness report.

Change nothing the user hasn't approved, and never install new tools or dependencies without a yes. Merge into
existing files; don't overwrite them.

## Phase 1: Inspect

Look before proposing anything:

- **Stack and surfaces:** `package.json` (scripts, TypeScript, test runner), `pyproject.toml`, `go.mod`,
  `Cargo.toml`, `Makefile`/`justfile`, and subfolders with their own config (`frontend/`, `backend/`, `packages/*`).
- **Existing checks:** lint, type-check, unit and integration tests, build, end-to-end (Playwright, Cypress).
- **Agent setup:** `CLAUDE.md`, `.claude/settings.json`, `.claude/agents/`, `.claude/hooks/`.
- **CI:** `.github/workflows/*`.
- **Risky areas:** `.env*` files, migration folders, generated code.
- **Visual verification:** a Playwright config, or a browser tool available in this session.

## Phase 2: Readiness report and choices

Show a checklist of each item below as ✅ present, ⚠️ partial or ❌ missing, with one line on what you'd do. Then ask
(AskUserQuestion, multi-select) which items to set up. With `--check-only`, stop here.

## Phase 3: The verify command

The whole setup depends on this one command.

1. Build it from checks that **already exist**: lint → type-check → unit tests → build. Run each from the folder
   where its config lives (`cd backend && uv run pytest`, not `uv run pytest` from the root). A monorepo gets one
   command that runs every surface.
2. If a check is missing but the tools are already installed (e.g. TypeScript without a `typecheck` script), offer
   to add the script (`tsc --noEmit`). If the tool itself is missing, list it as a gap and ask; don't install it on
   your own.
3. Add it as a single entry point where the ecosystem expects one (`"verify"` in package.json, a `make verify`
   target), so humans, hooks and CI run the same thing.
4. **Run it.** Report the real result. If it fails on the current code, list the failures as known issues for the
   user; don't disable or loosen checks to get green.
5. Separate a **fast check** (lint, type-check, unit tests; under about a minute) from the full command. The Stop
   hook uses the fast one.

## Phase 4: CLAUDE.md

Create it or merge into it. Keep it short; add only what Claude can't infer from the code:

```markdown
# Commands
- Verify everything: <verify command>
- Fast check: <fast check>
- E2E: <e2e command, if any>

# Workflow
- Work in small tasks; one task = one commit.
- Before saying a task is done, run the verify command and show its output.
- Fix root causes; never skip, weaken or delete a failing test to get green.
- Never edit an applied migration; add a new one.
- When compacting, keep the list of modified files and the verify command.
```

Leave out rules that don't apply (no migrations, no e2e). Don't duplicate what's already there.

## Phase 5: Permissions

Add to `.claude/settings.json` (merge with any existing `permissions.allow`) so the user reviews diffs instead of
approval prompts. Use the space form, which also matches the bare command:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint *)",
      "Bash(npm run typecheck *)",
      "Bash(npm test *)",
      "Bash(npm run build *)",
      "Bash(npm run verify *)",
      "Bash(git status *)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)"
    ]
  }
}
```

Use the project's real commands. Don't pre-approve `git push`, deletions, deploys or database commands.

## Phase 6: Hooks

Copy the bundled scripts to `.claude/hooks/`, make them executable, and fill in the placeholders:

- [stop-verify.sh](scripts/stop-verify.sh): set `FAST_CHECK` to the fast check. It runs only when there are
  uncommitted changes and blocks Claude from finishing while they fail. Claude Code stops honouring a Stop hook
  after it blocks several times in a row, so a stuck loop can't run forever.
- [protect-files.sh](scripts/protect-files.sh): set `MIGRATION_DIRS` to the project's migration folders (or leave
  them out if there are none). It blocks edits to `.env` files (not `.env.example`) and to committed migrations.
  It needs `python3` to read the hook input.

Register both in `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/stop-verify.sh" }] }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh" }]
      }
    ]
  }
}
```

Test each hook once by piping a sample input into it (a `.env` path must exit 2, a normal file 0), and tell the
user to check `/hooks` in their next session.

## Phase 7: Reviewer subagent

Install [the plan-reviewer template](references/plan-reviewer.md) as `.claude/agents/plan-reviewer.md`. It reviews
diffs against `docs/work/<slug>/SPEC.md` and `PLAN.md` with read-only tools, which is what `plan-verify-fix` expects.

## Phase 8: CI

If `.github/workflows/` has no workflow running the verify command, add `verify.yml` that installs dependencies and
runs it on pushes to the default branch and on pull requests. Add e2e as a separate job if the project has it. If a
workflow exists, add only the missing steps. Use the project's real runtime versions.

## Phase 9: Visual verification (report only)

Say which option the project can use for UI checks: existing Playwright tests, a browser tool in Claude Code, or
none. Recommend one if needed, but don't install it without a yes.

## Phase 10: Wrap up

Report what was set up, the verify command's real output, known failures, and what's still missing. Suggest a trial
run: `/plan-verify-fix` on a trivial change (such as a page title) to see the whole loop pass once. Offer to commit
the setup with `piv-commit`.
