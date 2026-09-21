# Work documents

Everything the loop needs to continue lives in `docs/work/<slug>/`. The slug is short and kebab-case, e.g.
`watch-page` or `issue-142-session-reload`. Ask in the interview whether to commit these files (the default is yes;
they explain the change to reviewers).

## SPEC.md

```markdown
# <Feature or bug title>

Status: draft | approved (<date>) | done (<date>, PR <link>)
Source: <issue URL, or "request from <date>">

## Goal
<What a user can do afterwards, 2–3 sentences.>

## Decisions
- <Decision>: <reason>. (Alternatives considered: <…>)

## Research
- <Finding with file:line or URL>

## Out of scope
- <Tempting extra we're not doing>

## Risks
- <Risk and how the plan handles it>

## End-to-end check
<The command or steps that prove the whole thing works, and the expected result.>
```

For bugs, replace Goal and Decisions with the diagnosis:

```markdown
## Symptom
Expected: <…>  Actual: <…>  Where: <environment, version>

## Reproduction
<Test name or script, the command to run it, and its failing output.>

## Root cause
<What is actually wrong, with file:line, and the evidence for it.>

## Fix approach
<The smallest change that addresses the root cause, and why not the alternatives.>
```

## PLAN.md

```markdown
# Plan: <title>

Spec: SPEC.md · Branch: <branch> · Verify: `<verify command>`

- [ ] 1. <Task title>
  - Files: <paths>
  - Out of scope: <…>
  - Check: `<command>` (or: screenshot of <page> matches design/<file>)
  - Evidence: <filled in when done: command, last lines of output, commit hash>
- [ ] 2. …
```

Mark the current task with `(in progress)`. Tick `[x]` only after the evidence is pasted and the commit exists.

## LOG.md

One dated line per event, newest last:

```markdown
- 2026-09-21 Task 3: build failed on missing type; fixed forward with a test. (a1b2c3d)
- 2026-09-21 Task 4: wrong approach (client-side filtering); rolled back to b2c3d4e and re-planned.
- 2026-09-21 Lesson: never edit an applied migration; add a new one. Proposed for CLAUDE.md.
```

The log is what makes the retro and the CLAUDE.md lessons honest.

## After the work

Each work folder covers one feature or bug. It is small and it stops changing once the work merges; the next piece
of work gets a new folder. Over time you collect folders, not one ever-growing spec.

At wrap-up (Phase 7), ask what to keep:

| Choice | Keeps | When |
|--------|-------|------|
| Keep only SPEC.md (recommended) | Why the change was made this way | Most work. The plan and log have served their purpose; commits and the PR hold the evidence. |
| Keep all three | The full story, including failures and recoveries | Work you expect to revisit or learn from |
| Delete the folder | Nothing; the PR description is the record | Small or throwaway work |

Whatever is kept, mark SPEC.md `Status: done` with the date, and add the PR link once the PR exists, so nobody
mistakes it for current documentation. Old folders can be deleted whenever they stop being useful.

A spec that keeps growing during the work means the scope is creeping: finish the planned work and start a new run
for the rest. Documents that describe the system as it is now (architecture, data model, API docs) are different:
update them through a task in PLAN.md that names them in its files, not by editing an old spec.
