//
//  DPMockTextFieldToolbar.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/23/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPMockTextFieldToolbar.h"

@implementation DPMockTextFieldToolbar

- (void)sizeToFit {
    _calledSizeToFit = YES;
    [super sizeToFit];
}

@end
