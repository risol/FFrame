import 'package:fframe/fframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  var frameCount = 0;
  var buildMicros = 0;
  var rasterMicros = 0;
  SchedulerBinding.instance.addTimingsCallback((timings) {
    for (final timing in timings) {
      frameCount++;
      buildMicros += timing.buildDuration.inMicroseconds;
      rasterMicros += timing.rasterDuration.inMicroseconds;
    }
    if (frameCount >= 120) {
      debugPrint(
        'FFrame benchmark: $frameCount frames, '
        'average build ${buildMicros ~/ frameCount} µs, '
        'average raster ${rasterMicros ~/ frameCount} µs',
      );
      frameCount = 0;
      buildMicros = 0;
      rasterMicros = 0;
    }
  });
  runApp(const _BenchmarkApp());
}

class _BenchmarkApp extends StatelessWidget {
  const _BenchmarkApp();

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _BenchmarkPage(),
      );
}

class _BenchmarkPage extends StatefulWidget {
  const _BenchmarkPage();

  @override
  State<_BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<_BenchmarkPage> {
  int _itemCount = 100;
  bool _useFFrame = true;

  @override
  Widget build(BuildContext context) {
    final columnCount = 10;
    final rowCount = (_itemCount + columnCount - 1) ~/ columnCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FFrame grid benchmark'),
        actions: <Widget>[
          DropdownButton<int>(
            value: _itemCount,
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem(value: 100, child: Text('100 cells')),
              DropdownMenuItem(value: 1000, child: Text('1,000 cells')),
            ],
            onChanged: (value) => setState(() => _itemCount = value ?? 100),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _useFFrame,
            onChanged: (value) => setState(() => _useFFrame = value),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _useFFrame
          ? FGrid(
              columns: List<FTrack>.filled(columnCount, const FTrack.flex()),
              rows: List<FTrack>.filled(rowCount, const FTrack.flex()),
              children: <FGridItem>[
                for (var i = 0; i < _itemCount; i++)
                  FGridItem(
                    row: i ~/ columnCount,
                    column: i % columnCount,
                    child: _cell(i),
                  ),
              ],
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
              ),
              itemCount: _itemCount,
              itemBuilder: (context, index) => _cell(index),
            ),
    );
  }

  Widget _cell(int index) => ColoredBox(
        color: Colors.primaries[index % Colors.primaries.length].shade100,
        child: Center(child: Text('$index')),
      );
}
