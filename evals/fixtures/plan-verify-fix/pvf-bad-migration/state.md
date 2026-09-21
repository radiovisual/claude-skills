Next.js App Router project. CLAUDE.md verify command: npm run verify (lint, typecheck, vitest, build).
Task 1 added migrations/0007_channels.sql with a wrong column (owner_id TEXT instead of UUID) and it was applied
to the local development database with npm run db:migrate. The file is committed. There is a db:reset script.
