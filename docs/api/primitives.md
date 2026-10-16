# Composition and foundation API

These APIs are exported from `package:fframe/fframe.dart` and keep application composition under FFrame names.

## Runtime and callbacks

| API | Purpose |
| --- | --- |
| `FWidget`, `FBuildContext`, `FWidgetBuilder`, `FIndexedWidgetBuilder` | Widget and builder boundary for FFrame and adapters |
| `FStatelessWidget`, `FStatefulWidget`, `FState<T>` | F-prefixed base types for app components |
| `FKey`, `FVoidCallback`, `FValueChanged<T>` | Keys and callbacks |
| `FColor`, `FOffset`, `FSize`, `FTextStyle`, `FFontWeight`, `FTextAlign`, `FTextOverflow`, `FTextDirection`, `FAxis` | Common value-type aliases |
| `FTextEditingController`, `FFocusNode`, `FScrollController`, `FScrollPhysics` | Text, focus, and scrolling state |
| `FTextInputAction`, `FTextInputType`, `FTextInputFormatter`, `FTextCapitalization`, `FInputFormatters` | Text input configuration |
| `FBoxConstraints`, `FEdgeInsetsGeometry`, `FBoxDecoration`, `FBorder`, `FDecoration`, `FBorderRadius`, `FBorderSide`, `FBoxShadow`, `FClip` | Layout and decoration values |
| `FTableBorder`, `FTableColumnWidth`, `FIntrinsicColumnWidth`, `FFixedColumnWidth` | Table geometry values |
| `FFrameTiming`, `FFrameTimingsCallback`, `FFrameScheduler`, `FFrameLog` | Frame diagnostics and logging |

## Layout widgets

| API | Purpose |
| --- | --- |
| `FRow`, `FColumn`, `FExpanded`, `FSpacer` | Linear composition |
| `FSizedBox`, `FPadding`, `FCenter`, `FAlign`, `FConstrainedBox`, `FContainer`, `FColoredBox` | Sizing, spacing, alignment, and surfaces |
| `FWrap`, `FStack`, `FPositioned` | Flow and layered composition |
| `FSingleChildScrollView`, `FListView`, `FScrollArea` | Scroll containers; builder list variants are lazy |
| `FTableRow`, `FTable` | Static table layout |
| `FDefaultTextStyle` | Text-style inheritance |

## Text and icons

`FText` renders plain text. `FRichText` accepts `FInlineSpan` and `FWidgetSpan`. `FIconData` is an opaque glyph identifier; use `FIcons` with `FIcon` rather than storing private code points in application source.

Layout enums include `FMainAxisSize`, `FMainAxisAlignment`, `FCrossAxisAlignment`, `FTextAlignment`, `FTextOverflowMode`, `FVerticalDirection`, `FStackFit`, `FWrapAlignment`, `FWrapCrossAlignment`, and `FLayoutAxis`.
