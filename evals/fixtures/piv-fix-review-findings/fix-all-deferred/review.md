# Code review

### F1 [Critical] src/auth/login.ts:42
Password comparison uses `==` on strings instead of a constant-time compare, which leaks timing information.

### F2 [Medium] src/auth/login.ts:10
The helper name `chk` is unclear; consider `verifyCredentials`.

### F3 [Low] src/auth/login.ts:3
Imports are not sorted alphabetically.
