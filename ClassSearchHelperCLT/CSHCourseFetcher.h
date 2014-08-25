//
//  CSHCourseFetcher.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourse.h"
#import "CSHCourseFetcherHelper.h"
#import "CSHError.h"

extern NSInteger const kCSHCourseFetcherError;

/*!
 *  The CSHCourseFetcher class facilitates course information fetching.
 *
 */
@interface CSHCourseFetcher : NSObject

/*!
 *  Fetches the number of remaining seats for one course with the given parameters.
 *
 *  @param year
 *  School year number. For example, @"2013" represents the 2013 - 14 school year, from Summer 2013 to Spring 2014.
 *
 *  @param term
 *  Term code (Summer, Spring, Fall, Full Year).
 *
 *  @param CRN
 *  Course registration number for the course.
 *
 *  @param completionHandler
 *  Completion handler called when fetching is complete, containing the number of seats and, if any error happened, the error info. numSeats will be kCSHCourseFetcherError when error happened that prevents fetching the real number.
 *
 */
+ (void)fetchRemainingSeatsForCourseWithYear:(NSString *)year
                                        term:(NSString *)term
                                         CRN:(NSString *)CRN
                           completionHandler:(void (^)(NSInteger numSeats, NSError *error))completionHandler;

/*!
 *  Fetches synchronously the number of remaining seats for one course with the given parameters. Please check the return value for kCSHCourseFetcherError.
 *
 *  @param year
 *  School year number. For example, @"2013" represents the 2013 - 14 school year, from Summer 2013 to Spring 2014.
 *
 *  @param term
 *  Term code (Summer, Spring, Fall, Full Year).
 *
 *  @param CRN
 *  Course registration number for the course.
 *
 *  @param error
 *  Out parameter if there is error during fetching.
 *
 *  @return
 *  Number of remaining seats for the course that matches the given parameters. If any error happened, the return value will be kCSHCourseFetcherError.
 *
 */
+ (NSInteger)fetchRemainingSeatsSynchronouslyForCourseWithYear:(NSString *)year
                                                          term:(NSString *)term
                                                           CRN:(NSString *)CRN
                                                         error:(NSError *__autoreleasing *)error;

@end
