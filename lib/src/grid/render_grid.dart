import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'grid.dart';
import 'track.dart';

/// Parent data for [RenderFGrid].
class FGridParentData extends ContainerBoxParentData<RenderBox> {
  int row = 0;
  int column = 0;
  int rowSpan = 1;
  int columnSpan = 1;
  FGridAlignment alignment = FGridAlignment.stretch;
}

/// Render object that places children into explicit grid cells.
class RenderFGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FGridParentData> {
  RenderFGrid({
    required List<FTrack> columns,
    required List<FTrack> rows,
    required double columnGap,
    required double rowGap,
    required TextDirection textDirection,
    required FOverflowBehavior overflowBehavior,
  })  : _columns = columns,
        _rows = rows,
        _columnGap = columnGap,
        _rowGap = rowGap,
        _textDirection = textDirection,
        _overflowBehavior = overflowBehavior;

  List<FTrack> _columns;
  List<FTrack> _rows;
  double _columnGap;
  double _rowGap;
  TextDirection _textDirection;
  FOverflowBehavior _overflowBehavior;

  set columns(List<FTrack> value) {
    if (listEquals(_columns, value)) return;
    _columns = value;
    markNeedsLayout();
  }

  set rows(List<FTrack> value) {
    if (listEquals(_rows, value)) return;
    _rows = value;
    markNeedsLayout();
  }

  set columnGap(double value) {
    if (_columnGap == value) return;
    _columnGap = value;
    markNeedsLayout();
  }

  set rowGap(double value) {
    if (_rowGap == value) return;
    _rowGap = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  set overflowBehavior(FOverflowBehavior value) {
    if (_overflowBehavior == value) return;
    _overflowBehavior = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FGridParentData) {
      child.parentData = FGridParentData();
    }
  }

  @override
  void performLayout() {
    _validateChildren();
    size = constraints.biggest;
    if (!size.width.isFinite || !size.height.isFinite) {
      size = constraints.constrain(_naturalSize());
    }
    final columnIntrinsics = _measureAxis(Axis.horizontal, size.height);
    final rowIntrinsics = _measureAxis(Axis.vertical, size.width);
    final widths = FTrackLayout.resolve(
      tracks: _columns,
      extent: size.width,
      gap: _columnGap,
      intrinsicSizes: columnIntrinsics,
    );
    final heights = FTrackLayout.resolve(
      tracks: _rows,
      extent: size.height,
      gap: _rowGap,
      intrinsicSizes: rowIntrinsics,
    );
    final xOffsets = _offsets(widths, _columnGap);
    final yOffsets = _offsets(heights, _rowGap);
    final totalWidth =
        _sum(widths) + math.max(0, widths.length - 1) * _columnGap;

    RenderBox? child = firstChild;
    while (child != null) {
      final data = child.parentData! as FGridParentData;
      final cellWidth = _spanExtent(
        widths,
        data.column,
        data.columnSpan,
        _columnGap,
      );
      final cellHeight = _spanExtent(heights, data.row, data.rowSpan, _rowGap);
      final stretch = data.alignment == FGridAlignment.stretch;
      child.layout(
        BoxConstraints(
          maxWidth: math.max(0, cellWidth),
          maxHeight: math.max(0, cellHeight),
          minWidth: stretch ? math.max(0, cellWidth) : 0,
          minHeight: stretch ? math.max(0, cellHeight) : 0,
        ),
        parentUsesSize: true,
      );
      final cellLogicalX = xOffsets[data.column];
      final x = _textDirection == TextDirection.ltr
          ? cellLogicalX
          : totalWidth - cellLogicalX - cellWidth;
      final y = yOffsets[data.row];
      data.offset = Offset(
        x +
            _horizontalAlignmentOffset(
              cellWidth,
              child.size.width,
              data.alignment,
            ),
        y +
            _verticalAlignmentOffset(
              cellHeight,
              child.size.height,
              data.alignment,
            ),
      );
      child = childAfter(child);
    }
  }

  Size _naturalSize() {
    final columnWidths = _measureAxis(Axis.horizontal, double.infinity);
    final rowHeights = _measureAxis(Axis.vertical, double.infinity);
    return Size(
      _estimateExtent(_columns, columnWidths, _columnGap),
      _estimateExtent(_rows, rowHeights, _rowGap),
    );
  }

