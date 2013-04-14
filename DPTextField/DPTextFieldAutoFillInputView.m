//
//  DPTextFieldAutoFillInputView.m
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPTextFieldAutoFillInputView.h"
#import "DPTextField.h"

@interface DPTextField ()
@property (readonly, nonatomic) NSArray *autoFillStrings;
@property (readonly, nonatomic) CGFloat toolbarHeight;
@end

@interface DPTextFieldAutoFillInputView () <UIInputViewAudioFeedback, UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) DPTextField *textField;
@property (strong, nonatomic) UIImageView *keyboardImageView;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation DPTextFieldAutoFillInputView

- (void)presentForTextField:(DPTextField *)textField {
    _textField = textField;
    [self configure];

    // If we were able to find the keyboard window and get the image, then
    // transition in the "cool" way.
    // Otherwise, do it in the "safe" way.
    [self presentSelfAnimated:(nil != [self keyboardImageView])];
}

- (void)dismiss {
    if (nil != [self keyboardImageView]) {
        // See if our frame still matches the keyboard image size.
        BOOL sameSize = CGSizeEqualToSize([[self keyboardImageView] frame].size, [self frame].size);
        [self dismissSelfAnimated:sameSize];
    } else {
        [self dismissSelfAnimated:NO];
    }
}

- (void)configure {
    [self captureKeyboardImage];
    [self buildTableView];
}

- (void)presentSelfAnimated:(BOOL)animated {
    if (animated) {
        // Add the keyboard image as the top layer. This makes a seamless
        // tranition when we set ourself as the inputview.
        [self addSubview:[self keyboardImageView]];
        [_textField setInputView:self];
        [_textField reloadInputViews];

        // Animate the keyboard image out of the way.
        // TODO: support different transition types.
        CGFloat centerX = [[self keyboardImageView] center].x;
        CGFloat centerY = [[self keyboardImageView] center].y;
        CGFloat toolbarHeight = [_textField toolbarHeight];
        [[self layer] setMasksToBounds:YES];
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [[self keyboardImageView] setCenter:CGPointMake(centerX, (-centerY) - toolbarHeight)];
        } completion:^(BOOL finished) {
            [[self keyboardImageView] setAlpha:0];
        }];
    } else {
        // Just set ourself as the input view. No animations.
        [_textField setInputView:self];
        [_textField reloadInputViews];
    }
}

- (void)dismissSelfAnimated:(BOOL)animated {
    if (animated) {
        [[self keyboardImageView] setAlpha:1];
        CGFloat centerX = [[self keyboardImageView] center].x;
        CGFloat centerY = [[self keyboardImageView] center].y;
        CGFloat toolbarHeight = [_textField toolbarHeight];
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [[self keyboardImageView] setCenter:CGPointMake(centerX, (-centerY) - toolbarHeight)];
        } completion:^(BOOL finished) {
            [_textField setInputView:nil];
            [_textField reloadInputViews];
        }];
    } else {
        // Just remove ourself as the input view. No animations.
        [_textField setInputView:nil];
        [_textField reloadInputViews];
    }
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return [_textField enableInputClicksWhenVisible];
}

#pragma mark - Keyboard image

- (void)captureKeyboardImage {
    UIWindow *keyboardWindow = [self findKeyboardWindow];
    if (nil == keyboardWindow) return;

    CALayer *keyboardLayer = [self findKeyboardLayerInWindow:keyboardWindow];
    if (nil == keyboardLayer) return;

    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat toolbarHeight = [_textField toolbarHeight];

    // Grab an image of the system keyboard so we can animate it out of the way
    // during our presentation.
    UIGraphicsBeginImageContextWithOptions(keyboardLayer.bounds.size, keyboardWindow.opaque, scale);
    [keyboardLayer renderInContext:UIGraphicsGetCurrentContext()];
    CGRect rect = CGRectMake(0, toolbarHeight * scale, keyboardLayer.bounds.size.width * scale, (keyboardLayer.bounds.size.height - toolbarHeight) * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([UIGraphicsGetImageFromCurrentImageContext() CGImage], rect);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
    [imageView setImage:[UIImage imageWithCGImage:imageRef]];
    [self setKeyboardImageView:imageView];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();

    // Grab a slice of the keyboard image, 1 px wide, minus the toolbar, to use
    // as the background image. This will make it match the system keyboard's
    // background.
    rect = CGRectMake(0, 0, 1, [imageView image].size.height);
    imageRef = CGImageCreateWithImageInRect([[[self keyboardImageView] image] CGImage], rect);
    imageView = [[UIImageView alloc] initWithFrame:self.frame];
    [imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [imageView setImage:[UIImage imageWithCGImage:imageRef]];
    CGImageRelease(imageRef);
    [self addSubview:imageView];
}

- (UIWindow *)findKeyboardWindow {
    // Usually the keyboard window is the last object in the application's
    // windows array. We'll start there and test the windows going backwards
    // through the array.
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (int i = [windows count] - 1; i >= 0; i--) {
        UIWindow *window = (UIWindow *)windows[i];
        if ([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]) {
            return window;
        }
    }
    return nil;
}

- (CALayer *)findKeyboardLayerInWindow:(UIWindow *)window {
    // Find the sublayer with the largest rectangular area.
    CALayer *largest = nil;
    for (CALayer *sublayer in [window.layer sublayers]) {
        if (nil == largest) {
            largest = sublayer;
        } else {
            CGFloat largestArea = largest.bounds.size.width * largest.bounds.size.height;
            CGFloat sublayerArea = sublayer.bounds.size.width * sublayer.bounds.size.height;
            largest = (sublayerArea > largestArea) ? sublayer : largest;
        }
    }
    return largest;
}

#pragma mark - Table view

- (void)buildTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 2, self.frame.size.width, self.frame.size.height - 2) style:UITableViewStyleGrouped];
    [_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_tableView setAllowsMultipleSelection:NO];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];

    if (nil != [self keyboardImageView]) {
        [_tableView setBackgroundView:nil];
    }

    [self addSubview:_tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_textField autoFillStrings] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = [[_textField autoFillStrings] objectAtIndex:[indexPath row]];

    if ([[_textField autoFillDataSource] respondsToSelector:@selector(textField:tableView:cellForAutoFillString:atIndexPath:)]) {
        return [[_textField autoFillDataSource] textField:_textField tableView:tableView cellForAutoFillString:string atIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"DPTextFieldAutoFillCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        [[cell textLabel] setText:string];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];

        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = [[_textField autoFillStrings] objectAtIndex:[indexPath row]];
    [_textField setText:string];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:_textField userInfo:nil];
}

@end
