# FFrame 完整开发计划

> **当前范围决策（2026-10-16）**：FFrame 应用代码只能使用 FFrame 自有的 `F` 前缀 API；不允许在应用中导入或组合 Flutter Widgets/Material 控件，也不通过便利 re-export 暴露它们。Flutter 是 FFrame 的底层运行时实现，不是应用层控件体系。FFrame 保留 `fframe_wpf` 作为唯一官方视觉系统，删除 `fframe_minimal`、`fframe_fluent`、`fframe_material` 等 FFrame 风格包以及 Flutter Material 主题适配器。FFrame 对基础组合、交互和设计系统的能力覆盖按本计划继续推进，不能把底层 Flutter 类型或控件直接当作缺失功能的替代方案。Cupertino 不属于当前目标。下文原多风格章节作为历史方案记录，实施与文档以此范围决策为准。

> **包职责决策（2026-10-16）**：`fframe` 是应用侧主包，提供 FFrame 自有基础组合 API、共享控件、应用入口，并统一导出布局和设计契约；`fframe_layout` 只承载视觉中立的桌面布局能力；`fframe_design` 定义设计系统契约；`fframe_wpf` 实现 WPF 视觉系统。应用只需依赖 `fframe` 和所选视觉系统，不直接依赖 `fframe_layout` 或 Flutter 控件库。

> **项目定位**：A desktop-first UI framework for Flutter.  
> **核心策略**：统一品牌，分层架构，多设计系统可插拔。  
> **设计原则**：Layout 与 Visual 分离、Core 不依赖具体设计系统、设计系统可独立演进、应用可选择一套或自定义实现。  
> **参考方向**：WinUI 3 的现代桌面交互与 Shell、WPF 的成熟 Desktop Layout、Flutter 的 Constraints / RenderObject 模型。

---

## 1. 最终定位

FFrame 不再只定义为“桌面布局库”，而升级为：

> **FFrame — A desktop-first UI framework for Flutter.**

FFrame 负责两类能力：

```text
1. Desktop Application Layout
2. Desktop Design System Infrastructure
```

FFrame 不是：

```text
Flutter WinUI clone
Material replacement
Fluent UI clone
Bootstrap for Flutter
```

FFrame 应该是：

```text
Application
  ├── fframe
  │     ├── fframe_layout
  │     └── fframe_design
  └── fframe_wpf
        └── fframe_design

All packages run on the Flutter runtime; application code uses only FFrame APIs.
```

---

## 2. 为什么要合并，但不能揉成一层

单独 Layout Framework 的问题：

```text
FFrame layout
    +
Material default visual
    =
结构正确，但视觉普通
```

完整 Desktop Framework 需要：

```text
Layout
+
Theme
+
Typography
+
Density
+
Motion
+
Control styling
+
Desktop interaction
+
Overlay behavior
```

所以产品层面应该合并，但架构上必须分层。

正确关系：

```text
Application
  ├── fframe ───────────────┐
  │     ├── fframe_layout   │
  │     └── fframe_design   │
  └── fframe_wpf ───────────┘
            │
      Flutter runtime
```

核心原则：

> **`fframe_layout` 永远不知道具体 Design System。**

---

## 3. 总体架构

推荐使用 monorepo。

```text
FFrame/
├── packages/
│   ├── fframe_layout/
│   │   ├── layout
│   │   ├── adaptive
│   │   ├── workspace
│   │   ├── overlay
│   │   └── desktop shell, dock, pane, and grid
│   │
│   ├── fframe_design/
│   │   ├── design-system contracts
│   │   ├── tokens contracts
│   │   ├── component style contracts
│   │   └── theme scope
│   │
│   ├── fframe/
│   │   ├── FFrame-owned composition primitives
│   │   ├── shared controls and app host
│   │   └── application-facing exports
│   │
│   └── fframe_wpf/
│       └── WPF-inspired tokens and component styles
│
├── examples/
│   └── showcase/
│
├── docs/
├── benchmark/
├── tooling/
└── melos.yaml
```

---

## 4. Package 职责

### 4.1 `fframe_layout`

只解决：

```text
layout
adaptive
workspace
window regions
pane
splitter
grid
dock
overlay placement
layout state
```

允许依赖：

