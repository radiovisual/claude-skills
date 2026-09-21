---
name: plan-verify-fix
description: Run a feature or bug fix end to end with the Plan → Verify → Fix loop. Interviews you, sends subagents to research, writes a spec and a plan of small verifiable tasks, then builds, verifies and commits each task on its own, stopping for your approval at the gates. Coaches the habits along the way.
argument-hint: "[what to build | issue URL or #number | resume <slug>] [--coach | --quiet]"
disable-model-invocation: true
---

# Plan → Verify → Fix

**Input**: $ARGUMENTS

You run the whole loop and do the work. The user approves at the gates and learns the habits as you go.

**The one rule:** every task ends in a check that returns pass/fail, and a commit. If it can't be verified, it
isn't done. Show evidence (the command and its output, a screenshot), never just "it works".

## Modes

Decide from the input and say which one you chose:

| Mode | When | Path |
|------|------|------|
| **Small** | The whole change fits in one sentence and one commit | Skip the interview and spec: one task, then verify and commit |
| **Feature** | Anything bigger | Interview → research → SPEC → PLAN → loop → review |
| **Bug** | An issue URL or number, an error, or "X is broken" | Same, but reproduce before fixing: [BUGS.md](references/BUGS.md) |
| **Resume** | `resume <slug>` | Read the work folder and continue from the first unfinished step |

**Coaching** (see [COACHING.md](references/COACHING.md)): by default, add one short **Habit** line at each gate
saying what just happened and why it matters. `--coach` explains more, including what the user would press or type
to do it themselves, and ends with a short retro. `--quiet` leaves the habit lines out.

## Where the work lives

Keep all state in files so any step can continue after `/clear` or in a new session:

```
docs/work/<slug>/SPEC.md   what and why, decisions, research, end-to-end check (or DIAGNOSIS for bugs)
docs/work/<slug>/PLAN.md   small tasks, each with files, out-of-scope, check, status and evidence
docs/work/<slug>/LOG.md    decisions, failures, recoveries and lessons, one dated line each
```

Templates: [DOCUMENTS.md](references/DOCUMENTS.md). A `## work` section in `.claude/references/conventions.md`
overrides the location. Update the files as you go; they are the source of truth, not the chat.

## Phase 0: Get ready

1. Read `CLAUDE.md` and `.claude/references/conventions.md` if present. Find the **verify command** (lint,
   type-check, tests, build). If the project has none, stop and offer `/verify-setup` (recommended), or agree on a
   verify command for this run and note it in SPEC.md.
2. `git status`: if there are uncommitted changes, ask whether to commit or stash first. Don't mix them into this work.
3. If on the default branch, create `feature/<slug>` or `fix/<issue>-<slug>`.
4. Pick the mode.

## Phase 1: Interview

Use the AskUserQuestion tool (plain numbered questions if it isn't available). Ask only what the input and code
don't already answer: at most 4 questions per round and 3 rounds. Offer concrete options with a recommended one
first. Question sets: [INTERVIEW.md](references/INTERVIEW.md).

Always settle: what "done" looks like (the end-to-end check), what's out of scope, and constraints (versions,
dependencies you may not add, data you must not touch).

## Phase 2: Research with subagents

Split the unknowns into 2–4 **independent** questions and send one subagent per question, in parallel. Use the
read-only `Explore` type for the codebase and `general-purpose` for external docs or APIs. Brief each one with the
template in [SUBAGENTS.md](references/SUBAGENTS.md): the question, where to look, what's out of bounds, and the exact
shape of the answer. Subagents research; they don't edit files.

Keep their conclusions, not their file dumps. Write the findings (with `file:line` references) into SPEC.md.

## Phase 3: Spec, then Gate 1

Write SPEC.md: goal, decisions (with the reason for each), research findings, out of scope, risks, and the
**end-to-end check**. For bugs, first reproduce it and write the diagnosis ([BUGS.md](references/BUGS.md)).

