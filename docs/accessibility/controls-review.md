# Accessibility and keyboard review

This is the source-level review and manual release checklist for the current controls. Widget tests cover deterministic overlay focus and dismissal behavior; platform screen-reader validation still needs a device/host pass.

## Implemented behavior

- `FButton`, `FIconButton`, `FCheckbox`, `FSwitch`, `FSelect`, `FSidebarItem`, tabs, and segmented choices expose semantic roles and keyboard activation.
- `FTextField` exposes label, enabled, multiline, obscured, validation, and live error information. A visible label is preferred over a placeholder-only field.
- `FDialog` creates a route focus scope, groups traversal, exposes a semantic route, and supports Escape when the barrier is dismissible.
- `FPopover` creates a traversal scope, closes on Escape, and returns focus to its trigger after Escape or outside dismissal. A caller can pass `focusNode` to observe or control the trigger focus.
- `FDataGrid` and `FTreeView` expose row/item semantics; tree expansion and selection support keyboard operation.
- `FToast` uses live-region semantics. Its message text describes the outcome without relying on color.

## Manual checks before release

Run these on each supported desktop host and at least one screen reader per target OS:

1. Navigate every showcase control with Tab and Shift+Tab; confirm the focus indicator is visible against all shipped design systems.
2. Operate buttons, checkboxes, switches, selects, segmented choices, tabs, tree rows, and grid headers with Enter/Space and their documented arrow keys.
3. Open every popover, select menu, and dialog from the keyboard. Verify first-focus placement, Escape dismissal, focus restoration, and that focus does not remain behind a modal dialog.
4. Read text-field labels, obscured input state, validation errors, grid row selection, tree levels/expansion, and toast announcements with screen readers.
5. Confirm scaling and high-contrast settings preserve focus, error, selected, and disabled distinctions.

This checklist is not a substitute for the manual host checks. Record OS, screen reader, Flutter version, and findings in the release rehearsal.
