# fframe_design

Contracts for pluggable FFrame design systems: semantic tokens, control state, style resolvers, and the `FTheme` inherited scope. It contains no concrete visual language.

Implement `FDesignSystem`, supply `FDesignTokens` and `FComponentStyles`, then expose the system from a package that applications can select at runtime.
