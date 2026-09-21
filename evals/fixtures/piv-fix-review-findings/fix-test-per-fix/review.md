# Code review

### F1 [High] src/dates.ts:5
`addDays` mutates the Date passed in.

### F2 [High] src/dates.ts:14
`isWeekend` treats Saturday as a weekday (checks day 5 instead of 6).

### F3 [Medium] src/dates.ts:20
`parseISODate` accepts `2026-02-30`.
