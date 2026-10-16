# RFC 0005 — Workspace policy

## Summary

`FWorkspace` combines navigation, content, and inspector panes. The workspace selects visible regions from its minimum size requirements, and `FSplitView` handles resizing after selection.

## Narrow behavior

- Keep the main content region.
- Show all requested panes when their minimum requirements fit.
- Drop inspector when the navigation/content/inspector minimum widths do not fit.
- Keep expanded navigation when its minimum width fits; otherwise use `compactChild` if supplied.
- Show an overlay pane only when the app opens it through `FWorkspaceController`.

## Policy

`FWorkspacePolicy` supplies preferred/min/max sizes, collapse priorities, splitter thickness, and pointer hit extent. Each side pane may override its sizing and use remove, compact, or overlay behavior.

## Ownership

Pane state belongs to the workspace controller; navigation selection and page data remain app-owned.
