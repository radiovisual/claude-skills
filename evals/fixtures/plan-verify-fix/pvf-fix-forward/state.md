Next.js App Router project. CLAUDE.md verify command: npm run verify (lint, typecheck, vitest, build).
Task 3 (related videos sidebar) is implemented as planned. `npm run verify` fails:
  related.test.ts > never lists the current video in its own related list
  Expected not to contain "v_42", received ["v_42", "v_17", "v_8", "v_3", "v_29"]
The query in lib/related.ts:18 orders by embedding distance but doesn't exclude the source video.
