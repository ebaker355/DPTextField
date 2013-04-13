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

@property (weak, nonatomic) IBOutlet UIResponder *previousField, *nextField;

@property (assign, nonatomic) BOOL inputAccessoryViewHidden;
@property (assign, nonatomic) BOOL previousBarButtonEnabled, nextBarButtonEnabled;

@property (assign, nonatomic) BOOL doneBarButtonHidden;
@property (assign, nonatomic) BOOL doneBarButtonEnabled;

@end
