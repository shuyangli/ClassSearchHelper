//
//  CSHScheduler.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourseFetcherHelper.h"
#import "CSHCourseListFetcher.h"
#import "CSHSchedule.h"
#import "CSHSchedulerConstraint.h"

/*!
 *  The CSHScheduler class defines objects that generate schedules for given courses. It takes into consideration time conflicts, user preferences, and other factors.
 *
 */
@interface CSHScheduler : NSObject

@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *term;

@property (strong, nonatomic, readonly) NSArray *allRequiredConstraints;    // of CSHSchedulerConstraint's, must all be required constraints
@property (strong, nonatomic) CSHSchedulerConstraint *rankingConstraint;    // Unlike the required constraint, which is a make-or-break deal, ranking constraints are more ambiguous. To not confuse people on which constraint has the highest priority, we'll let the developers configure the ranking constraint, so it considers multiple options. Developers can always nest multiple CSHSchedulerRankingConstraintBlock's in one constraint.
@property (strong, nonatomic, readonly) NSArray *filteredSchedules;

#pragma mark - Instance methods
/*!
 *  Add a course to be scheduled. All sections of this course will be considered when scheduling.
 *
 *  @param courseNumber
 *  Course number of course to be scheduled. Format: @"SUBJ XXXXX".
 */
- (void)addCourseWithCourseNumber:(NSString *)courseNumber;

/*!
 *  Add an array of courses to be scheduled. All sections of the courses will be considered when scheduling.
 *
 *  @param courseNumbers
 *  An array of course numbers to be scheduled. Format of course number: @"SUBJ XXXXX".
 */
- (void)addCoursesWithCourseNumbers:(NSArray *)courseNumbers;

/*!
 *  Asynchronously fetch the information from the server to be scheduled. This method or the synchronous method must be called before accessing filteredSchedules.
 *
 */
- (void)fetchCoursesWithCompletionHandler:(void (^)(void))completionHandler;

/*!
 *  Synchronously fetch the information from the server to be scheduled. This method or the asynchronous method must be called before accessing filteredSchedules.
 *
 */
- (void)fetchCoursesSynchronously;

/*!
 *  Add a CSHSchedulerConstraint as one of the required constraints. This constraint must be a required constraint.
 *
 */
- (void)addRequiredConstraint:(CSHSchedulerConstraint *)requiredConstraint;

/*!
 *  Remove a CSHSchedulerConstraint from the required constraints.
 *
 */
- (void)removeRequiredConstraint:(CSHSchedulerConstraint *)requiredConstraint;

#pragma mark - Creation methods
/*!
 *  Returns an initialized CSHScheduler object with the given year, term, and course numbers.
 *
 *  @param year
 *  Year number.
 *
 *  @param term
 *  Term number. Please use the defined kCSHCourseTerm constants.
 *
 *  @param courseNumbers
 *  An array of course numbers to be scheduled. Format of course number: @"SUBJ XXXXX". May be nil.
 */
- (instancetype)initWithYear:(NSString *)year
                        term:(NSString *)term
               courseNumbers:(NSArray *)courseNumbers;

@end
