//
//  DPTextField.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPTextField.h"

const NSUInteger kPreviousButtonIndex   = 0;
const NSUInteger kNextButtonIndex       = 1;

#pragma mark - DPTextFieldInternalDelegate

@interface DPTextFieldInternalDelegate : NSObject <UITextFieldDelegate>
@property (assign, nonatomic) id<UITextFieldDelegate> delegate;
@end

@implementation DPTextFieldInternalDelegate
@synthesize delegate;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (nil != delegate && [delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:textField];
    }
    return (nil != textField);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (nil != delegate && [delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (nil != delegate && [delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [delegate textFieldShouldEndEditing:textField];
    }
    return (nil != textField);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (nil != delegate && [delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // If our delegate responds to this message, check its response first.
    if (nil != delegate && [delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if (NO == [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            return NO;
        }
    }

    // Either our delegate doesn't respond, or said YES.
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;
        // Check field length restriction.
        NSUInteger maxLength = [field maximumLength];
        if (maxLength > 0) {
            NSUInteger newLength = field.text.length + string.length - range.length;
            if (newLength > maxLength) {
                return NO;
            }
        }
    }

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (nil != delegate && [delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [delegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (nil != delegate && [delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate textFieldShouldReturn:textField];
    }
    return YES;
}

@end

#pragma mark - DPTextField

@interface DPTextField ()
@property (strong, nonatomic) DPTextFieldInternalDelegate *internalDelegate;
@property (strong, nonatomic) NSMutableArray *autoFillStrings;
@property (assign, nonatomic) BOOL resizeToolbarWhenKeyboardFrameChanges;
@end

@implementation DPTextField
@synthesize previousField = _previousField;
@synthesize nextField = _nextField;
@synthesize inputAccessoryViewHidden = _inputAccessoryViewHidden;
@synthesize previousNextBarButtonItem = _previousNextBarButtonItem;
@synthesize autoFillDataSource = _autoFillDataSource;
@synthesize autoFillBarButtonItem = _autoFillBarButtonItem;
@synthesize autoFillBarButtonHidden = _autoFillBarButtonHidden;
@synthesize autoFillBarButtonEnabled = _autoFillBarButtonEnabled;
@synthesize doneBarButtonItem = _doneBarButtonItem;
@synthesize doneBarButtonHidden = _doneBarButtonHidden;
@synthesize resizeToolbarWhenKeyboardFrameChanges = _resizeToolbarWhenKeyboardFrameChanges;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        [self configureControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureControl];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureControl];
    }
    return self;
}

- (void)configureControl {
    // Always have an internal delegate.
    [self installInternalDelegate:nil];
    
    // Set option defaults.
    [self setInputAccessoryViewHidden:NO];
}

- (void)setPreviousField:(UIResponder *)previousField {
    _previousField = previousField;
    [self updateToolbarAnimated:NO];
    [self updatePreviousNextButtons];
}

- (void)setNextField:(UIResponder *)nextField {
    _nextField = nextField;
    [self updateToolbarAnimated:NO];
    [self updatePreviousNextButtons];
}

#pragma mark - Internal delegate

- (void)installInternalDelegate:(DPTextFieldInternalDelegate *)delegate {
    // If an internal delegate is already set, replace it.
    if (nil != [self internalDelegate] && (nil != delegate)) {
        if (nil != [[self internalDelegate] delegate]) {
            [delegate setDelegate:[[self internalDelegate] delegate]];
        }
        [self setInternalDelegate:delegate];
    }
    // If no internal delegate is set, create one.
    if (nil == [self internalDelegate]) {
        [self setInternalDelegate:(nil != delegate ? delegate : [[DPTextFieldInternalDelegate alloc] init])];
    }
    [super setDelegate:[self internalDelegate]];
}

- (id<UITextFieldDelegate>)delegate {
    [self installInternalDelegate:nil];
    return [super delegate];
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    if ([delegate isKindOfClass:[DPTextFieldInternalDelegate class]]) {
        [self installInternalDelegate:delegate];
    } else {
        [self installInternalDelegate:nil];
        [[self internalDelegate] setDelegate:delegate];
    }
}

- (id<UITextFieldDelegate>)customDelegate {
    return [[self internalDelegate] delegate];
}

#pragma mark - Responder status

- (BOOL)becomeFirstResponder {
    // Resize the toolbar if we are going to become the first responder, but
    // make sure to do it after [super becomeFirstResponder]
    BOOL result;
    if ([self canBecomeFirstResponder]) {
        result = [super becomeFirstResponder];
        if (result) {
            if (![self inputAccessoryViewHidden]) {
                [self setResizeToolbarWhenKeyboardFrameChanges:YES];
            }

            // Watch for text changes.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self];

            // Initialize auto-fill.
            [self queryAutoFillDataSource];
        }
        return result;
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    if ([self canResignFirstResponder]) {
        [self setResizeToolbarWhenKeyboardFrameChanges:NO];

        // Stop watching text changes.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self];
    }
    return [super resignFirstResponder];
}

#pragma mark - Toolbar

- (void)installToolbar {
    if (nil == [self inputAccessoryView]) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        // Customize toolbar appearance to match keyboard.
        [toolbar setBarStyle:[self barStyleMatchingKeyboard]];
        [self setInputAccessoryView:toolbar];
        [toolbar sizeToFit];
        [self updateToolbarAnimated:NO];
    }
}

- (void)updateToolbarAnimated:(BOOL)animated {
    if ([self inputAccessoryViewHidden]) return;
    
    NSMutableArray *barItems = [NSMutableArray array];

    // Previous|Next buttons
    UIBarButtonItem *barItem = [self previousNextBarButtonItem];
    if (nil != barItem) {
        [barItems addObject:barItem];
    }

    // AutoFill button
    if (nil != [self autoFillDataSource]) {
        if ([barItems count] > 0) {
            [barItems addObject:[self flexibleSpaceBarButtonItem]];
        }
        [barItems addObject:[self autoFillBarButtonItem]];
    }

    // Done button
    if (NO == [self doneBarButtonHidden]) {
        [barItems addObjectsFromArray:@[[self flexibleSpaceBarButtonItem], [self doneBarButtonItem]]];
    }

    [[self toolbar] setItems:barItems animated:animated];
}

- (UIBarStyle)barStyleMatchingKeyboard {
    if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()) {
        if (UIKeyboardAppearanceAlert == [self keyboardAppearance]) {
            return UIBarStyleBlackTranslucent; 
        }
    }
    return UIBarStyleDefault;
}

- (UIToolbar *)toolbar {
    return (UIToolbar *)[self inputAccessoryView];
}

- (void)setInputAccessoryViewHidden:(BOOL)inputAccessoryViewHidden {
    _inputAccessoryViewHidden = inputAccessoryViewHidden;
    if (_inputAccessoryViewHidden) {
        [self setInputAccessoryView:nil];
    } else {
        [self installToolbar];
    }
    [self setResizeToolbarWhenKeyboardFrameChanges:!_inputAccessoryViewHidden];
}

- (void)setResizeToolbarWhenKeyboardFrameChanges:(BOOL)resizeToolbarWhenKeyboardFrameChanges {
    _resizeToolbarWhenKeyboardFrameChanges = resizeToolbarWhenKeyboardFrameChanges;
    if (_resizeToolbarWhenKeyboardFrameChanges) {
        [[NSNotificationCenter defaultCenter] addObserver:self.toolbar selector:@selector(sizeToFit) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[self toolbar] sizeToFit];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self.toolbar name:UIKeyboardDidChangeFrameNotification object:nil];
    }
}

- (UIBarButtonItem *)flexibleSpaceBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

#pragma mark - Previous|Next toolbar buttons and functionality

- (BOOL)previousBarButtonEnabled {
    if (nil != _previousNextBarButtonItem) {
        UISegmentedControl *segControl = (UISegmentedControl *)[_previousNextBarButtonItem customView];
        return [segControl isEnabledForSegmentAtIndex:kPreviousButtonIndex];
    }
    return NO;
}

- (void)setPreviousBarButtonEnabled:(BOOL)previousBarButtonEnabled {
    if (nil != _previousNextBarButtonItem) {
        previousBarButtonEnabled = (previousBarButtonEnabled && (nil != self.previousField));
        UISegmentedControl *segControl = (UISegmentedControl *)[_previousNextBarButtonItem customView];
        [segControl setEnabled:previousBarButtonEnabled forSegmentAtIndex:kPreviousButtonIndex];
    }
}

- (BOOL)nextBarButtonEnabled {
    if (nil != _previousNextBarButtonItem) {
        UISegmentedControl *segControl = (UISegmentedControl *)[_previousNextBarButtonItem customView];
        return [segControl isEnabledForSegmentAtIndex:kNextButtonIndex];
    }
    return NO;
}

- (void)setNextBarButtonEnabled:(BOOL)nextBarButtonEnabled {
    if (nil != _previousNextBarButtonItem) {
        nextBarButtonEnabled = (nextBarButtonEnabled && (nil != self.nextField));
        UISegmentedControl *segControl = (UISegmentedControl *)[_previousNextBarButtonItem customView];
        [segControl setEnabled:nextBarButtonEnabled forSegmentAtIndex:kNextButtonIndex];
    }
}

- (UIBarButtonItem *)previousNextBarButtonItem {
    if (nil == _previousNextBarButtonItem) {
        // Only instantiate if this field has siblings.
        if (nil != self.previousField || nil != self.nextField) {
            // Create a segmented control with two segments (Previous|Next) as
            // the custom view for the bar button item.
            UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"Previous", @"Previous"), NSLocalizedString(@"Next", @"Next") ]];
            [segControl setMomentary:YES];
            [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
            [segControl addTarget:self action:@selector(makePreviousOrNextFieldFirstResponder:) forControlEvents:UIControlEventValueChanged];
            _previousNextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];
            [self updatePreviousNextButtons];
        }
    }
    return _previousNextBarButtonItem;
}

