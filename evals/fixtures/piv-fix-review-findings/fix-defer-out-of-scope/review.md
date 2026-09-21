# Code review

### F1 [High] src/auth/rateLimit.ts:12
The limiter keys on `req.ip`, which is the proxy address behind the load balancer; use the forwarded client IP.

### F2 [Medium] src/billing/invoice.ts
While here: the billing module duplicates currency formatting; refactor into a shared helper.
