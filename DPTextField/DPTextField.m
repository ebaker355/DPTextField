//
//  DPTextField.m
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPTextField.h"

@interface DPTextFieldInternalSharedDelegate : NSObject <UITextFieldDelegate>
+ (instancetype)sharedDelegate;
@end

@interface DPTextField ()
@property (assign, nonatomic) id<UITextFieldDelegate> customDelegate;
@property (weak, nonatomic) id textDidChangeObserver;
@end

@implementation DPTextField

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (void)initSelf {
    [self setDelegate:[DPTextFieldInternalSharedDelegate sharedDelegate]];
    [self updateToolbar];

    __weak typeof(self) weakSelf = self;
    self.textDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateToolbar];

        if (strongSelf.textDidChange) {
            strongSelf.textDidChange(strongSelf);
        }
    }];
}

- (void)dealloc
{
    if (self.textDidChangeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.textDidChangeObserver];
        self.textDidChangeObserver = nil;
    }
}

#pragma mark - Custom delegate handling

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    if ([delegate isKindOfClass:[DPTextFieldInternalSharedDelegate class]]) {
        [super setDelegate:delegate];
    } else {
        [self setCustomDelegate:delegate];
    }
}

#pragma mark - Responder chain

- (BOOL)canMakePreviousFieldBecomeFirstResponder {
    return self.previousField && [self canResignFirstResponder] && [self.previousField canBecomeFirstResponder];
}

- (BOOL)makePreviousFieldBecomeFirstResponder {
    return [self.previousField becomeFirstResponder];
}

- (BOOL)canMakeNextFieldBecomeFirstResponder {
    return self.nextField && [self canResignFirstResponder] && [self.nextField canBecomeFirstResponder];
}

- (BOOL)makeNextFieldBecomeFirstResponder {
    return [self.nextField becomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
    BOOL retVal = [super becomeFirstResponder];
    if (retVal) {
        [self updateToolbar];

        if (self.shouldSelectAllTextWhenBecomingFirstResponder) {
            [self selectAllText];
        }
    }
    return retVal;
}

- (void)selectAllText {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        UITextRange *range = [strongSelf textRangeFromPosition:strongSelf.beginningOfDocument toPosition:strongSelf.endOfDocument];
        [strongSelf setSelectedTextRange:range];
    });
}

#pragma mark - Toolbar

- (void)updateToolbar {
    UIToolbar *toolbar = nil;
    if (!self.inputAccessoryView) {
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        switch (self.keyboardAppearance) {
            case UIKeyboardAppearanceDark:
                [toolbar setBarStyle:UIBarStyleBlack];
                [toolbar setTintColor:[UIColor whiteColor]];
                break;
                
            default:
                [toolbar setBarStyle:UIBarStyleDefault];
                break;
        }
        [self setInputAccessoryView:toolbar];
    } else {
        toolbar = (UIToolbar *)self.inputAccessoryView;
    }

    NSMutableArray *items = [NSMutableArray array];

    UIBarButtonItem *item = nil;
    if (self.previousField || self.nextField) {
        item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DPTextField_AngleLeft"] style:UIBarButtonItemStylePlain target:self action:@selector(makePreviousFieldBecomeFirstResponder)];
        item.enabled = [self canMakePreviousFieldBecomeFirstResponder];
        [items addObject:item];

        item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DPTextField_AngleRight"] style:UIBarButtonItemStylePlain target:self action:@selector(makeNextFieldBecomeFirstResponder)];
        item.enabled = [self canMakeNextFieldBecomeFirstResponder];
        [items addObject:item];
    }

    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:item];

    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignFirstResponder)];
    [items addObject:item];

    [toolbar setItems:items animated:NO];
    [toolbar sizeToFit];
}

@end



#pragma mark - Internal Shared Delegate implementation

@implementation DPTextFieldInternalSharedDelegate

+ (instancetype)sharedDelegate {
    static DPTextFieldInternalSharedDelegate *_sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDelegate = [[DPTextFieldInternalSharedDelegate alloc] init];
    });
    return _sharedDelegate;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            if (![field.customDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
                return NO;
            }
        }

        if (field.shouldChangeCharactersInRange_ReplacementString_Block) {
            if (!field.shouldChangeCharactersInRange_ReplacementString_Block(field, range, string)) {
                return NO;
            }
        }

        NSUInteger maximumTextLength = field.maximumTextLength;
        if (maximumTextLength > 0) {
            NSUInteger newLength = field.text.length + string.length - range.length;
            // If the string is being shortened, allow it.
            if (newLength < field.text.length) {
                return YES;
            }
            return newLength <= maximumTextLength;
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
            [field.customDelegate textFieldDidBeginEditing:textField];
        }

        if (field.didBeginEditing) {
            field.didBeginEditing(field);
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
            [field.customDelegate textFieldDidEndEditing:textField];
        }

        if (field.didEndEditing) {
            field.didEndEditing(field);
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
            if (![field.customDelegate textFieldShouldBeginEditing:textField]) {
                return NO;
            }
        }

        if (field.shouldBeginEditing) {
            return field.shouldBeginEditing(field);
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
            if (![field.customDelegate textFieldShouldClear:textField]) {
                return NO;
            }
        }

        if (field.shouldClear) {
            return field.shouldClear(field);
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
            if (![field.customDelegate textFieldShouldEndEditing:textField]) {
                return NO;
            }
        }

        if (field.shouldEndEditing) {
            return field.shouldEndEditing(field);
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isKindOfClass:[DPTextField class]]) {
        DPTextField *field = (DPTextField *)textField;

        if (field.customDelegate && [field.customDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
            if (![field.customDelegate textFieldShouldReturn:textField]) {
                return NO;
            }
        }

        if (field.shouldReturn) {
            if (!field.shouldReturn(field)) {
                return NO;
            }
        }

        switch (field.returnKeyType) {
            case UIReturnKeyNext:
                return [field makeNextFieldBecomeFirstResponder];
                break;
                
            default:
                return [field resignFirstResponder];
                break;
        }
    }
    return YES;
}

@end