// Enable/disable the segments based on presence of sibling fields.
- (void)updatePreviousNextButtons {
    UISegmentedControl *segControl = (UISegmentedControl *)[[self previousNextBarButtonItem] customView];
    if (nil == segControl) return;

    [segControl setEnabled:(nil != [self previousField]) forSegmentAtIndex:kPreviousButtonIndex];
    [segControl setEnabled:(nil != [self nextField]) forSegmentAtIndex:kNextButtonIndex];
}

- (void)makePreviousOrNextFieldFirstResponder:(id)sender {
    // Respond only to our previous|next segmented control.
    UISegmentedControl *segControl = (UISegmentedControl *)[self.previousNextBarButtonItem customView];
    if (sender == segControl) {
        // The seg control's selected index determines previous or next.
        switch ([segControl selectedSegmentIndex]) {
            case kPreviousButtonIndex:
                [self makeFieldFirstResponder:self.previousField];
                break;
                
            case kNextButtonIndex:
                [self makeFieldFirstResponder:self.nextField];
                break;
        }
    }
}

- (void)makeFieldFirstResponder:(UIResponder *)aField {
    if (nil == aField) return;
    if ([self canResignFirstResponder] && [aField canBecomeFirstResponder]) {
        [aField becomeFirstResponder];
    }
}

