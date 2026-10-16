# Layout benchmark

`grid_layout_benchmark.dart` provides a manual grid-size comparison. It can switch between `FGrid` and Flutter's lazy `GridView`, and between 100 and 1,000 cells. Run the command from `examples/showcase` so Flutter uses the Showcase host platforms and package dependencies.

Run in profile mode on the same device/window size and collect Flutter frame timings:

```sh
flutter run --profile -t benchmark/grid_layout_benchmark.dart
```

Use DevTools Performance to compare build, layout, raster, and memory. The built-in `GridView` is lazy while `FGrid` lays out every explicit child, so treat this as a workload comparison rather than a claim that the widgets perform identical work. Record Flutter version, device, size, and selected cell count with results.

For splitter and adaptive resize traces, use the example app: resize the window repeatedly at 1440×900, 1024×768, and 640×480, then drag each splitter. Inspect frame timings while dragging and check that panes do not oscillate around adaptive thresholds.
