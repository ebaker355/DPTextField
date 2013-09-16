//
//  DPTextField.h
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/12/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

@import UIKit;

@class DPTextField;

typedef BOOL(^DPTextField_ShouldChangeCharactersInRange_ReplacementString)(DPTextField *textField, NSRange range, NSString *string);

typedef void(^DPTextFieldDidBeginEditing)(DPTextField *textField);

/**
 UITextField subclass that adds extra functionality. If you're using Interface Builder, set the text field control's class to this class.
 */
@interface DPTextField : UITextField

/**
 The custom delegate set for the text field.
 Since DPTextField uses a custom internal delegate, a custom delegate cannot be accessed
 via the delegate property; use this property instead. You still use setDelegate: to set
 this delegate.
 
 Note: Consider using DPTextField's block methods, instead of a delegate.
 */
@property (readonly, nonatomic) id<UITextFieldDelegate> customDelegate;

/**
 Block version of UITextFieldDelegate protocol method textField:shouldChangeCharactersInRange:replacementString:
 */
@property (copy, nonatomic) DPTextField_ShouldChangeCharactersInRange_ReplacementString shouldChangeCharactersInRange_ReplacementString_Block;

/**
 Setter for block version of textField:shouldChangeCharactersInRange:replacementString:
 for autocompletion.
 
 @param shouldChangeCharactersInRange_ReplacementString_Block The block.
 */
- (void)setShouldChangeCharactersInRange_ReplacementString_Block:(DPTextField_ShouldChangeCharactersInRange_ReplacementString)shouldChangeCharactersInRange_ReplacementString_Block;

/**
 Block version of UITextFieldDelegate protocol method textFieldDidBeginEditing:
 */
@property (copy, nonatomic) DPTextFieldDidBeginEditing didBeginEditingBlock;

/**
 Setter for block version of textFieldDidBeginEditing: for autocompletion.
 
 @param didBeginEditingBlock The block.
 */
- (void)setDidBeginEditingBlock:(DPTextFieldDidBeginEditing)didBeginEditingBlock;

/**
 The previous responder in the responder chain.
 When this property is set, the previous bar button item (<) will appear in the field's input accessory toolbar.
 This property may be set in Interface Builder.
 */
@property (weak, nonatomic) IBOutlet UIResponder *previousField;

/**
 The next responder in the responder chain.
 When this property is set, the next bar button item (>) will appear in the field's input accessory toolbar.
 This property may be set in Interface Builder.
 */
@property (weak, nonatomic) IBOutlet UIResponder *nextField;

/**
 Returns YES if the previous field can become the first responder, and the current field can resign being first responder; otherwise returns NO.
 */
- (BOOL)canMakePreviousFieldBecomeFirstResponder;

/**
 Attempts to make the previous field the first responder. Returns YES if successful; otherwise returns NO.
 */
- (BOOL)makePreviousFieldBecomeFirstResponder;

/**
 Returns YES if the next field can become the first responder, and the current field can resign being first responder; otherwise returns NO.
 */
- (BOOL)canMakeNextFieldBecomeFirstResponder;

/**
 Attempts to make the next field the first responder. Returns YES if successful; otherwise returns NO.
 */
- (BOOL)makeNextFieldBecomeFirstResponder;

@end
