# FDockLayout

`FDockLayout` 提供 top、bottom、start、end 与 body 五个区域，嵌套布局可组合更复杂的停靠结构。

```dart
FDockLayout(
  top: const Toolbar(),
  start: const NavigationTree(),
  end: const Inspector(),
  bottom: const StatusBar(),
  body: const Editor(),
  startSize: 240,
  endSize: 320,
  gap: 1,
)
```

start/end 按 `Directionality` 解释；top/bottom 尺寸可由 `topSize` / `bottomSize` 指定，省略时由子项自然高度决定。
