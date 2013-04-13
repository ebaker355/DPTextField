//
//  DPTextFieldSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"
#import <objc/runtime.h>

SPEC_BEGIN(DPTextFieldSpecs)

describe(@"A DPTextField", ^{
    __block DPTextField *field;
    beforeEach(^{
        field = [[DPTextField alloc] init];
    });

    it(@"should use correct default settings", ^{
        [[@([field toolbarHidden]) should] beNo];
    });

    it(@"should use a UIToolbar as its inputAccessoryView", ^{
        [[@([field toolbarHidden]) should] beNo];
        [[field toolbar] shouldNotBeNil];
        [[field inputAccessoryView] shouldNotBeNil];
        [[[field toolbar] should] beIdenticalTo:[field inputAccessoryView]];
        [[[field toolbar] should] beKindOfClass:[UIToolbar class]];
    });

    it(@"should be able to show and hide the toolbar", ^{
        [[@([field toolbarHidden]) should] beNo];
        [[field toolbar] shouldNotBeNil];

        [field setToolbarHidden:YES];
        [[field toolbar] shouldBeNil];

        [field setToolbarHidden:NO];
        [[field toolbar] shouldNotBeNil];
    });

    it(@"should style the toolbar to match the keyboard", ^{
        [field setToolbarHidden:YES];
        [field setKeyboardAppearance:UIKeyboardAppearanceDefault];
        [field setToolbarHidden:NO];
        [[@([[field toolbar] barStyle]) should] equal:@(UIBarStyleDefault)];

        [field setToolbarHidden:YES];
        [field setKeyboardAppearance:UIKeyboardAppearanceAlert];
        [field setToolbarHidden:NO];
        [[@([[field toolbar] barStyle]) should] equal:@(UIBarStyleBlackTranslucent)];
    });

    context(@"with a previous and next field", ^{
        __block DPTextField *previousField, *nextField;
        beforeEach(^{
            previousField = [[DPTextField alloc] init];
            nextField = [[DPTextField alloc] init];
            [field setPreviousField:previousField];
            [field setNextField:nextField];
        });

        it(@"should include a Previous|Next segmented control in the toolbar", ^{
            BOOL foundPrevNextButtons = NO;
            for (UIBarButtonItem *item in [[field toolbar] items]) {
                // Look for bar button items with a UISegmentedControl as their custom view.
                if ([[item customView] isKindOfClass:[UISegmentedControl class]]) {
                    UISegmentedControl *segControl = (UISegmentedControl *)[item customView];
                    // Our segControl should have 2 segments.
                    if (2 == [segControl numberOfSegments]) {
                        // Our segControl should be wired to the proper selector.
                        NSArray *actions = [segControl actionsForTarget:field forControlEvent:UIControlEventValueChanged];
                        if ([actions containsObject:NSStringFromSelector(@selector(makePreviousOrNextFieldFirstResponder:))]) {
                            foundPrevNextButtons = YES;
                        }
                    }
                }
            }

            [[@(foundPrevNextButtons) should] beYes];
        });
    });
});

SPEC_END
