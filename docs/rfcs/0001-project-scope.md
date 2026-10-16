# RFC 0001 — Project scope

## Summary

FFrame is a Flutter-native, desktop-first application layout layer between low-level widgets and component libraries.

## Goals

- Provide grid, split, adaptive, workspace, and shell layout primitives.
- Base decisions on local constraints and capabilities.
- Keep core independent of Material, platform window APIs, and app state.
- Allow app-owned children from Material, Forui, Fluent, or custom libraries.

## Non-goals

Buttons, form controls, visual themes, routing, data binding, native window chrome, and business state management.

## Decision

Core source imports Flutter widgets/rendering only. Material conveniences live under `package:fframe/material.dart`. Public types use an `F` prefix. 0.x may change APIs as real applications exercise the abstractions.
