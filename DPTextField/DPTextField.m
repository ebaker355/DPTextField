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

@interface DPTextField ()
@property (readonly, nonatomic) UIBarButtonItem *previousNextBarButtonItem;
@property (readonly, nonatomic) UIBarButtonItem *doneBarButtonItem;
@property (assign, nonatomic) BOOL resizeToolbarWhenKeyboardFrameChanges;
@end

@implementation DPTextField
@synthesize previousField = _previousField;
@synthesize nextField = _nextField;
@synthesize inputAccessoryViewHidden = _inputAccessoryViewHidden;
@synthesize previousNextBarButtonItem = _previousNextBarButtonItem;
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
        }
        return result;
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    if ([self canResignFirstResponder]) {
        [self setResizeToolbarWhenKeyboardFrameChanges:NO];
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

    UIBarButtonItem *barItem = [self previousNextBarButtonItem];
    if (nil != barItem) {
        [barItems addObject:barItem];
    }

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

#pragma mark - Previous|Next toolbar buttons

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

#pragma mark - Done toolbar button

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

@end
