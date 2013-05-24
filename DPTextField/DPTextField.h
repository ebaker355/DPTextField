//
//  DPTextField.h
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPTextFieldAutoFillDataSource.h"

@interface DPTextField : UITextField 
@property (readonly, nonatomic) id<UITextFieldDelegate> customDelegate;

@property (assign, nonatomic) BOOL inputAccessoryViewHidden;

@property (weak, nonatomic) IBOutlet UIResponder *previousField, *nextField;
@property (readonly, nonatomic) UIBarButtonItem *previousNextBarButtonItem;
@property (assign, nonatomic) BOOL previousBarButtonEnabled, nextBarButtonEnabled;

@property (assign, nonatomic) IBOutlet id<DPTextFieldAutoFillDataSource> autoFillDataSource;
@property (readonly, nonatomic) UIBarButtonItem *autoFillBarButtonItem;
@property (assign, nonatomic) BOOL autoFillBarButtonHidden;
@property (assign, nonatomic) BOOL autoFillBarButtonEnabled;
@property (assign, nonatomic) BOOL textFieldShouldReturnAfterAutoFill;
@property (assign, nonatomic) BOOL textFieldShouldSelectAllTextWhenBecomingFirstResponder;
@property (assign, nonatomic) CGFloat presentAutoFillAnimationDuration;
@property (assign, nonatomic) CGFloat dismissAutoFillAnimationDuration;

@property (readonly, nonatomic) UIBarButtonItem *doneBarButtonItem;
@property (assign, nonatomic) BOOL doneBarButtonHidden;
@property (assign, nonatomic) BOOL doneBarButtonEnabled;

@property (assign, nonatomic) NSUInteger maximumLength;

@property (assign, nonatomic) BOOL allowSwipeToDismissKeyboard;

- (void)selectAllText;

@end
