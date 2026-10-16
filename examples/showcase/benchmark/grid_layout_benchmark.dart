import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';

void main() {
  FFrameScheduler.ensureInitialized();
  var frameCount = 0;
  var buildMicros = 0;
  var rasterMicros = 0;
  FFrameScheduler.addTimingsCallback((timings) {
    for (final timing in timings) {
      frameCount++;
      buildMicros += timing.buildDuration.inMicroseconds;
      rasterMicros += timing.rasterDuration.inMicroseconds;
    }
    if (frameCount >= 120) {
      FFrameLog.info(
        'FFrame layout benchmark: $frameCount frames, '
        'average build ${buildMicros ~/ frameCount} µs, '
        'average raster ${rasterMicros ~/ frameCount} µs',
        name: 'fframe.benchmark',
      );
      frameCount = 0;
      buildMicros = 0;
      rasterMicros = 0;
    }
  });
  runFFrameApp(const _BenchmarkApp());
}

class _BenchmarkApp extends FStatelessWidget {
  const _BenchmarkApp();

  @override
  FWidget build(FBuildContext context) => FFrameApp(
    title: 'FFrame Layout Benchmark',
    designSystem: FWpfDesignSystem.light(),
    home: const _BenchmarkPage(),
  );
}

class _BenchmarkPage extends FStatefulWidget {
  const _BenchmarkPage();

  @override
  FState<_BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends FState<_BenchmarkPage> {
  int _itemCount = 100;
  bool _useGrid = true;

  @override
  FWidget build(FBuildContext context) {
    final colors = FTheme.of(context).tokens.colors;
    const columnCount = 10;
    final rowCount = (_itemCount + columnCount - 1) ~/ columnCount;
    final cells = <FWidget>[
      for (var index = 0; index < _itemCount; index++) _cell(index, colors),
    ];
    final layout = _useGrid
        ? FGrid(
            columns: List<FTrack>.filled(columnCount, const FTrack.flex()),
            rows: List<FTrack>.filled(rowCount, const FTrack.fixed(44)),
            children: <FGridItem>[
              for (var index = 0; index < _itemCount; index++)
                FGridItem(
                  row: index ~/ columnCount,
                  column: index % columnCount,
                  child: cells[index],
                ),
            ],
          )
        : FWrap(spacing: 4, runSpacing: 4, children: cells);

    return FDesktopShell(
      titleBar: FContainer(
        height: 48,
        padding: const FEdgeInsets.symmetric(horizontal: 16),
        color: colors.surfaceRaised,
        child: FRow(
          children: <FWidget>[
            FText(
              'FFrame layout benchmark',
              style: FTheme.of(context).tokens.typography.title,
            ),
            const FSpacer(),
            FSelect<int>(
              value: _itemCount,
              onChanged: (value) => setState(() => _itemCount = value ?? 100),
              items: const <FSelectItem<int>>[
                FSelectItem(value: 100, label: '100 cells'),
                FSelectItem(value: 1000, label: '1,000 cells'),
              ],
            ),
            const FSizedBox(width: 8),
            FButton(
              onPressed: () => setState(() => _useGrid = !_useGrid),
              child: FText(_useGrid ? 'Use FWrap' : 'Use FGrid'),
            ),
          ],
        ),
      ),
      body: FColumn(
        crossAxisAlignment: FCrossAxisAlignment.stretch,
        children: <FWidget>[
          FContainer(
            height: 34,
            padding: const FEdgeInsets.symmetric(horizontal: 14),
            color: colors.surfaceSubtle,
            child: FRow(
              children: <FWidget>[
                FText('${_useGrid ? 'FGrid' : 'FWrap'} · $_itemCount cells'),
                const FSpacer(),
                const FText('Frame timings print every 120 frames'),
              ],
            ),
          ),
          FExpanded(
            child: FScrollArea(
              padding: const FEdgeInsets.all(12),
              child: layout,
            ),
          ),
        ],
      ),
    );
  }

  FWidget _cell(int index, FColorTokens colors) {
    final color = switch (index % 4) {
      0 => colors.surfaceRaised,
      1 => colors.surfaceSubtle,
      2 => colors.selection,
      _ => colors.hover,
    };
    return FContainer(
      width: _useGrid ? null : 92,
      height: 40,
      color: color,
      alignment: FAlignment.center,
      child: FText('$index'),
    );
  }
}
