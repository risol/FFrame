# Theme resolution

`FThemeData` carries the selected `FDesignSystem`, brightness, and an optional density override. The design-system instance supplies the actual palette; choose its matching light or dark variant when setting brightness. `FStandardDensityTokens` offers normal and compact desktop presets and keeps its `hitTargetMin` metric at 40 logical pixels. Shared button, field, select, and menu controls use an explicit density override for their dimensions; without one, their design-system resolver remains authoritative. Checkboxes and switches also use the effective minimum target.

`FTheme.of(context)` reads the nearest scope; `maybeOf` supports reusable widgets that can operate without FFrame theming. Replacing the data notifies descendants through Flutter's inherited-widget mechanism.

`FFrameApp` provides the application host and FTheme scope. App source uses this FFrame entry point and FFrame controls; the host uses Flutter's runtime internally.
