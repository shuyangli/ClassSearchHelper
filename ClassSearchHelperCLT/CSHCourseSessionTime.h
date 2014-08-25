//
//  CSHCourseSessionTime.h
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  Type representing days of the week.
 *
 */
typedef NS_OPTIONS(NSUInteger, CSHWeekdayOptions) {
    kCSHWeekdayNotSet       = 0,
    kCSHWeekdaySunday       = 1 << 0,
    kCSHWeekdayMonday       = 1 << 1,
    kCSHWeekdayTuesday      = 1 << 2,
    kCSHWeekdayWednesday    = 1 << 3,
    kCSHWeekdayThursday     = 1 << 4,
    kCSHWeekdayFriday       = 1 << 5,
    kCSHWeekdaySaturday     = 1 << 6
};


/*!
 *  The CSHCourseSessionTime class represents the times a specific class session meets during the week. It contains a start time, an end time, a start date, an end date, and a CSHWeekdayOptions of weekdays where the class session meets.
 *
 */
@interface CSHCourseSessionTime : NSObject

@property (assign, nonatomic) CSHWeekdayOptions weekdays;
@property (strong, nonatomic) NSDateComponents *startTime;
@property (strong, nonatomic) NSDateComponents *endTime;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

/*!
 *  Returns if the session time is overlapping with another given session time.
 *
 *  @param sessionTime
 *  Another session time to compare against.
 *
 */
- (BOOL)isOverlappingWithSessionTime:(CSHCourseSessionTime *)sessionTime;

/*!
 *  Returns an initialized CSHCourseSessionTime object with given strings representing the weekdays, time, and dates where the class session meets.
 *
 *  For example, a given string @"M W F 9:30A - 10:20A" would be interpreted as: weekdays = Monday|Wednesday|Friday, startTime = 9:30, endTime = 10:20.
 *
 *  @param timeString
 *  Formatted string representing a time where a class meets. Format: Days Of The Week StartTime - EndTime.
 *
 *  @param startDateString
 *  Formatted string representing a date. Format: "MM/dd/yyyy"
 *
 *  @param endDateString
 *  Formatted string representing a date. Format: "MM/dd/yyyy"
 *
 */
- (instancetype)initWithFormattedTimeString:(NSString *)timeString
                            startDateString:(NSString *)startDateString
                              endDateString:(NSString *)endDateString;

/*!
 *  Returns a new CSHCourseSessionTime object with given strings representing the weekdays, time, and dates where the class session meets.
 *
 *  For example, a given string @"M W F 9:30A - 10:20A" would be interpreted as: weekdays = Monday|Wednesday|Friday, startTime = 9:30, endTime = 10:20.
 *
 *  @param timeString
 *  Formatted string representing a time where a class meets. Format: Days Of The Week StartTime - EndTime.
 *
 *  @param startDateString
 *  Formatted string representing a date. Format: "MM/dd/yyyy"
 *
 *  @param endDateString
 *  Formatted string representing a date. Format: "MM/dd/yyyy"
 *
 */
+ (instancetype)sessionTimeWithFormattedTimeString:(NSString *)timeString
                                   startDateString:(NSString *)startDateString
                                     endDateString:(NSString *)endDateString;

@end
