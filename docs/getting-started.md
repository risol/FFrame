# 快速开始

FFrame 是桌面优先应用框架。应用代码只使用 FFrame API：从 `package:fframe/fframe.dart` 导入以 `F` 开头的应用根、基础组合控件、布局、主题和交互控件，不导入或组合 Flutter Widgets/Material 控件。Flutter 是 FFrame 底层运行时。WPF-inspired 视觉系统由 `fframe_wpf` 提供。

## 安装

```yaml
dependencies:
  fframe: ^0.2.0
  fframe_wpf: ^0.2.0
```

```dart
import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';
```

在应用代码中统一使用 FFrame 的 `F` 前缀 API。`fframe_layout` 是分层架构中的低层布局包；桌面应用建议依赖 `fframe`，以便同时使用 FFrame 自有组合控件和完整应用入口。

```dart
void main() => runFFrameApp(const ExampleApp());

class ExampleApp extends FStatelessWidget {
  const ExampleApp();

  @override
  FWidget build(FBuildContext context) => FFrameApp(
        designSystem: FWpfDesignSystem.light(),
        home: FDesktopShell(
          body: const FCenter(child: FText('Hello, FFrame')),
        ),
      );
}
```

`FFrameApp` 设置设计系统与密度，并为 FFrame 控件提供主题作用域。应用使用 `FText`、`FRow`、`FColumn`、`FContainer` 等基础组合 API，再组合 `FButton`、`FTextField`、`FSelect` 等共享控件。

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

`examples/showcase/` 是唯一的综合示例，采用 WPF 风格展示 FFrame 桌面布局和控件：包括 Explorer、编辑器、结果表、Inspector、命令区、状态区和控件画廊。运行 Showcase：

```sh
cd examples/showcase
flutter run -d windows
```
