//
//  DPTextFieldSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"
#import "DPTextFieldToolbar.h"

SPEC_BEGIN(DPTextFieldSpecs)

describe(@"DPTextField", ^{
    context(@"class", ^{
        it(@"should subclass UITextField", ^{
            [[[DPTextField class] should] beSubclassOfClass:[UITextField class]];
        });
    });

    __block DPTextField *textField;
    __block DPTextField *prevTextField;
    __block DPTextField *nextTextField;

    beforeEach(^{
        textField = [[DPTextField alloc] init];
        prevTextField = [[DPTextField alloc] init];
        nextTextField = [[DPTextField alloc] init];
    });

#pragma mark - Toolbar tests

    it(@"should have a readonly toolbar property", ^{
        [[textField should] respondToSelector:@selector(toolbar)];
        [[textField shouldNot] respondToSelector:@selector(setToolbar:)];
    });

    it(@"should instantiate the toolbar when inited", ^{
        [[textField toolbar] shouldNotBeNil];
    });

    it(@"should use a DPTextFieldToolbar", ^{
        [[[textField toolbar] should] beKindOfClass:[DPTextFieldToolbar class]];
    });

    it(@"should set the toolbar as its inputAccessoryView", ^{
        [[[textField inputAccessoryView] should] beIdenticalTo:[textField toolbar]];
    });

    it(@"should have a readonly previousNextBarButtonItem property", ^{
        [[textField should] respondToSelector:@selector(previousNextBarButtonItem)];
        [[textField shouldNot] respondToSelector:@selector(setPreviousNextBarButtonItem:)];
    });

    it(@"should instantiate the previousNextBarButtonItem when inited", ^{
        [[textField previousNextBarButtonItem] shouldNotBeNil];
    });

    it(@"should use a UISegmentedControl with 2 segments for the previousNextBarButtonItem custom view", ^{
        [[[[textField previousNextBarButtonItem] customView] should] beKindOfClass:[UISegmentedControl class]];
        [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] numberOfSegments]) should] equal:@2];
    });

    it(@"should disable the previous and next buttons by default", ^{
        [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:0]) should] beNo];
        [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:1]) should] beNo];
    });

    it(@"should have a readonly doneBarButtonItem property", ^{
        [[textField should] respondToSelector:@selector(doneBarButtonItem)];
        [[textField shouldNot] respondToSelector:@selector(setDoneBarButtonItem:)];
    });

    it(@"should instantiate the doneBarButtonItem when inited", ^{
        [[textField doneBarButtonItem] shouldNotBeNil];
    });

#pragma mark - Previous and Next field tests

    it(@"should have a previousField property", ^{
        [[textField should] respondToSelector:@selector(previousField)];
        [[textField should] respondToSelector:@selector(setPreviousField:)];
    });

    it(@"should have a nextField property", ^{
        [[textField should] respondToSelector:@selector(nextField)];
        [[textField should] respondToSelector:@selector(setNextField:)];
    });

    context(@"with only a previous field assigned", ^{

        beforeEach(^{
            [textField setPreviousField:prevTextField];
        });

        it(@"should have the previousField property set correctly", ^{
            [[[textField previousField] should] beIdenticalTo:prevTextField];
            [[textField nextField] shouldBeNil];
        });

        it(@"should enable the previous button, and disable the next button", ^{
            [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:0]) should] beYes];
            [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:1]) should] beNo];
        });
    });

    context(@"with only a next field assigned", ^{

        beforeEach(^{
            [textField setNextField:nextTextField];
        });

        it(@"should have the nextField property set correctly", ^{
            [[[textField nextField] should] beIdenticalTo:nextTextField];
            [[textField previousField] shouldBeNil];
        });

        it(@"should disable the previous button, and enable the next button", ^{
            [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:0]) should] beNo];
            [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:1]) should] beYes];
        });
    });

    context(@"with a previous field and a next field assigned", ^{

        beforeEach(^{
            [textField setPreviousField:prevTextField];
            [textField setNextField:nextTextField];
        });

        it(@"should enable the previous button and the next button", ^{
            [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:0]) should] beYes];
            [[@([(UISegmentedControl *)[[textField previousNextBarButtonItem] customView] isEnabledForSegmentAtIndex:1]) should] beYes];
        });
    });
});

SPEC_END
