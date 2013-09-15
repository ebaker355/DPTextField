//
//  DPTextField.m
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPTextField.h"

@implementation DPTextField

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

@end
