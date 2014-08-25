//
//  CSHScheduler.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHScheduler.h"
#import "CSHScheduler_Private.h"
#import "CSHSchedule_Private.h"
#import <pthread.h>

@interface CSHScheduler ()

@property (strong, nonatomic) NSMutableArray *allRequiredConstraints_priv;
@property (strong, nonatomic) NSMutableArray *allPossibleCourses_priv;
@property (strong, nonatomic) NSMutableSet *allCourseNumbers_priv;
@property (strong, nonatomic) NSArray *allPossibleSchedules_priv;

// Private helpers
+ (NSArray *)possibleSchedulesWithScheduledCourses:(NSArray *)scheduledCourses
                                        newCourses:(NSArray *)newCourses;

// This property is used to access allPossibleSchedules_priv if we don't want to modify its contents
@property (strong, nonatomic, readonly) NSArray *allPossibleSchedules;

@end

@implementation CSHScheduler

- (void)addCourseWithCourseNumber:(NSString *)courseNumber {
    self.allPossibleSchedules_priv = nil;
    [self.allCourseNumbers_priv addObject:courseNumber];
}

- (void)addCoursesWithCourseNumbers:(NSArray *)courseNumbers {
    self.allPossibleSchedules_priv = nil;
    [self.allCourseNumbers_priv addObjectsFromArray:courseNumbers];
}

- (void)fetchCoursesWithCompletionHandler:(void (^)(void))completionHandler {
    
    // We need a year and a term to query
    if (!self.year || !self.term) return;
    
    // Generate an NSDictionary on the fly to save Subject -> NSSet(Courses) mapping
    NSMutableDictionary *allSubjectsToCourses = [[NSMutableDictionary alloc] init];
    
    for (NSString *courseName in self.allCourseNumbers) {
        
        // Parse strings with format "CSE 20211"
        NSArray *courseComponents = [courseName componentsSeparatedByString:@" "];
        NSString *subject = courseComponents[0];
        NSString *course = courseComponents[1];
        
        if (!allSubjectsToCourses[subject]) {
            allSubjectsToCourses[subject] = [[NSMutableSet alloc] init];
        }
        
        [allSubjectsToCourses[subject] addObject:course];
    }
    
    // Gather courses
    
    // Asynchronously dispatch multiple blocks to fetch each subject, and add everything to a dispatch group to synchronize upon completion
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    // NSMutableArray is not thread-safe, so we need to lock around mutation points
    __block pthread_mutex_t writeToCoursesMutex;
    pthread_mutex_init(&writeToCoursesMutex, NULL);
    
    for (NSString *subject in allSubjectsToCourses.allKeys) {
        
        // For each subject, we gather all its courses
        NSSet *allCourseNumbersWithSubject = allSubjectsToCourses[subject];
        
        // Enter dispatch group
        dispatch_group_enter(dispatchGroup);
        [CSHCourseListFetcher fetchCoursesWithYear:self.year term:self.term division:kCSHCourseDivisionAll campus:kCSHCourseCampusMain subject:subject attribute:kCSHCourseAttributeAny credit:kCSHCourseCreditAll completionHandler:^(NSArray *courses, NSError *error) {
            
            // Filter all fetched courses, and add the matching ones to all possible courses
            
            // Lock around this area for thread safety
            pthread_mutex_lock(&writeToCoursesMutex);
            [self.allPossibleCourses_priv addObjectsFromArray:[courses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K IN %@", @"courseNumber", allCourseNumbersWithSubject]]];
            pthread_mutex_unlock(&writeToCoursesMutex);
            
            // Finished fetching, leave dispatch group
            dispatch_group_leave(dispatchGroup);
        }];
    }
    
    // When everything is done, we call completion handler
    dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (completionHandler) completionHandler();
    });
}

