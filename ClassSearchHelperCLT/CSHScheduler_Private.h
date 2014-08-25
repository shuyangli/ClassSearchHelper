//
//  CSHScheduler_Private.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHScheduler.h"

@interface CSHScheduler (RawDataExt)

@property (strong, nonatomic, readonly) NSArray *allPossibleCourses;
@property (strong, nonatomic, readonly) NSSet *allCourseNumbers;

@end
