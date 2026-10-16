# FDesktopShell

`FDesktopShell` 只组合应用区域，不实现系统标题栏或视觉控件。

```dart
FDesktopShell(
  titleBar: const MyTitleBar(),
  commandArea: const MyToolbar(),
  navigation: FWorkspacePane(child: const MyNavigation()),
  body: const MyMainContent(),
  inspector: FWorkspacePane(child: const MyInspector()),
  statusBar: const MyStatusBar(),
)
```

`FTitleBarLayout` 对齐 leading、title、center 和 actions；`FStatusArea` 布置左右状态信息。系统窗口按钮、窗口拖动 hit-test 与 macOS traffic lights 属于平台集成层，不由普通布局组件实现。