- (void)fetchCoursesSynchronously {
    // Even though we say it's a synchronous method, we cheat by calling the async version of fetchCourses inside fetchCoursesWithCompletionHandler to give us some performance bonus.
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    [self fetchCoursesWithCompletionHandler:^{
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)addRequiredConstraint:(CSHSchedulerConstraint *)requiredConstraint {
    if (requiredConstraint.type != kCSHSchedulerConstraintTypeRequired) {
        // The type is wrong! We need to raise an expection
        [NSException raise:@"Illegal constraint type" format:@"Expecting constraint type kCSHSchedulerConstraintTypeRequired, given constraint %@ has different type information.", requiredConstraint];
    }
    [self.allRequiredConstraints_priv addObject:requiredConstraint];
}

- (void)removeRequiredConstraint:(CSHSchedulerConstraint *)requiredConstraint {
    [self.allRequiredConstraints_priv removeObject:requiredConstraint];
}

- (void)setRankingConstraint:(CSHSchedulerConstraint *)rankingConstraint {
    if (rankingConstraint.type != kCSHSchedulerConstraintTypeRanking) {
        // The type is wrong! We need to raise an expection
        [NSException raise:@"Illegal constraint type" format:@"Expecting constraint type kCSHSchedulerConstraintTypeRanking, given constraint %@ has different type information.", rankingConstraint];
    }
    _rankingConstraint = rankingConstraint;
}

- (NSArray *)filteredSchedules {
    // This method is the heart of CSHScheduler!
    NSMutableArray *allSchedules = [[self allPossibleSchedules] mutableCopy];
    
    // First filter with all required constraints
    for (CSHSchedulerConstraint *requiredConstraint in self.allRequiredConstraints) {
        [allSchedules filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return requiredConstraint.requiredConstraint(evaluatedObject);
        }]];
    }
    
    // Then rank with the ranking constraing
    if (self.rankingConstraint) {
        [allSchedules sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return self.rankingConstraint.rankingConstraint(obj1, obj2);
        }];
    }
    
    return allSchedules;
}

- (NSArray *)allRequiredConstraints {
    return self.allRequiredConstraints_priv;
}

#pragma mark - Private Helper

+ (NSArray *)possibleSchedulesWithScheduledCourses:(NSArray *)scheduledCourses
                                        newCourses:(NSArray *)newCourses {
    
    // If the new courses is empty, we're done
    // Combine all scheduled courses into a schedule
    if (![newCourses count] > 0) {
        return @[[[CSHSchedule alloc] initWithCourses:scheduledCourses]];
    }
    
    CSHCourse *newCourse = [newCourses firstObject];
    NSMutableArray *newNewCourses = [newCourses mutableCopy];
    [newNewCourses removeObject:newCourse];
    
    // For the upcoming course in newCourses, it will either be scheduled or not scheduled
    NSArray *schedulesWithCourseScheduled;
    NSArray *schedulesWithCourseNotScheduled;
    
    // In case
    if ([CSHSchedule canAddCourse:newCourse toScheduledCourses:scheduledCourses error:nil]) {
        // We indeed can schedule this course, so it's in
        NSMutableArray *newScheduledCourses = [NSMutableArray arrayWithArray:scheduledCourses];
        [newScheduledCourses addObject:newCourse];
        
        schedulesWithCourseScheduled = [self possibleSchedulesWithScheduledCourses:newScheduledCourses
                                                                        newCourses:newNewCourses];
    }
    
    // Out case
    schedulesWithCourseNotScheduled = [self possibleSchedulesWithScheduledCourses:scheduledCourses
                                                                       newCourses:newNewCourses];
    
    
    NSMutableArray *returningArray = [NSMutableArray arrayWithArray:schedulesWithCourseScheduled];
    [returningArray addObjectsFromArray:schedulesWithCourseNotScheduled];
    
    return returningArray;
}

#pragma mark - Creation methods

- (instancetype)initWithYear:(NSString *)year term:(NSString *)term courseNumbers:(NSArray *)courseNumbers {
    if (self = [super init]) {
        _allPossibleCourses_priv = [[NSMutableArray alloc] init];
        _allPossibleSchedules_priv = nil;
        _year = year;
        _term = term;
        
        [self addCoursesWithCourseNumbers:courseNumbers];
    }
    
    return self;
}
        
#pragma mark - Lazy Instantiation

- (NSMutableArray *)allRequiredConstraints_priv {
    if (!_allRequiredConstraints_priv) {
        _allRequiredConstraints_priv = [[NSMutableArray alloc] init];
    }
    return _allRequiredConstraints_priv;
}

- (NSMutableSet *)allCourseNumbers_priv {
    if (!_allCourseNumbers_priv) {
        _allCourseNumbers_priv = [[NSMutableSet alloc] init];
    }
    return _allCourseNumbers_priv;
}

- (NSArray *)allPossibleSchedules {
    if (!self.allPossibleSchedules_priv) {
        self.allPossibleSchedules_priv = [CSHScheduler possibleSchedulesWithScheduledCourses:nil newCourses:self.allPossibleCourses_priv];
    }
    return self.allPossibleSchedules_priv;
}

@end

@implementation CSHScheduler (RawDataExt)

- (NSArray *)allPossibleCourses {
    return [self.allPossibleCourses_priv copy];
}

- (NSSet *)allCourseNumbers {
    return [self.allCourseNumbers_priv copy];
}

@end
