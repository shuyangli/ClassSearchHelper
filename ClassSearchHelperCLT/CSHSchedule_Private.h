//
//  CSHSchedule+Private.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHSchedule.h"

@interface CSHSchedule (Private)

/*!
 *  Helper method to determine if one given course can be scheduled alongside an array of already scheduled courses.
 *
 *  @param course
 *  The new course to be scheduled.
 *
 *  @param scheduledCourses
 *  Courses that are already scheduled. This array contains CSHCourse objects.
 *
 *  @param error
 *  Out parameter containing error message if the course cannot be scheduled.
 *
 */
+ (BOOL)canAddCourse:(CSHCourse *)course
  toScheduledCourses:(NSArray *)scheduledCourses
               error:(NSError *__autoreleasing *)error;

@end