```dart
package:flutter/widgets.dart
package:flutter/rendering.dart
package:flutter/foundation.dart
```

禁止依赖：

```dart
package:flutter/material.dart
package:flutter/cupertino.dart
fluent_ui
forui
```

### 4.2 `fframe_design`

这是整个多设计系统架构的关键。

它不提供某一种具体视觉，而定义：

```text
Design tokens
Control style contracts
Theme scope
Component behavior contracts
State system
Density system
Motion system
```

建议抽象：

```dart
abstract interface class FDesignSystem {
  FColorTokens get colors;
  FTypographyTokens get typography;
  FSpacingTokens get spacing;
  FRadiusTokens get radius;
  FMotionTokens get motion;
  FDensityTokens get density;

  FButtonStyleResolver get button;
  FInputStyleResolver get input;
  FSelectStyleResolver get select;
  FMenuStyleResolver get menu;
  FPanelStyleResolver get panel;
}
```

注意：

> `FDesignSystem` 描述的是“设计语义”，不是 `Material ThemeData`。

### 4.3 `fframe_material`

Material 设计系统适配实现。

依赖：

```text
flutter/material.dart
fframe_layout
fframe_design
```

职责：

```text
ThemeData bridge
Material-backed Button
Material-backed Input
Material-backed Select
Material-backed Dialog
Material-backed Menu
Material navigation integration
```

目标：

> 利用 Material 已有的 focus / semantics / keyboard / state machinery，但覆盖视觉。

### 4.4 `fframe_fluent`

Fluent 风格实现。

可以有两种实现策略：

```text
A. 基于 Flutter/Material primitives 自己绘制 Fluent visual
B. 内部适配 fluent_ui
```

建议第一阶段采用 A 优先，B 可选。

### 4.5 `fframe_minimal`

官方中性 Design System。

定位：

```text
Modern
Neutral
Desktop
Developer-tool oriented
Cross-platform
```

这套系统应该成为 FFrame 官方 Showcase 的默认视觉。

---

## 5. 用户使用模式

### Core Only

```dart
import 'package:fframe_layout/fframe_layout.dart';
```

用户可以只使用：

```dart
FWorkspace(...)
FGrid(...)
FSplitView(...)
```

完全不使用 FFrame 视觉层。

### Material Design System

```dart
FFrameApp(
  designSystem: FMaterialDesignSystem(),
  home: ...,
)
```

### Fluent Design System

```dart
FFrameApp(
  designSystem: FFluentDesignSystem(),
  home: ...,
)
```

### Minimal Design System

```dart
FFrameApp(
  designSystem: FMinimalDesignSystem(),
  home: ...,
)
```

### 应用自定义 Design System

```dart
class MyCompanyDesignSystem implements FDesignSystem {
  ...
}
```

```dart
FFrameApp(
  designSystem: MyCompanyDesignSystem(),
)
```

这必须成为一等场景。

---

## 6. Design System 架构

多套 Design System 的核心不能依赖：

```text
if fluent
if material
if minimal
```

必须使用：

```text
tokens
resolvers
component contracts
Inherited Theme
```

---

## 7. Token System

建议：

```text
FFrameDesignTokens
├── colors
├── typography
├── spacing
├── radius
├── borders
├── elevation
├── density
├── motion
└── controlSizes
```

### 7.1 Color Tokens

不要直接公开：

```text
blue500
gray700
```

优先语义 token：

```dart
class FColorTokens {
  Color get canvas;
  Color get surface;
  Color get surfaceRaised;
  Color get surfaceOverlay;

  Color get textPrimary;
  Color get textSecondary;
  Color get textDisabled;

  Color get border;
  Color get borderStrong;

  Color get accent;
  Color get accentHover;
  Color get accentPressed;

  Color get selection;
  Color get hover;

  Color get danger;
  Color get warning;
  Color get success;
}
```

### 7.2 Typography Tokens

```dart
class FTypographyTokens {
  TextStyle get windowTitle;
  TextStyle get title;
  TextStyle get sectionTitle;
  TextStyle get body;
  TextStyle get bodyStrong;
  TextStyle get caption;
  TextStyle get label;
  TextStyle get command;
  TextStyle get monospace;
}
```

### 7.3 Density Tokens

Desktop 不能简单理解为“所有东西缩小”。

