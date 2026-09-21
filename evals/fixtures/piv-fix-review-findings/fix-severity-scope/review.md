# PR #57 review

### F1 [Low] src/export/csv.ts:2
Unused import `path`.

### F2 [High] src/export/csv.ts:18
Values containing commas are not quoted, so rows split into extra columns.

### F3 [Critical] src/routes.ts:9
The export route has no auth middleware; any visitor can download all orders.

### F4 [Medium] src/export/csv.ts:25
No test for an empty order list.