#pragma mark - Auto-fill toolbar button and functionality

- (UIBarButtonItem *)autoFillBarButtonItem {
    if (nil == _autoFillBarButtonItem) {
        _autoFillBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"AutoFill", @"AutoFill") style:UIBarButtonItemStyleBordered target:self action:@selector(autoFill:)];
    }
    return _autoFillBarButtonItem;
}

- (BOOL)autoFillBarButtonHidden {
    if (nil == _autoFillDataSource) return YES;
    return _autoFillBarButtonHidden;
}

- (void)setAutoFillBarButtonHidden:(BOOL)autoFillBarButtonHidden {
    if (nil == _autoFillDataSource) return;
    _autoFillBarButtonHidden = autoFillBarButtonHidden;
    [self updateToolbarAnimated:YES];
}

- (BOOL)autoFillBarButtonEnabled {
    if (nil == _autoFillDataSource) return NO;
    if ([self autoFillBarButtonHidden]) return NO;
    return [[self autoFillBarButtonItem] isEnabled];
}

- (void)setAutoFillBarButtonEnabled:(BOOL)autoFillBarButtonEnabled {
    if (nil == _autoFillDataSource) return;
    [_autoFillBarButtonItem setEnabled:autoFillBarButtonEnabled];
    if (autoFillBarButtonEnabled) {
        [self updateAutoFillBarButtonItemEnabledState];
    }
}