```dart
class FDensityTokens {
  double get controlHeight;
  double get compactControlHeight;
  double get navigationItemHeight;
  double get toolbarHeight;
  double get rowHeight;
  double get iconSize;
  double get hitTargetMin;
}
```

### 7.4 Spacing Tokens

```dart
class FSpacingTokens {
  double get xxs;
  double get xs;
  double get sm;
  double get md;
  double get lg;
  double get xl;
  double get xxl;
}
```

### 7.5 Radius Tokens

```dart
class FRadiusTokens {
  BorderRadius get control;
  BorderRadius get panel;
  BorderRadius get popup;
  BorderRadius get dialog;
}
```

### 7.6 Motion Tokens

```dart
class FMotionTokens {
  Duration get fast;
  Duration get normal;
  Duration get slow;

  Curve get standard;
  Curve get emphasized;
}
```

---

## 8. Component State Model

所有 Design System 共用一套状态语义：

```dart
enum FControlState {
  normal,
  hovered,
  focused,
  pressed,
  selected,
  disabled,
}
```

复杂组件允许：

```dart
Set<FControlState>
```

不要让每个 Design System 自己发明状态模型。

---

## 9. Style Resolver

Component API 与 visual style 分离。

例如：

```dart
abstract interface class FButtonStyleResolver {
  FButtonVisualStyle resolve(
    FButtonVariant variant,
    Set<FControlState> states,
  );
}
```

返回：

```dart
class FButtonVisualStyle {
  final Color background;
  final Color foreground;
  final Color border;
  final double borderWidth;
  final BorderRadius radius;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double height;
}
```

这样 `FButton` 不需要知道当前是 Fluent 还是 Minimal。

---

## 10. Theme Scope

核心：

```dart
class FTheme extends InheritedWidget {
  final FDesignSystem designSystem;
}
```

访问：

```dart
final theme = FTheme.of(context);
```

也可以提供：

```dart
context.fTheme
```

支持局部 override：

```dart
FTheme(
  data: theme.copyWith(
    density: theme.density.copyWith(
      rowHeight: 28,
    ),
  ),
  child: DataInspector(),
)
```

---

## 11. Light / Dark / Runtime Switching

设计系统应支持：

```dart
FMinimalDesignSystem.light()
FMinimalDesignSystem.dark()
```

以及运行时切换：

```dart
setState(() {
  designSystem = FFluentDesignSystem.dark();
});
```

要求：

```text
Layout 不改变结构
Theme descendants 更新
业务代码无 if/else design system 判断
```

---

## 12. Component Layer

第一阶段只做高价值 Desktop 控件。

### Phase A — Foundation Components

```text
FButton
FIconButton
FTextField
FSearchBox
FSelect
FCheckbox
FSwitch
FDivider
FPanel
FScrollArea
```

### Phase B — Navigation Components

```text
FSidebar
FSidebarItem
FNavigationItem
FTabs
FTab
FBreadcrumb
FCommandBar
```

### Phase C — Overlay Components

```text
FMenu
FContextMenu
FPopover
FTooltip
FDialog
FFlyout
FSelect popup
```

这层复用 `fframe_layout` 的 overlay placement。

### Phase D — Data / Tool Components

```text
FTreeView
FDataGrid
FPropertyGrid
FListView
FVirtualList
```

这些属于 1.x 后期。

---

## 13. Layout 与 Components 的依赖关系

正确：

```text
FSelect
    ↓
FAnchoredOverlay
    ↓
`fframe_layout`
```

错误：

```text
FAnchoredOverlay
    ↓
FSelect
```

`fframe_layout` 不得反向依赖共享控件。

---

## 14. Public API 规划

### `fframe_layout`

```dart
import 'package:fframe_layout/fframe_layout.dart';
```

导出：

```text
FGrid
FTrack
FPane
FSplitView
FDockLayout
FWorkspace
FAdaptiveBuilder
FAdaptiveValue
FPlacement
FAnchoredOverlay
```

### `fframe_design`

导出：

```text
FDesignSystem
FTheme
FColorTokens
FTypographyTokens
FSpacingTokens
FDensityTokens
FControlState
component style contracts
```

### `fframe`

应用侧主包，包含并导出：

```text
FFrame composition primitives
desktop layouts from fframe_layout
design contracts from fframe_design
shared controls and FFrameApp
```

