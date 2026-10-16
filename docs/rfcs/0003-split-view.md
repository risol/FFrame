# RFC 0003 — Split view

## Summary

`FSplitView` composes `FPane` widgets, flexes, and accessible `FSplitter` handles. A `FPaneController` owns explicit user size and collapse state.

## Interaction

- Pointer drag changes adjacent pane extents within min/max.
- Arrow keys resize; Home resets preferred sizes; End grows the leading pane.
- Enter/Space toggles the trailing pane when it is collapsible.
- Double click resets the adjacent panes.
- Semantics exposes splitter as a value slider.

## Narrow constraints

When requested sizes exceed available space, panes shrink toward their minimums; collapsible panes are temporarily removed in ascending collapse priority; if minima still exceed the parent, all visible extents are scaled to fit. Temporary layout collapse does not rewrite the controller's explicit state.

## Persistence

`snapshot()` returns immutable pane state. Storage and serialization belong to the app.
