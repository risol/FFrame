// Keep compatibility with the declared Flutter 3.22 floor.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:fframe_design/fframe_design.dart';

import 'controls.dart';
import 'primitives.dart';

/// Column definition for [FDataGrid].
class FDataGridColumn<T> {
  const FDataGridColumn({
    required this.label,
    required this.cellBuilder,
    this.width = 160,
    this.compare,
  }) : assert(width > 0);

  final String label;
  final double width;
  final FWidget Function(FBuildContext context, T row) cellBuilder;
  final int Function(T left, T right)? compare;
}

/// A virtualized table for application data.
///
/// Give the grid bounded height (for example with [Expanded] or [SizedBox]).
/// Rows are built lazily; columns use stable fixed widths so the horizontal
/// viewport and row cells remain aligned without intrinsic measurement.
class FDataGrid<T> extends StatefulWidget {
  const FDataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.rowKey,
    this.selectedRowKeys = const <Object>{},
    this.onSelectionChanged,
    this.rowHeight,
  }) : assert(columns.length > 0);

  final List<FDataGridColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row)? rowKey;
  final Set<Object> selectedRowKeys;
  final FValueChanged<Set<Object>>? onSelectionChanged;
  final double? rowHeight;

  @override
  State<FDataGrid<T>> createState() => _FDataGridState<T>();
}

class _FDataGridState<T> extends State<FDataGrid<T>> {
  int? _sortColumn;
  bool _ascending = true;

  List<T> get _visibleRows {
    final rows = List<T>.of(widget.rows);
    final columnIndex = _sortColumn;
    if (columnIndex == null) return rows;
    final compare = widget.columns[columnIndex].compare;
    if (compare == null) return rows;
    rows.sort((left, right) {
      final result = compare(left, right);
      return _ascending ? result : -result;
    });
    return rows;
  }

  Object? _keyFor(T row) => widget.rowKey?.call(row);

  void _sort(int index) {
    if (widget.columns[index].compare == null) return;
    setState(() {
      if (_sortColumn == index) {
        _ascending = !_ascending;
      } else {
        _sortColumn = index;
        _ascending = true;
      }
    });
  }

