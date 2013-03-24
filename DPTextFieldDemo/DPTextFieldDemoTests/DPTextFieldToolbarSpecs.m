//
//  DPTextFieldToolbarSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextFieldToolbar.h"
#import "DPMockTextFieldToolbar.h"

SPEC_BEGIN(DPTextFieldToolbarSpecs)

describe(@"DPTextFieldToolbar", ^{
    context(@"class", ^{
        it(@"should subclass UIToolbar", ^{
            [[[DPTextFieldToolbar class] should] beSubclassOfClass:[UIToolbar class]];
        });
    });

    __block DPMockTextFieldToolbar *mockToolbar;

    beforeEach(^{
        mockToolbar = [[DPMockTextFieldToolbar alloc] init];
    });

    it(@"should size to fit when the keyboard frame changes", ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidChangeFrameNotification object:nil userInfo:nil];
        [[@([mockToolbar calledSizeToFit]) should] beYes];
    });
});

SPEC_END
