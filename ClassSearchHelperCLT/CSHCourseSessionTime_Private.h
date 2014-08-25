//
//  CSHCourseSessionTime_Private.h
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourseSessionTime.h"

@interface CSHCourseSessionTime (NSDateExt)

/*!
 *  Returns an NSDate object with the given formatted string representing a date.
 *
 *  For example, a given string @"08/01/2001" would be interpreted as "August 1st, 2001".
 *
 *  @param string
 *  Formatted string representing a date. Format: "MM/dd/yyyy"
 *
 */
+ (NSDate *)dateWithFormattedString:(NSString *)string;

/*!
 *  Returns a formatted string representing a given date.
 *
 *  @param date
 *  Date containing year, month, and day fields.
 *
 *  @return
 *  A formatted string representing the given date.
 *
 */
+ (NSString *)stringWithDate:(NSDate *)date;

@end

@interface CSHCourseSessionTime (NSDateComponentsExt)

/*!
 *  Returns an NSDateComponents object with a given string representing a time with an hour component and a minute component, like @"9:30A".
 *
 *  @param string
 *  Formatted string representing a time. Format: "h:mma".
 *
 *  @return
 *  An NSDateComponents object containing the hour and minute fields represented in the given string.
 *
 */
+ (NSDateComponents *)dateComponentsWithFormattedTimeString:(NSString *)string;

/*!
 *  Returns a formatted string representing a given time component.
 *
 *  @param timeComponents
 *  Time components containing hour and minute fields.
 *
 *  @return
 *  A formatted string representing the hour and minute fields in the given NSDateComponents object.
 *
 */
+ (NSString *)stringWithTimeComponents:(NSDateComponents *)timeComponents;

@end

@interface CSHCourseSessionTime (CSHWeekdayOptionsExt)

/*!
 *  Returns a CSHWeekdayOptions variable with a given string representing one or more days of the week, like @"M W F".
 *
 *  @param string
 *  Formatted string representing one or more days of the week. Format: @"D D D D D".
 *
 *  @return
 *  A CSHWeekdayOptions variable representing the weekdays in the given string.
 *
 */
+ (CSHWeekdayOptions)weekdaysWithFormattedString:(NSString *)string;

/*!
 *  Returns a formatted string representing a given CSHWeekdayOptions variable.
 *
 *  @param weekdays
 *  A CSHWeekdayOptions variable representing one or more days of the week.
 *
 *  @return
 *  A formatted string representing the days of the week in the given CSHWeekdayOptions variable.
 *
 */
+ (NSString *)stringWithWeekdays:(CSHWeekdayOptions)weekdays;

@end
