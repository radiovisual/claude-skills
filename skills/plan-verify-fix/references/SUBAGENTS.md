# Working with subagents

Subagents start with an empty context. They're good for work you can describe completely in one message and whose
answer you can check. They keep file dumps and dead ends out of the main session, which stays focused on decisions.

## Breaking a problem down for subagents

A question is ready to hand off when it is:

- **Independent:** its answer doesn't depend on another subagent's answer. If it does, run them in sequence.
- **Bounded:** it names where to look and where not to. "Understand the app" is not bounded; "how does
  `app/watch/[id]/page.tsx` get its data, following imports into `lib/db/`" is.
- **Answerable in a fixed shape:** you know in advance what the answer looks like (a list of call sites with
  `file:line`, a comparison table, yes/no with evidence).

Good splits for research: one agent per code area; one for history (`git log -S`, recent changes near the bug);
one for external docs or library behavior; one to find existing patterns you should copy. Two to four agents is
usually right. More than that means the problem wasn't narrowed enough first.

Don't hand off decisions that need the user, anything that needs the main session's context to judge, or the
final synthesis. Those stay with you.

## Research brief

```
Question: <one question>
Context: <2–3 sentences of what we're building or fixing and why this matters>
Look in: <paths, packages, URLs>
Don't: edit files; go beyond <boundary>; propose a full design
Answer with:
- <exact shape, e.g. "each call site as file:line and one sentence">
- Confidence (high/medium/low) and what you couldn't verify
Keep it under 300 words.
```

Use `Explore` for codebase questions (read-only) and `general-purpose` for web and documentation research. Launch
independent briefs in the same turn so they run in parallel.

## Plan critic brief

```
Read docs/work/<slug>/SPEC.md and PLAN.md. Don't edit anything.
Report only:
- requirements in SPEC.md that no task covers
- tasks without a runnable pass/fail check, or too big for one commit
- tasks in an order that breaks the build in between
- anything in PLAN.md that SPEC.md marks out of scope
One line each, most important first. If the plan is sound, say so.
```

## Reviewer brief

```
Review the diff of this branch against <base> (git diff <base>...HEAD) in light of
docs/work/<slug>/SPEC.md and PLAN.md. Don't edit anything.
Report only:
- missing requirements
- untested edge cases that could plausibly break
- changes outside the plan's scope
- correctness bugs you can point to (file:line and why)
Skip style and preferences. For each finding give severity (critical/high/medium/low) and a concrete fix.
```

Tell reviewers to report only correctness and requirement gaps. Otherwise they suggest improvements endlessly and
the work grows beyond the plan.

## Implementation subagents (parallel tasks)

Only for tasks that touch disjoint files, and only when the user agrees. Use `general-purpose` with
`isolation: worktree`, one task per agent. Brief: the task from PLAN.md (files, out of scope, check), the verify
command, "commit when the check passes and report the commit hash and the check output". Review each result's diff
before merging, and run the full verify command on the merged result.
