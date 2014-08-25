//
//  CSHSchedulerConstraint.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHSchedulerConstraint.h"

NSComparisonResult kCSHSchedulerRankingPreferFirst  = NSOrderedAscending;
NSComparisonResult kCSHSchedulerRankingSame         = NSOrderedSame;
NSComparisonResult kCSHSchedulerRankingPreferSecond = NSOrderedDescending;

@implementation CSHSchedulerConstraint

- (instancetype)initWithRequiredConstraint:(CSHSchedulerRequiredConstraintBlock)block {
    if (self = [super init]) {
        _type = kCSHSchedulerConstraintTypeRequired;
        _requiredConstraint = [block copy];
        _rankingConstraint = nil;
    }
    return self;
}

- (instancetype)initWithRankingConstraint:(CSHSchedulerRankingConstraintBlock)block {
    if (self = [super init]) {
        _type = kCSHSchedulerConstraintTypeRanking;
        _rankingConstraint = [block copy];
        _requiredConstraint = nil;
    }
    return self;
}

#warning Need to implement description to pretty print the block information
//- (NSString *)description {
//    return
//}

@end