# FFrame 开发计划（历史版）

> 本文档记录最初的 layout-only 方向。后续完整框架路线以 [FFrame_Full_Framework_Plan.md](FFrame_Full_Framework_Plan.md) 为准。
>
> **当前 API 决策（2026-10-16）**：应用 UI 使用 FFrame 自有的 `F` 前缀 API。Riverpod、Markdown、FFlow 和平台功能通过可选的 FWidget 适配边界衔接；Material 控件不属于共享控件面。`fframe` 是应用侧主包，`fframe_layout` 承载桌面布局，`fframe_design` 定义样式契约，`fframe_wpf` 是唯一官方视觉系统；下文原有多组件库和多视觉系统设想均为历史记录。最新状态以 [docs/roadmap-status.md](docs/roadmap-status.md) 为准。

> **项目定位**：A desktop-first adaptive layout framework for Flutter.  
> **核心原则**：WinUI 3 inspired，Flutter-native，UI-library agnostic。  
> **默认适配**：Flutter Material。  
> **长期目标**：成为 Flutter Desktop / Web 应用在 `widgets` 与 Material/Forui/Fluent 等组件库之间缺失的 application-layout layer。

---

## 0. 文档信息

| 项目 | 内容 |
|---|---|
| 项目名 | **FFrame** |
| Package 建议名 | `fframe` |
| GitHub Repo 建议 | `fframe` |
| 初始平台 | Windows / macOS / Linux / Web |
| 移动端 | 支持，但不是首要设计目标 |
| 默认 UI 框架 | Material |
| 核心依赖 | `flutter/widgets.dart` 为主 |
| 核心参考 | WinUI 3 |
| 补充参考 | WPF 的成熟 Desktop Layout 模式 |
| 实现基础 | Flutter Constraints / RenderObject / Widget composition |
| 第一阶段目标 | 布局系统，而非完整 UI Kit |

---

# 1. 项目愿景

Flutter 已经提供非常强的底层布局能力：

- `Row`
- `Column`
- `Flex`
- `Stack`
- `Wrap`
- `LayoutBuilder`
- `BoxConstraints`
- `CustomMultiChildLayout`
- `RenderBox`

Material、Forui、Fluent 等则解决：

- Button
- Input
- Menu
- Dialog
- Card
- Theme
- Navigation controls
- Form controls

但对于 Desktop / Web 工具型应用，中间仍然缺少一层统一的应用级布局抽象，例如：

- Desktop workspace
- 可调整 Sidebar
- Inspector Pane
- 多栏布局
- `Auto / Fixed / Flex` 轨道
- Pane collapse
- 窗口变窄后的自适应策略
- Navigation pane mode
- Command area overflow
- Window shell
- Title bar content region
- Overlay placement policy

**FFrame 的目标就是填补这一层。**

---

# 2. 非目标

第一阶段必须明确“不做什么”，避免演变成另一个 Material / WinUI clone。

FFrame **不负责**：

- Button
- TextField
- Checkbox
- Radio
- Switch
- Dialog 的视觉设计
- Card
- Typography
- Color theme
- Icon system
- Toast
- Snackbar
- Form validation
- DataTable
- TreeView
- Routing
- State management
- Dependency injection
- MVVM
- 数据绑定框架
- Win32 原生控件封装

FFrame 可以为这些组件提供**布局容器和位置策略**，但不重新实现控件本身。

---

# 3. 设计原则

## 3.1 Flutter-native

不要机械复刻 XAML API。

不做：

```dart
ColumnDefinition(width: GridLength.star())
```

优先：

```dart
FTrack.flex()
```

不做：

```dart
GridColumn(child: ...)
```

优先：

```dart
FGridItem(
  column: 1,
  child: ...,
)
```

---

## 3.2 UI-library agnostic

核心 package 尽量只依赖：

```dart
import 'package:flutter/widgets.dart';
```

避免核心直接依赖：

```dart
Theme.of(context)
Scaffold
NavigationRail
NavigationBar
Material
```

Material 相关能力放到 adapter 层。

---

## 3.3 Desktop-first

设计优先考虑：

- 任意窗口尺寸
- resize
- hover / mouse
- keyboard
- 多 Pane
- 高信息密度
- Sidebar + Content + Inspector
- Splitter
- Title bar
- 大尺寸屏幕
- 多显示器
- 桌面窗口最小尺寸

Mobile 是 graceful degradation，而不是 API 的主要驱动力。

---

## 3.4 Constraints-first，而不是 Device-first

核心逻辑禁止依赖：

```dart
Platform.isWindows
Platform.isAndroid
```

布局决策优先基于：

```dart
BoxConstraints
Size
availableWidth
availableHeight
minWidth
preferredWidth
```

例如：

```dart
if (constraints.maxWidth >= requiredWidth) {
  // three-pane
}
```

而不是：

```dart
if (isDesktop) {
  // three-pane
}
```

---

## 3.5 Capability-based adaptive layout

不要只做：

```text
sm / md / lg / xl
```

更推荐：

```text
singlePane
dualPane
triplePane
compactNavigation
expandedNavigation
canShowInspector
canShowLabels
```

Window size class 可以存在，但它只是基础工具，不应该成为所有布局逻辑的唯一依据。

---

## 3.6 组合优于继承

推荐：

```dart
FWorkspace(
  navigation: ...,
  content: ...,
  inspector: ...,
)
```

而不是复杂继承层级：

```text
BaseDesktopLayout
  └── AdaptiveDesktopLayout
      └── MaterialDesktopLayout
```

---

# 4. 总体架构

```text
┌──────────────────────────────────────────────┐
│ Application                                  │
│ Dashboard / IDE / DB Client / Editor         │
├──────────────────────────────────────────────┤
│ Material / Forui / Fluent / Custom Widgets   │
├──────────────────────────────────────────────┤
│ FFrame Adapters                              │
│ Material shell / navigation integration      │
├──────────────────────────────────────────────┤
│ FFrame Application Layout                    │
│ Workspace / Navigation / Commands / Window   │
├──────────────────────────────────────────────┤
│ FFrame Layout Primitives                     │
│ Grid / Track / Dock / Split / Pane           │
├──────────────────────────────────────────────┤
│ Flutter Widgets / Constraints / RenderObject │
└──────────────────────────────────────────────┘
```

