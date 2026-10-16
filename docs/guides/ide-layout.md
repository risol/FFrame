# IDE / 编辑器布局

将 `FDesktopShell` 作为区域骨架、`FWorkspace` 作为横向工作区，再把主编辑区切成竖直 editor/results panes：

```dart
FDesktopShell(
  titleBar: const AppTitleBar(),
  commandArea: const AppToolbar(),
  navigation: FWorkspacePane(child: const FileTree()),
  body: FSplitView.vertical(
    children: const [
      FPane.flex(id: 'editor', minSize: 280, child: Editor()),
      FPane(id: 'console', preferredSize: 220, minSize: 120, child: Console()),
    ],
  ),
  inspector: const FWorkspacePane(child: PropertiesPanel()),
  statusBar: const AppStatusBar(),
)
```

保存 `FPaneController.snapshot()` 即可持久化用户分栏尺寸；序列化格式由应用决定。