  List<double> _measureAxis(Axis axis, double crossExtent) {
    final tracks = axis == Axis.horizontal ? _columns : _rows;
    final gap = axis == Axis.horizontal ? _columnGap : _rowGap;
    final measured = List<double>.generate(tracks.length, (index) {
      final track = tracks[index];
      if (track is FFixedTrack) return track.size;
      if (track is FFlexTrack) return track.min;
      return track.min;
    });
    RenderBox? child = firstChild;
    while (child != null) {
      final data = child.parentData! as FGridParentData;
      final start = axis == Axis.horizontal ? data.column : data.row;
      final span = axis == Axis.horizontal ? data.columnSpan : data.rowSpan;
      final end = start + span;
      if (end > tracks.length) {
        child = childAfter(child);
        continue;
      }
      final autoIndices = <int>[];
      for (var i = start; i < end; i++) {
        if (tracks[i] is FAutoTrack) autoIndices.add(i);
      }
      if (autoIndices.isNotEmpty) {
        final crossTracks = axis == Axis.horizontal ? _rows : _columns;
        final crossGap = axis == Axis.horizontal ? _rowGap : _columnGap;
        final crossStart = axis == Axis.horizontal ? data.row : data.column;
        final crossSpan =
            axis == Axis.horizontal ? data.rowSpan : data.columnSpan;
        final crossSize = _knownSpan(
          crossTracks,
          crossStart,
          crossSpan,
          crossGap,
        );
        final availableCross = crossExtent.isFinite
            ? math.min(
                crossExtent,
                math.max(crossSize, _finiteOrZero(crossExtent)),
              )
            : crossSize;
        final intrinsic = axis == Axis.horizontal
            ? child.getMaxIntrinsicWidth(availableCross)
            : child.getMaxIntrinsicHeight(availableCross);
        final current =
            _sum(measured.sublist(start, end)) + math.max(0, span - 1) * gap;
        var deficit = math.max(0.0, intrinsic - current);
        var growable = List<int>.of(autoIndices);
        while (deficit > 0.001 && growable.isNotEmpty) {
          final share = deficit / growable.length;
          var consumed = 0.0;
          final capped = <int>[];
          for (final index in growable) {
            final track = tracks[index] as FAutoTrack;
            final room =
                math.max(0.0, (track.max ?? double.infinity) - measured[index]);
            final addition = math.min(share, room);
            measured[index] += addition;
            consumed += addition;
            if (addition + 0.001 < share) capped.add(index);
          }
          deficit -= consumed;
          if (capped.isEmpty || consumed <= 0.001) break;
          growable =
              growable.where((index) => !capped.contains(index)).toList();
        }
      }
      child = childAfter(child);
    }
    return measured;
  }

  void _validateChildren() {
    assert(() {
      RenderBox? child = firstChild;
      while (child != null) {
        final data = child.parentData! as FGridParentData;
        if (data.row + data.rowSpan > _rows.length ||
            data.column + data.columnSpan > _columns.length) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('FGridItem is outside the grid tracks.'),
            ErrorDescription(
              'Cell row=${data.row}, column=${data.column}, '
              'rowSpan=${data.rowSpan}, columnSpan=${data.columnSpan} exceeds '
              '${_rows.length} rows or ${_columns.length} columns.',
            ),
            ErrorHint('Add explicit tracks or reduce the cell span.'),
          ]);
        }
        child = childAfter(child);
      }
      return true;
    }());
  }

  static double _finiteOrZero(double value) => value.isFinite ? value : 0;

  static double _knownSpan(
    List<FTrack> tracks,
    int start,
    int span,
    double gap,
  ) {
    var result = 0.0;
    for (var i = start; i < start + span && i < tracks.length; i++) {
      final track = tracks[i];
      result += track is FFixedTrack ? track.size : track.min;
    }
    return result + math.max(0, span - 1) * gap;
  }

  static double _estimateExtent(
    List<FTrack> tracks,
    List<double> measured,
    double gap,
  ) {
    var extent = 0.0;
    for (var i = 0; i < tracks.length; i++) {
      extent +=
          tracks[i] is FFlexTrack ? (tracks[i] as FFlexTrack).min : measured[i];
    }
    return extent + math.max(0, tracks.length - 1) * gap;
  }

  static List<double> _offsets(List<double> extents, double gap) {
    var cursor = 0.0;
    return List<double>.generate(extents.length, (index) {
      final offset = cursor;
      cursor += extents[index] + gap;
      return offset;
    });
  }

  static double _spanExtent(
    List<double> extents,
    int start,
    int span,
    double gap,
  ) {
    var extent = 0.0;
    for (var i = start; i < start + span; i++) {
      extent += extents[i];
    }
    return extent + math.max(0, span - 1) * gap;
  }

  static double _sum(List<double> values) =>
      values.fold<double>(0, (a, b) => a + b);

  double _horizontalAlignmentOffset(
    double cell,
    double child,
    FGridAlignment alignment,
  ) =>
      switch (alignment) {
        FGridAlignment.stretch => 0,
        FGridAlignment.center => (cell - child) / 2,
        FGridAlignment.start =>
          _textDirection == TextDirection.ltr ? 0 : cell - child,
        FGridAlignment.end =>
          _textDirection == TextDirection.ltr ? cell - child : 0,
      };

  static double _verticalAlignmentOffset(
    double cell,
    double child,
    FGridAlignment alignment,
  ) =>
      switch (alignment) {
        FGridAlignment.stretch || FGridAlignment.start => 0,
        FGridAlignment.center => (cell - child) / 2,
        FGridAlignment.end => cell - child,
      };

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_overflowBehavior == FOverflowBehavior.clip) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
        context,
        offset,
      ) {
        defaultPaint(context, offset);
      });
    } else {
      defaultPaint(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  double computeMinIntrinsicWidth(double height) => _estimateExtent(
        _columns,
        _measureAxis(Axis.horizontal, height),
        _columnGap,
      );

  @override
  double computeMaxIntrinsicWidth(double height) => _estimateExtent(
        _columns,
        _measureAxis(Axis.horizontal, height),
        _columnGap,
      );

  @override
  double computeMinIntrinsicHeight(double width) =>
      _estimateExtent(_rows, _measureAxis(Axis.vertical, width), _rowGap);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _estimateExtent(_rows, _measureAxis(Axis.vertical, width), _rowGap);
}
