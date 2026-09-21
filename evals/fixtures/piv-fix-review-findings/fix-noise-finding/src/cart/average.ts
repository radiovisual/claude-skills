export function averagePrice(items: Item[] = []): number {
  if (items === undefined) return 0;
  return items.reduce((sum, i) => sum + i.price, 0) / items.length;
}