它不默认引入具体视觉系统；应用另行依赖 `fframe_wpf` 等实现包。

---

## 15. Design System 包命名

推荐：

```text
fframe_minimal
fframe_material
fframe_fluent
```

以后可以扩展：

```text
fframe_cupertino
fframe_company_x
```

不要把 Design System 放进一个 Enum：

```dart
// 不推荐
FThemeStyle.material
FThemeStyle.fluent
FThemeStyle.minimal
```

必须允许第三方实现。

---

## 16. Design System Plugin Contract

```dart
abstract interface class FDesignSystem {
  String get id;
  String get name;

  FDesignTokens get tokens;
  FComponentStyles get components;
}
```

第三方：

```dart
class AcmeDesignSystem implements FDesignSystem {
  ...
}
```

无需修改 FFrame。

---

## 17. Monorepo 工具

推荐使用 `melos`。

用于：

```text
bootstrap
analyze
test
format
publish
version
```

---

## 18. 从当前 FFrame 仓库迁移

当前已有：

```text
lib/src/grid
lib/src/pane
lib/src/adaptive
lib/src/workspace
lib/src/navigation
lib/src/overlay
lib/src/shell
lib/src/material
```

迁移步骤：

### Step 1

建立：

```text
packages/fframe_layout/
```

移动：

```text
grid
pane
adaptive
workspace
dock
overlay
shell layout
navigation layout
command layout
debug
```

### Step 2

建立：

```text
packages/fframe_design/
```

先只定义：

```text
tokens
theme scope
state model
style contracts
```

不要立即写大量控件。

### Step 3

现有 Material 代码移动：

```text
packages/fframe_material/
```

### Step 4

建立：

```text
packages/fframe_minimal/
```

这是第一个真正完整的视觉系统。

### Step 5

保留一个综合 example，布局和控件放在同一个 Showcase：

```text
examples/showcase
```

---

## 19. 官方默认 Design System

建议：

> **FMinimal**

原因：

```text
默认 Material → 用户会认为 FFrame = Material wrapper
默认 Fluent   → 用户会认为 FFrame = Windows-only framework
默认 Minimal  → 更符合 cross-platform desktop framework
```

---

## 20. FMinimal 视觉目标

关键词：

```text
calm
dense
neutral
precise
desktop
low-noise
high-information-density
```

Surface：

```text
canvas
surface
surfaceSubtle
surfaceRaised
surfaceOverlay
```

Border：

```text
borderSubtle
borderNormal
borderStrong
focusRing
```

Control Height 建议：

```text
compact: 28
normal: 32
comfortable: 36
```

不要直接依赖 `VisualDensity.compact`。

---

## 21. Typography

建议桌面基准：

```text
caption       11~12
body          13
bodyStrong    13
command       13
section       12~13 semibold
title         15~16
windowTitle   13~14
```

实际值由字体与平台微调。

---

## 22. Motion

Desktop motion 要克制：

```text
hover       80~120ms
selection   100~150ms
pane        140~220ms
dialog      160~240ms
```

避免 mobile-style 大 scale。

---

## 23. Focus / Hover / Keyboard

所有 Controls 必须支持：

```text
Tab focus
visible focus ring
keyboard activation
Space / Enter
Arrow navigation
Escape close
pointer hover
pressed state
```

这些行为应该共享，不应该每套 Design System 重写。

---

## 24. `FSelect` 作为架构验证控件

`FSelect` 是多设计系统架构最重要的验证组件之一。

因为它同时覆盖：

```text
input surface
focus
hover
text
icon
popup
placement
scroll
keyboard
selection
overlay
```

API：

```dart
FSelect<T>(
  value: value,
  items: items,
  onChanged: onChanged,
)
```

分层：

```text
FSelect
├── behavior
│   ├── open/close
│   ├── keyboard
│   ├── selection
│   └── focus
│
├── layout
│   └── FAnchoredOverlay
│
└── visual
    └── FSelectStyleResolver
```

---

## 25. `FDialog` 分层

```text
FDialog
├── positioning
├── focus trapping
├── escape handling
├── semantics
└── visual resolver
```

---

## 26. `FSidebar` 分层

```text
FSidebar
├── layout
├── item behavior
├── collapse mode
├── keyboard navigation
└── style resolver
```

