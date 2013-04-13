//
//  DPTextFieldDoneButtonSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"

@interface DPTextField ()
- (void)done:(id)sender;
@end

SPEC_BEGIN(DPTextFieldDoneButtonSpecs)

describe(@"The done toolbar button", ^{
	__block DPTextField *field;
    beforeEach(^{
        field = [[DPTextField alloc] init];
    });

    it(@"should be enabled by default", ^{
        [[@([field doneBarButtonEnabled]) should] beYes];
        [[@([field doneBarButtonHidden]) should] beNo];
    });

    it(@"should be shown in the toolbar", ^{
        BOOL foundDoneBtn = NO;
        UIToolbar *toolbar = (UIToolbar *)[field inputAccessoryView];
        for (UIBarButtonItem *item in [toolbar items]) {
            if ([item target] == field && [NSStringFromSelector([item action]) isEqualToString:NSStringFromSelector(@selector(done:))]) {
                foundDoneBtn = YES;
                break;
            }
        }

        [[@(foundDoneBtn) should] beYes];
    });

    context(@"when hidden", ^{
        beforeEach(^{
            [field setDoneBarButtonHidden:YES];
        });

        it(@"should not be shown in the toolbar", ^{
            BOOL foundDoneBtn = NO;
            UIToolbar *toolbar = (UIToolbar *)[field inputAccessoryView];
            for (UIBarButtonItem *item in [toolbar items]) {
                if ([item target] == field && [NSStringFromSelector([item action]) isEqualToString:NSStringFromSelector(@selector(done:))]) {
                    foundDoneBtn = YES;
                    break;
                }
            }

            [[@(foundDoneBtn) should] beNo];
        });
    });

    context(@"when tapped", ^{
        it(@"should tell the field to be done", ^{
            [[field should] receive:@selector(done:) withArguments:field.doneBarButtonItem];

            UIBarButtonItem *doneBtn = [field doneBarButtonItem];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [doneBtn.target performSelector:doneBtn.action withObject:doneBtn];
#pragma clang diagnostic pop
        });

        it(@"should tell the field to resignFirstResponder through the done message", ^{
            [[field should] receive:@selector(resignFirstResponder) andReturn:@YES];

            [field done:field.doneBarButtonItem];
        });
    });
});

SPEC_END
