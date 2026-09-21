# Coaching

The user wants to build habits, not only get results. Keep coaching short and tied to what just happened. One
**Habit** line at each gate by default; more only with `--coach`; none with `--quiet`.

## Habit lines by moment

| Moment | Habit line (adapt to what happened) |
|--------|-------------------------------------|
| Mode chosen: Small | Small change, so no spec: a one-sentence diff doesn't need a plan, but it still needs a check. |
| Interview | Settle "done" before code: the end-to-end check is the target the whole loop works toward. |
| Research | Research ran in subagents, so the file reading stayed out of this session and only the conclusions came back. |
| Gate 1 (spec) | A spec you approved is cheaper to change than code. Starting implementation in a fresh session keeps the context clean. |
| Gate 2 (plan) | Each task is one commit with its own check, so any failure is small and every success is a safe point to return to. |
| A check failed | Read the exact error first. Fix the cause; making the error disappear isn't a fix. |
| Fix forward | The failing test comes first: it proves the bug exists and proves the fix works. |
| Roll back | Wrong approach, so back to the last good commit. Patching a wrong design costs more than restarting it. |
| Two strikes | Two failed fixes means the context is misleading us. A fresh start with what we learned usually wins. |
| Visual gate | Some things only a person can judge. Asking now is cheaper than reworking later. |
| Review | A reviewer that didn't write the code catches what the author's context explains away. |
| Gate 3 | Judge the evidence, not the chat: the check outputs and commits are what you'd show a colleague. |

## With `--coach`

At each gate, add up to three lines:

1. What just happened and why.
2. How the user would do it themselves in Claude Code, for example:
   - Plan without edits: Shift+Tab until the status bar shows plan mode, or `claude --permission-mode plan`.
   - Edit a plan before approving: Ctrl+G.
   - Stop Claude mid-action: Esc. Restore a checkpoint: Esc Esc or `/rewind`.
   - Fresh context: `/clear`. Summarize and keep going: `/compact <what to keep>`.
   - Keep working until a condition holds: `/goal <condition>`.
   - Independent review: `/code-review`.
   - Side question without adding to context: `/btw <question>`.
3. One thing to try next time.

## How to teach breaking problems down

When the user's request is large or vague, show the breakdown instead of just doing it:

- Name the outcome and the check first, then work backwards to tasks.
- Split until each task is one commit and its check runs in about a minute.
- Split research by independent question, not by file count ([SUBAGENTS.md](SUBAGENTS.md)).
- Point out tasks that can't be verified yet, and what would make them verifiable (a test seam, a fixture, an eval
  set with a threshold for things with no single right answer).

## Retro (with `--coach`, at the end)

Three lines: what went well; one failure and whether it was rolled back or fixed forward; one habit to practise
next time. Take them from LOG.md, not from memory.
