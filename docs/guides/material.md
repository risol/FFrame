# Material 集成

Material adapter 从 `package:fframe/material.dart` 导入，不会被核心 barrel 自动载入。

## 导航壳

```dart
FMaterialShell(
  destinations: const [
    FMaterialDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    FMaterialDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
  ],
  selectedIndex: selectedIndex,
  onDestinationSelected: onSelected,
  body: const WorkspacePage(),
)
```

局部宽度低于 `drawerBreakpoint` 时使用 `NavigationDrawer`；窄屏使用 `NavigationBar`；桌面宽度使用 `NavigationRail`，达到 `extendedBreakpoint` 后显示扩展 rail。极窄窗口中的 drawer 由应用通过传入的 `GlobalKey<ScaffoldState>` 打开，以便标题栏按钮继续由应用控制。

`FMaterialCommandArea` 接收 `FCommandItem`，在 overflow 时通过 Material `PopupMenuButton` 展示隐藏项。核心的 `FCommandArea` 可改用其他库的菜单 builder。

FFrame 不依赖 `Theme.of`，应用控制配色与组件风格。
