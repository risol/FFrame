# Flutter constraints 与 FFrame

Flutter 的布局规则是约束向下、尺寸向上、父级决定位置。FFrame 根据组件收到的 `BoxConstraints` 计算轨道和 pane 尺寸，不根据 `Platform` 或设备类型做布局判断。

## 连续尺寸与布局切换

- **Responsive sizing**：尺寸连续变化，例如 flex track 随可用宽度增长。
- **Adaptive layout**：结构或模式变化，例如宽窗口显示 Inspector，窄窗口只显示内容。

`FGrid` 和 `FSplitView` 主要处理连续尺寸；`FAdaptiveBuilder`、`FAdaptiveVisibility` 与 `FWorkspace` 处理布局状态切换。

## 有界与无界约束

固定和 auto 轨道在无界方向仍可计算。flex 轨道在无界方向只保留最小尺寸，因为它没有有限的剩余空间可分配。包含滚动区域的应用应将滚动视图放在 FFrame 布局外层，并保证横纵轴中需要 flex 的方向有界。

## 调试

使用 `FFrameDebugOverlay(child: app)` 查看局部最大宽高；`FLayoutVisualizer` 可标出子树边界。
