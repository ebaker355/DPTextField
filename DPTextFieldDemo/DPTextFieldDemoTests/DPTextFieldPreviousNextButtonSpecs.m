//
//  DPTextFieldPreviousNextButtonSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"

SPEC_BEGIN(DPTextFieldPreviousNextButtonSpecs)

describe(@"The previous and next toolbar buttons", ^{
    __block DPTextField *field;
    __block DPTextField *previousField, *nextField;
    __block UISegmentedControl *segControl;
    __block NSUInteger prevSegIndex, nextSegIndex;

    beforeEach(^{
        field = [[DPTextField alloc] init];
        previousField = [[DPTextField alloc] init];
        nextField = [[DPTextField alloc] init];
        segControl = nil;
        prevSegIndex = 0;
        nextSegIndex = 1;
    });

    context(@"when a text field has no siblings", ^{
        it(@"should not appear in the toolbar", ^{
            // Ensure field has no siblings.
            [field.previousField shouldBeNil];
            [field.nextField shouldBeNil];

            // The previous and next buttons should not be instantiated.
            [field.previousNextBarButtonItem shouldBeNil];
        });
    });

    context(@"when a text field has a previous field, but no next field", ^{
        beforeEach(^{
            [field setPreviousField:previousField];
            [field setNextField:nil];
        });

        it(@"should appear in the toolbar", ^{
            [field.previousNextBarButtonItem shouldNotBeNil];
        });

        it(@"should enable the previous button", ^{
            segControl = (UISegmentedControl *)[field.previousNextBarButtonItem customView];
            [[@([segControl isEnabledForSegmentAtIndex:prevSegIndex]) should] beYes];
        });

        it(@"should disable the next button", ^{
            segControl = (UISegmentedControl *)[field.previousNextBarButtonItem customView];
            [[@([segControl isEnabledForSegmentAtIndex:nextSegIndex]) should] beNo];
        });
    });

    context(@"when a text field has a next field, but no previous field", ^{
        beforeEach(^{
            [field setPreviousField:nil];
            [field setNextField:nextField];
        });

        it(@"should appear in the toolbar", ^{
            [field.previousNextBarButtonItem shouldNotBeNil];
        });

        it(@"should enable the next button", ^{
            segControl = (UISegmentedControl *)[field.previousNextBarButtonItem customView];
            [[@([segControl isEnabledForSegmentAtIndex:nextSegIndex]) should] beYes];
        });

        it(@"should disable the previous button", ^{
            segControl = (UISegmentedControl *)[field.previousNextBarButtonItem customView];
            [[@([segControl isEnabledForSegmentAtIndex:prevSegIndex]) should] beNo];
        });
    });

    context(@"when a text field has both a previous field and a next field", ^{
        beforeEach(^{
            [field setPreviousField:previousField];
            [field setNextField:nextField];
            segControl = (UISegmentedControl *)[field.previousNextBarButtonItem customView];
        });

        it(@"should appear in the toolbar", ^{
            [field.previousNextBarButtonItem shouldNotBeNil];
        });

        it(@"should enable the next button", ^{
            [[@([segControl isEnabledForSegmentAtIndex:nextSegIndex]) should] beYes];
        });

        it(@"should enable the previous button", ^{
            [[@([segControl isEnabledForSegmentAtIndex:prevSegIndex]) should] beYes];
        });

        it(@"should keep the previousBarButtonEnabled property updated", ^{
            [segControl setEnabled:YES forSegmentAtIndex:prevSegIndex];
            [[@(field.previousBarButtonEnabled) should] equal:@([segControl isEnabledForSegmentAtIndex:prevSegIndex])];

            [segControl setEnabled:NO forSegmentAtIndex:prevSegIndex];
            [[@(field.previousBarButtonEnabled) should] equal:@([segControl isEnabledForSegmentAtIndex:prevSegIndex])];

            [field setPreviousBarButtonEnabled:NO];
            [[@([segControl isEnabledForSegmentAtIndex:prevSegIndex]) should] equal:@([field previousBarButtonEnabled])];

            [field setPreviousBarButtonEnabled:YES];
            [[@([segControl isEnabledForSegmentAtIndex:prevSegIndex]) should] equal:@([field previousBarButtonEnabled])];
        });

        it(@"should keep the nextBarButtonEnabled property updated", ^{
            [segControl setEnabled:YES forSegmentAtIndex:nextSegIndex];
            [[@(field.nextBarButtonEnabled) should] equal:@([segControl isEnabledForSegmentAtIndex:nextSegIndex])];

            [segControl setEnabled:NO forSegmentAtIndex:prevSegIndex];
            [[@(field.nextBarButtonEnabled) should] equal:@([segControl isEnabledForSegmentAtIndex:nextSegIndex])];

            [field setNextBarButtonEnabled:NO];
            [[@([segControl isEnabledForSegmentAtIndex:nextSegIndex]) should] equal:@([field nextBarButtonEnabled])];

            [field setNextBarButtonEnabled:YES];
            [[@([segControl isEnabledForSegmentAtIndex:nextSegIndex]) should] equal:@([field nextBarButtonEnabled])];
        });

        context(@"when the previous button is tapped", ^{
            it(@"should make the previous field the first responder", ^{
                [[previousField should] receive:@selector(canBecomeFirstResponder) andReturn:@YES];
                [[previousField should] receive:@selector(becomeFirstResponder) andReturn:@YES];

                // Trigger "tap" on previous button.
                [segControl setSelectedSegmentIndex:prevSegIndex];
                [segControl sendActionsForControlEvents:UIControlEventValueChanged];
            });
        });

        context(@"when the next button is tapped", ^{
            it(@"should make the next field the first responder", ^{
                [[nextField should] receive:@selector(canBecomeFirstResponder) andReturn:@YES];
                [[nextField should] receive:@selector(becomeFirstResponder) andReturn:@YES];

                // Trigger "tap" on next button.
                [segControl setSelectedSegmentIndex:nextSegIndex];
                [segControl sendActionsForControlEvents:UIControlEventValueChanged];
            });
        });
    });
});

SPEC_END
