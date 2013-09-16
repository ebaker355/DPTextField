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
    return [self canMakePreviousFieldBecomeFirstResponder] && [self.previousField becomeFirstResponder];
}

- (BOOL)canMakeNextFieldBecomeFirstResponder {
    return self.nextField && [self canResignFirstResponder] && [self.nextField canBecomeFirstResponder];
}

- (BOOL)makeNextFieldBecomeFirstResponder {
    return [self canMakeNextFieldBecomeFirstResponder] && [self.nextField becomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
    BOOL retVal = [super becomeFirstResponder];
    if (retVal && self.shouldSelectAllTextWhenBecomingFirstResponder) {
        // NOTE: Unless we wrap the setSelectedTextRange call in a dispatch_after block,
        // it will fail 50% of the time. Is this a UITextField bug?
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        __weak typeof(self) weakSelf = self;
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            UITextRange *range = [strongSelf textRangeFromPosition:strongSelf.beginningOfDocument toPosition:strongSelf.endOfDocument];
            [strongSelf setSelectedTextRange:range];
        });
    }
    return retVal;
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
