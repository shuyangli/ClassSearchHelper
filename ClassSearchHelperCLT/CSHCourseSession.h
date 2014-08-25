//
//  CSHCourseSession.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourseSessionTime.h"
#import "CSHCampusLocation.h"

/*!
 *  The CSHCourseSession class represents a specific course session, including the times, date range, and location where the session meets.
 *
 */
@interface CSHCourseSession : NSObject

@property (strong, nonatomic) CSHCourseSessionTime *sessionTime;
@property (strong, nonatomic) CSHCampusLocation *location;

/*!
 *  Returns an initialized CSHCourseSession object with a given session time and location.
 *
 *  @param sessionTime
 *  Time of the course session.
 *
 *  @param location
 *  Location of the course session.
 *
 */
- (instancetype)initWithSessionTime:(CSHCourseSessionTime *)sessionTime
                           location:(CSHCampusLocation *)location;

/*!
 *  Returns an initialized CSHCourseSession object with strings representing the course session's time, start date, end date, and location.
 *
 */
- (instancetype)initWithTimeString:(NSString *)timeString
                   startDateString:(NSString *)startDateString
                     endDateString:(NSString *)endDateString
                    locationString:(NSString *)locationString;

/*!
 *  Returns a new CSHCourseSession object with a given session time and location.
 *
 *  @param sessionTime
 *  Time of the course session.
 *
 *  @param location
 *  Location of the course session.
 *
 */
+ (instancetype)sessionWithSessionTime:(CSHCourseSessionTime *)sessionTime
                              location:(CSHCampusLocation *)location;

/*!
 *  Returns a new CSHCourseSession object with strings representing the course session's time, start date, end date, and location.
 *
 */
+ (instancetype)sessionWithTimeString:(NSString *)timeString
                      startDateString:(NSString *)startDateString
                        endDateString:(NSString *)endDateString
                       locationString:(NSString *)locationString;

/*!
 *  Returns an NSArray of new CSHCourseSession object with strings representing the course session's time, start date, end date, and location.
 *
 */
+ (NSArray *)multipleSessionsWithTimeString:(NSString *)timeString
                            startDateString:(NSString *)startDateString
                              endDateString:(NSString *)endDateString
                             locationString:(NSString *)locationString;


@end
