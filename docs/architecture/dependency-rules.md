# Package dependency rules

```text
fframe_layout -> Flutter widgets/foundation/rendering runtime
fframe_design -> Flutter value types and theme-scope runtime
fframe -> fframe_layout + fframe_design; owns FFrame primitives, shared controls, app host, and integration contracts
fframe_wpf -> fframe_design
```

`fframe_layout` must not import design contracts or a concrete visual system. Shared controls depend on design contracts. `fframe_wpf` provides the only first-party visual system. Application UI uses `package:fframe/fframe.dart`; optional adapters may depend on Riverpod, Markdown, FFlow, or a platform window plugin and return `FWidget` values. Those integrations do not become dependencies of core FFrame. No dependency may point back from a lower layer to a higher one.

Local package versions are linked by Melos during `melos bootstrap`; published package manifests use semver constraints so each package remains publishable independently.
