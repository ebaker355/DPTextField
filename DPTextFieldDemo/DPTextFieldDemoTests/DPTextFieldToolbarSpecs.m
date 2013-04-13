//
//  DPTextFieldToolbarSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"

SPEC_BEGIN(DPTextFieldToolbarSpecs)

describe(@"The text field toolbar", ^{
    __block DPTextField *field;
    __block UIToolbar *toolbar;

    beforeEach(^{
        field = [[DPTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
        toolbar = (UIToolbar *)[field inputAccessoryView];
    });

    context(@"when the text field is the first responder", ^{
        beforeEach(^{
            [field becomeFirstResponder];
        });

        it(@"should size to fit when the keyboard frame changes", ^{
            [[toolbar should] receive:@selector(sizeToFit)];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidChangeFrameNotification object:nil userInfo:nil];
        });
    });

    context(@"when the text field is not the first responder", ^{
        beforeEach(^{
            [field resignFirstResponder];
        });

        it(@"should not size to fit when the keyboard frame changes", ^{
            [[toolbar shouldNot] receive:@selector(sizeToFit)];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidChangeFrameNotification object:nil userInfo:nil];
        });
    });
});

SPEC_END
