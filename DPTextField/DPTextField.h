//
//  DPTextField.h
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPTextFieldToolbar;

@interface DPTextField : UITextField

@property (readonly, nonatomic) UIBarButtonItem *previousNextBarButtonItem;

@property (weak, nonatomic) IBOutlet UIResponder *previousField, *nextField;

@property (readonly, nonatomic) UIToolbar *toolbar;
@property (assign, nonatomic) BOOL toolbarHidden;

@end
