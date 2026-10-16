# Split panes

`FSplitView` 接收 `FPane` 子项。固定 pane 使用 `preferredSize`；主工作区通常用 `FPane.flex`。拖动分隔条时，尺寸会在 pane 的最小与最大值之间变化。

```dart
final panes = FPaneController();

FSplitView.horizontal(
  controller: panes,
  children: const [
    FPane(id: 'navigation', preferredSize: 240, minSize: 180, maxSize: 420, collapsible: true, child: Navigation()),
    FPane.flex(id: 'content', minSize: 480, child: Editor()),
  ],
)
```

`FSplitView.vertical` 用于上下分区。`FPaneController` 提供 `setSize`、`collapse`、`expand`、`toggle`、`reset`、`snapshot` 与 `restore`。

当最小尺寸加起来超过空间时，split view 会暂时按 `collapsePriority` 从小到大折叠可折叠 pane；窗口变宽后自动恢复。若仍然不够，尺寸会按比例压缩以避免 RenderFlex overflow。显式控制器的 collapse state 与临时空间折叠分开保存。

分隔条默认提供 pointer cursor、焦点、方向键增减、Home 重置、End 扩展和 slider semantics。可以通过 `splitterBuilder` 自定义视觉。
