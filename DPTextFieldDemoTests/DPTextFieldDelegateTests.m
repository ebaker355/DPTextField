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
    [self.sut setDidBeginEditing:^(DPTextField *textField) {
        blockCalled = YES;
    }];

    [self.sut.delegate textFieldDidBeginEditing:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldDidBeginEditing block should be called.");

    blockCalled = NO;
    [self.sut setDidEndEditing:^(DPTextField *textField) {
        blockCalled = YES;
    }];

    [self.sut.delegate textFieldDidEndEditing:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldDidEndEditing block should be called.");

    blockCalled = NO;
    [self.sut setShouldBeginEditing:^BOOL(DPTextField *textField) {
        blockCalled = YES;
        return YES;
    }];

    [self.sut.delegate textFieldShouldBeginEditing:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldShouldBeginEditing block should be called.");

    blockCalled = NO;
    [self.sut setShouldClear:^BOOL(DPTextField *textField) {
        blockCalled = YES;
        return YES;
    }];

    [self.sut.delegate textFieldShouldClear:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldShouldClear block should be called.");

    blockCalled = NO;
    [self.sut setShouldEndEditing:^BOOL(DPTextField *textField) {
        blockCalled = YES;
        return YES;
    }];

    [self.sut.delegate textFieldShouldEndEditing:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldShouldEndEditing block should be called.");

    blockCalled = NO;
    [self.sut setShouldReturn:^BOOL(DPTextField *textField) {
        blockCalled = YES;
        return YES;
    }];

    [self.sut.delegate textFieldShouldReturn:self.sut];

    XCTAssertTrue(blockCalled, @"The DPTextFieldShouldReturn block should be called.");
}

- (void)testDelegateHonorsMaximumTextLengthProperty {
    [self.sut setMaximumTextLength:0];
    XCTAssertTrue([self.sut.delegate textField:self.sut shouldChangeCharactersInRange:NSMakeRange(0, 6) replacementString:@"foobar"], @"The text length should not be restricted when maximumTextLength < 1.");

    [self.sut setMaximumTextLength:3];
    XCTAssertFalse([self.sut.delegate textField:self.sut shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"foobar"], @"The text length should be restricted to maximumTextLength.");
    XCTAssertTrue([self.sut.delegate textField:self.sut shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"foo"], @"The text length should be allowed to be <= maximumTextLength.");
}

- (void)testDelegateMakesNextFieldFirstResponderWhenReturnKeyIsNext {
    id mockField = [OCMockObject niceMockForClass:[DPTextField class]];
    [self.sut setNextField:mockField];

    [[[mockField expect] andReturnValue:@YES] canBecomeFirstResponder];
    [[[mockField expect] andReturnValue:@YES] becomeFirstResponder];

    [self.sut setReturnKeyType:UIReturnKeyNext];
    [self.sut.delegate textFieldShouldReturn:self.sut];

    XCTAssertNoThrow([mockField verify], @"The next field should become the first responder when the current field returns and has a Next type return key..");
}

- (void)testDelegateResignsFirstResponderWhenReturnKeyIsNotNext {
    [self.sut setReturnKeyType:UIReturnKeyDefault];

    id delegate = self.sut.delegate;
    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut expect] andReturnValue:@YES] resignFirstResponder];

    [delegate textFieldShouldReturn:mockSut];

    XCTAssertNoThrow([mockSut verify], @"The field should resign first responder when return key is selected and is not Next.");
}

@end
