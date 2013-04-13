//
//  DPTextFieldAutoFillSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"

UIBarButtonItem *findAutoFillBarButtonItemForField(DPTextField *textField);

SPEC_BEGIN(DPTextFieldAutoFillSpecs)

describe(@"DPTextField auto fill", ^{
	__block DPTextField *field;
    beforeEach(^{
        field = [[DPTextField alloc] init];
    });

    context(@"without a data source", ^{
        beforeEach(^{
            [field setAutoFillDataSource:nil];
        });

        it(@"should not show the autofill button", ^{
            [findAutoFillBarButtonItemForField(field) shouldBeNil];
            [[@([field autoFillBarButtonHidden]) should] beYes];
            [[@([field autoFillBarButtonEnabled]) should] beNo];
        });

        it(@"should not allow the autofill button to be shown", ^{
            [field setAutoFillBarButtonHidden:NO];
            [[@([field autoFillBarButtonHidden]) should] beYes];
        });

        it(@"should not allow the autofill button to be enabled", ^{
            [field setAutoFillBarButtonEnabled:YES];
            [[@([field autoFillBarButtonEnabled]) should] beNo];
        });
    });
});

SPEC_END

UIBarButtonItem *findAutoFillBarButtonItemForField(DPTextField *textField) {
    UIBarButtonItem *item = nil;
    for (UIBarButtonItem *barItem in [(UIToolbar *)[textField inputAccessoryView] items]) {
        if ([barItem target] == textField && [NSStringFromSelector([barItem action]) isEqualToString:NSStringFromSelector(@selector(autoFill:))]) {
            item = barItem;
            break;
        }
    }
    return item;
}