---

# 5. 模块规划

建议 package 内部划分为：

```text
lib/
├── fframe.dart
│
├── src/
│   ├── foundation/
│   │   ├── axis.dart
│   │   ├── range.dart
│   │   ├── size_policy.dart
│   │   └── layout_debug.dart
│   │
│   ├── adaptive/
│   │   ├── adaptive_value.dart
│   │   ├── window_size_class.dart
│   │   ├── adaptive_builder.dart
│   │   ├── adaptive_visibility.dart
│   │   └── layout_state.dart
│   │
│   ├── grid/
│   │   ├── track.dart
│   │   ├── grid_item.dart
│   │   ├── grid.dart
│   │   └── render_grid.dart
│   │
│   ├── pane/
│   │   ├── pane.dart
│   │   ├── pane_policy.dart
│   │   ├── split_view.dart
│   │   ├── splitter.dart
│   │   └── pane_controller.dart
│   │
│   ├── dock/
│   │   ├── dock.dart
│   │   └── dock_layout.dart
│   │
│   ├── workspace/
│   │   ├── workspace.dart
│   │   ├── workspace_policy.dart
│   │   └── workspace_controller.dart
│   │
│   ├── navigation/
│   │   ├── navigation_layout.dart
│   │   ├── navigation_mode.dart
│   │   └── navigation_policy.dart
│   │
│   ├── shell/
│   │   ├── desktop_shell.dart
│   │   ├── title_bar_layout.dart
│   │   ├── command_area.dart
│   │   └── status_area.dart
│   │
│   └── overlay/
│       ├── placement.dart
│       ├── placement_policy.dart
│       └── anchored_layout.dart
│
├── material/
│   ├── fframe_material.dart
│   ├── material_shell.dart
│   ├── material_navigation.dart
│   └── material_command_area.dart
│
└── debug/
    ├── inspector_overlay.dart
    └── layout_visualizer.dart
```

---

# 6. Phase 0 — RFC 与 API 原型

## 目标

在真正写 RenderObject 之前，把核心抽象确定下来。

预计输出：

```text
docs/rfcs/
├── 0001-project-scope.md
├── 0002-track-sizing.md
├── 0003-split-view.md
├── 0004-adaptive-layout.md
├── 0005-workspace.md
└── 0006-material-adapter.md
```

---

## 6.1 Track 模型

核心类型：

```dart
sealed class FTrack {
  const FTrack();
}

final class FFixedTrack extends FTrack {
  const FFixedTrack(this.size);
  final double size;
}

final class FAutoTrack extends FTrack {
  const FAutoTrack();
}

final class FFlexTrack extends FTrack {
  const FFlexTrack(
    this.flex, {
    this.min,
    this.max,
  });

  final double flex;
  final double? min;
  final double? max;
}
```

最终公开 API 建议：

```dart
const [
  FTrack.fixed(240),
  FTrack.flex(),
  FTrack.fixed(320),
]
```

支持：

```dart
FTrack.flex(
  2,
  min: 400,
  max: 1200,
)
```

### 第一阶段 sizing 类型

必须支持：

- `fixed`
- `auto`
- `flex`

后续候选：

- `minmax`
- `fitContent`
- `percentage`

但第一版不要过度扩张。

---

# 7. Phase 1 — Core Grid MVP

这是 FFrame 最重要的基础。

## 7.1 `FGrid`

目标 API：

```dart
FGrid(
  columns: const [
    FTrack.fixed(240),
    FTrack.flex(),
    FTrack.fixed(320),
  ],
  rows: const [
    FTrack.auto(),
    FTrack.flex(),
    FTrack.auto(),
  ],
  children: [
    FGridItem(
      row: 0,
      column: 0,
      columnSpan: 3,
      child: toolbar,
    ),
    FGridItem(
      row: 1,
      column: 0,
      child: sidebar,
    ),
    FGridItem(
      row: 1,
      column: 1,
      child: editor,
    ),
    FGridItem(
      row: 1,
      column: 2,
      child: inspector,
    ),
  ],
)
```

---

## 7.2 Grid 必须支持

### Track

- Fixed
- Auto
- Flex

### Cell

- row
- column
- rowSpan
- columnSpan

### Alignment

- stretch
- start
- center
- end

### Constraints

- min track size
- max track size
- tight / loose parent constraints

### Gap

```dart
FGrid(
  columnGap: 8,
  rowGap: 8,
)
```

---

## 7.3 Grid 第一版不支持

暂缓：

- implicit tracks
- named lines
- CSS Grid 语法
- masonry
- auto-placement 高级算法
- baseline grid
- RTL 特殊自动排列
- percentage track

避免 MVP 失控。

---

# 8. Track Layout Algorithm

需要提前写 RFC。

建议步骤：

## Step 1：计算 Fixed

```text
remaining =
available
- fixed tracks
- gaps
```

## Step 2：测量 Auto

Auto track 根据 child intrinsic / loose constraint 计算。

必须注意 Flutter intrinsic measurement 成本。

尽量避免大量：

```dart
getMaxIntrinsicWidth()
```

优先设计单 pass / bounded extra pass。

## Step 3：分配 Flex

剩余空间按：

```text
flex weight
```

分配。

例如：

```text
1* | 2*
```

剩余 900：

```text
300 | 600
```

## Step 4：应用 min / max

例如：

```dart
FTrack.flex(
  min: 300,
  max: 600,
)
```

## Step 5：overflow policy

需要明确：

```dart
enum FOverflowBehavior {
  clip,
  scroll,
  overflow,
}
```

第一版可以只提供：

```text
clip
overflow
```

Scroll 交给外层 `SingleChildScrollView`。

---

# 9. Phase 2 — SplitView / Resizable Pane

Desktop 框架的第二核心。

目标 API：

```dart
FSplitView(
  direction: Axis.horizontal,
  children: [
    FPane(
      id: 'sidebar',
      preferredSize: 240,
      minSize: 180,
      maxSize: 420,
      collapsible: true,
      child: sidebar,
    ),
    FPane.flex(
      id: 'content',
      minSize: 480,
      child: content,
    ),
    FPane(
      id: 'inspector',
      preferredSize: 320,
      minSize: 260,
      maxSize: 520,
      collapsible: true,
      child: inspector,
    ),
  ],
)
```

