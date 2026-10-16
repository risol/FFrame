# Application-level combinations

## Segmented choices

`FSegmentedControl<T>` is a controlled mutually exclusive choice group. Use it for a small set of peer modes; use `FSelect` for longer menus.

```dart
FSegmentedControl<String>(
  items: const <FSegmentedItem<String>>[
    FSegmentedItem(value: 'grid', label: 'Grid'),
    FSegmentedItem(value: 'list', label: 'List'),
  ],
  selectedValue: layout,
  onChanged: (value) => setState(() => layout = value),
)
```

## Validation

See the [input contract](input-contract.md) for field registration, synchronous validation, reset, and save behavior. Domain and async validation stay with application state.

## Toast feedback

`showFToast` inserts a themed, non-modal message in the nearest overlay. It returns an `FToastHandle` for early dismissal. Use dialogs for decisions that must interrupt the current task.

```dart
final toast = showFToast(
  context,
  message: 'Changes saved',
  variant: FToastVariant.success,
  duration: const Duration(seconds: 3),
);
// Later, if needed:
toast.dismiss();
```

Toast messages use live-region semantics. Keep the message short and do not rely on color or the icon alone to convey the result.
