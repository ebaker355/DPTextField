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

typedef void(^DPTextFieldDidEndEditing)(DPTextField *textField);

typedef BOOL(^DPTextFieldShouldBeginEditing)(DPTextField *textField);

typedef BOOL(^DPTextFieldShouldClear)(DPTextField *textField);

typedef BOOL(^DPTextFieldShouldEndEditing)(DPTextField *textField);

typedef BOOL(^DPTextFieldShouldReturn)(DPTextField *textField);

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
@property (copy, nonatomic) DPTextFieldDidBeginEditing didBeginEditing;

/**
 Setter for block version of textFieldDidBeginEditing: for autocompletion.
 
 @param didBeginEditingBlock The block.
 */
- (void)setDidBeginEditing:(DPTextFieldDidBeginEditing)didBeginEditingBlock;

/**
 Block version of UITextFieldDelegate protocol method textFieldDidEndEditing:
 */
@property (copy, nonatomic) DPTextFieldDidEndEditing didEndEditing;

/**
 Setter for block version of textFieldDidEndEditing: for autocompletion.

 @param didEndEditingBlock The block.
 */
- (void)setDidEndEditing:(DPTextFieldDidEndEditing)didEndEditingBlock;

/**
 Block version of UITextFieldDelegate protocol method textFieldShouldBeginEditing:
 */
@property (copy, nonatomic) DPTextFieldShouldBeginEditing shouldBeginEditing;

/**
 Setter for block version of textFieldShouldBeginEditing: for autocompletion.

 @param shouldBeginEditingBlock The block.
 */
- (void)setShouldBeginEditing:(DPTextFieldShouldBeginEditing)shouldBeginEditingBlock;

/**
 Block version of UITextFieldDelegate protocol method textFieldShouldClear:
 */
@property (copy, nonatomic) DPTextFieldShouldClear shouldClear;

/**
 Setter for block version of textFieldShouldClear: for autocompletion.

 @param shouldClearBlock The block.
 */
- (void)setShouldClear:(DPTextFieldShouldClear)shouldClearBlock;

/**
 Block version of UITextFieldDelegate protocol method textFieldShouldEndEditing:
 */
@property (copy, nonatomic) DPTextFieldShouldEndEditing shouldEndEditing;

/**
 Setter for block version of textFieldShouldEndEditing: for autocompletion.

 @param shouldEndEditingBlock The block.
 */
- (void)setShouldEndEditing:(DPTextFieldShouldEndEditing)shouldEndEditingBlock;

/**
 Block version of UITextFieldDelegate protocol method textFieldShouldReturn:
 */
@property (copy, nonatomic) DPTextFieldShouldReturn shouldReturn;

/**
 Setter for block version of textFieldShouldReturn: for autocompletion.

 @param shouldReturnBlock The block.
 */
- (void)setShouldReturn:(DPTextFieldShouldReturn)shouldReturnBlock;

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

/**
 Gets or sets the maximum number of characters allowed in the field's text property.
 */
@property (assign, nonatomic) NSUInteger maximumTextLength;

/**
 Gets or sets whether the text field's text should be automatically selected when the field becomes
 the first responder.
 */
@property (assign, nonatomic) BOOL shouldSelectAllTextWhenBecomingFirstResponder;

@end
