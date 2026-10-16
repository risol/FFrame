# RFC 0006 — Material adapter

## Summary

Material helpers are opt-in imports and do not enter the core barrel.

## Components

- `FMaterialShell` maps destinations to `NavigationBar` under the compact width threshold, then `NavigationRail`, extending it at a wider threshold.
- `FMaterialCommandArea` presents hidden commands in a `PopupMenuButton`.
- FFrame regions remain app-supplied; the adapter does not choose an app theme or implement business navigation.

## Compatibility

Adapters may be opinionated and may follow Material conventions. Core APIs must remain usable without importing this library.
