import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Position of an anchored overlay relative to its anchor rectangle.
enum FPlacement {
  topStart,
  top,
  topEnd,
  rightStart,
  right,
  rightEnd,
  bottomEnd,
  bottom,
  bottomStart,
  leftEnd,
  left,
  leftStart,
}

/// Placement preferences for an anchored overlay.
@immutable
class FPlacementPolicy {
  /// Creates a placement policy.
  FPlacementPolicy({
    required this.preferred,
    List<FPlacement> fallback = const <FPlacement>[],
    this.viewportPadding = 8,
    this.mainAxisOffset = 4,
    this.crossAxisOffset = 0,
    this.flip = true,
    this.shift = true,
  })  : assert(viewportPadding >= 0),
        assert(mainAxisOffset >= 0),
        fallback = List<FPlacement>.unmodifiable(fallback);

  /// Preferred placement.
  final FPlacement preferred;

  /// Ordered fallback placements.
  final List<FPlacement> fallback;

  /// Minimum inset from the viewport edge.
  final double viewportPadding;

  /// Separation from the anchor on the placement axis.
  final double mainAxisOffset;

  /// Offset on the cross axis.
  final double crossAxisOffset;

  /// Whether the opposite side is considered before shifting.
  final bool flip;

  /// Whether an out-of-bounds overlay is shifted into the viewport.
  final bool shift;
}

/// A resolved overlay placement.
@immutable
class FPlacementResult {
  /// Creates a placement result.
  const FPlacementResult({
    required this.placement,
    required this.rect,
    required this.fits,
  });

  /// Placement selected by the resolver.
  final FPlacement placement;

  /// Resolved overlay rectangle in viewport coordinates.
  final Rect rect;

  /// Whether the unshifted overlay fit inside the padded viewport.
  final bool fits;
}

