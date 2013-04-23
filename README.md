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
- automatic handling of Next and Done return key types
- proper device rotation handling for iPhone and iPad
- correct handling of iPad's undocked keyboard

## Preview

![Auto fill](https://raw.github.com/ebaker355/DPTextField/master/DPTextFieldAutoFill.gif "Auto fill")

## Motivation

Auto fill makes filling out forms much simpler, especially for mobile devices.
There are several excellent UITextField-based controls available for iOS that
implement an auto fill feature. However, of the ones that I personally have
tried, most of them assume that your form layout has ample space around the text
fields to accommodate displaying a list of auto fill strings below it, similar
to the way Google Search's auto complete works.

I do not want to have to design my UI in such a way as to accommodate auto fill.
Rather, I'd like to re-use the space that I'm already expecting to be used for
input - the iOS keyboard window.

Fortunately, Apple provides the `inputView` property on `UITextField` instances.
You can set any view you want to this property, and iOS will display it instead
of the standard keyboard. Great!

But... simply setting a custom input view causes the keyboard to disappear
instantly, and the new input view to be displayed instantly. It is rather abrupt
in an otherwise smoothly-animated OS. DPTextField addresses this.

When the auto fill list is presented, the iOS keyboard "appears" to slide out of
the way, revealing the strings list below. After a string is selected (or if the
auto fill is canceled), the iOS keyboard "appears" to slide back into place.
This gives your users a much nicer-feeling transition. Since the iOS keyboard
space is being reused, DPTextField can be used with any UI layout, without the
need to consider extra spacing for auto fill suggestions.

## Installation

### CocoaPods

The easiest and highly recommended way to add DPTextField to your project is
to use [CocoaPods](http://cocoapods.org).

Add the pod to your `Podfile`:

```ruby
platform :ios, '6.0'
pod 'DPTextField'
```

then run `pod install`.

Be sure to `#import "DPTextField.h"`. Then, in Interface Builder, you can set
your UITextField controls to use the `DPTextField` class. Your view controller
can be the auto fill data source, so long as it implements the
`DPTextFieldAutoFillDataSource` protocol.

### Source

Alternatively, you can clone this repository and add the 5 files in the
DPTextField directory to your project.

## Usage 

### The toolbar

DPTextField uses a `UIToolbar` as its `inputAccessoryView`. The toolbar
correctly resizes itself in response to device orientation changes (iPhone
only). The toolbar's appearance can be customized any way you like. By default,
it will appear with a standard styled `UIToolbar` for normal keyboards, and with
a black transluscent style for alert keyboards. At any time, the toolbar can be
hidden by setting the `inputAccessoryViewHidden` property to `YES`.

```objc
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

```objc
// Return all appropriate auto-fill strings for the given string.
- (NSArray *)textField:(DPTextField *)textField autoFillStringsForString:(NSString *)string {
    NSArray *autoFillStrings = [self allAvailableAutoFillStrings];    // Read from some serialized source

    NSMutableArray *matches = [NSMutableArray array];

    // Pre-sort the autoFillStrings array.
    NSArray *sortedAutoFillStrings = [autoFillStrings sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

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

```objc
- (NSUInteger)minimumLengthForAutoFillQueryForTextField:(DPTextField *)textField {
    // Require at least 3 characters for autoFill in all fields, except field1.
    if (self.field1 == textField) {
        return 1;
    }
    return 3;
}
```

Its nice for your users to be able to remove items from the auto fill strings
list. You can enable this ability by providing implementations for the methods
`textField:canRemoveAutoFillString:atIndexPath:` and
`textField:removeAutoFillString:atIndexPath:`. Users may now use the familiar
horizontal swipe gesture to remove strings. Here's an example:

```objc
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

Finally, you can provide your own custom table view cells for the auto fill list
by implementing the method
`textField:tableView:cellForAutoFillString:atIndexPath:`. This allows you to
style the cells after a particular theme used by your app. If you do not provide
this method, then cells use the `UITableViewCellStyleDefault` style, with the
`UITableViewCellSelectionStyleGray` selection style, by default. Your
implementation may look something like this: (Note that non-editable cells are
colored blue.)

```objc
- (UITableViewCell *)textField:(DPTextField *)textField tableView:(UITableView *)tableView cellForAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TextFieldAutoFillCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [[cell textLabel] setText:string];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];

    BOOL editable = [self textField:textField canRemoveAutoFillString:string atIndexPath:indexPath];
    [[cell textLabel] setTextColor:(editable ? [UIColor blackColor] : [UIColor blueColor])];

    return cell;
}
```

### Auto-correction

For fields that implement auto fill, it is usually a good idea to disable
auto-correction. This can be done in Interface Builder. It may not always be
necessary. I suggest testing your interface with correction enabled and disabled
to see which works best for the type of data you're working with.

### Maximum string length

You can specify a maximum-allowed string length for your field, like this:

```objc
[field setMaximumLength:4];
```

### Return key

If your field uses a `UIReturnKeyNext` return key, and the Next toolbar button
is available, then the field will make the next field the first responder when
the Next return key is tapped.

If your field uses a `UIReturnKeyDone` return key, and the Done toolbar button
is available, then the keyboard will be dismissed when the Done return key is
tapped.

These behaviors can be overridden in a custom delegate. All other special
handling of the different return key types must be implemented in a custom
delegate.

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

```objc
// assuming 'field' is a DPTextField instance...

id<UITextFieldDelegate> myDelegate = [[NSObject alloc] init];
[field setDelegate:myDelegate];     // Or wire up in IB.

id delegate = [field delegate];     // Returns internal delegate!

id customDelegate = [field customDelegate]; // Returns myDelegate.
```

## Contributing

Feel free to fork and send pull requests. It might be nice to have different
keyboard transitions to choose from.

## App Store Safe?

As of yet, unknown. I plan to submit an app to the App Store very soon, which
will include this control. If Apple approves the app, I will update this section
of the README. __Until then, use at your own risk.__ If you use this control in
an app that gets approved, please let me know!

## License

Usage is provided under the [MIT License](http://http://opensource.org/licenses/mit-license.php).  See LICENSE for the full details.

## Credit

A mention would be nice, but is by no means required. At the very least, shoot
me an email and let me know if you've gotten any good use out of this control,
or if you have any ideas for improvements.
