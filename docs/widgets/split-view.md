# FSplitView

使用 `FSplitView.horizontal` 或 `.vertical` 放置一组 pane。分隔条的视觉由核心 Widget 提供基本中性色 handle；可通过 `splitterBuilder` 接入现有组件库。

```dart
FSplitView.horizontal(
  controller: controller,
  splitterThickness: 6,
  splitterHitTestExtent: 12,
  children: const [
    FPane(id: 'tree', preferredSize: 240, minSize: 180, maxSize: 400, child: Tree()),
    FPane.flex(id: 'editor', minSize: 480, child: Editor()),
    FPane(id: 'inspector', preferredSize: 320, minSize: 240, collapsible: true, child: Inspector()),
  ],
)
```

给每个 pane 设置稳定 id 才能通过 controller 命令它。省略 id 时会生成基于子项顺序的本地 id，适合无持久状态的简单布局。
