# Dashboard 布局

仪表板通常由自适应内容网格与可收起导航组成。FFrame 负责外层工作区，卡片内部继续使用应用自己的组件：

```dart
FWorkspace(
  navigation: FWorkspacePane(child: const DashboardNavigation()),
  content: FGrid(
    columns: const [FTrack.flex(), FTrack.flex()],
    rows: const [FTrack.auto(), FTrack.flex()],
    columnGap: 16,
    rowGap: 16,
    children: const [
      FGridItem(row: 0, column: 0, child: SummaryCards()),
      FGridItem(row: 0, column: 1, child: ActivityChart()),
      FGridItem(row: 1, column: 0, child: RecentOrders()),
      FGridItem(row: 1, column: 1, child: AlertsPanel()),
    ],
  ),
)
```

需要从双列切换到单列时，将网格放入 `FAdaptiveBuilder`，以局部宽度决定轨道数量。
