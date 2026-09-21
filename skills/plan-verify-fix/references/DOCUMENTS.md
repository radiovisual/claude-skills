# Work documents

Everything the loop needs to continue lives in `docs/work/<slug>/`. The slug is short and kebab-case, e.g.
`watch-page` or `issue-142-session-reload`. Ask in the interview whether to commit these files (the default is yes;
they explain the change to reviewers).

## SPEC.md

```markdown
# <Feature or bug title>

Status: draft | approved (<date>)
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
