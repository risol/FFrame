# Track sizing

`FGrid` 的每一行和每一列都必须显式定义。

| Track | 解析方式 | 适用场景 |
|---|---|---|
| `FTrack.fixed(size)` | 固定逻辑像素 | 标题栏、工具窗格 |
| `FTrack.auto()` | 根据子项 intrinsic size 测量 | 小型标签、工具区 |
| `FTrack.flex(weight: n)` | 分配剩余空间 | 主编辑区、内容区 |

Auto 与 flex 支持 `min` / `max`。Flex 按权重分配剩余空间，达到 max 的轨道会把未使用空间重新分配给其他 flex 轨道。若所有 flex 都达到上限，剩余区域保持空白。

跨多个 auto track 的子项会将所需宽高分摊给这些轨道。Auto sizing 会执行 intrinsic 查询；复杂控件建议使用固定或 flex 轨道。

## Spans 与对齐

`FGridItem` 使用从 0 开始的 `row`、`column`、`rowSpan` 与 `columnSpan`。`alignment` 可设为 `stretch`、`start`、`center` 或 `end`。列索引按文本方向的 start 侧解释；RTL 中逻辑第一列位于右侧。

## Overflow

`FOverflowBehavior.clip` 会裁切超出 Grid bounds 的内容；`overflow` 保留子项绘制，是否被裁切仍可能受祖先约束。滚动由外层 `SingleChildScrollView` 等控件负责。
