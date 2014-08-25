//
//  CSHSchedulerConstraint.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourseSessionTime.h"
#import "CSHSchedule.h"

#pragma mark - Typedef's
/*!
 *  Tag type specifically for the use of the CSHSchedulerConstraint class, to tag if the enclosing CSHSchedulerConstraintBlock is a RequiredConstraintBlock or a RankingConstraintBlock.
 *
 */
typedef NS_ENUM(NSInteger, CSHSchedulerConstraintType) {
    kCSHSchedulerConstraintTypeRequired = 0,
    kCSHSchedulerConstraintTypeRanking
};

/*!
 *  Type representing a required constraint on schedules.
 *
 *  A CSHSchedulerRequiredConstraintBlock is a block of type BOOL (^)(CSHSchedule *). It takes a CSHSchedule object, and returns if this schedule is acceptable (YES) or not (NO).
 *
 */
typedef BOOL (^CSHSchedulerRequiredConstraintBlock)(CSHSchedule *schedule);

/*!
 *  Type representing the result of a CSHSchedulerRankingConstraintBlock.
 *
 *  Note: with this enumeration, sorting of schedules can be done with sortedArrayUsingComparator.
 *
 */
typedef NSComparisonResult CSHSchedulerRankingResult;
extern NSComparisonResult kCSHSchedulerRankingPreferFirst;
extern NSComparisonResult kCSHSchedulerRankingSame;
extern NSComparisonResult kCSHSchedulerRankingPreferSecond;

/*!
 *  Type representing a ranking constraint on schedules.
 *
 *  A CSHSchedulerRankingConstraintBlock is a block of type CSHSchedulerRankingResult (^)(CSHSchedule *firstSchedule, CSHSchedule *secondSchedule). It takes two CSHSchedule objects, and returns a CSHSchedulerRankingResult of one of the options:
 *
 *  - kCSHSchedulerRankingPreferFirst: The first schedule is preferred over the second schedule.
 *
 *  - kCSHSchedulerRankingPreferSecond: The second schedule is preferred over the first schedule.
 *
 *  - kCSHSchedulerRankingSame: Both schedules are equally preferrable.
 *
 */
typedef CSHSchedulerRankingResult (^CSHSchedulerRankingConstraintBlock)(CSHSchedule *firstSchedule, CSHSchedule *secondSchedule);

#pragma mark - Actual interface
/*!
 *  The CSHSchedulerConstraint class is an Objective-C wrapper class for the CSHSchedulerConstraintBlock block type.
 *
 *  It serves as a one-of datatype, similar to a tagged C++ Union type, that only contains one CSHSchedulerRequiredConstraintBlock or one CSHSchedulerRankingConstraintBlock.
 *
 *  @warning
 *  You cannot modify an already initialized CSHSchedulerConstraint object in any way.
 *
 */
@interface CSHSchedulerConstraint : NSObject

@property (assign, nonatomic, readonly) CSHSchedulerConstraintType type;
@property (copy, nonatomic, readonly) CSHSchedulerRequiredConstraintBlock requiredConstraint;
@property (copy, nonatomic, readonly) CSHSchedulerRankingConstraintBlock rankingConstraint;

/*!
 *  Returns an initialized, properly tagged CSHSchedulerConstraint object with the given block as its required constraint.
 *
 */
- (instancetype)initWithRequiredConstraint:(CSHSchedulerRequiredConstraintBlock)block;

/*!
 *  Returns an initialized, properly tagged CSHSchedulerConstraint object with the given block as its ranking constraint.
 *
 */
- (instancetype)initWithRankingConstraint:(CSHSchedulerRankingConstraintBlock)block;

@end