---

## 9.1 Splitter

需要支持：

- Mouse drag
- Pointer cursor
- Keyboard resize
- Focus
- Double click reset
- Min / max size
- Collapse
- Optional snap points

API：

```dart
FSplitterThemeData(
  thickness: 6,
  hitTestExtent: 10,
)
```

核心 package 不提供 Material 视觉，只提供基础 handle。

---

## 9.2 Controller

```dart
final controller = FPaneController();

controller.collapse('inspector');
controller.expand('inspector');
controller.setSize('sidebar', 280);
controller.reset('sidebar');
```

状态：

```dart
FPaneState(
  size: 240,
  collapsed: false,
)
```

---

## 9.3 Persistent layout state

后期提供：

```dart
controller.snapshot()
controller.restore(snapshot)
```

用于：

- 保存 sidebar width
- inspector width
- collapse state

不直接绑定 SharedPreferences。

应用自行持久化。

---

# 10. Phase 3 — Adaptive System

不要简单复制 Bootstrap breakpoint。

核心抽象：

```dart
FAdaptiveValue<T>
FLayoutState
FAdaptiveBuilder
FAdaptiveVisibility
FWindowClass
```

---

## 10.1 `FAdaptiveValue<T>`

API：

```dart
const FAdaptiveValue<double>(
  compact: 8,
  medium: 12,
  expanded: 16,
)
```

或者：

```dart
FAdaptiveValue<EdgeInsets>(
  compact: const EdgeInsets.all(8),
  medium: const EdgeInsets.all(12),
  expanded: const EdgeInsets.all(16),
)
```

规则：

```text
compact
medium
expanded
```

默认 window class 可以参考现代 adaptive UI 经验，但必须允许自定义。

---

## 10.2 Capability-based Conditions

更重要的是：

```dart
FLayoutCondition(
  minWidth: 1000,
  minHeight: 600,
)
```

支持：

```dart
FAdaptiveBuilder(
  states: [
    FLayoutState(
      when: FLayoutCondition(minWidth: 1200),
      builder: threePane,
    ),
    FLayoutState(
      when: FLayoutCondition(minWidth: 800),
      builder: twoPane,
    ),
    FLayoutState.fallback(
      builder: singlePane,
    ),
  ],
)
```

---

# 11. Phase 4 — Workspace

Workspace 是 FFrame 最能体现 Desktop-first 的层。

目标：

```dart
FWorkspace(
  navigation: FWorkspacePane(
    preferredSize: 240,
    minSize: 180,
    collapsible: true,
    child: navigation,
  ),
  content: content,
  inspector: FWorkspacePane(
    preferredSize: 320,
    minSize: 260,
    collapsible: true,
    child: inspector,
  ),
)
```

窗口宽度充足：

```text
Navigation | Content | Inspector
```

中等：

```text
Navigation | Content
```

更窄：

```text
Content
```

隐藏 Pane 不一定销毁。

需要设计：

```dart
enum FPaneCollapseBehavior {
  remove,
  overlay,
  compact,
}
```

---

# 12. Workspace Policy

```dart
FWorkspacePolicy(
  navigation: FPanePolicy(
    preferredSize: 240,
    minSize: 180,
    collapsePriority: 2,
  ),
  content: FPanePolicy(
    minSize: 480,
    collapsePriority: 100,
  ),
  inspector: FPanePolicy(
    preferredSize: 320,
    minSize: 260,
    collapsePriority: 1,
  ),
)
```

当空间不足：

```text
1. Inspector collapse
2. Navigation compact
3. Navigation overlay
4. Content 保持 minimum
```

这个系统比固定 breakpoint 更符合桌面布局。

---

# 13. Phase 5 — Navigation Layout

参考 WinUI NavigationView 的 adaptive 思路，但不实现视觉控件。

核心：

```dart
enum FNavigationMode {
  expanded,
  compact,
  minimal,
  overlay,
}
```

API：

```dart
FNavigationLayout(
  mode: FNavigationMode.expanded,
  navigation: navigation,
  content: content,
)
```

Adaptive：

```dart
FAdaptiveNavigationLayout(
  expandedWidth: 240,
  compactWidth: 56,
  content: content,
  navigationBuilder: (context, mode) {
    return MyNavigation(mode: mode);
  },
)
```

Material adapter：

```dart
FMaterialNavigationShell(
  destinations: [...],
  body: ...,
)
```

内部可以使用：

- `NavigationRail`
- `NavigationBar`
- `Drawer`
- 自定义 Sidebar

---

# 14. Phase 6 — Desktop Shell

目标：

```dart
FDesktopShell(
  titleBar: ...,
  navigation: ...,
  commandArea: ...,
  body: ...,
  inspector: ...,
  statusBar: ...,
)
```

典型结构：

```text
┌──────────────────────────────────────────────┐
│ Title Bar                                    │
├──────────────────────────────────────────────┤
│ Command Area                                 │
├────────────┬─────────────────────┬───────────┤
│ Navigation │ Content             │ Inspector │
│            │                     │           │
├────────────┴─────────────────────┴───────────┤
│ Status Bar                                   │
└──────────────────────────────────────────────┘
```

Shell 只负责布局区域，不实现视觉组件。

---

# 15. Title Bar Layout

提供：

```dart
FTitleBarLayout(
  leading: ...,
  title: ...,
  center: ...,
  actions: ...,
)
```

但第一版：

- 不负责 Win32 hit-test
- 不负责 maximize / minimize
- 不负责 native caption buttons
- 不负责 macOS traffic lights

未来通过 adapter / optional integration 处理。

---

# 16. Phase 7 — Dock Layout

Dock 来源于成熟桌面 UI 模式。

API：

```dart
FDockLayout(
  top: toolbar,
  left: sidebar,
  right: inspector,
  bottom: statusBar,
  body: content,
)
```

支持：

```dart
FDock(
  side: FDockSide.left,
  size: 240,
  child: ...
)
```