  void _toggleSelection(T row) {
    final key = _keyFor(row);
    if (key == null || widget.onSelectionChanged == null) return;
    final selected = Set<Object>.of(widget.selectedRowKeys);
    if (!selected.add(key)) selected.remove(key);
    widget.onSelectionChanged!(Set<Object>.unmodifiable(selected));
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    final density = theme.effectiveDensity;
    final rows = _visibleRows;
    final totalWidth = widget.columns.fold<double>(
      0,
      (width, column) => width + column.width,
    );
    final height = widget.rowHeight ?? density.hitTargetMin;

    return Semantics(
      container: true,
      label: 'Data grid, ${rows.length} rows, ${widget.columns.length} columns',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <FWidget>[
              Container(
                height: density.toolbarHeight,
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  border: Border(
                    bottom: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: <FWidget>[
                    for (var index = 0; index < widget.columns.length; index++)
                      SizedBox(
                        width: widget.columns[index].width,
                        child: _FDataGridHeader<T>(
                          column: widget.columns[index],
                          sorted: _sortColumn == index,
                          ascending: _ascending,
                          onPressed: widget.columns[index].compare == null
                              ? null
                              : () => _sort(index),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemExtent: height,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final key = _keyFor(row);
                    final selected =
                        key != null && widget.selectedRowKeys.contains(key);
                    return _FDataGridRow<T>(
                      row: row,
                      index: index,
                      columns: widget.columns,
                      selected: selected,
                      height: height,
                      onActivate:
                          key == null || widget.onSelectionChanged == null
                              ? null
                              : () => _toggleSelection(row),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FDataGridRow<T> extends StatefulWidget {
  const _FDataGridRow({
    required this.row,
    required this.index,
    required this.columns,
    required this.selected,
    required this.height,
    required this.onActivate,
  });

  final T row;
  final int index;
  final List<FDataGridColumn<T>> columns;
  final bool selected;
  final double height;
  final FVoidCallback? onActivate;

  @override
  State<_FDataGridRow<T>> createState() => _FDataGridRowState<T>();
}

class _FDataGridRowState<T> extends State<_FDataGridRow<T>> {
  bool _focused = false;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    return Semantics(
      container: true,
      button: widget.onActivate != null,
      enabled: widget.onActivate != null,
      selected: widget.selected,
      label: 'Row ${widget.index + 1}${widget.selected ? ', selected' : ''}',
      child: FocusableActionDetector(
        enabled: widget.onActivate != null,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onActivate?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onActivate,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.selected
                  ? colors.selection
                  : (widget.index.isEven
                      ? colors.surface
                      : colors.surfaceSubtle),
              border: Border(
                bottom: BorderSide(
                  color: colors.border.withOpacity(.6),
                  width: .5,
                ),
              ),
              boxShadow: _focused
                  ? <BoxShadow>[
                      BoxShadow(
                        color: colors.focusRing,
                        spreadRadius: 1,
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              height: widget.height,
              child: Row(
                children: <FWidget>[
                  for (final column in widget.columns)
                    SizedBox(
                      width: column.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: DefaultTextStyle.merge(
                            style: theme.tokens.typography.body
                                .copyWith(color: colors.textPrimary),
                            child: column.cellBuilder(context, widget.row),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FDataGridHeader<T> extends StatelessWidget {
  const _FDataGridHeader({
    required this.column,
    required this.sorted,
    required this.ascending,
    required this.onPressed,
  });

  final FDataGridColumn<T> column;
  final bool sorted;
  final bool ascending;
  final FVoidCallback? onPressed;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return Semantics(
      button: onPressed != null,
      label: column.label,
      value: sorted ? (ascending ? 'Ascending' : 'Descending') : null,
      child: FButton(
        onPressed: onPressed,
        variant: FButtonVariant.subtle,
        size: FControlSize.compact,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <FWidget>[
            Flexible(
              child: Text(
                column.label,
                overflow: TextOverflow.ellipsis,
                style: theme.tokens.typography.label,
              ),
            ),
            if (sorted) ...<FWidget>[
              const SizedBox(width: 4),
              FIcon(
                ascending ? FIcons.arrowUpward : FIcons.arrowDownward,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A lazy, expandable tree row.
class FTreeNode<T> {
  const FTreeNode({
    required this.id,
    required this.value,
    required this.label,
    this.children = const [],
    this.loadChildren,
    this.initiallyExpanded = false,
  });

  final Object id;
  final T value;
  final String label;
  final List<FTreeNode<T>> children;
  final Future<List<FTreeNode<T>>> Function()? loadChildren;
  final bool initiallyExpanded;

  bool get canExpand => children.isNotEmpty || loadChildren != null;
}

class _VisibleTreeNode<T> {
  const _VisibleTreeNode(this.node, this.depth);

  final FTreeNode<T> node;
  final int depth;
}

/// A virtualized tree view with expansion, selection, and lazy child loading.
class FTreeView<T> extends StatefulWidget {
  const FTreeView({
    super.key,
    required this.nodes,
    this.selectedId,
    this.onSelected,
    this.onLoadError,
    this.indent = 18,
    this.rowHeight,
  }) : assert(indent > 0);

  final List<FTreeNode<T>> nodes;
  final Object? selectedId;
  final FValueChanged<FTreeNode<T>>? onSelected;
  final FValueChanged<Object>? onLoadError;
  final double indent;
  final double? rowHeight;

  @override
  State<FTreeView<T>> createState() => _FTreeViewState<T>();
}

class _FTreeViewState<T> extends State<FTreeView<T>> {
  final Set<Object> _expanded = <Object>{};
  final Set<Object> _loading = <Object>{};
  final Map<Object, List<FTreeNode<T>>> _loaded =
      <Object, List<FTreeNode<T>>>{};

  @override
  void initState() {
    super.initState();
    _collectInitiallyExpanded(widget.nodes);
  }

  @override
  void didUpdateWidget(FTreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.nodes, widget.nodes)) {
      _expanded.removeWhere((id) => !_containsId(widget.nodes, id));
      _loaded.removeWhere((id, _) => !_containsId(widget.nodes, id));
      _collectInitiallyExpanded(widget.nodes);
    }
  }

  void _collectInitiallyExpanded(List<FTreeNode<T>> nodes) {
    for (final node in nodes) {
      if (node.initiallyExpanded) _expanded.add(node.id);
      _collectInitiallyExpanded(node.children);
    }
  }

  bool _containsId(List<FTreeNode<T>> nodes, Object id) {
    for (final node in nodes) {
      if (node.id == id || _containsId(node.children, id)) return true;
    }
    return false;
  }

  List<FTreeNode<T>> _childrenFor(FTreeNode<T> node) =>
      _loaded[node.id] ?? node.children;

  List<_VisibleTreeNode<T>> _flatten() {
    final result = <_VisibleTreeNode<T>>[];
    void visit(List<FTreeNode<T>> nodes, int depth) {
      for (final node in nodes) {
        result.add(_VisibleTreeNode<T>(node, depth));
        if (_expanded.contains(node.id)) visit(_childrenFor(node), depth + 1);
      }
    }

    visit(widget.nodes, 0);
    return result;
  }

  Future<void> _toggle(FTreeNode<T> node) async {
    if (_expanded.remove(node.id)) {
      setState(() {});
      return;
    }
    _expanded.add(node.id);
    if (node.children.isEmpty &&
        !_loaded.containsKey(node.id) &&
        node.loadChildren != null) {
      setState(() => _loading.add(node.id));
      try {
        final children = await node.loadChildren!();
        if (!mounted) return;
        setState(() {
          _loaded[node.id] = children;
          _loading.remove(node.id);
        });
      } catch (error) {
        if (!mounted) return;
        setState(() => _loading.remove(node.id));
        if (widget.onLoadError != null) {
          widget.onLoadError!(error);
        } else {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              library: 'fframe',
              context: ErrorDescription(
                'while loading children for tree node ${node.label}',
              ),
            ),
          );
        }
        return;
      }
      return;
    }
    setState(() {});
  }

  @override
  FWidget build(FBuildContext context) {
    final visibleNodes = _flatten();
    final theme = FTheme.of(context);
    final rowHeight = widget.rowHeight ??
        theme.effectiveDensity.hitTargetMin
            .clamp(40, double.infinity)
            .toDouble();
    return Semantics(
      container: true,
      label: 'Tree view, ${visibleNodes.length} visible items',
      child: ListView.builder(
        itemCount: visibleNodes.length,
        itemExtent: rowHeight,
        itemBuilder: (context, index) {
          final entry = visibleNodes[index];
          final node = entry.node;
          final expanded = _expanded.contains(node.id);
          final selected = widget.selectedId == node.id;
          return Padding(
            padding:
                EdgeInsetsDirectional.only(start: entry.depth * widget.indent),
            child: Semantics(
              container: true,
              selected: selected,
              expanded: node.canExpand ? expanded : null,
              label: '${node.label}, level ${entry.depth + 1}',
              child: Focus(
                canRequestFocus: false,
                onKeyEvent: (focus, event) {
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                      node.canExpand &&
                      !expanded) {
                    _toggle(node);
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                      node.canExpand &&
                      expanded) {
                    _toggle(node);
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    focus.focusInDirection(TraversalDirection.down);
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    focus.focusInDirection(TraversalDirection.up);
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    widget.onSelected?.call(node);
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Row(
                  children: <FWidget>[
                    SizedBox(
                      width: widget.indent,
                      child: node.canExpand
                          ? _loading.contains(node.id)
                              ? Semantics(
                                  liveRegion: true,
                                  label: 'Loading children',
                                  child: FIcon(FIcons.refresh, size: 14),
                                )
                              : FIconButton(
                                  icon: FIcon(
                                    expanded
                                        ? FIcons.expandMore
                                        : FIcons.chevronRight,
                                    size: 14,
                                  ),
                                  tooltip: expanded ? 'Collapse' : 'Expand',
                                  onPressed: () => _toggle(node),
                                  size: FControlSize.compact,
                                )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: FButton(
                        onPressed: widget.onSelected == null
                            ? null
                            : () => widget.onSelected?.call(node),
                        variant: selected
                            ? FButtonVariant.secondary
                            : FButtonVariant.subtle,
                        size: FControlSize.compact,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            node.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
