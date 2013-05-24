//
//  DPViewController.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/24/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPViewController.h"
#import "DPTextField.h"

@interface DPViewController () <DPTextFieldAutoFillDataSource>
@property (strong, readonly, nonatomic) NSMutableArray *autoFillStrings;

@property (weak, nonatomic) IBOutlet DPTextField *field1;
@property (weak, nonatomic) IBOutlet DPTextField *field2;
@property (weak, nonatomic) IBOutlet DPTextField *field3;
@property (weak, nonatomic) IBOutlet DPTextField *field4;
@end

@implementation DPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.field1 setDoneBarButtonHidden:YES];
//    [self.field2 setDoneBarButtonEnabled:NO];
//    [self.field3 setInputAccessoryViewHidden:YES];

    [self.field1 setTextFieldShouldReturnAfterAutoFill:YES];
    [self.field2 setTextFieldShouldReturnAfterAutoFill:YES];
    [self.field3 setTextFieldShouldReturnAfterAutoFill:YES];
    [self.field4 setTextFieldShouldReturnAfterAutoFill:YES];

    [self.field1 setTextFieldShouldSelectAllTextWhenBecomingFirstResponder:YES];
    [self.field2 setTextFieldShouldSelectAllTextWhenBecomingFirstResponder:NO];
    [self.field3 setTextFieldShouldSelectAllTextWhenBecomingFirstResponder:YES];
    [self.field4 setTextFieldShouldSelectAllTextWhenBecomingFirstResponder:YES];

    [self.field2 setMaximumLength:4];
}

#pragma mark - DPTextFieldAutoFillDataSource

- (NSArray *)allAvailableAutoFillStrings {
    if (nil == _autoFillStrings) {
        _autoFillStrings = [NSMutableArray arrayWithArray:@[
                            @"Zero", @"One",
                            @"Two", @"Twenty",
                            @"Three", @"Thirty",
                            @"Four", @"Forty",
                            @"Five", @"Fifty",
                            @"Six", @"Sixty",
                            @"Seven", @"Seventy",
                            @"Eight", @"Eighty",
                            @"Nine", @"Ninety",
                            @"Ten", @"One hundred",
                            @"One thousand", @"Ten thousand" ]];
    }
    return _autoFillStrings;
}

// Return all appropriate auto-fill strings for the given string.
- (NSArray *)textField:(DPTextField *)textField autoFillStringsForString:(NSString *)string {
    NSArray *autoFillStrings = [self allAvailableAutoFillStrings];    // Read from some serialized source

    NSMutableArray *matches = [NSMutableArray array];

    // Pre-sort the autoFillStrings array.
    NSArray *sortedAutoFillStrings = [autoFillStrings sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // If the search string is nil or empty, just return all auto-fill strings.
    if (nil != string && [string length] > 0) {
        // Match the given string.

        // First pass, find strings with a matching prefix.
        for (NSString *possibleMatch in sortedAutoFillStrings) {
            NSRange range = [possibleMatch rangeOfString:string options:NSCaseInsensitiveSearch];
            if (0 == range.location) {
                [matches addObject:possibleMatch];
            }
        }

        // Second pass, find strings that contain string.
        for (NSString *possibleMatch in sortedAutoFillStrings) {
            NSRange range = [possibleMatch rangeOfString:string options:NSCaseInsensitiveSearch];
            if (NSNotFound != range.location) {
                [matches addObject:possibleMatch];
            }
        }
    } else {
        // Return all available autoFillStrings.
        [matches addObjectsFromArray:sortedAutoFillStrings];
    }
    return matches;
}

- (NSUInteger)minimumLengthForAutoFillQueryForTextField:(DPTextField *)textField {
    if (self.field1 == textField) {
        return 2;
    }
    return 0;
}

- (BOOL)textField:(DPTextField *)textField canRemoveAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath {
    return (!([string isEqualToString:@"Eight"]) &&
            !([string isEqualToString:@"Eighty"]) &&
            !([string isEqualToString:@"Zero"]));
}

- (void)textField:(DPTextField *)textField removeAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath {
    [[self autoFillStrings] removeObject:string];
}

@end