适合：

- Tool window
- Utility application
- File explorer
- Database client

---

# 17. Phase 8 — Command Area

不实现 Button，只实现布局和 overflow 策略。

目标：

```dart
FCommandArea(
  primary: [...],
  secondary: [...],
  overflow: [...],
)
```

后期增加：

```dart
FCommandItem(
  priority: 100,
  compactBuilder: ...,
  expandedBuilder: ...,
)
```

自动：

```text
空间足够
→ icon + label

空间减少
→ icon

继续减少
→ overflow menu
```

Material adapter 再负责真正 menu。

---

# 18. Phase 9 — Overlay Placement

Desktop 菜单/Popover 越界属于 Layout 问题。

核心：

```dart
enum FPlacement {
  topStart,
  top,
  topEnd,
  rightStart,
  right,
  rightEnd,
  bottomEnd,
  bottom,
  bottomStart,
  leftEnd,
  left,
  leftStart,
}
```

Policy：

```dart
FPlacementPolicy(
  preferred: FPlacement.bottomStart,
  fallback: [
    FPlacement.topStart,
    FPlacement.bottomEnd,
  ],
  viewportPadding: 8,
)
```

核心能力：

- anchor rect
- overlay size
- viewport size
- safe padding
- flip
- shift
- clamp

Material adapter 可与 `MenuAnchor` 等结合。

---

# 19. Material Adapter

Material 是 FFrame 第一优先适配对象。

建议公开：

```dart
import 'package:fframe/fframe.dart';
import 'package:fframe/material.dart';
```

不要让 core import material。

---

## 19.1 Material Shell

```dart
FMaterialShell(
  destinations: [
    FMaterialDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
  ],
  body: ...,
)
```

根据空间：

```text
expanded
→ extended NavigationRail

compact
→ NavigationRail

minimal
→ Drawer / overlay

mobile
→ NavigationBar
```

这部分可以是 opinionated adapter。

---

# 20. Public API 风格

建议所有核心类型统一 `F` 前缀：

```text
FGrid
FGridItem
FTrack
FPane
FSplitView
FSplitter
FDockLayout
FWorkspace
FAdaptiveValue
FAdaptiveBuilder
FNavigationLayout
FDesktopShell
FPlacement
```

这样：

```dart
import 'package:fframe/fframe.dart';
```

后不会污染常用名称。

---

# 21. 示例应用

必须提供一个完整 Example App，而不是只有零散 Demo。

建议：

```text
example/
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── grid_demo.dart
│   │   ├── split_demo.dart
│   │   ├── workspace_demo.dart
│   │   ├── adaptive_demo.dart
│   │   └── material_demo.dart
│   └── app.dart
```

Example UI 建议做成：

> 小型数据库 / IDE 风格工具

包含：

```text
Navigation
Tree
Editor
Inspector
Toolbar
Status bar
```

能一次展示 FFrame 的价值。

---

# 22. Documentation Site

最低要求：

```text
docs/
├── getting-started.md
├── concepts/
│   ├── constraints.md
│   ├── tracks.md
│   ├── panes.md
│   ├── adaptive-layout.md
│   └── workspace.md
├── widgets/
│   ├── grid.md
│   ├── split-view.md
│   ├── dock-layout.md
│   └── desktop-shell.md
└── guides/
    ├── material.md
    ├── ide-layout.md
    ├── dashboard-layout.md
    └── database-client-layout.md
```

后期可部署：

- GitHub Pages
- Docusaurus
- VitePress

第一版 Markdown 即可。

---

# 23. Testing Strategy

## 23.1 Unit Tests

重点测试纯计算逻辑：

- track sizing
- flex allocation
- min/max constraint
- collapse priority
- adaptive condition
- overlay placement

Track test 示例：

```text
available = 1000
fixed = 200
auto = 100
gap = 20
flex = remaining

expected flex = 680
```

---

## 23.2 Widget Tests

测试：

- FGrid placement
- span
- resizing
- collapse
- adaptive state
- Material adapter switch

使用：

```dart
tester.binding.setSurfaceSize(...)
```

覆盖：

```text
640×480
800×600
1024×768
1280×800
1440×900
1920×1080
2560×1440
```

---

## 23.3 Golden Tests

核心布局必须 golden test。

例如：

```text
goldens/
├── grid_fixed_flex.png
├── grid_auto_flex.png
├── workspace_wide.png
├── workspace_medium.png
├── workspace_compact.png
├── split_horizontal.png
└── split_vertical.png
```

---

## 23.4 Pointer / Keyboard Tests

Splitter：

- drag
- click
- keyboard arrow
- focus traversal

Navigation：

- tab traversal
- focus
- semantics

---

# 24. 性能要求

FFrame 是布局框架，因此性能是核心质量指标。

目标：

- 普通布局尽量单 pass
- 避免不必要 intrinsic layout
- resize 时避免大量 subtree rebuild
- Splitter drag 保持稳定帧率
- Grid 的 layout complexity 与 child 数量近似线性

---

## 24.1 Benchmark

创建：

```text
benchmark/
├── grid_100_children.dart
├── grid_1000_children.dart
├── splitter_drag.dart
└── adaptive_resize.dart
```

需要比较：

```text
原生 Row / Column
vs
FGrid
```

记录：

- build time
- layout time
- raster impact
- memory

---

# 25. Accessibility

虽然 FFrame 不是控件库，但仍必须处理：

- Splitter semantics
- Focus traversal
- Keyboard resizing
- Pane visibility semantics
- Overlay focus scope

Splitter 推荐支持：

```text
Arrow Left / Right
Arrow Up / Down
Home
End
Enter collapse/expand（可选）
```

---

# 26. RTL

第一版 Grid 应至少避免硬编码：

```text
left
right
```

公共 API 优先：

```text
start
end
```

但 desktop pane placement 仍可以保留：

```text
left
right
```

需要在 RFC 中明确：

```text
logical direction
vs
physical direction
```

---

# 27. API 稳定性策略

0.x 阶段：

```text
0.1.x
0.2.x
0.3.x
...
```

允许 API breaking changes。

建议：

