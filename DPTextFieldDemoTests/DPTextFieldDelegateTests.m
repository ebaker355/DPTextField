//
//  DPTextFieldDelegateTests.m
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/15/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

@import XCTest;
#import "OCMock.h"

#import "DPTextField.h"

@interface DPTextFieldDelegateTests : XCTestCase
@property (strong, nonatomic) DPTextField *sut;
@end

@implementation DPTextFieldDelegateTests

- (void)setUp
{
    [super setUp];
    self.sut = [[DPTextField alloc] init];
}

- (void)tearDown
{
    self.sut = nil;
    [super tearDown];
}

- (void)testUsesDPTextFieldInternalSharedDelegateWhenInitialized {
    XCTAssertNotNil([self.sut delegate], @"The delegate should not be nil.");

    DPTextField *otherField = [[DPTextField alloc] init];
    XCTAssertEqualObjects(self.sut.delegate, otherField.delegate, @"All DPTextField instances should use the same shared delegate.");

    XCTAssertEqualObjects(NSStringFromClass([self.sut.delegate class]), @"DPTextFieldInternalSharedDelegate", @"DPTextField delegate should be of class DPTextFieldInternalSharedDelegate.");
}

- (void)testCustomDelegatePropertyIsInitiallyNil {
    XCTAssertNil(self.sut.customDelegate, @"The custom delegate should initially be nil.");
}

- (void)testSetDelegateSetsTheCustomDelegate {
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(UITextFieldDelegate)];

    self.sut.delegate = mockDelegate;

    XCTAssertEqualObjects(self.sut.customDelegate, mockDelegate, @"The delegate should be accessible through the customDelegate property.");
    XCTAssertEqualObjects(NSStringFromClass([self.sut.delegate class]), @"DPTextFieldInternalSharedDelegate", @"DPTextField delegate should be of class DPTextFieldInternalSharedDelegate.");
}

- (void)testDPTextFieldInternalSharedDelegateCallsBlockDelegateMethods {
    __block BOOL blockCalled = NO;

    [self.sut setShouldChangeCharactersInRange_ReplacementString_Block:^BOOL(DPTextField *textField, NSRange range, NSString *string) {
        blockCalled = YES;
        return YES;
    }];

    [self.sut.delegate textField:self.sut shouldChangeCharactersInRange:NSMakeRange(0, 1) replacementString:@" "];

    XCTAssertTrue(blockCalled, @"The DPTextField_ShouldChangeCharactersInRange_ReplacementString block should be called.");

    blockCalled = NO;
    [self.sut setDidBeginEditingBlock:^(DPTextField *textField) {
        blockCalled = YES;
    }];

    [self.sut.delegate textFieldDidBeginEditing:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldDidBeginEditing block should be called.");
}

@end
