import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fframe/fframe.dart';

void main() {
  test('flips bottom placement above the anchor when needed', () {
    final result = FPlacementResolver.resolve(
      anchor: const Rect.fromLTWH(60, 100, 20, 16),
      overlaySize: const Size(100, 70),
      viewport: const Rect.fromLTWH(0, 0, 240, 160),
      policy: FPlacementPolicy(
        preferred: FPlacement.bottomStart,
        viewportPadding: 8,
        fallback: const <FPlacement>[FPlacement.topStart],
      ),
    );
    expect(result.placement, FPlacement.topStart);
    expect(result.fits, isTrue);
    expect(result.rect.bottom, lessThanOrEqualTo(100));
  });

  test('shifts an oversized horizontal placement inside the viewport', () {
    final result = FPlacementResolver.resolve(
      anchor: const Rect.fromLTWH(180, 30, 20, 20),
      overlaySize: const Size(120, 60),
      viewport: const Rect.fromLTWH(0, 0, 240, 120),
      policy:
          FPlacementPolicy(preferred: FPlacement.bottomEnd, viewportPadding: 8),
    );
    expect(result.rect.left, greaterThanOrEqualTo(8));
    expect(result.rect.right, lessThanOrEqualTo(232));
  });
}
