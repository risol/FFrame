# RFC 0001 — Project scope

> Historical scope record. The current official-package scope is documented in
> `FFrame_Full_Framework_Plan.md` and `docs/guides/controls.md`: applications
> use only `F`-prefixed FFrame APIs. `fframe_wpf` is the only first-party
> visual system.

## Summary

FFrame is a Flutter-native, desktop-first application layout layer between low-level widgets and component libraries.

## Goals

- Provide grid, split, adaptive, workspace, and shell layout primitives.
- Base decisions on local constraints and capabilities.
- Keep core independent of Material, platform window APIs, and app state.
- Provide an FFrame-owned application composition API so app code does not
  depend on Flutter or third-party widget names.

## Non-goals

Buttons, form controls, visual themes, routing, data binding, native window chrome, and business state management.

## Decision

FFrame uses Flutter's rendering and input systems internally. Application code
uses the `F`-prefixed API from `fframe`; it does not import Flutter Widgets or
Material. `fframe_layout` remains independent of design contracts and concrete
visual systems. 0.x may change APIs as real applications exercise the
abstractions.
