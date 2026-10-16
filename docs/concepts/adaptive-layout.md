# Adaptive layout

`FAdaptiveValue<T>` 提供 compact / medium / expanded 三个值。默认宽度边界是 600 和 1200 logical pixels，可在 `FAdaptiveBuilder` 和 `FWindowClassSizing.fromWidth` 中自定义。

```dart
FAdaptiveBuilder(
  states: [
    FLayoutState(
      when: const FLayoutCondition(minWidth: 1200),
      builder: (_) => const ThreePaneView(),
    ),
    FLayoutState(
      when: const FLayoutCondition(minWidth: 760),
      builder: (_) => const TwoPaneView(),
    ),
    FLayoutState.fallback(builder: (_) => const ContentOnlyView()),
  ],
)
```

条件包含 min/max width、min/max height 与可选 predicate。顺序由应用决定，首个匹配分支生效。`FLayoutScope.maybeOf(context)` 可读取当前局部尺寸与 window class。

`FAdaptiveVisibility` 依据本地约束显示子项；默认通过 `Offstage` 保留其状态。
