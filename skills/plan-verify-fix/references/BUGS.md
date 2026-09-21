# Bug mode

Don't fix what you haven't reproduced. A fix without a failing check first is a guess.

## 1. Read the ticket

For a GitHub issue: `gh issue view <number> --comments` (or the URL). Note expected vs. actual behavior, the steps,
the environment, and anything already tried. Ask the interview questions ([INTERVIEW.md](INTERVIEW.md)) only for
what's missing.

## 2. Research in parallel

Typical subagents (briefs in [SUBAGENTS.md](SUBAGENTS.md)):

- **Code path:** trace the behavior from the entry point (route, command, event) to where the wrong result is made.
- **History:** `git log -S '<symbol>'`, `git log --since=<date> -- <paths>`, recent dependency upgrades. When did
  it last work?
- **Known issues:** the library's changelog and issue tracker, duplicates in this repository's issues.

## 3. Reproduce with a failing check

Write the smallest automated test that shows the bug, at the lowest level that still shows it (unit before
integration before end-to-end). Run it and capture the failure. If an automated test is impossible (visual,
timing, a third-party service), write exact manual steps or a script instead and say why.

**Reproduction gate:** show the test and its failing output. Ask the user to confirm it's the same bug they see.
Don't proceed on a reproduction the user doesn't recognize.

If you can't reproduce it: say so, list what you tried, and ask for more information. Don't fix blind.

## 4. Find the root cause

Keep asking why until you reach the code that is actually wrong, not where the symptom shows. Confirm the cause
with evidence: a log line, a value in the debugger or test, or a bisect result (`git bisect run <test command>`
when you know a good commit). Write the diagnosis into SPEC.md, then **Gate 1** as usual.

Signs you're treating the symptom: a new `try/catch` that swallows the error, a special case for the reported
input, a retry around something that shouldn't fail, a skipped or loosened test.

## 5. Fix and verify

Usually a one- or two-task plan: the fix, and any hardening the root cause calls for (the same bug elsewhere, a
guard at the boundary). The reproduction test must now pass, the full verify command must pass, and the new test
stays as a regression test.

## 6. Close the loop

Offer to open a PR with `Fixes #<number>` and to comment on the issue with the root cause and the fix. Both are
visible to others, so do them only on a yes.