```text
0.1.0  Grid
0.2.0  SplitView
0.3.0  Adaptive
0.4.0  Workspace
0.5.0  Material Adapter
0.6.0  Shell
0.7.0  Dock
0.8.0  Overlay
0.9.0  API stabilization
1.0.0  Stable
```

---

# 28. Roadmap

## v0.1 — Grid Foundation

必须完成：

- `FTrack`
- Fixed / Auto / Flex
- `FGrid`
- `FGridItem`
- row / column span
- gaps
- min/max
- unit tests
- golden tests
- basic docs

发布标准：

> 可以稳定实现三栏 Desktop layout。

---

## v0.2 — SplitView

完成：

- `FPane`
- `FSplitView`
- `FSplitter`
- min/max
- resize
- collapse
- controller
- horizontal / vertical

发布标准：

> 可以实现 Explorer / IDE pane resize。

---

## v0.3 — Adaptive Layout

完成：

- `FAdaptiveValue`
- `FWindowClass`
- `FAdaptiveBuilder`
- `FAdaptiveVisibility`
- `FLayoutCondition`

发布标准：

> resize window 时布局可以稳定切换状态。

---

## v0.4 — Workspace

完成：

- `FWorkspace`
- navigation pane
- inspector
- content
- collapse priority
- overlay mode

发布标准：

> 可以实现三栏工具应用 shell。

---

## v0.5 — Material Integration

完成：

- Material adapter
- Material navigation example
- Drawer / Rail / NavigationBar strategy
- Material example app

发布标准：

> Material 用户无需自己重复写 adaptive navigation plumbing。

---

## v0.6 — Desktop Shell

完成：

- `FDesktopShell`
- title bar region
- toolbar / command region
- status region
- workspace integration

---

## v0.7 — Dock

完成：

- `FDockLayout`
- Top / Bottom / Start / End / Fill
- Nested docks

---

## v0.8 — Overlay

完成：

- anchored overlay placement
- flip
- shift
- viewport clamp

---

## v0.9 — Stabilization

重点：

- API rename
- remove redundant abstractions
- benchmark
- accessibility
- docs
- test coverage
- migration notes

禁止新增大功能。

---

## v1.0

1.0 发布条件：

- Core API 稳定
- 关键 API 至少经过 2 个真实应用验证
- Windows/macOS/Linux/Web CI
- 完整 docs
- Example app
- Golden tests
- Performance benchmark
- Public API 文档
- 无 critical accessibility issue

---

# 29. 推荐开发顺序

严格建议按以下顺序：

```text
1. Track sizing
      ↓
2. FGrid
      ↓
3. SplitView
      ↓
4. Pane policy
      ↓
5. Adaptive state
      ↓
6. Workspace
      ↓
7. Material adapter
      ↓
8. Desktop Shell
      ↓
9. Dock
      ↓
10. Overlay
```

不要先做 Shell。

Shell 是组合层。

如果 Grid / Pane / Adaptive 不稳定，Shell API 会被迫反复修改。

---

# 30. 第一阶段必须做的真实应用验证

不要只写 Demo。

至少用 FFrame 做两个真实场景。

## 场景 A：Database Client

```text
┌──────────────────────────────────────────────┐
│ Toolbar                                      │
├────────────┬─────────────────────┬───────────┤
│ DB Tree    │ Query Editor        │ Inspector │
│            ├─────────────────────┤           │
│            │ Result              │           │
├────────────┴─────────────────────┴───────────┤
│ Status                                       │
└──────────────────────────────────────────────┘
```

测试：

- nested split
- Grid
- inspector collapse
- toolbar
- window resize

---

## 场景 B：Settings / Admin Tool

```text
Navigation | Content
```

测试：

- adaptive navigation
- Material integration
- forms
- content max width

---

# 31. Repository 结构

建议：

```text
fframe/
├── .github/
│   └── workflows/
│       ├── test.yml
│       ├── analyze.yml
│       └── publish-dry-run.yml
│
├── lib/
├── test/
├── example/
├── benchmark/
├── docs/
│   └── rfcs/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── pubspec.yaml
└── analysis_options.yaml
```

---

# 32. CI

每次 PR：

```text
flutter format --set-exit-if-changed
flutter analyze
flutter test
```

至少测试：

- Windows
- Ubuntu
- macOS

Web：

```text
flutter test --platform chrome
```

必要时单独 golden runner。

---

# 33. Code Quality

建议启用较严格 lint。

重点：

- public API 必须有 doc comment
- 禁止无理由 dynamic
- immutable config
- const constructors
- sealed class 表达有限状态
- 避免 hidden side effects
- controller 生命周期明确

---

# 34. Package 依赖原则

Core 尽量做到：

```yaml
dependencies:
  flutter:
    sdk: flutter
```

第一版尽量**零第三方依赖**。

理由：

- 布局框架必须稳定
- 减少版本冲突
- 更容易长期维护
- 更容易适配 Flutter stable

---

# 35. Material Compatibility Strategy

FFrame 不“兼容 Material”其实不需要做太多特殊工作。

只要：

```text
FFrame 负责 layout
Material 负责 widgets
```

天然就可以：

```dart
FGrid(
  columns: const [
    FTrack.fixed(240),
    FTrack.flex(),
  ],
  children: [
    FGridItem(
      column: 0,
      child: NavigationRail(...),
    ),
    FGridItem(
      column: 1,
      child: Card(...),
    ),
  ],
)
```

Material adapter 的作用只是减少常见 boilerplate，而不是解决基本兼容问题。

---

# 36. Forui / Fluent Compatibility

后期如果需求存在：

```text
fframe_forui
fframe_fluent
```

或者：

```dart
package:fframe/forui.dart
package:fframe/fluent.dart
```

但不要在 v1.0 前承诺。

核心 API 必须保证：

```text
无 Material 类型
无 Forui 类型
无 Fluent 类型
```

---

# 37. 推荐 API Demo

最终希望用户可以写：

