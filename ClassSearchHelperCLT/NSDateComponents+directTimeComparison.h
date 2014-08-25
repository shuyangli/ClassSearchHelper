//
//  NSDateComponents+directTimeComparison.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (directTimeComparison)

/*!
 *  Returns if the NSDateComponents object represents a time that's earlier than the given NSDateComponents object.
 *
 *  @param dateComponents
 *  Given date components containing an hour field and a minute field.
 *
 *  @warning
 *  This comparison is simplified, only considers the hour and minute, and is not intended for general purpose use.
 *
 */
- (BOOL)isEarlierThanDateComponents:(NSDateComponents *)dateComponents;

/*!
 *  Returns if the NSDateComponents object represents a time that's at the same time as the given NSDateComponents object.
 *
 *  @param dateComponents
 *  Given date components containing an hour field and a minute field.
 *
 *  @warning
 *  This comparison is simplified, only considers the hour and minute, and is not intended for general purpose use.
 *
 */
- (BOOL)isEqualToDateComponents:(NSDateComponents *)dateComponents;

@end
