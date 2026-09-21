Next.js App Router project. CLAUDE.md verify command: npm run verify (lint, typecheck, vitest, build).
Task 4 (search page) was planned as a server query using pgvector. The implementation instead loads all 20,000
videos into the browser and filters client-side. The diff is now 900 lines across 14 files, the build warns the page
bundle is 6 MB, and eval:search recall@5 dropped from 0.81 to 0.40. Last good commit: b2c3d4e (task 3).
