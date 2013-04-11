//
//  DPTextField.h
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPTextFieldToolbar.h"

@interface DPTextField : UITextField

@property (readonly, nonatomic) DPTextFieldToolbar *toolbar;
@property (readonly, nonatomic) UIBarButtonItem *previousNextBarButtonItem;
@property (readonly, nonatomic) UIBarButtonItem *doneBarButtonItem;

@property (weak, nonatomic) IBOutlet UIResponder *previousField, *nextField;

@end