可直接嵌入 `FWorkspace`。

---

## 27. 复杂控件延后

### `FDataGrid`

不要第一阶段就做。

因为涉及：

```text
virtualization
selection
sorting
resizing
editing
keyboard navigation
accessibility
```

### `FTreeView`

同理延后到 1.x：

```text
expand/collapse
virtualization
keyboard
drag & drop
lazy loading
```

---

## 28. Material Theme 共存

`fframe_material` 可以提供：

```dart
FMaterialThemeBridge(
  themeData: ThemeData(...),
)
```

支持：

```text
ThemeData → F tokens
F tokens → ThemeData
```

但明确标注：

> best-effort mapping。

---

## 29. Forui / Fluent UI 共存

Core 本身天然兼容 Forui、Fluent UI。

未来可按需求增加：

```text
fframe_forui
fframe_fluent_bridge
```

但不要绑进 Core。

---

## 30. Shared Behavior，Multiple Visuals

不要：

```text
FMaterialButton
FFluentButton
FMinimalButton
```

三套完整逻辑。

应该：

```text
FButton
├── gestures
├── focus
├── semantics
├── keyboard
└── style resolver
```

具体 Design System 只提供 visual style。

这样才能保证所有设计系统：

```text
keyboard
focus
semantics
behavior
```

一致。

---

## 31. Windowing 边界

1.0 之前只提供：

```text
title bar layout region
window content region
window padding
```

不要承诺：

```text
native multi-window manager
Win32 chrome
macOS traffic lights
```

这些后期单独做 integration。

---

## 32. Overlay 是共享基础设施

Core overlay 必须稳定支持：

```text
preferred placement
fallback placement
flip
shift
viewport clamp
safe padding
anchor following
```

Select、Menu、Tooltip、Popover 都复用它。

---

## 33. Shell / Workspace 边界

`FDesktopShell` 只负责：

```text
title bar region
command region
navigation region
content region
inspector region
status region
```

不提供视觉背景。

`FWorkspace` 继续保持 UI-agnostic。

---

# 34. Roadmap

## Phase 0 — Repo Refactor

目标：

```text
single package → monorepo
```

完成：

- Melos
- package split
- CI split
- examples split
- docs relocation

建议版本：

```text
0.2.0
```

---

## Phase 1 — Core Stabilization

完成并稳定：

```text
FGrid
FTrack
FSplitView
FPane
FAdaptive
FWorkspace
FAnchoredOverlay
```

重点：

```text
constraints
unbounded behavior
intrinsic performance
accessibility
RTL
goldens
benchmark
```

---

## Phase 2 — Design Contracts

完成：

```text
FDesignSystem
FTheme
FDesignTokens
FControlState
style resolvers
density
motion
```

此阶段不做完整 Controls。

---

## Phase 3 — FMinimal Foundation

完成：

```text
color tokens
typography
spacing
radius
borders
density
motion
```

同时实现：

```text
FButton
FIconButton
FTextField
FSearchBox
FPanel
```

目标：

> 先把 Showcase 做漂亮。

---

## Phase 4 — Desktop Essentials

完成：

```text
FSelect
FCheckbox
FSwitch
FTabs
FSidebar
FSidebarItem
FTooltip
FMenu
FPopover
FDialog
```

---

## Phase 5 — Material Design System

把当前 Material adapter 升级成：

```text
完整 FMaterialDesignSystem
```

职责：

```text
ThemeData bridge
control visuals
Material-backed implementation
```

---

## Phase 6 — Fluent Design System

完成：

```text
FFluentDesignSystem
```

目标不是 WinUI clone，而是：

```text
Fluent-inspired
desktop
polished
cross-platform
```

---

## Phase 7 — Showcase

官方 Showcase 必须支持运行时：

```text
Minimal
Material
Fluent
```

切换。

同一套应用布局，切换视觉系统。

这将成为 FFrame 最强的架构演示。

---

## 35. Showcase 架构

```dart
FFrameApp(
  designSystem: selectedDesignSystem,
  home: const DatabaseStudio(),
)
```

Database Studio 不应该出现：

```text
if material
if fluent
if minimal
```

---

## 36. Showcase 页面

建议包含：

```text
Database Client
Settings
File Explorer
Dashboard
Command Palette
Dialog / Overlay Gallery
Controls Gallery
```

