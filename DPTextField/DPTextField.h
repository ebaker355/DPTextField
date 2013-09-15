//
//  DPTextField.h
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

@import UIKit;

/** UITextField subclass that adds extra functionality. If you're using Interface Builder, set the text field control's class to this class. */
@interface DPTextField : UITextField

/** The previous responder in the responder chain.
 When this property is set, the previous bar button item (<) will appear in the field's input accessory toolbar.
 This property may be set in Interface Builder. */
@property (weak, nonatomic) IBOutlet UIResponder *previousField;

/** The next responder in the responder chain.
 When this property is set, the next bar button item (>) will appear in the field's input accessory toolbar.
 This property may be set in Interface Builder. */
@property (weak, nonatomic) IBOutlet UIResponder *nextField;

/** Returns YES if the previous field can become the first responder, and the current field can resign being first responder; otherwise returns NO. */
- (BOOL)canMakePreviousFieldBecomeFirstResponder;

/** Attempts to make the previous field the first responder. Returns YES if successful; otherwise returns NO. */
- (BOOL)makePreviousFieldBecomeFirstResponder;

/** Returns YES if the next field can become the first responder, and the current field can resign being first responder; otherwise returns NO. */
- (BOOL)canMakeNextFieldBecomeFirstResponder;

/** Attempts to make the next field the first responder. Returns YES if successful; otherwise returns NO. */
- (BOOL)makeNextFieldBecomeFirstResponder;

@end
