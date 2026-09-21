# Recovery: when a task goes wrong

Pick the recovery by what's wrong, and write the choice and the reason in LOG.md.

| Situation | Recovery |
|-----------|----------|
| Right approach, a bug | **Fix forward:** write a failing test that reproduces it, then fix the root cause. |
| Wrong approach (the design doesn't fit, the diff keeps growing, it fights the codebase) | **Roll back:** `git reset --hard <last good commit>` (every passing task is a commit, so there always is one), update PLAN.md, ask the user before continuing. |
| The same failure after two different fixes | **Two strikes:** stop. Summarize what was tried and what was learned, and ask the user. Suggest `/clear` and resuming with a better brief; a clean context beats a polluted one. |
| A bad database migration was applied | Roll it back with the project's down migration or reset script, then write a **new** migration. Never edit a migration that has run. `/rewind` does not undo database changes. |
| Files created or changed by shell commands | `git status` and `git clean`/`git checkout` as appropriate. `/rewind` only restores Claude's own file edits. |
| An experiment that didn't pay off (a metric or eval got worse) | Roll back to the commit before it and try the next idea. Record the result either way. |
| A failing test that seems unrelated | Find out why it fails. Never skip, weaken or delete it to get green. If it was already failing before this work, show that with `git stash` and a run on the clean tree, and ask the user. |
| Production differs from local | Read the real logs, paste the exact error, fix the root cause, and verify in that environment, not just locally. Choose rollback or fix forward by user impact. |

## Root cause, not symptom

When a check fails, read the exact error before changing anything. Changes that make the error go away without
explaining it (catching and ignoring, special-casing the input, adding sleeps or retries, loosening assertions)
don't count as fixes.

## What the user controls

Some recovery is the user's to do, not yours: pressing Esc to interrupt, `/rewind` to restore a checkpoint,
`/clear` for a fresh context. Suggest them by name when they'd help.
