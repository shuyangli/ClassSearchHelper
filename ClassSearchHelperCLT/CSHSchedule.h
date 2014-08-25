//
//  CSHSchedule.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourse.h"

/*!
 *  The CSHSchedule class represents a schedule of courses that can be taken together.
 *
 */
@interface CSHSchedule : NSObject

@property (strong, nonatomic, readonly) NSArray *courses;
@property (nonatomic, readonly) NSUInteger numCredits;

#pragma mark - Instance methods
/*!
 *  Add a course to this schedule.
 *
 *  @param course
 *  The new courses to be scheduled.
 *
 *  @param error
 *  Out parameter containing error message if the course cannot be scheduled.
 *
 */
- (void)addCourse:(CSHCourse *)course
            error:(NSError *__autoreleasing *)error;

/*!
 *  Add an array of courses to this schedule.
 *
 *  @param courses
 *  The new courses to be scheduled.
 *
 *  @param error
 *  Out parameter containing error message if the courses cannot be scheduled.
 *
 */
- (void)addCourses:(NSArray *)courses
             error:(NSError *__autoreleasing *)error;

#pragma mark - Creation methods
/*!
 *  Returns an initialized CSHSchedule object with an array of given courses.
 *
 *  @param courses
 *  An array of CSHCourse courses to go in this schedule.
 *
 *  @warning
 *  If the given array of courses contain courses that cannot go in the same schedule, the initialization will silently fail and return nil.
 */
- (instancetype)initWithCourses:(NSArray *)courses;

@end
