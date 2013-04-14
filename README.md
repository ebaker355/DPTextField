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

## Usage 

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

### Previous | Next and Done toolbar buttons

A DPTextField has IBOutlets for sibling fields, called `previousField` and
`nextField`. These can be connected to other `UIResponder` controls using
Interface Builder.

When these outlets are connected, DPTextField will display Previous and Next
buttons in its toolbar. These will switch the first responder field in the view,
if allowed.

The previous and next buttons are only enabled when the outlets are connected.
If neither outlet is connected, the buttons are not displayed in the toolbar.
The buttons can also be manually enabled/disabled by setting the
`previousBarButtonEnabled` and `nextBarButtonEnabled` boolean properties. This
is useful for preventing a field from resigining first responder if it fails a
validation check. (Note that setting these properties to YES only enables the
bar button if the field's respective outlet is connected to another control.)

A Done button is also displayed in the toolbar by default. When tapped, it
simply tells the DPTextField to `resignFirstResponder`. It can be removed by
setting the `doneBarButtonItemHidden` property to `YES`. Alternatively, it can
be enabled/disabled via the `doneBarButtonItemEnabled` property.

### AutoFill

A DPTextField accepts a data source to provide auto-fill strings. The data
source can be set in code, or wired up in Interface Builder, and must adopt the
`DPTextFieldAutoFillDataSource` protocol.

When a data source is provided, the AutoFill toolbar button will appear in the
keyboard toolbar. The button can be manually hidden, if appropriate, by setting
the `autoFillBarButtonItemHidden` boolean property. (Note that setting this
property to `YES` has no effect if the `autoFillDataSource` property is nil.)
The same is true for the button's enabled state. Also, if the data source does
not provide any matching strings, the button cannot be enabled.

The `DPTextFieldAutoFillDataSource` protocol provides several methods to
customize the auto-fill behavior, but only one method is required. The data
source must provide its own algorithm to determine which auto-fill strings are
appropriate to match the text entered in the field. This is an example of the
required method that implements a 2-pass algorithm. The first pass finds matches
that _begin with_ the entered text. The second pass find matches that _contain_
the entered text. There is no need to worry about duplicates in the matches
array. DPTextField will automatically filter any duplicates. It will not,
however, sort the matches. So its a good idea to pre-sort.

```
// Return all appropriate auto-fill strings for the given string.
- (NSArray *)textField:(DPTextField *)textField autoFillStringsForString:(NSString *)string {
    NSArray *autoFillStrings = [self allAvailableAutoFillStrings];    // Read from some serialized source

    NSMutableArray *matches = [NSMutableArray array];

    // Pre-sort the autoFillStrings array.
    NSArray *sortedAutoFillStrings = [autoFillStrings sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];

    // If the search string is nil or empty, just return all auto-fill strings.
    if (nil != string && [string length] > 0) {
        // Match the given string.

        // First pass, find strings with a matching prefix.
        for (NSString *possibleMatch in sortedAutoFillStrings) {
            NSRange range = [possibleMatch rangeOfString:string options:NSCaseInsensitiveSearch];
            if (0 == range.location) {
                [matches addObject:possibleMatch];
            }
        }

        // Second pass, find strings that contain string.
        for (NSString *possibleMatch in sortedAutoFillStrings) {
            NSRange range = [possibleMatch rangeOfString:string options:NSCaseInsensitiveSearch];
            if (NSNotFound != range.location) {
                [matches addObject:possibleMatch];
            }
        }
    } else {
        // Return all available autoFillStrings.
        [matches addObjectsFromArray:sortedAutoFillStrings];
    }
    return matches;
}
```

You can require that a minimum number of characters are entered into the field
before the data source is queried for auto fill strings. Implement the
`minimumLengthForAutoFillQueryForTextField:` method in your data source, like
this:

```
- (NSUInteger)minimumLengthForAutoFillQueryForTextField:(DPTextField *)textField {
    // Require at least 3 characters for autoFill in all fields, except field1.
    if (self.field1 == textField) {
        return 1;
    }
    return 3;
}
```

Its nice for your user to be able to remove items from the auto fill strings
list. You can enable this ability by providing implementations for the methods
`textField:canRemoveAutoFillString:atIndexPath:` and
`textField:removeAutoFillString:atIndexPath:`. The user may use the familiar
horizontal swipe gesture to remove strings. Here's an example:

```
- (BOOL)textField:(DPTextField *)textField canRemoveAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath {
    // So long as the string is not one that should never be removed...
    return YES;
}

- (void)textField:(DPTextField *)textField removeAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath {
    // Remove the string from the serialized data source.
    // NOTE: Remove only 1 string! If the string count remaining does not match
    // what the auto fill table view expects, then crashes may occur!

    [[self autoFillStrings] removeObject:string];
}
```

### Auto-correction

For fields that implement auto fill, it is usually a good idea to disable
auto-correction. This can be done in Interface Builder. It may not always be
necessary. I suggest testing your interface with correction enabled and disabled
to see which works best for the type of data you're working with.

## About the delegate...

In order for a DPTextField to gain a measure of control over its superclass
object, it must instantiate its own internal delegate object that conforms to
the `UITextFieldDelegate` protocol. This does not prevent you from assigning
your own custom delegate object, either in code or in Interface Builder, exactly
the way you would with a standard UITextField, using the `setDelegate:` method.
The internal delegate will defer to your custom delegate.

The only caveat, however, is if you want to get a reference back to your custom
delegate from the DPTextField control (which you should rarely, if ever, need to
do). If you simply call the DPTextField's `delegate` property, you'll receive
its internal delegate instance. In order to retrieve your custom delegate, use
the `customDelegate` property, like this:

```
// assuming 'field' is a DPTextField instance...

id<UITextFieldDelegate> myDelegate = [[NSObject alloc] init];
[field setDelegate:myDelegate];     // Or wire up in IB.

id delegate = [field delegate];     // Returns internal delegate!

id customDelegate = [field customDelegate]; // Returns myDelegate.
```
