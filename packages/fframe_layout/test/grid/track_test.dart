import 'package:flutter_test/flutter_test.dart';
import 'package:fframe_layout/fframe_layout.dart';

void main() {
  group('FTrackLayout.resolve', () {
    test('allocates fixed, auto, gaps, and remaining flex space', () {
      final sizes = FTrackLayout.resolve(
        tracks: const <FTrack>[
          FTrack.fixed(200),
          FTrack.auto(),
          FTrack.flex(),
        ],
        extent: 1000,
        gap: 10,
        intrinsicSizes: const <double>[200, 100, 0],
      );
      expect(sizes, <double>[200, 100, 680]);
    });

    test('redistributes flex space when a track reaches max', () {
      final sizes = FTrackLayout.resolve(
        tracks: const <FTrack>[
          FTrack.flex(weight: 1, max: 200),
          FTrack.flex(weight: 2),
        ],
        extent: 900,
        gap: 0,
      );
      expect(sizes, <double>[200, 700]);
    });

    test('preserves minimums when available space is too small', () {
      final sizes = FTrackLayout.resolve(
        tracks: const <FTrack>[
          FTrack.flex(min: 80),
          FTrack.flex(min: 120),
        ],
        extent: 100,
        gap: 0,
      );
      expect(sizes, <double>[80, 120]);
    });
  });
}
