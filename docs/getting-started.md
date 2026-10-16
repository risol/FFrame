# 快速开始

FFrame 是 Flutter 的桌面优先应用布局框架。核心包依赖 Flutter widgets/rendering API；按钮、输入框、主题与业务状态仍由应用或 UI 库提供。

## 安装

```yaml
dependencies:
  fframe: ^0.1.0
```

```dart
import 'package:fframe/fframe.dart';
```

需要 Material 快捷组件时，额外导入：

```dart
import 'package:fframe/material.dart';
```

## 第一个 Workspace

```dart
FWorkspace(
  navigation: FWorkspacePane(child: const NavigationTree()),
  content: const Editor(),
  inspector: FWorkspacePane(child: const Inspector()),
)
```

Workspace 根据自身收到的宽度约束选用三栏、双栏、紧凑导航或仅内容布局。需要自定义窗口行为时，传入 `FWorkspacePolicy`。

## 栅格布局

```dart
FGrid(
  columns: const [FTrack.fixed(240), FTrack.flex(), FTrack.fixed(320)],
  rows: const [FTrack.fixed(48), FTrack.flex()],
  columnGap: 8,
  children: [
    FGridItem(row: 0, column: 0, columnSpan: 3, child: const Toolbar()),
    FGridItem(row: 1, column: 0, child: const NavigationTree()),
    FGridItem(row: 1, column: 1, child: const Editor()),
    FGridItem(row: 1, column: 2, child: const Inspector()),
  ],
)
```

`FTrack.auto()` 会查询子组件 intrinsic size。对复杂或大量子树优先使用 `flex`，避免额外 intrinsic 测量。当前包要求 Flutter 3.22+ / Dart 3.4+。

## 可拖动分栏

```dart
final paneController = FPaneController();

FSplitView.horizontal(
  controller: paneController,
  children: const [
    FPane(id: 'tree', preferredSize: 240, minSize: 180, child: NavigationTree()),
    FPane.flex(id: 'editor', minSize: 480, child: Editor()),
    FPane(id: 'inspector', preferredSize: 320, minSize: 240, child: Inspector()),
  ],
)
```

分隔条支持鼠标拖动、键盘方向键、Home 重置、End 扩展到最大尺寸，以及语义滑块操作。应用可以通过 `snapshot()` / `restore()` 保存 pane state。

## 示例应用

`example/` 是一个 Material 数据库客户端，展示 Explorer、编辑器、结果表、Inspector、工具栏和状态区。运行：

```sh
cd example
flutter run -d windows
```
