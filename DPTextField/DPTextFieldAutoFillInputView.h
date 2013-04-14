//
//  DPTextFieldAutoFillInputView.h
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPTextField;

@interface DPTextFieldAutoFillInputView : UIView

- (void)presentForTextField:(DPTextField *)textField;
- (void)dismiss;

@end
