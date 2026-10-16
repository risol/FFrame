import 'package:flutter/widgets.dart';

import 'render_grid.dart';
import 'track.dart';

/// Alignment of a grid child inside the cell it occupies.
enum FGridAlignment { stretch, start, center, end }

/// How grid children behave when resolved tracks exceed the grid's size.
enum FOverflowBehavior { clip, overflow }

/// Positions a child in an [FGrid]. Indices are zero-based.
class FGridItem extends ParentDataWidget<FGridParentData> {
  /// Creates a grid cell at ([row], [column]).
  const FGridItem({
    super.key,
    this.row = 0,
    this.column = 0,
    this.rowSpan = 1,
    this.columnSpan = 1,
    this.alignment = FGridAlignment.stretch,
    required super.child,
  })  : assert(row >= 0),
        assert(column >= 0),
        assert(rowSpan > 0),
        assert(columnSpan > 0);

  /// Zero-based row index.
  final int row;

  /// Zero-based column index, counted from the text direction's start edge.
  final int column;

  /// Number of rows occupied by this child.
  final int rowSpan;

  /// Number of columns occupied by this child.
  final int columnSpan;

  /// Child alignment within its resolved cell.
  final FGridAlignment alignment;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as FGridParentData;
    var needsLayout = false;
    if (data.row != row) {
      data.row = row;
      needsLayout = true;
    }
    if (data.column != column) {
      data.column = column;
      needsLayout = true;
    }
    if (data.rowSpan != rowSpan) {
      data.rowSpan = rowSpan;
      needsLayout = true;
    }
    if (data.columnSpan != columnSpan) {
      data.columnSpan = columnSpan;
      needsLayout = true;
    }
    if (data.alignment != alignment) {
      data.alignment = alignment;
      needsLayout = true;
    }
    if (needsLayout) renderObject.parent?.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FGrid;
}

/// A constraint-driven grid with explicit fixed, auto, and flex tracks.
///
/// Auto tracks use a bounded intrinsic measurement pass. Keep them for small
/// toolbars and labels; use flex tracks for large or complex subtrees.
class FGrid extends MultiChildRenderObjectWidget {
  /// Creates a grid with explicit [columns] and [rows].
  FGrid({
    super.key,
    required List<FTrack> columns,
    required List<FTrack> rows,
    required List<FGridItem> children,
    this.columnGap = 0,
    this.rowGap = 0,
    this.overflowBehavior = FOverflowBehavior.clip,
  })  : columns = List<FTrack>.unmodifiable(columns),
        rows = List<FTrack>.unmodifiable(rows),
        assert(columns.isNotEmpty),
        assert(rows.isNotEmpty),
        assert(columnGap >= 0 && columnGap < double.infinity),
        assert(rowGap >= 0 && rowGap < double.infinity),
        super(children: List<Widget>.unmodifiable(children));

  /// Column track definitions.
  final List<FTrack> columns;

  /// Row track definitions.
  final List<FTrack> rows;

  /// Horizontal space between columns.
  final double columnGap;

  /// Vertical space between rows.
  final double rowGap;

  /// Paint behavior when track sizes exceed the available extent.
  final FOverflowBehavior overflowBehavior;

  @override
  RenderFGrid createRenderObject(BuildContext context) => RenderFGrid(
        columns: columns,
        rows: rows,
        columnGap: columnGap,
        rowGap: rowGap,
        textDirection: Directionality.of(context),
        overflowBehavior: overflowBehavior,
      );

  @override
  void updateRenderObject(BuildContext context, RenderFGrid renderObject) {
    renderObject
      ..columns = columns
      ..rows = rows
      ..columnGap = columnGap
      ..rowGap = rowGap
      ..textDirection = Directionality.of(context)
      ..overflowBehavior = overflowBehavior;
  }
}
