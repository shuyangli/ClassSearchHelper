//
//  main.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 08/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourseListFetcher.h"
#import "CSHCourseFetcher.h"
#import "CSHScheduler.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        //        NSArray *courses = [CSHCourseListFetcher fetchCoursesSynchronouslyWithYear:@"2014"
        //                                                                              term:kCSHCourseTermFall
        //                                                                          division:kCSHCourseDivisionAll
        //                                                                            campus:kCSHCourseCampusMain
        //                                                                           subject:@"CSE"
        //                                                                         attribute:kCSHCourseAttributeAny
        //                                                                            credit:kCSHCourseCreditAll
        //                                                                             error:nil];
        //
        //        NSInteger remainingSeats = [CSHCourseFetcher fetchRemainingSeatsSynchronouslyForCourseWithYear:@"2014"
        //                                                                                                  term:kCSHCourseTermFall
        //                                                                                                   CRN:@"16003"
        //                                                                                                 error:nil];
        //
        CSHScheduler *scheduler = [[CSHScheduler alloc] initWithYear:@"2014"
                                                                term:kCSHCourseTermFall
                                                       courseNumbers:@[@"CSE 20211", @"CSE 21211", @"MATH 10120", @"FTT 47600", @"DESN 31140"]];
        
        [scheduler fetchCoursesSynchronously];
        
        [scheduler addRequiredConstraint:[[CSHSchedulerConstraint alloc] initWithRequiredConstraint:^BOOL(CSHSchedule *schedule) {
            if ([schedule.courses count] < 2) return NO;
            return YES;
        }]];
        
        scheduler.rankingConstraint = [[CSHSchedulerConstraint alloc] initWithRankingConstraint:^CSHSchedulerRankingResult(CSHSchedule *firstSchedule, CSHSchedule *secondSchedule) {
            NSUInteger firstNumCSECourses = 0;
            NSUInteger secondNumCSECourses = 0;
            for (CSHCourse *course in firstSchedule.courses) {
                if ([course.subject isEqualToString:@"CSE"]) firstNumCSECourses++;
            }
            
            for (CSHCourse *course in secondSchedule.courses) {
                if ([course.subject isEqualToString:@"CSE"]) secondNumCSECourses++;
            }
            
            if (firstNumCSECourses > secondNumCSECourses) return kCSHSchedulerRankingPreferFirst;
            if (secondNumCSECourses > firstNumCSECourses) return kCSHSchedulerRankingPreferSecond;
            return kCSHSchedulerRankingSame;
        }];
        
        NSLog(@"%@", [scheduler filteredSchedules]);
    }
    
    return 0;
}

