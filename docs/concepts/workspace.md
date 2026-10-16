# Workspace

`FWorkspace` 将 navigation、content、inspector 组合成一个可响应的桌面工作区。默认策略优先保留 content，空间不足时先移除 Inspector，再收缩导航；如果导航提供 `compactChild`，可用窄 rail 替代完整导航。

```dart
FWorkspace(
  navigation: FWorkspacePane(
    child: const NavigationTree(),
    compactChild: const CompactNavigation(),
    collapseBehavior: FPaneCollapseBehavior.overlay,
  ),
  content: const Editor(),
  inspector: const FWorkspacePane(child: Inspector()),
)
```

Pane 可以采用 `remove`、`compact`、`overlay` collapse behavior。Overlay pane 由 `FWorkspaceController.toggleNavigation()` / `toggleInspector()` 打开；触发按钮由应用提供。

通过 `FWorkspacePolicy` 调整导航、内容、Inspector 的最小/首选尺寸、collapse priority 和分隔条大小。业务状态仍归应用所有。
