# RFC 0004 — Adaptive layout

## Summary

Adaptive decisions are based on `LayoutBuilder` constraints. `FAdaptiveValue<T>` maps common width classes, while `FLayoutCondition` expresses capability requirements directly.

## Selection

`FAdaptiveBuilder` checks states in declaration order and selects the first matching condition. An optional final `FLayoutState.fallback` handles all other sizes. Default class boundaries are 600 and 1200 logical pixels and can be overridden.

## State

`FLayoutScope` exposes local size and resolved window class. `FAdaptiveVisibility` maintains hidden children offstage by default; apps can opt out and supply a replacement.

## Non-goals

No dependency on physical device classes, platform checks, or a global responsive breakpoint service.
