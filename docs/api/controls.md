# Shared control reference

Each shared control requires an `FTheme` scope, normally supplied by `FFrameApp`.

| Control | Contract |
| --- | --- |
| `FButton`, `FIconButton` | Enabled/disabled action, keyboard activation, focus state, optional tooltip |
| `FTextField`, `FSearchBox` | Text controller/focus node, input formatting, secure input, multiline, error/helper text, form validator |
| `FForm`, `FFormController`, `FValidator`, `FAutovalidateMode` | Register text fields; validate, reset, and save synchronously |
| `FSelect<T>`, `FSelectItem<T>` | Controlled selection, menu keyboard navigation, enabled/disabled options |
| `FCheckbox`, `FSwitch` | Controlled boolean state with semantic labels and keyboard activation |
| `FSegmentedControl<T>`, `FSegmentedItem<T>` | Small mutually exclusive, controlled choice set |
| `FDataGrid<T>`, `FDataGridColumn<T>` | Lazy rows, fixed column widths, comparator sorting, controlled keyed selection |
| `FTreeView<T>`, `FTreeNode<T>` | Lazy visible rows, expansion, async child loading/error callback, controlled selection |
| `FSidebar`, `FSidebarItem`, `FTabs`, `FTab` | Desktop navigation and selected content |
| `FPanel`, `FDivider`, `FScrollArea` | Shared surfaces and scroll behavior |
| `FMenu`, `FMenuItem`, `FPopover`, `FTooltip` | Non-modal menus and anchored surfaces |
| `FDialog`, `showFDialog<T>` | Modal route with focus scope, barrier policy, Escape behavior |
| `FToast`, `FToastVariant`, `FToastHandle`, `showFToast` | Live-region transient feedback with early dismissal |

Control dimensions and typography come from the active design system. `FTextField.maxLength` uses Flutter's grapheme-aware limiter; its counter currently reports Unicode scalar count. Data-grid server paging, resizing, editing, and remote queries are application concerns.
