//
//  DPTextFieldToolbar.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 3/22/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPTextFieldToolbar.h"

@implementation DPTextFieldToolbar

- (id)init {
    self = [super init];
    if (self) {
        [self configureControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureControl];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureControl];
    }
    return self;
}

- (void)configureControl {
    // On iOS, the toolbar height changes at different device orientations. This
    // observer allows our custom toolbar to be sized properly.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeToFit) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
