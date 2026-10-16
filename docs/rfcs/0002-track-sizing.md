# RFC 0002 — Track sizing

## Summary

`FTrack` supports fixed, intrinsic auto, and weighted flex sizing in a custom multi-child RenderObject grid.

## Algorithm

1. Initialize fixed tracks and auto tracks from intrinsic measurements, clamped by min/max.
2. Subtract gaps and initialized sizes from the bounded axis extent.
3. Divide remaining space among flex tracks by weight.
4. Cap flex tracks at max and redistribute remaining space until no flex track can grow.
5. Preserve minimum sizes when the parent is too small; `FGrid` overflow policy then controls painting.

Auto track measurement uses child max-intrinsic dimensions and distributes spanning deficits among auto tracks. This is a bounded extra measurement pass; auto tracks are intended for small structural regions. Complex controls should use flex tracks.

## Compatibility

Rows/columns are explicit. There is no implicit placement, percentage sizing, named lines, or CSS Grid syntax in v0.1.