/// Computes flip, shift, and clamp placement for an anchored overlay.
abstract final class FPlacementResolver {
  /// Resolves an overlay rectangle from [anchor] and [overlaySize].
  static FPlacementResult resolve({
    required Rect anchor,
    required Size overlaySize,
    required Rect viewport,
    required FPlacementPolicy policy,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final candidates = <FPlacement>{
      policy.preferred,
      if (policy.flip) _opposite(policy.preferred, textDirection),
      ...policy.fallback,
    }.toList();
    final padded = Rect.fromLTRB(
      viewport.left + policy.viewportPadding,
      viewport.top + policy.viewportPadding,
      math.max(
        viewport.left + policy.viewportPadding,
        viewport.right - policy.viewportPadding,
      ),
      math.max(
        viewport.top + policy.viewportPadding,
        viewport.bottom - policy.viewportPadding,
      ),
    );

    FPlacementResult? best;
    var bestOverflow = double.infinity;
    for (final candidate in candidates) {
      final rect = _position(
        anchor,
        overlaySize,
        candidate,
        policy,
        textDirection,
      );
      final overflow = _overflow(rect, padded);
      final fits = overflow <= 0.001;
      if (fits) {
        best = FPlacementResult(placement: candidate, rect: rect, fits: true);
        break;
      }
      if (overflow < bestOverflow) {
        bestOverflow = overflow;
        best = FPlacementResult(placement: candidate, rect: rect, fits: false);
      }
    }

    final result = best ??
        FPlacementResult(
          placement: policy.preferred,
          rect: _position(
            anchor,
            overlaySize,
            policy.preferred,
            policy,
            textDirection,
          ),
          fits: false,
        );
    final rect = policy.shift ? _shiftInto(result.rect, padded) : result.rect;
    return FPlacementResult(
      placement: result.placement,
      rect: rect,
      fits: result.fits,
    );
  }

  static Rect _position(
    Rect anchor,
    Size size,
    FPlacement placement,
    FPlacementPolicy policy,
    TextDirection direction,
  ) {
    final startIsLeft = direction == TextDirection.ltr;
    final leftStart = startIsLeft ? anchor.left : anchor.right - size.width;
    final leftEnd = startIsLeft ? anchor.right - size.width : anchor.left;
    final rightStart = startIsLeft ? anchor.right : anchor.left - size.width;
    final rightEnd = startIsLeft ? anchor.left - size.width : anchor.right;
    final x = switch (placement) {
      FPlacement.topStart || FPlacement.bottomStart => leftStart,
      FPlacement.topEnd || FPlacement.bottomEnd => leftEnd,
      FPlacement.top || FPlacement.bottom => anchor.center.dx - size.width / 2,
      FPlacement.leftStart ||
      FPlacement.rightStart =>
        placement.name.startsWith('left')
            ? anchor.left - size.width
            : anchor.right,
      FPlacement.leftEnd ||
      FPlacement.rightEnd =>
        placement.name.startsWith('left')
            ? anchor.left - size.width
            : anchor.right,
      FPlacement.left ||
      FPlacement.right =>
        placement.name == 'left' ? anchor.left - size.width : anchor.right,
    };
    final y = switch (placement) {
      FPlacement.topStart ||
      FPlacement.top ||
      FPlacement.topEnd =>
        anchor.top - size.height - policy.mainAxisOffset,
      FPlacement.bottomStart ||
      FPlacement.bottom ||
      FPlacement.bottomEnd =>
        anchor.bottom + policy.mainAxisOffset,
      FPlacement.leftStart || FPlacement.rightStart => anchor.top,
      FPlacement.left || FPlacement.right => anchor.center.dy - size.height / 2,
      FPlacement.leftEnd || FPlacement.rightEnd => anchor.bottom - size.height,
    };
    final adjustedX = _isVertical(placement)
        ? x +
            (placement.name.startsWith('right')
                ? policy.mainAxisOffset
                : -policy.mainAxisOffset)
        : x + policy.crossAxisOffset;
    final adjustedY = _isVertical(placement) ? y + policy.crossAxisOffset : y;
    // Keep logical start/end semantics and avoid unused calculations in the
    // switch above becoming platform-specific left/right assumptions.
    assert(
      leftStart.isFinite &&
          leftEnd.isFinite &&
          rightStart.isFinite &&
          rightEnd.isFinite,
    );
    return Rect.fromLTWH(adjustedX, adjustedY, size.width, size.height);
  }

  static bool _isVertical(FPlacement placement) => switch (placement) {
        FPlacement.left ||
        FPlacement.leftStart ||
        FPlacement.leftEnd ||
        FPlacement.right ||
        FPlacement.rightStart ||
        FPlacement.rightEnd =>
          true,
        _ => false,
      };

  static FPlacement _opposite(FPlacement placement, TextDirection direction) =>
      switch (placement) {
        FPlacement.topStart => FPlacement.bottomStart,
        FPlacement.top => FPlacement.bottom,
        FPlacement.topEnd => FPlacement.bottomEnd,
        FPlacement.bottomStart => FPlacement.topStart,
        FPlacement.bottom => FPlacement.top,
        FPlacement.bottomEnd => FPlacement.topEnd,
        FPlacement.leftStart => FPlacement.rightStart,
        FPlacement.left => FPlacement.right,
        FPlacement.leftEnd => FPlacement.rightEnd,
        FPlacement.rightStart => FPlacement.leftStart,
        FPlacement.right => FPlacement.left,
        FPlacement.rightEnd => FPlacement.leftEnd,
      };

  static double _overflow(Rect rect, Rect bounds) =>
      math.max(0, bounds.left - rect.left) +
      math.max(0, rect.right - bounds.right) +
      math.max(0, bounds.top - rect.top) +
      math.max(0, rect.bottom - bounds.bottom);

  static Rect _shiftInto(Rect rect, Rect bounds) {
    double shiftAxis(double start, double extent, double min, double max) {
      if (extent >= max - min) return min;
      return start.clamp(min, max - extent).toDouble();
    }

    final left = shiftAxis(rect.left, rect.width, bounds.left, bounds.right);
    final top = shiftAxis(rect.top, rect.height, bounds.top, bounds.bottom);
    return Rect.fromLTWH(left, top, rect.width, rect.height);
  }
}
