//
//  DPTextFieldAutoFillDataSource.h
//  DPTextFieldDemo
//
//  Created by Baker, Eric on 4/13/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPTextField;

@protocol DPTextFieldAutoFillDataSource <NSObject>

@optional
- (NSUInteger)minimumLengthForAutoFillQueryForTextField:(DPTextField *)textField;
- (UITableViewCell *)textField:(DPTextField *)textField tableView:(UITableView *)tableView cellForAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)textField:(DPTextField *)textField canRemoveAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath;
- (void)textField:(DPTextField *)textField removeAutoFillString:(NSString *)string atIndexPath:(NSIndexPath *)indexPath;

@required
- (NSArray *)textField:(DPTextField *)textField autoFillStringsForString:(NSString *)string;

@end
