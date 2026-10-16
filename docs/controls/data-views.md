# Data views

## Lazy lists

`FListView.builder` and `FListView.separated` create visible and cached items on demand. The builder accepts nullable `itemCount` for an unbounded list. Provide a bounded height when composing the list inside a `FColumn`.

```dart
FExpanded(
  child: FListView.builder(
    itemCount: records.length,
    itemBuilder: (context, index) => RecordRow(record: records[index]),
  ),
)
```

## Data grid

`FDataGrid<T>` lazily builds rows and uses fixed-width columns. Set `compare` for sortable columns and `rowKey` plus `onSelectionChanged` for controlled row selection. It needs bounded height. Sorting is in-memory and local to the grid; paging, server queries, editing, and column resizing remain application or adapter responsibilities.

```dart
FDataGrid<User>(
  rows: users,
  rowKey: (user) => user.id,
  selectedRowKeys: selectedIds,
  onSelectionChanged: updateSelection,
  columns: <FDataGridColumn<User>>[
    FDataGridColumn<User>(
      label: 'Name',
      cellBuilder: (context, user) => FText(user.name),
      compare: (a, b) => a.name.compareTo(b.name),
    ),
    FDataGridColumn<User>(
      label: 'Status',
      width: 120,
      cellBuilder: (context, user) => FText(user.status),
    ),
  ],
)
```

## Tree view

`FTreeView<T>` virtualizes visible rows, supports controlled selection and arrow-key navigation, and can load children on expansion. IDs must be unique within one tree. A failed child loader leaves the node expanded and can be retried by collapsing and expanding it again. Pass `onLoadError` to handle failures in application state; otherwise FFrame reports them through Flutter's error hook.

```dart
FTreeView<Project>(
  nodes: <FTreeNode<Project>>[
    FTreeNode<Project>(
      id: 'workspace',
      value: project,
      label: project.name,
      loadChildren: () => repository.loadChildren(project.id),
    ),
  ],
  selectedId: selectedId,
  onSelected: (node) => select(node.value),
)
```