---

## 37. 多 Design System 验收标准

切换 Design System 后：

```text
布局完全不变
业务代码不变
行为语义不变
视觉明显变化
```

这才证明架构成功。

---

## 38. Design System 插件验收

第三方必须可以：

```dart
class CustomDesignSystem implements FDesignSystem
```

然后：

```dart
FFrameApp(
  designSystem: CustomDesignSystem(),
)
```

无需 fork FFrame。

---

## 39. 控件 API 必须语义化

不要暴露：

```text
materialElevation
fluentAccentBrush
```

应该暴露：

```text
variant
size
emphasis
state
```

例如：

```dart
FButton(
  variant: FButtonVariant.primary,
)
```

Design System 自己解释。

---

## 40. Variant / Size 统一

```dart
enum FButtonVariant {
  primary,
  secondary,
  subtle,
  danger,
}
```

```dart
enum FControlSize {
  compact,
  medium,
  large,
}
```

注意：

```text
size = 单个控件语义大小
density = 整个应用的信息密度
```

二者不要混为一谈。

---

## 41. FFrame Theme 层次

```text
FTheme
├── design system
├── brightness
├── density
└── optional overrides
```

---

## 42. CI 规划

Monorepo CI：

```text
format
analyze
unit test
widget test
golden test
web test
package dry-run
```

Matrix：

```text
Windows
macOS
Linux
Web
```

---

## 43. Golden Strategy

Golden 分两类：

```text
fframe_layout Visual Goldens
Design System Goldens
```

Core 看：

```text
geometry
placement
```

Design System 看：

```text
visual
hover
focus
selected
disabled
```

---

## 44. Benchmark

Core benchmark：

```text
FGrid
SplitView resize
Adaptive resize
Overlay placement
```

Control benchmark：

```text
1000 list rows
100 buttons
select open/close
theme switch
```

---

## 45. 文档结构

```text
docs/
├── architecture/
│   ├── dependency-rules.md
│   ├── design-system-contract.md
│   ├── control-state-model.md
│   ├── theme-resolution.md
│   └── layout-philosophy.md
│
├── core/
├── design-system/
├── controls/
├── integrations/
├── guides/
└── showcase/
```

必须专门写：

> **How to build a custom FFrame design system**

包括：

```text
tokens
resolvers
controls
theme scope
golden tests
package naming
```

---

## 46. Current Package Dependency Rules

```text
Application
├── fframe
│   ├── fframe_layout
│   └── fframe_design
└── fframe_wpf
    └── fframe_design

fframe_layout ──> Flutter widgets/foundation/rendering
fframe_design ──> Flutter runtime types
```

必须禁止循环依赖。

最理想状态：

> `fframe_layout` 完全不知道 design。

`fframe_design` 与 `fframe_layout` 保持同层依赖 Flutter runtime；设计契约包不依赖布局包。`fframe` 负责应用侧 API，WPF 包只实现设计契约。

---

## 47. Application Package

`fframe` 是应用侧主包，提供：

```text
layout API + design contracts + common controls
```

但不自动引入所有 Design System。

避免用户安装：

```text
Material + Fluent + Minimal
```

全部依赖。

---

## 48. Accessibility Contract

所有官方 Design System 必须保证：

```text
focus visible
contrast
keyboard
semantics
hit targets
```

视觉系统不能破坏行为。

---

## 49. Design System Compliance

后期建议增加：

```text
fframe_design_test
```

提供：

```dart
runDesignSystemComplianceTests(...)
```

检查：

```text
required tokens
focus states
disabled states
dark mode
density
```

这样第三方设计系统也可以声明：

```text
FFrame-compatible Design System
```

---

## 50. 第三方生态

未来可以出现：

```text
fframe_nord
fframe_dracula
fframe_company
fframe_retro
```

无需进入主仓库。

---

# 51. 1.0 Scope

## Core

```text
FGrid
FTrack
FSplitView
FPane
FAdaptive
FWorkspace
FDockLayout
FAnchoredOverlay
FDesktopShell
```

## Design Infrastructure

```text
FDesignSystem
FTheme
Tokens
States
Style Resolvers
```

## Official Design System

至少一套：

```text
FMinimal
```

## Controls

