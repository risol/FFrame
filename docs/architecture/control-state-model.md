# Control state model

FFrame controls report a shared `Set<FControlState>` to style resolvers. The common states are `normal`, `hovered`, `focused`, `pressed`, `selected`, and `disabled`. A control may combine states, such as hovered and focused. `FControlSize` describes the semantic size of one control, while `FDensityTokens` describes application-wide spacing and row metrics.

Behavior belongs to shared controls: focus, keyboard activation, pointer interaction, and semantics. A visual system resolves colors, typography, shape, and sizing without replacing that behavior.
