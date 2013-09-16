//
//  DPTextFieldTests.m
//  DPTextFieldTests
//
//  Created by Eric D. Baker on 9/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

@import XCTest;
#import "OCMock.h"

#import "DPTextField.h"

@interface DPTextFieldTests : XCTestCase
@property (strong, nonatomic) DPTextField *sut;
@end

@implementation DPTextFieldTests

- (void)setUp {
    [super setUp];
    self.sut = [[DPTextField alloc] initWithFrame:CGRectZero];
}

- (void)tearDown {
    self.sut = nil;
    [super tearDown];
}

- (void)testIsSubclassOfUITextField {
    XCTAssertTrue([[DPTextField class] isSubclassOfClass:[UITextField class]], @"DPTextField should subclass UITextField.");
}

- (void)testHasAPreviousFieldProperty {
    XCTAssertTrue([self.sut respondsToSelector:@selector(previousField)], @"DPTextField should have a readable previousField property.");
    XCTAssertTrue([self.sut respondsToSelector:@selector(setPreviousField:)], @"DPTextField should have a settable previousField property.");
}

- (void)testHasANextFieldProperty {
    XCTAssertTrue([self.sut respondsToSelector:@selector(nextField)], @"DPTextField should have a readable nextField property.");
    XCTAssertTrue([self.sut respondsToSelector:@selector(setNextField:)], @"DPTextField should have a settable nextField property.");
}

- (void)testHasMaximumTextLengthProperty {
    XCTAssertTrue([self.sut respondsToSelector:@selector(maximumTextLength)], @"DPTextField should have a readable maximumTextLength property.");
    XCTAssertTrue([self.sut respondsToSelector:@selector(setMaximumTextLength:)], @"DPTextField should have a settable maximumTextLength property.");
}

@end