- (void)setAutoFillDataSource:(id<DPTextFieldAutoFillDataSource>)autoFillDataSource {
    _autoFillDataSource = autoFillDataSource;
    if (nil != _autoFillDataSource && nil == _autoFillStrings) {
        _autoFillStrings = [[NSMutableArray alloc] init];
    }
    [self queryAutoFillDataSource];
}

- (void)queryAutoFillDataSource {
    if (nil == _autoFillDataSource && nil != _autoFillStrings) {
        [_autoFillStrings removeAllObjects];
        _autoFillStrings = nil;
    } else {
        // Reset strings.
        [_autoFillStrings removeAllObjects];

        // See if we have enough characters to query the data source.
        NSUInteger minChars = 0;
        if ([_autoFillDataSource respondsToSelector:@selector(minimumLengthForAutoFillQueryForTextField:)]) {
            minChars = [_autoFillDataSource minimumLengthForAutoFillQueryForTextField:self];
        }

        NSString *string = [[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (nil != string && [string length] >= minChars) {
            [_autoFillStrings addObjectsFromArray:[self filterAutoFillStrings:[_autoFillDataSource textField:self autoFillStringsForString:string]]];
        } else {
            [_autoFillStrings removeAllObjects];
        }
    }

    [self updateAutoFillBarButtonItemEnabledState];
}

- (NSArray *)filterAutoFillStrings:(NSArray *)strings {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    for (NSString *string in strings) {
        NSString *filteredString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (NO == [filtered containsObject:filteredString]) {
            [filtered addObject:filteredString];
        }
    }
    return filtered;
}

- (void)updateAutoFillBarButtonItemEnabledState {
    // If there is only one matching auto-fill string, and its an exact match
    // with the text already entered, then disable the AutoFill button.
    if (1 == [_autoFillStrings count]) {
        NSString *string = [_autoFillStrings lastObject];
        [_autoFillBarButtonItem setEnabled:(!(NSOrderedSame == [[self text] compare:string options:NSCaseInsensitiveSearch]))];
    } else {
        [_autoFillBarButtonItem setEnabled:([_autoFillStrings count] > 0)];
    }
}

- (void)autoFill:(id)sender {
    // If there is only one auto-fill string match, then simply apply it.
    if (1 == [_autoFillStrings count]) {
        [self applyAutoFillString:[_autoFillStrings lastObject]];
        // Do not allow the same string to be continually auto-filled.
        [_autoFillBarButtonItem setEnabled:NO];
    } else {
        [self presentAutoFillInputView];
    }
}

- (void)applyAutoFillString:(NSString *)string {
    [self setText:string];
    // We seem to have to post this notification manually.
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self userInfo:nil];

    // Close the auto-fill input view if presented.
    if (nil != [self inputView]) {
        [self cancelAutoFill:self];
    }

    [self queryAutoFillDataSource];
}

- (void)presentAutoFillInputView {
    NSLog(@"presetAutoFill with string: %@", _autoFillStrings);
}

- (void)dismissAutoFillInputView {

}

- (void)cancelAutoFill:(id)sender {

}

#pragma mark - Done toolbar button and functionality

- (UIBarButtonItem *)doneBarButtonItem {
    if (nil == _doneBarButtonItem) {
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    }
    return _doneBarButtonItem;
}

- (void)setDoneBarButtonHidden:(BOOL)doneBarButtonHidden {
    _doneBarButtonHidden = doneBarButtonHidden;
    [self updateToolbarAnimated:YES];
}

- (BOOL)doneBarButtonEnabled {
    return [[self doneBarButtonItem] isEnabled];
}

- (void)setDoneBarButtonEnabled:(BOOL)doneBarButtonEnabled {
    [[self doneBarButtonItem] setEnabled:doneBarButtonEnabled];
}

- (void)done:(id)sender {
    [self resignFirstResponder];
}

#pragma mark - Notifications

- (void)textDidChange:(NSNotification *)notification {
    [self queryAutoFillDataSource];
}

@end