```text
FButton
FIconButton
FTextField
FSearchBox
FSelect
FCheckbox
FSwitch
FPanel
FSidebar
FTabs
FMenu
FTooltip
FDialog
```

---

## 52. 1.0 不做

```text
DataGrid
TreeView
Dockable Workspace
PropertyGrid
Multi-window
Ribbon
Native Window Chrome
Advanced Drag & Drop
```

---

## 53. 1.x / 2.0

### 1.x

```text
1.1 FTreeView
1.2 FDataGrid
1.3 Dockable panels
1.4 Property grid
1.5 advanced command palette
```

### 2.0

```text
Dockable Workspace
Floating panels
Multi-window
Layout persistence
IDE-class shell
```

---

## 54. 当前版本调整建议

当前仓库已经声明 `0.1.0`。

建议下一步：

```text
0.2.0
```

定义为：

> Architecture refactor release.

完成 monorepo 和 design contracts。

建议版本路线：

```text
0.2.0  Monorepo + package boundaries
0.3.0  Design System contracts
0.4.0  FMinimal foundations
0.5.0  Desktop basic controls
0.6.0  Select / Menu / Overlay controls
0.7.0  Navigation / Tabs / Sidebar
0.8.0  Material design system
0.9.0  Fluent design system + API stabilization
1.0.0  Stable framework
```

---

## 55. 当前 Demo 改造

当前 Database Studio 与 Administration 页面合并为唯一的综合示例：

```text
examples/showcase
```

该示例同时展示：

```text
桌面布局、工作区 pane、grid、命令区和状态区
按钮、输入框、下拉框、菜单、对话框等控件
WPF design system、dark mode 和 compact density
```

---

## 56. Showcase 视觉目标

必须做到：

> **一眼不像默认 Flutter demo。**

检查项：

```text
自定义 typography
自定义 density
自定义 sidebar item
自定义 search box
自定义 select
自定义 menu
自定义 dialog
完整 hover/focus
一致 radius
surface hierarchy
icon alignment
```

---

## 57. 多主题 Showcase

一个页面：

```text
Theme:
[ Minimal ] [ Material ] [ Fluent ]
```

实时切换。

建议它成为 README GIF / 视频的主展示。

---

## 58. README 新定位

建议：

```md
# FFrame

A desktop-first UI framework for Flutter.

FFrame provides adaptive desktop layouts, resizable workspaces,
design-system infrastructure, and polished desktop controls.

Use the application-facing `fframe` API with `fframe_wpf`,
or implement a custom design system against `fframe_design`.
```

---

## 59. 用户心智模型

```text
`fframe_layout`
= desktop layout engine

FFrame Design
= design-system protocol

FMinimal / Material / Fluent
= skins + control visuals

FFrame Controls
= shared behavior
```

---

## 60. 贡献者边界

贡献一个新 Design System：

```text
不需要修改 `fframe_layout`
```

贡献一个 Layout primitive：

```text
不能 import design system
```

贡献一个 Control：

```text
behavior 必须可被所有 design systems 使用
```

---

## 61. 最重要的架构规则

整个项目始终遵守：

### Rule 1

> **`fframe_layout` 不依赖 Design System。**

### Rule 2

> **Control Behavior 不复制到每套 Design System。**

### Rule 3

> **Design System 只决定视觉语义和视觉实现。**

### Rule 4

> **公开 API 不暴露具体 Material / Fluent 概念。**

### Rule 5

> **第三方 Design System 不需要修改 `fframe_layout`。**

---

# 62. 最终架构图

```text
                         Application
                              │
             ┌────────────────┼────────────────┐
             │                │                │
          FMinimal         FMaterial        FFluent
             │                │                │
             └────────────────┼────────────────┘
                              │
                       FFrame Design
                              │
                       FFrame Controls
                              │
                       `fframe_layout`
                              │
                           Flutter
```

更具体：

```text
`fframe_layout`
├── Grid
├── Pane
├── Split
├── Dock
├── Adaptive
├── Workspace
├── Shell
└── Overlay

FFrame Design
├── Tokens
├── Theme
├── States
├── Density
├── Motion
└── Style Resolvers

FFrame Controls
├── Button
├── Input
├── Select
├── Sidebar
├── Tabs
├── Menu
└── Dialog

Official Design Systems
├── Minimal
├── Material
└── Fluent
```

