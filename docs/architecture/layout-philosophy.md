# Layout philosophy

FFrame makes desktop application structure declarative while preserving Flutter's constraints model. Layout decisions derive from local available space and pane minimums, never from a platform or device-type check. The core owns grids, panes, workspace composition, shell regions, and overlay geometry. It does not own application colors, text styles, or control visuals.

Prefer flex tracks for complex content, define sensible pane minimums, and use adaptive builders when the available space cannot satisfy all requested regions. Keep persistence in app-owned storage through controller snapshots.