```dart
FDesktopShell(
  titleBar: AppTitleBar(),
  commandArea: AppToolbar(),
  body: FWorkspace(
    navigation: FPane(
      preferredSize: 240,
      minSize: 180,
      maxSize: 360,
      collapsible: true,
      child: NavigationRail(...),
    ),
    content: FSplitView.vertical(
      children: [
        FPane.flex(
          child: QueryEditor(),
        ),
        FPane(
          preferredSize: 280,
          minSize: 160,
          child: ResultsView(),
        ),
      ],
    ),
    inspector: FPane(
      preferredSize: 320,
      minSize: 260,
      maxSize: 480,
      collapsible: true,
      child: InspectorPanel(),
    ),
  ),
  statusBar: StatusBar(),
)
```

这段代码应该成为 FFrame 的“产品体验目标”。

---

# 38. Debug 工具

布局框架非常适合提供 debug overlay。

例如：

```dart
FFrameDebugOverlay(
  child: app,
)
```

显示：

```text
Pane: sidebar
size: 240
min: 180
max: 360

Track 0:
fixed 240

Track 1:
flex 1
resolved 832
```

可以极大提高开发体验。

后期甚至提供：

```dart
debugPaintFFrame = true;
```

---

# 39. 错误信息设计

必须比 Flutter 原生 overflow 更容易理解。

例如不要只报：

```text
RenderBox was not laid out
```

FFrame 自己可以 assertion：

```text
FFrame layout error:

FSplitView requires at least 840 logical pixels.

Current available width: 720

Pane requirements:
- navigation: min 180
- content: min 480
- inspector: min 160
- splitters: 20

Consider making one pane collapsible or reducing minSize.
```

这是框架价值的一部分。

---

# 40. Naming 规范

建议：

```text
FGrid
FGridItem
FTrack

FPane
FPanePolicy
FPaneController

FSplitView
FSplitter

FAdaptiveValue
FAdaptiveBuilder
FLayoutCondition

FWorkspace
FWorkspacePolicy

FNavigationLayout

FDockLayout

FDesktopShell
FTitleBarLayout
FCommandArea

FPlacement
FPlacementPolicy
```

避免：

```text
FLayout
```

作为万能组件名。

`FFrame` 已经是 package / 品牌。

---

# 41. 是否需要自己的 Theme

Core 不应该引入完整 Theme System。

可以有：

```dart
FFrameThemeData
```

但只包含布局相关 token，例如：

```text
splitterThickness
defaultPaneMinSize
compactNavigationWidth
defaultGap
animationDuration
```

不要包含：

```text
primaryColor
buttonColor
textStyle
cardColor
```

Material 负责视觉 theme。

---

# 42. Animation

第一版只支持必要动画：

- pane expand/collapse
- navigation mode change

不要第一阶段加入复杂 motion system。

API：

```dart
FPane(
  animationDuration: const Duration(milliseconds: 180),
)
```

Core 默认 animation 可关闭：

```dart
animate: false
```

方便高频 resize。

---

# 43. Window Resize 策略

Resize 是 Desktop Framework 的关键测试场景。

必须确保：

```text
拖窗口边缘
→ 不抖动
→ 不循环 layout
→ Pane 不来回 collapse/expand
```

需要 hysteresis：

```text
collapse below 900
expand above 940
```

避免：

```text
899 → collapse
901 → expand
899 → collapse
```

API 后期可以支持：

```dart
FAdaptiveThreshold(
  enter: 900,
  exit: 940,
)
```

---

# 44. State Ownership

核心原则：

> FFrame 管布局状态，不管业务状态。

可以内部持有：

- pane size
- collapsed
- selected layout mode

但：

- 当前页面
- 当前文件
- 查询内容
- 用户登录

不属于 FFrame。

---

# 45. Extension Points

关键组件提供 builder。

例如：

```dart
FSplitView(
  splitterBuilder: (context, state) {
    return MySplitter(...);
  },
)
```

Navigation：

```dart
FAdaptiveNavigationLayout(
  navigationBuilder: (context, mode) {
    return MyNavigation(mode: mode);
  },
)
```

这样用户可以接任何 UI library。

---

# 46. API Ergonomics

优先支持 shorthand：

```dart
FSplitView.horizontal(...)
FSplitView.vertical(...)
```

Track：

```dart
FTrack.fixed(240)
FTrack.auto()
FTrack.flex()
FTrack.flex(2)
```

Pane：

```dart
FPane.flex(...)
```

避免用户大量写：

```dart
FPane(
  sizingMode: FPaneSizingMode.flex,
  flex: 1,
)
```

---

# 47. Example Cookbook

README / docs 必须覆盖：

## Two-column

```text
Sidebar | Content
```

## Three-column

```text
Sidebar | Content | Inspector
```

## IDE

```text
Toolbar
Sidebar | Editor
        | Console
Status
```

## Database client

## Settings app

## Dashboard

## Adaptive narrow window

---

# 48. README 首屏建议

```md
# FFrame

A desktop-first adaptive layout framework for Flutter.

FFrame fills the gap between Flutter's low-level layout primitives
and component libraries such as Material, Forui and Fluent UI.

```dart
FWorkspace(
  navigation: FPane(...),
  content: ...,
  inspector: FPane(...),
)
```

- Track-based Grid
- Resizable panes
- Adaptive workspaces
- Desktop shell
- UI-library agnostic
```

---

# 49. 品牌定位

推荐始终使用：

> **FFrame — Desktop-first adaptive layout for Flutter**

不要：

> Flutter WinUI

也不要：

> Flutter Bootstrap

原因：

FFrame 应该吸收 WinUI 3 / WPF 的成熟思想，但形成 Flutter 自己的 API。

---

# 50. WinUI 3 借鉴范围

重点参考：

- Grid
- adaptive NavigationView
- layout panels
- adaptive application shell
- window/title-bar region
- command surface
- overlay/flyout placement

不要复制：

- WinUI visual style
- Fluent theme
- Button implementation
- TextBox implementation
- Windows-only API

---

# 51. WPF 补充参考范围

仅在 WinUI 3 覆盖不足时参考：

- DockPanel
- GridSplitter
- 成熟 desktop workspace patterns
- Auto / Fixed / Star sizing edge cases

WPF 不作为品牌主参考。

---

# 52. Flutter 原则

实现必须尊重 Flutter 官方 layout model：

> Constraints go down. Sizes go up. Parent sets position.

