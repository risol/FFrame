import 'dart:math' as math;

/// The sizing rule for one [FGrid] row or column.
sealed class FTrack {
  const FTrack._();

  /// A track whose size is always [size] logical pixels.
  const factory FTrack.fixed(double size) = FFixedTrack;

  /// A track sized from its children's intrinsic extent, bounded by [min] and
  /// [max]. Auto tracks are measured once before final child layout.
  const factory FTrack.auto({double min, double? max}) = FAutoTrack;

  /// A track that receives a share of remaining space. [weight] defaults to
  /// one; [min] and [max] constrain the resolved size.
  const factory FTrack.flex({double weight, double min, double? max}) =
      FFlexTrack;

  double get min;
  double? get max;
}

/// Fixed-size track implementation.
final class FFixedTrack extends FTrack {
  const FFixedTrack(this.size)
      : assert(size >= 0 && size < double.infinity),
        super._();

  /// The track extent in logical pixels.
  final double size;

  @override
  double get min => size;

  @override
  double? get max => size;
}

/// Intrinsic-size track implementation.
final class FAutoTrack extends FTrack {
  const FAutoTrack({this.min = 0, this.max})
      : assert(min >= 0 && min < double.infinity),
        assert(max == null || max >= min && max < double.infinity),
        super._();

  @override
  final double min;

  @override
  final double? max;
}

/// Remaining-space track implementation.
final class FFlexTrack extends FTrack {
  const FFlexTrack({this.weight = 1, this.min = 0, this.max})
      : assert(weight > 0 && weight < double.infinity),
        assert(min >= 0 && min < double.infinity),
        assert(max == null || max >= min && max < double.infinity),
        super._();

  /// Relative share of the free extent.
  final double weight;

  @override
  final double min;

  @override
  final double? max;
}

/// Resolves a list of tracks into concrete extents.
///
/// [intrinsicSizes] contains the measured size for each auto track. If the
/// available extent is unbounded, flex tracks resolve to their minimum size.
abstract final class FTrackLayout {
  /// Calculates track extents using fixed, intrinsic, then weighted-flex
  /// sizing. Flex max constraints are honored by redistributing capped space
  /// to the remaining flex tracks.
  static List<double> resolve({
    required List<FTrack> tracks,
    required double extent,
    required double gap,
    List<double>? intrinsicSizes,
  }) {
    assert(gap >= 0 && gap.isFinite);
    final result = List<double>.filled(tracks.length, 0);
    final flexIndices = <int>[];
    var used = math.max(0, tracks.length - 1) * gap;

    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final value = switch (track) {
        FFixedTrack(:final size) => size,
        FAutoTrack(:final min, :final max) => _clampTrack(
            intrinsicSizes != null && i < intrinsicSizes.length
                ? intrinsicSizes[i]
                : min,
            min,
            max,
          ),
        FFlexTrack(:final min) => min,
      };
      result[i] = value;
      used += value;
      if (track is FFlexTrack) flexIndices.add(i);
    }

    if (flexIndices.isEmpty || !extent.isFinite) return result;
    var free = math.max(0.0, extent - used);
    var active = List<int>.of(flexIndices);

    // Iterative water filling handles tracks that hit max while preserving
    // the declared flex weights of the unsaturated tracks.
    while (active.isNotEmpty && free > 0.0001) {
      final totalWeight = active.fold<double>(
        0,
        (sum, index) => sum + (tracks[index] as FFlexTrack).weight,
      );
      if (totalWeight <= 0) break;
      var consumed = 0.0;
      final capped = <int>[];
      for (final index in active) {
        final track = tracks[index] as FFlexTrack;
        final share = free * track.weight / totalWeight;
        final room = track.max == null
            ? double.infinity
            : math.max(0.0, track.max! - result[index]);
        final addition = math.min(share, room);
        result[index] += addition;
        consumed += addition;
        if (addition + 0.0001 < share) capped.add(index);
      }
      free -= consumed;
      if (capped.isEmpty || consumed <= 0.0001) break;
      active = active.where((index) => !capped.contains(index)).toList();
    }
    return result;
  }

  static double _clampTrack(double value, double min, double? max) {
    final lower = math.max(0.0, min);
    final upper = max == null ? double.infinity : math.max(lower, max);
    return value.clamp(lower, upper).toDouble();
  }
}
