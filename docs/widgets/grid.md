# FGrid

`FGrid` 是显式轨道的多子项 RenderObject 布局。

```dart
FGrid(
  columns: const [FTrack.fixed(220), FTrack.flex(weight: 2), FTrack.flex(weight: 1, min: 240)],
  rows: const [FTrack.auto(max: 72), FTrack.flex()],
  columnGap: 8,
  rowGap: 8,
  children: [
    FGridItem(row: 0, column: 0, columnSpan: 3, child: const Toolbar()),
    FGridItem(row: 1, column: 0, child: const Sidebar()),
    FGridItem(row: 1, column: 1, child: const Editor()),
    FGridItem(row: 1, column: 2, child: const Inspector()),
  ],
)
```

行列数不会自动扩展。跨度超出显式轨道时 debug mode 会给出包含 cell 范围的错误信息。父级提供有界尺寸时，Grid 填满可用 bounds；无界方向按轨道最小/固有尺寸计算。
