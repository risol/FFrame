# Icon vocabulary

Application code refers to glyphs through `FIcons` and renders them with `FIcon`. This keeps icon names stable and avoids exposing a platform icon catalog. The bundled `FFrameSymbols` font supplies the glyphs.

The vocabulary now covers common navigation, editing, status, search, visibility, attachment, and data actions. Add a named `FIcons` entry when a new semantic action is needed; do not use private code points in application code. Keep code-point mappings centralized in `primitives.dart` and verify that the bundled font contains the glyph before publishing.

Icon-only actions must include a tooltip or accessible label. Decorative icons should be excluded from semantics by their containing control where appropriate. Use `FIcon` size and color overrides sparingly; the defaults follow the active FFrame theme.
