//
//  DPTextField.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPTextField.h"

@implementation DPTextField

- (id)init {
    self = [super init];
    if (self) {
        [self customizeControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customizeControl];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customizeControl];
    }
    return self;
}

- (void)customizeControl {
    _toolbar = [[DPTextFieldToolbar alloc] init];
    [self setInputAccessoryView:_toolbar];

    UISegmentedControl *prevNextControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Previous", @"Previous"), NSLocalizedString(@"Next", @"Next")]];
    [prevNextControl setMomentary:YES];
    [prevNextControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [prevNextControl setEnabled:NO forSegmentAtIndex:0];
    [prevNextControl setEnabled:NO forSegmentAtIndex:1];
    _previousNextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:prevNextControl];

    _doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

- (void)setPreviousField:(UIResponder *)previousField {
    _previousField = previousField;
    UISegmentedControl *prevNextControl = (UISegmentedControl *)[self.previousNextBarButtonItem customView];
    [prevNextControl setEnabled:(nil != previousField) forSegmentAtIndex:0];
}

- (void)setNextField:(UIResponder *)nextField {
    _nextField = nextField;
    UISegmentedControl *prevNextControl = (UISegmentedControl *)[self.previousNextBarButtonItem customView];
    [prevNextControl setEnabled:(nil != nextField) forSegmentAtIndex:1];
}

- (void)done:(id)sender {
    
}

@end
