# 数据库客户端布局

`examples/showcase/lib/main.dart` 展示完整示例：Material 导航、桌面标题栏、命令区、可响应 Explorer、SQL 编辑器、结果网格、Inspector 与连接状态栏。

外层使用 `FDesktopShell`，三栏容器由 `FWorkspace` 在约束变化时切换。主工作区里的 `FGrid` 负责编辑器与查询结果的垂直分区。导航与 Inspector 的窄屏 overlay 可由 `FWorkspaceController` 从应用标题栏操作。

该示例是交互式布局样例，不连接真实数据库，也不包含查询执行状态管理。
