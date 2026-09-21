# Code review

### F1 [High] src/api/orders.ts:31
Missing `await` on `db.save(order)`, so errors are never caught.

### F2 [Medium] src/ui/Checkout.tsx
The pay button may overlap the order summary on narrow phones; could not verify without a device.
