//
//  CSHSchedule.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHSchedule.h"
#import "CSHSchedule_Private.h"
#import "CSHError.h"

@interface CSHSchedule ()

@property (strong, nonatomic) NSMutableArray *courses_priv;

@end

@implementation CSHSchedule

- (NSUInteger)numCredits {
    double creditValue = 0;
    for (CSHCourse *course in self.courses) {
        creditValue += [course.credit doubleValue];
    }
    
    return creditValue;
}

- (void)addCourse:(CSHCourse *)course
            error:(NSError *__autoreleasing *)error {
    if ([CSHSchedule canAddCourse:course toScheduledCourses:self.courses error:error]) {
        [self.courses_priv addObject:course];
    }
}

- (void)addCourses:(NSArray *)courses
             error:(NSError *__autoreleasing *)error {
    
    NSMutableArray *allowedCourses = [self.courses mutableCopy];
    
    for (CSHCourse *course in courses) {
        if ([CSHSchedule canAddCourse:course toScheduledCourses:allowedCourses error:error]) {
            
            // Caching courses; we don't want to directly add a course to the schedule
            [allowedCourses addObject:course];
        } else {
            return;
        }
    }
    
    [self.courses_priv addObjectsFromArray:allowedCourses];
}

- (NSString *)description {
    NSMutableString *returnedDescription = [[NSMutableString alloc] init];
    for (CSHCourse *course in self.courses) {
        [returnedDescription appendFormat:@"(%@ %@ - %@, %@)", course.subject, course.courseNumber, course.section, course.sessions];
    }
    
    return returnedDescription;
}

#pragma mark - Private helpers

+ (BOOL)canAddCourse:(CSHCourse *)course
  toScheduledCourses:(NSArray *)scheduledCourses
               error:(NSError *__autoreleasing *)error {
    
    // Check the new course against all scheduled courses
    for (CSHCourse *scheduledCourse in scheduledCourses) {
        
        if ([course isOverlappingWithCourse:scheduledCourse]) {
            // Courses are overlapping
            if (error) {
                *error = [NSError errorWithDomain:CSHScheduleErrorDomain
                                             code:kCSHScheduleErrorOverlappingCourses
                                         userInfo:@{ kCSHErrorDescriptionKey : [NSString stringWithFormat:@"Course %@ is overlapping with %@: %@, %@", course.CRN, scheduledCourse.CRN, course, scheduledCourse] }];
            }
            return NO;
            
        } else {
            
            NSArray *doubledCourses = [scheduledCourses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"courseNumber LIKE %@", course.courseNumber]];
            if ([doubledCourses count] > 0) {
                // Registering for one course twice
                if (error) {
                    *error = [NSError errorWithDomain:CSHScheduleErrorDomain
                                                 code:kCSHScheduleErrorDoubleRegister
                                             userInfo:@{ kCSHErrorDescriptionKey : [NSString stringWithFormat:@"Double registering for course %@: %@, %@", course.courseNumber, course, [doubledCourses firstObject]]}];
                }
                return NO;
            }
        }
    }
    
    // All tests passed; it's OK to add this course
    return YES;
}

- (NSArray *)courses {
    return self.courses_priv;
}

#pragma mark - Creation methods

- (instancetype)initWithCourses:(NSArray *)courses {
    if (self = [super init]) {
        self.courses_priv = [[NSMutableArray alloc] init];
        
        // For safety, we add each course to the schedule
        for (CSHCourse *course in courses) {
            NSError *addCourseError;
            [self addCourse:course error:&addCourseError];
            
            if (addCourseError) {
                // If we cannot add the course, goto fail
                return nil;
            }
        }
    }
    return self;
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)courses_priv {
    if (!_courses_priv) {
        _courses_priv = [[NSMutableArray alloc] init];
    }
    return _courses_priv;
}

@end