这意味着不要试图把 XAML / CSS 的 layout engine 生搬硬套进 Flutter。

FFrame 的算法最终必须转换成：

```text
BoxConstraints
child.layout(...)
parentData.offset
RenderBox.size
```

---

# 53. 初始技术决策

## Grid

建议直接使用：

```text
MultiChildRenderObjectWidget
+
RenderBox
+
ParentData
```

原因：

- 性能可控
- child placement 可控
- span 更自然
- Track algorithm 可以集中实现

不要用大量：

```dart
Row
Column
Expanded
```

拼装核心 `FGrid`。

---

## SplitView

可以先 Widget composition。

等性能需要再下沉 RenderObject。

---

## Adaptive

纯 Widget 层即可：

```text
LayoutBuilder
InheritedWidget（必要时）
```

---

# 54. MVP Definition

真正的 MVP 不是整个 roadmap。

MVP 只包含：

```text
FTrack
FGrid
FGridItem
FPane
FSplitView
FPaneController
FAdaptiveBuilder
FAdaptiveValue
```

如果这几个东西做得稳定，FFrame 已经具有独立价值。

---

# 55. MVP Acceptance Criteria

必须能够用 Material 写：

```text
Database Client Demo
```

要求：

- Navigation pane 可 resize
- Content flex
- Inspector 可 resize
- Inspector 可以 collapse
- 窗口缩小时自动单 Pane / 双 Pane
- 1440 → 800 resize 无异常
- Material widget 无兼容问题
- keyboard 可控制 splitter
- golden tests 稳定

---

# 56. 1.0 前禁止事项

在 1.0 前尽量禁止：

- 自己做 Button
- 自己做 TextField
- 自己做主题系统
- 自己做 router
- 自己做 state management
- 模仿 WinUI 全控件
- 同时支持十几种 layout paradigm
- 太早抽象 plugin architecture
- 过早拆多个 packages

先把核心 layout 做好。

---

# 57. 风险清单

## 风险 1：Auto sizing 复杂度

Flutter intrinsic layout 可能造成性能问题。

策略：

- 明确限制 Auto 行为
- benchmark
- documentation 提醒
- 尽量减少 intrinsic pass

---

## 风险 2：API 过度 WinUI 化

结果：

```text
Flutter 开发者觉得不像 Flutter
```

策略：

> 借语义，不借语法。

---

## 风险 3：Scope creep

最危险。

一旦开始：

```text
Button
Menu
TreeView
Tabs
Theme
```

项目会变成 UI framework。

必须保持：

> Layout framework only.

---

## 风险 4：Responsive 与 Adaptive 概念混乱

文档明确：

```text
Responsive
= continuous sizing

Adaptive
= layout/state changes
```

FFrame 两者都支持。

---

## 风险 5：平台特定窗口行为

Window chrome 不属于普通 Widget layout。

v1.0 只做 region abstraction。

平台 API 以后另做 integration。

---

# 58. 建议开发节奏

## Sprint 1

- RFC
- package scaffold
- Track API
- fixed/flex Grid prototype

## Sprint 2

- Auto track
- span
- Grid tests
- debug overlay

## Sprint 3

- SplitView
- Splitter
- PaneController

## Sprint 4

- adaptive system
- workspace prototype

## Sprint 5

- Material demo
- real application validation

## Sprint 6

- stabilize API
- docs
- benchmarks
- publish 0.1 / 0.2 系列

---

# 59. 开源策略

建议早期：

```text
MIT 或 BSD-3-Clause
```

原因：

- Flutter ecosystem 友好
- 更容易被商用桌面项目采用
- 降低集成门槛

---

# 60. Issue Labels

建议：

```text
area:grid
area:pane
area:adaptive
area:workspace
area:material
area:overlay
area:docs

type:bug
type:feature
type:performance
type:api
type:breaking

platform:windows
platform:macos
platform:linux
platform:web
```

---

# 61. RFC 流程

所有重大 API 先 RFC。

RFC 模板：

```md
# Summary

# Motivation

# Goals

# Non-goals

# Proposed API

# Layout Algorithm

# Alternatives

# Performance

# Accessibility

# Compatibility

# Open Questions
```

尤其必须 RFC：

- Grid algorithm
- Pane collapse
- Adaptive state
- Workspace policy
- Overlay placement

---

# 62. 成功标准

FFrame 成功不是看 Widget 数量。

而是：

> 用户能否用极少的代码构建一个稳定、可 resize、可 adaptive 的 Flutter desktop workspace。

理想效果：

用户过去写：

```text
LayoutBuilder
→ if width
→ Row
→ Expanded
→ SizedBox
→ another LayoutBuilder
→ Visibility
→ Stack
→ Overlay
```

使用 FFrame 后：

```dart
FWorkspace(
  navigation: ...,
  content: ...,
  inspector: ...,
)
```

---

# 63. 长期方向

1.x 之后可以考虑：

## Multi-window layout coordination

```text
main window
tool window
inspector window
```

## Dockable panels

类似：

- Visual Studio
- JetBrains
- Blender

但这是大型功能，不进入 1.0。

---

## Layout persistence

```dart
FWorkspaceSnapshot
```

序列化：

```json
{
  "sidebar": {
    "size": 260,
    "collapsed": false
  }
}
```

---

## Dockable workspace

未来：

```dart
FDockWorkspace
```

支持：

- drag pane
- dock left/right/bottom
- floating pane

这可能成为 FFrame 2.0 的核心。

---

# 64. 推荐 2.0 方向

如果 1.x 稳定：

```text
FFrame 2.0
→ Dockable Workspace
```

目标用户：

- IDE
- Design tools
- Database tools
- DevTools
- Debugger
- Node editor applications

这个方向与 FFlow 也会形成很好的项目生态：

```text
FFrame
→ Application workspace/layout

FFlow
→ Node/graph editor
```

---

# 65. FFrame 与 FFlow 的关系

建议品牌层面保持：

```text
FFrame
FFlow
```

共同原则：

- Flutter-native
- Desktop-friendly
- developer-tool oriented
- composable
- source-level flexibility

未来可以形成：

```text
F ecosystem
```

但现阶段不要建立 umbrella framework。

---

