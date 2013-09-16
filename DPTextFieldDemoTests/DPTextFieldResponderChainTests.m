//
//  DPTextFieldResponderChainTests.m
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/15/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

@import XCTest;
#import "OCMock.h"

#import "DPTextField.h"

@interface DPTextFieldResponderChainTests : XCTestCase
@property (strong, nonatomic) DPTextField *sut;
@property (strong, nonatomic) DPTextField *previousField;
@property (strong, nonatomic) DPTextField *nextField;
@end

@implementation DPTextFieldResponderChainTests

- (void)setUp
{
    [super setUp];
    self.sut = [[DPTextField alloc] initWithFrame:CGRectZero];
    self.previousField = [[DPTextField alloc] initWithFrame:CGRectZero];
    self.nextField = [[DPTextField alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
    self.nextField = nil;
    self.previousField = nil;
    self.sut = nil;
    [super tearDown];
}

#pragma mark - Previous field

- (void)testDoesNotMakePreviousFieldFirstResponderWhenNil {
    self.sut.previousField = nil;
    XCTAssertFalse([self.sut canMakePreviousFieldBecomeFirstResponder], @"Should not be allowed to make previous field first responder when the previousField property is nil.");
    XCTAssertFalse([self.sut makePreviousFieldBecomeFirstResponder], @"Should not make previous field first responder when the previousField property is nil.");
}

- (void)testDoesNotMakePreviousFieldFirstResponderWhenCannotResignFirstResponder {
    [self.sut setPreviousField:self.previousField];

    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut stub] andReturnValue:@NO] canResignFirstResponder];

    XCTAssertFalse([mockSut canMakePreviousFieldBecomeFirstResponder], @"Should not be allowed to make previous field first responder when cannot resign first responder.");
    XCTAssertFalse([mockSut makePreviousFieldBecomeFirstResponder], @"Should not make previous field first responder when cannot resign first responder.");
}

- (void)testDoesNotMakePreviousFieldFirstResponderWhenPreviousFieldCannotBecomeFirstResponder {
    id mockPreviousField = [OCMockObject partialMockForObject:self.previousField];
    [self.sut setPreviousField:mockPreviousField];

    [[[mockPreviousField expect] andReturnValue:@NO] canBecomeFirstResponder];
    XCTAssertFalse([self.sut canMakePreviousFieldBecomeFirstResponder], @"Should not be allowed to make previous field first responder when the previous field cannot become first responder.");
    XCTAssertNoThrow([mockPreviousField verify], "Previous field should have been asked if it can become first responder.");

    [[[mockPreviousField expect] andReturnValue:@NO] canBecomeFirstResponder];
    XCTAssertFalse([self.sut makePreviousFieldBecomeFirstResponder], @"Should not make previous field first responder when the previous field cannot become first responder.");
    XCTAssertNoThrow([mockPreviousField verify], "Previous field should have been asked if it can become first responder.");
}

- (void)testCanMakePreviousFieldFirstResponder {
    id mockPreviousField = [OCMockObject partialMockForObject:self.previousField];
    [[[mockPreviousField stub] andReturnValue:@YES] canBecomeFirstResponder];

    [self.sut setPreviousField:mockPreviousField];

    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut stub] andReturnValue:@YES] canResignFirstResponder];

    XCTAssertTrue([mockSut canMakePreviousFieldBecomeFirstResponder], @"Should be allowed to make previous field first responder.");
}

- (void)testDoesMakePreviousFieldFirstResponder {
    id mockPreviousField = [OCMockObject partialMockForObject:self.previousField];
    [[[mockPreviousField stub] andReturnValue:@YES] canBecomeFirstResponder];
    [[[mockPreviousField expect] andReturnValue:@YES] becomeFirstResponder];

    [self.sut setPreviousField:mockPreviousField];

    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut stub] andReturnValue:@YES] canResignFirstResponder];

    XCTAssertTrue([mockSut makePreviousFieldBecomeFirstResponder], @"Should make previous field first responder.");
    XCTAssertNoThrow([mockPreviousField verify], @"Previous field should become first responder.");
}

#pragma mark - Next field

- (void)testDoesNotMakeNextFieldFirstResponderWhenNil {
    self.sut.nextField = nil;
    XCTAssertFalse([self.sut canMakeNextFieldBecomeFirstResponder], @"Should not be allowed to make next field first responder when the nextField property is nil.");
    XCTAssertFalse([self.sut makeNextFieldBecomeFirstResponder], @"Should not make next field first responder when the nextField property is nil.");
}

- (void)testDoesNotMakeNextFieldFirstResponderWhenCannotResignFirstResponder {
    [self.sut setNextField:self.nextField];

    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut stub] andReturnValue:@NO] canResignFirstResponder];

    XCTAssertFalse([mockSut canMakeNextFieldBecomeFirstResponder], @"Should not be allowed to make next field first responder when cannot resign first responder.");
    XCTAssertFalse([mockSut makeNextFieldBecomeFirstResponder], @"Should not make next field first responder when cannot resign first responder.");
}

- (void)testDoesNotMakeNextFieldFirstResponderWhenNextFieldCannotBecomeFirstResponder {
    id mockNextField = [OCMockObject partialMockForObject:self.nextField];
    [self.sut setNextField:mockNextField];

    [[[mockNextField expect] andReturnValue:@NO] canBecomeFirstResponder];
    XCTAssertFalse([self.sut canMakeNextFieldBecomeFirstResponder], @"Should not be allowed to make next field first responder when the next field cannot become first responder.");
    XCTAssertNoThrow([mockNextField verify], @"Next field should have been asked if it can become first responder.");

    [[[mockNextField expect] andReturnValue:@NO] canBecomeFirstResponder];
    XCTAssertFalse([self.sut makeNextFieldBecomeFirstResponder], @"Should not make next field first responder when the next field cannot become first responder.");
    XCTAssertNoThrow([mockNextField verify], @"Next field should have been asked if it can become first responder.");
}

- (void)testCanMakeNextFieldFirstResponder {
    id mockNextField = [OCMockObject partialMockForObject:self.nextField];
    [[[mockNextField stub] andReturnValue:@YES] canBecomeFirstResponder];

    [self.sut setNextField:mockNextField];

    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut stub] andReturnValue:@YES] canResignFirstResponder];

    XCTAssertTrue([mockSut canMakeNextFieldBecomeFirstResponder], @"Should be allowed to make next field first responder.");
}

- (void)testDoesMakeNextFieldFirstResponder {
    id mockNextField = [OCMockObject partialMockForObject:self.nextField];
    [[[mockNextField stub] andReturnValue:@YES] canBecomeFirstResponder];
    [[[mockNextField expect] andReturnValue:@YES] becomeFirstResponder];

    [self.sut setNextField:mockNextField];

    id mockSut = [OCMockObject partialMockForObject:self.sut];
    [[[mockSut stub] andReturnValue:@YES] canResignFirstResponder];

    XCTAssertTrue([mockSut makeNextFieldBecomeFirstResponder], @"Should make next field first responder.");
    XCTAssertNoThrow([mockNextField verify], @"Next field should become first responder.");
}

- (void)testSelectsAllTextWhenBecomingFirstResponderIfShould {
    [self.sut setText:@"foobar"];
    [self.sut becomeFirstResponder];
    UITextRange *range = [self.sut selectedTextRange];
    XCTAssertEqualObjects(range.start, self.sut.beginningOfDocument, @"Selection range should be at start of text.");
    XCTAssertEqualObjects(range.end, self.sut.endOfDocument, @"Selection range should be at end of text.");
}

@end
