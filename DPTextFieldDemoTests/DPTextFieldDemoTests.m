//
//  DPTextFieldDemoTests.m
//  DPTextFieldDemoTests
//
//  Created by Eric D. Baker on 9/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

@import XCTest;
#import "DPTextField.h"

@interface DPTextFieldDemoTests : XCTestCase
@end

@implementation DPTextFieldDemoTests {
    DPTextField *sut;
}

- (void)setUp {
    [super setUp];
    sut = [[DPTextField alloc] initWithFrame:CGRectZero];
}

- (void)tearDown {
    sut = nil;
    [super tearDown];
}

- (void)testIsSubclassOfUITextField {
    XCTAssertTrue([[DPTextField class] isSubclassOfClass:[UITextField class]], @"DPTextField should subclass UITextField");
}

- (void)testHasAPreviousFieldProperty {
    XCTAssertTrue([sut respondsToSelector:@selector(previousField)], @"DPTextField should have a readable previousField property");
    XCTAssertTrue([sut respondsToSelector:@selector(setPreviousField:)], @"DPTextField should have a settable previousField property");
}

- (void)testHasANextFieldProperty {
    XCTAssertTrue([sut respondsToSelector:@selector(nextField)], @"DPTextField should have a readable nextField property");
    XCTAssertTrue([sut respondsToSelector:@selector(setNextField:)], @"DPTextField should have a settable nextField property");
}

@end