---

# 63. 建议下一步实施顺序

## 第一阶段

```text
1. 保持当前代码稳定
2. 建立 monorepo
3. 拆 fframe_layout
4. 拆 fframe_material
5. 创建 fframe_design
```

## 第二阶段

只实现：

```text
tokens
FTheme
control state
button style contract
input style contract
panel style contract
```

不要一次做所有控件。

## 第三阶段

实现 `FMinimal`，只做：

```text
FButton
FIconButton
FTextField
FSearchBox
FPanel
```

先把 Showcase 视觉做漂亮。

## 第四阶段

做：

```text
FSelect
FMenu
FTooltip
FDialog
```

验证 overlay + design system。

## 第五阶段

做：

```text
Sidebar
Tabs
CommandBar
```

完成完整 Desktop App 体验。

## 第六阶段

再做：

```text
FMaterial
FFluent
```

---

# 64. 最终建议

FFrame 最合理的长期方向不是：

```text
一个 Layout Package
```

也不是：

```text
一套固定视觉 UI Kit
```

而是：

> **一个 Desktop-first Flutter UI Framework，包含稳定的布局核心、一套 Design System 协议、共享的 Desktop Control 行为，以及多套可替换的视觉系统。**

即：

```text
Layout Engine
+
Control Behavior
+
Design System Protocol
+
Multiple Visual Systems
```

这四层组合起来，才是 FFrame 真正有长期价值的架构。

---

# Appendix A — Monorepo Checklist

- [ ] 创建 `packages/`
- [ ] 创建 `fframe_layout`
- [ ] 创建 `fframe_design`
- [ ] 创建 `fframe`
- [ ] 创建 `fframe_material`
- [ ] 创建 `fframe_minimal`
- [ ] 预留 `fframe_fluent`
- [ ] 安装 Melos
- [ ] 调整 CI
- [ ] 调整 docs
- [ ] 拆 example
- [ ] package import audit
- [ ] dependency cycle check

---

# Appendix B — Design Contract Checklist

- [ ] `FDesignSystem`
- [ ] `FTheme`
- [ ] `FDesignTokens`
- [ ] `FColorTokens`
- [ ] `FTypographyTokens`
- [ ] `FSpacingTokens`
- [ ] `FRadiusTokens`
- [ ] `FDensityTokens`
- [ ] `FMotionTokens`
- [ ] `FControlState`
- [ ] Button resolver
- [ ] Input resolver
- [ ] Select resolver
- [ ] Menu resolver
- [ ] Panel resolver

---

# Appendix C — FMinimal Checklist

- [ ] Light
- [ ] Dark
- [ ] Compact density
- [ ] Normal density
- [ ] Surface hierarchy
- [ ] Focus ring
- [ ] Hover states
- [ ] Button
- [ ] IconButton
- [ ] TextField
- [ ] SearchBox
- [ ] Panel
- [ ] Select
- [ ] Menu
- [ ] Tooltip
- [ ] Sidebar
- [ ] Tabs
- [ ] Dialog

---

# Appendix D — 1.0 Checklist

- [ ] `fframe_layout` API stable
- [ ] Core constraint semantics documented
- [ ] Core benchmark complete
- [ ] `fframe_design` contract stable
- [ ] `FMinimal` complete
- [ ] Core controls complete
- [ ] Material design system stable
- [ ] Fluent design system beta/stable
- [ ] Theme switching example
- [ ] Database showcase
- [ ] Settings showcase
- [ ] Light / dark
- [ ] Compact / normal
- [ ] Keyboard navigation
- [ ] Accessibility
- [ ] Windows CI
- [ ] macOS CI
- [ ] Linux CI
- [ ] Web CI
- [ ] Golden test suite
- [ ] API docs
- [ ] Design system author guide
- [ ] Migration guide
- [ ] pub.dev dry run
- [ ] v1.0.0

---

# Appendix E — 推荐品牌结构

```text
FFrame
Desktop-first UI framework for Flutter.

FFlow
Node-based flow and graph editor for Flutter.
```

FFrame 内部：

```text
`fframe_layout`
FFrame Design
FMinimal
FMaterial
FFluent
```

不再另外建立 FDesk 品牌。

这样品牌集中，同时架构保持模块化。