**Gate 1:** show a short summary and the path to SPEC.md. Wait for approval or edits. Tell the user they may
`/clear` now and continue with `/plan-verify-fix resume <slug>`; a fresh context builds better than a long one.

## Phase 4: Plan, then Gate 2

Break the spec into tasks in PLAN.md. Every task is:

- **Small**: one commit. If you can't describe its diff in two sentences, split it.
- **Specified**: files to touch, what's out of scope.
- **Verifiable**: the exact check (a test command, the verify command, or a screenshot compared with a mockup),
  runnable in about a minute.

Order tasks so each leaves the project working. Then send one subagent with fresh context to critique the plan
("what's missing or wrong? correctness and requirements only") and fix what it finds.

**Gate 2:** show the task list. Wait for approval. The user may edit PLAN.md directly.

## Phase 5: Build loop (runs on its own)

For each unchecked task in PLAN.md:

1. Mark it in progress. Read only the files it needs.
2. Write or update the test first, where practical, and watch it fail.
3. Implement.
4. Run the task's check, then the full verify command. Iterate until both pass. Fix root causes; never skip,
   weaken or delete a test to get green.
5. UI work: screenshot and compare with the mockup if you have a browser tool; otherwise stop at a **visual gate**
   and ask the user to look.
6. Paste the evidence (command + the last lines of output) into the task in PLAN.md, tick it, and commit it with
   `piv-commit`: one commit per task.

**Stop and ask the user** when: the same failure survives two different fixes; the approach turns out wrong; the
task needs something outside the plan (new dependency, scope change, schema change on shared data); a step is
destructive or outward-facing (pushing, migrations on real data, messages to other people); or you need a human to
look at something. Recovery choices: [RECOVERY.md](references/RECOVERY.md). Log every failure and recovery in LOG.md.

**Keep context clean:** after every few tasks, make sure PLAN.md is up to date. If the session is getting long,
suggest `/compact keep PLAN.md status and the verify command` or `/clear` plus `resume`.

**Parallel work (optional):** tasks that touch completely separate files can go to `general-purpose` subagents with
`isolation: worktree`, one task each, briefed like research agents plus the task's check. Only when the user
agrees; review and merge each result before starting dependent tasks.

## Phase 6: Independent review

When all tasks are ticked, get a review from a fresh context: run the `code-review` skill on the branch, or send a
`general-purpose` subagent with the reviewer brief in [SUBAGENTS.md](references/SUBAGENTS.md) (diff against SPEC.md
and PLAN.md; missing requirements, untested edge cases and out-of-scope changes only). Handle the findings with
`piv-fix-review-findings`: the user decides what to fix now. Run the end-to-end check from SPEC.md and the full
verify command again.

## Phase 7: Gate 3 and wrap-up

Show: tasks done with their evidence, the end-to-end check result, review findings and how each was handled, and
anything deferred.

**Close the work folder** before the PR, so the PR carries its final state. Ask what to keep (see "After the work"
in [DOCUMENTS.md](references/DOCUMENTS.md)):

- **Keep only SPEC.md** (recommended): it records why the change was made this way. PLAN.md and LOG.md are
  removed; their evidence lives on in the commits and the PR.
- **Keep all three**: for when the full story, failures included, is worth having in the repository.
- **Delete the folder**: when the PR description is record enough.

For anything kept, set SPEC.md to `Status: done (<date>)`. Commit the result with `piv-commit`. If a PR is opened
next, add its link to SPEC.md afterwards in a small follow-up commit on the same branch.

Then offer, and do only on a yes:

- Open a PR with `piv-create-pr` (link the issue: `Fixes #N`).
- For a bug, comment on the issue with the root cause and the fix.
- Add lessons to `CLAUDE.md` (only rules Claude kept getting wrong, one line each).

With `--coach`, finish with a three-line retro: what went well, one failure and how it was recovered, one habit to
practise next time.
