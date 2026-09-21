# Code review

### F1 [High] src/cart/average.ts:8
`averagePrice()` returns NaN for an empty cart.

### F2 [High] src/cart/average.ts:3
`items` may be undefined; add a null check before iterating.
