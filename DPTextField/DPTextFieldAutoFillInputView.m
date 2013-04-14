//
//  DPTextFieldAutoFillInputView.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPTextFieldAutoFillInputView.h"
#import "DPTextField.h"

@implementation DPTextFieldAutoFillInputView

- (void)presentForTextField:(DPTextField *)textField {
    [textField setInputView:self];
    [textField reloadInputViews];

    //* - TEST CODE START
#warning Active test code
#pragma mark - Test code
    {
        [self setBackgroundColor:[UIColor blueColor]];
    }
    // TEST CODE END */
}

@end
