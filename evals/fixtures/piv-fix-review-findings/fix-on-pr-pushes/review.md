# Code review

### F1 [High] src/auth/rateLimit.ts:20
The limiter never resets its counter after the window expires.