# 66. 最终技术路线总结

```text
Flutter
│
│  Constraints / RenderObject
│
▼
fframe_layout
│
├── FTrack
├── FGrid
├── FPane
├── FSplitView
└── FAdaptive
│
▼
FFrame Application API (`fframe`)
│
├── FWorkspace
├── FNavigationLayout
├── FDockLayout
├── FDesktopShell
└── FPlacement
│
▼
Design system
│
└── fframe_wpf
│
▼
Application
```

---

# 67. 最重要的三条约束

整个开发过程中始终坚持：

## 1.

> **FFrame 是 Layout Framework，不是 UI Component Library。**

## 2.

> **WinUI 3 是设计参考，不是需要复刻的 API。**

## 3.

> **任何设计最终都必须服从 Flutter 的 constraint-based layout model。**

---

# 68. 第一批建议实现的源码文件

开始编码时建议按这个顺序创建：

```text
lib/
├── fframe.dart
└── src/
    ├── grid/
    │   ├── track.dart
    │   ├── grid_parent_data.dart
    │   ├── grid_item.dart
    │   ├── grid.dart
    │   └── render_grid.dart
    │
    ├── pane/
    │   ├── pane.dart
    │   ├── pane_controller.dart
    │   ├── splitter.dart
    │   └── split_view.dart
    │
    └── adaptive/
        ├── adaptive_value.dart
        ├── adaptive_builder.dart
        └── layout_condition.dart
```

第一周不要创建：

```text
shell/
material/
overlay/
dock/
```

先证明 Grid + Split + Adaptive 三个核心抽象成立。

---

# 69. 第一批测试文件

```text
test/
├── grid/
│   ├── track_test.dart
│   ├── fixed_track_test.dart
│   ├── auto_track_test.dart
│   ├── flex_track_test.dart
│   ├── span_test.dart
│   └── grid_constraints_test.dart
│
├── pane/
│   ├── split_view_test.dart
│   ├── splitter_test.dart
│   └── pane_controller_test.dart
│
└── adaptive/
    ├── adaptive_value_test.dart
    └── adaptive_builder_test.dart
```

---

# 70. 第一版 Demo 代码目标

v0.1~0.3 完成后，README 中应该可以直接展示：

```dart
FAdaptiveBuilder(
  states: [
    FLayoutState(
      when: const FLayoutCondition(minWidth: 1100),
      builder: (context) => FSplitView.horizontal(
        children: [
          FPane(
            preferredSize: 240,
            minSize: 180,
            child: const AppNavigation(),
          ),
          FPane.flex(
            minSize: 480,
            child: const MainContent(),
          ),
          FPane(
            preferredSize: 320,
            minSize: 260,
            collapsible: true,
            child: const Inspector(),
          ),
        ],
      ),
    ),
    FLayoutState.fallback(
      builder: (context) => const MainContent(),
    ),
  ],
)
```

Material、Forui、Fluent 的 Widget 都可以直接作为 child。

---

# 71. 参考资料

以下资料建议作为架构研究参考，而不是 API 复制目标。

## Flutter

- Flutter layout constraints  
  https://docs.flutter.dev/ui/layout/constraints

- Flutter adaptive layouts  
  https://docs.flutter.dev/learn/pathway/tutorial/adaptive-layout

## WinUI / Windows App SDK

- Layout panels  
  https://learn.microsoft.com/windows/apps/develop/ui/layout-panels

- NavigationView  
  https://learn.microsoft.com/windows/apps/develop/ui/controls/navigationview

- Windows App SDK / WinUI 3 application structure  
  https://learn.microsoft.com/windows/apps/develop/ui/windows-app-sdk-app-structure

## 参考原则

阅读这些文档时，只抽取：

```text
layout semantics
adaptive semantics
desktop workspace patterns
```

不要照搬：

```text
XAML syntax
Windows visual styling
Windows-only controls
```

---

# 72. 最终结论

FFrame 最合理的产品定义是：

> **FFrame is a desktop-first adaptive application layout framework for Flutter.**

它不是：

```text
Flutter Bootstrap
Flutter WinUI
Material replacement
```

而是：

```text
Flutter Widgets / Constraints
        ↓
      FFrame
        ↓
Material / Forui / Fluent
        ↓
Desktop Application
```

第一阶段只做好：

```text
Grid
Split
Pane
Adaptive
Workspace
```

只要这五个模块做得足够稳定，FFrame 就已经具备明确的生态价值。

---

# Appendix A — MVP Checklist

- [ ] 创建 `fframe` package
- [ ] 建立 RFC 目录
- [ ] 定义 `FTrack`
- [ ] Fixed track
- [ ] Auto track
- [ ] Flex track
- [ ] `FGrid`
- [ ] `FGridItem`
- [ ] Grid row/column span
- [ ] Grid gap
- [ ] Grid min/max
- [ ] Grid unit tests
- [ ] Grid golden tests
- [ ] `FPane`
- [ ] `FSplitView`
- [ ] `FSplitter`
- [ ] Pointer resize
- [ ] Keyboard resize
- [ ] `FPaneController`
- [ ] Collapse / expand
- [ ] `FAdaptiveValue`
- [ ] `FLayoutCondition`
- [ ] `FAdaptiveBuilder`
- [ ] Window resize tests
- [ ] Material demo
- [ ] Database client demo
- [ ] Benchmark
- [ ] README
- [ ] CHANGELOG
- [ ] LICENSE
- [ ] CI
- [ ] pub.dev dry run

---

# Appendix B — 1.0 Checklist

- [ ] FGrid stable
- [ ] FSplitView stable
- [ ] Adaptive stable
- [ ] Workspace stable
- [ ] Material integration stable
- [ ] Desktop Shell stable
- [ ] Dock layout
- [ ] Overlay placement
- [ ] Accessibility
- [ ] RTL audit
- [ ] Windows test
- [ ] macOS test
- [ ] Linux test
- [ ] Web test
- [ ] Golden test suite
- [ ] Performance benchmarks
- [ ] API docs
- [ ] Migration notes
- [ ] Two real-world validation apps
- [ ] No critical API issue
- [ ] `dart pub publish --dry-run`
- [ ] v1.0.0
