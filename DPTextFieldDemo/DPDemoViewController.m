//
//  DPDemoViewController.m
//  DPTextFieldDemo
//
//  Created by Eric D. Baker on 9/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPDemoViewController.h"
#import "DPTextField.h"

@interface DPDemoViewController ()

@property (weak, nonatomic) IBOutlet DPTextField *field1;
@property (weak, nonatomic) IBOutlet DPTextField *field2;
@property (weak, nonatomic) IBOutlet DPTextField *field3;
@property (weak, nonatomic) IBOutlet DPTextField *field4;

@end

@implementation DPDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.field1 setShouldSelectAllTextWhenBecomingFirstResponder:YES];
    [self.field2 setShouldSelectAllTextWhenBecomingFirstResponder:YES];
    [self.field3 setShouldSelectAllTextWhenBecomingFirstResponder:YES];
    [self.field4 setShouldSelectAllTextWhenBecomingFirstResponder:YES];

    [self.field1 setTextDidChange:^(DPTextField *textField) {
        NSLog(@"text changed for field 1: %@", textField.text);
    }];
}
@end
