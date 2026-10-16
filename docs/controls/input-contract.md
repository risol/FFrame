# Input contract

`FTextField` uses `EditableText` internally and owns its visual state, focus behavior, semantics, and formatting API. It does not require Material. The controller and focus node are optional; FFrame disposes only objects that it creates.

```dart
FTextField(
  label: 'Account password',
  placeholder: 'Enter a password',
  obscureText: true,
  keyboardType: FTextInputType.visiblePassword,
  enableSuggestions: false,
  autocorrect: false,
  maxLength: 128,
  helperText: 'Use at least 12 characters.',
)

FTextField(
  label: 'Port',
  keyboardType: FTextInputType.number,
  inputFormatters: <FTextInputFormatter>[FInputFormatters.digitsOnly],
  maxLength: 5,
)

FTextField(
  label: 'Notes',
  minLines: 3,
  maxLines: 8,
  placeholder: 'Write a note',
)
```

`maxLength` applies a grapheme-aware input formatter. The optional counter reports the current Unicode scalar count. Set `showCounter: false` to hide it. `errorText` takes precedence over `helperText`, paints the field border with the design system danger color, and is exposed as a live semantic message.

## Forms

`FForm` groups fields. A caller can pass a `FFormController`, or retrieve the nearest controller with `FForm.of(context)`. Validation returns `false` when any field reports an error. `reset` clears registered fields and `save` calls each field's `onSaved` callback.

```dart
final form = FFormController();

FForm(
  controller: form,
  child: FColumn(children: <FWidget>[
    FTextField(
      label: 'Email',
      validator: (value) => value.contains('@') ? null : 'Enter an email.',
      onSaved: (value) => email = value,
      autovalidateMode: FAutovalidateMode.onUserInteraction,
    ),
    FButton(
      onPressed: () {
        if (form.validate()) form.save();
      },
      child: const FText('Continue'),
    ),
  ]),
)
```

Validation is synchronous. Async checks belong in application state; pass the resulting message through `errorText` and keep the network or domain rule out of the input control.
