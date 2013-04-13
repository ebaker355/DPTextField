//
//  DPTextFieldDelegateSpecs.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "DPTextField.h"

SPEC_BEGIN(DPTextFieldDelegateSpecs)

describe(@"A DPTextField's delegate", ^{
	__block DPTextField *field;
    beforeEach(^{
        field = [[DPTextField alloc] init];
    });

    it(@"should set its own internal delegate", ^{
        id delegate = [field delegate];
        [delegate shouldNotBeNil];
        [[NSStringFromClass([delegate class]) should] equal:@"DPTextFieldInternalDelegate"];
    });

    it(@"should wrap delegates set externally", ^{
        id delegateMock = [KWMock mockForProtocol:@protocol(UITextFieldDelegate)];
        [field setDelegate:delegateMock];
        id customDelegate = [field customDelegate];
        [[customDelegate should] beIdenticalTo:delegateMock];
    });
});

SPEC_END
