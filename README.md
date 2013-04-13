DPTextField
===========

DPTextField is a replacement control for UITextField that provides several
useful features, including:

- Previous/Next field toolbar buttons (with outlets that can be wired up in
Interface Builder)
- unobtrusive and editable auto-fill functionality
- a Done toolbar button, and swipe gesture, to remove the keyboard without
submitting a form
- set maximum characters allowed in field
- proper device rotation handling for iPhone and iPad
- correct handling of iPad's undocked keyboard

## Preview

[insert images here]

## Installation

[insert installation instructions here]

## Code

### The toolbar

DPTextField uses a `UIToolbar` as its `inputAccessoryView`. The toolbar
correctly resizes itself in response to device orientation changes (iPhone
only). The toolbar's appearance can be customized any way you like. By default,
it will appear with a standard styled `UIToolbar` for normal keyboards, and with
a black transluscent style for alert keyboards. At any time, the toolbar can be
hidden by setting the `inputAccessoryViewHidden` property to `YES`.

```
DPTextField *field = [[DPTextField alloc] init];
[field.toolbar setBarStyle:UIBarStyleBlackOpaque];
[field setInputAccessoryViewHidden:YES];
```

### Previous/Next buttons
