# Integration boundaries

FFrame owns application composition, visual resolution, shared control behavior, and the `FWidget` contract. Integrations own their specialized runtime and adapt its output to an `FWidget`. `FWidget` is a stable alias of Flutter's `Widget`; accepting it lets FFrame host third-party widgets without making `fframe` depend on every state or content library.

## Riverpod

Keep Riverpod responsible for providers, async loading, repositories, and domain state. Keep shared visual controls in FFrame. A Riverpod consumer may return an FFrame subtree because the output is an `FWidget`:

```dart
class UserPanel extends ConsumerWidget {
  const UserPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return FPanel(child: FText(user.name));
  }
}
```

If an application requires all source-level class names to use the F prefix, put Riverpod-specific base classes and builder wrappers in an optional bridge package (for example, `fframe_riverpod`) and export names such as `FRiverpodConsumerWidget`. Do not add a Riverpod dependency to core FFrame. `ProviderScope` can sit outside `FFrameApp`; both scopes are Flutter widgets, and each continues to own its own concern.

## Markdown and rich text

Use `FRichText` with `FInlineSpan` and `FWidgetSpan` for inline formatted content. `FMarkdown` accepts an `FMarkdownRenderer` implementation; a parser adapter owns Markdown syntax, links, block layout, and extensions, while FFrame supplies theme-derived text roles and a stable `FWidget` result. This keeps parser choice and versioning outside `fframe`.

## FFlow

FFlow owns flow execution and graph state. Its adapter should map flow state/events into FFrame model values and return FFrame controls or an `FWidget` view. Shared controls do not own workflow execution. If FFlow provides custom widgets, host them through `FWidgetAdapter` or a dedicated F-prefixed bridge component.

## Dependency direction

```text
application state (Riverpod) ─┐
Markdown / FFlow adapters ─────┼─> FWidget boundary ─> FFrame controls + theme
platform window plugin ────────┘
```

No core package imports a state manager, Markdown parser, workflow engine, or platform window plugin. `FFrameApp` owns the design-system scope and optional `FWindowManager` scope.
