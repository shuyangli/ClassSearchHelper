//
//  CSHCourseListFetcher.h
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourse.h"
#import "CSHCourseFetcherHelper.h"
#import "CSHError.h"

/*!
 *  The CSHCourseListFetcher class facilitates course information queries.
 *
 */
@interface CSHCourseListFetcher : NSObject

/*!
 *  Fetches a list of courses which match the supplied query parameters.
 *
 *  @param year
 *  School year number. For example, @"2013" represents the 2013 - 14 school year, from Summer 2013 to Spring 2014.
 *
 *  @param term
 *  Term code (Summer, Spring, Fall, Full Year).
 *
 *  @param division
 *  Division code (undergraduate, graduate, etc). The default query parameter is kCSHCourseDivisionAll.
 *
 *  @param campus
 *  Campus code (Main campus, Washington D.C., Rome, etc). The default query parameter is kCSHCourseCampusMain.
 *
 *  @param subject
 *  Subject code.
 *
 *  @param attribute
 *  Attribute code. The default query parameter is kCSHCourseAttributeAny.
 *
 *  @param credit
 *  Number of credits (variable, 0, 1, 2, 3 or more). The default query parameter is kCSHCourseCreditAll.
 *
 *  @param completionHandler
 *  Completion handler called when fetching is complete.
 *
 *  Please refer to the CSHCourseSearchConstants.plist file.
 */
+ (void)fetchCoursesWithYear:(NSString *)year
                        term:(NSString *)term
                    division:(NSString *)division
                      campus:(NSString *)campus
                     subject:(NSString *)subject
                   attribute:(NSString *)attribute
                      credit:(NSString *)credit
           completionHandler:(void (^)(NSArray *courses, NSError *error))completionHandler;

/*!
 *  Fetches a list of courses synchronously which match the supplied query parameters.
 *
 *  @param year
 *  School year number. For example, @"2013" represents the 2013 - 14 school year, from Summer 2013 to Spring 2014.
 *
 *  @param term
 *  Term code (Summer, Spring, Fall, Full Year).
 *
 *  @param division
 *  Division code (undergraduate, graduate, etc). The default query parameter is kCSHCourseDivisionAll.
 *
 *  @param campus
 *  Campus code (Main campus, Washington D.C., Rome, etc). The default query parameter is kCSHCourseCampusMain.
 *
 *  @param subject
 *  Subject code.
 *
 *  @param attribute
 *  Attribute code. The default query parameter is kCSHCourseAttributeAny.
 *
 *  @param credit
 *  Number of credits (variable, 0, 1, 2, 3 or more). The default query parameter is kCSHCourseCreditAll.
 *
 *  @param error
 *  Out parameter used if an error occurs during this query. May be nil.
 *
 *  Please refer to the CSHCourseSearchConstants.plist file.
 */
+ (NSArray *)fetchCoursesSynchronouslyWithYear:(NSString *)year
                                          term:(NSString *)term
                                      division:(NSString *)division
                                        campus:(NSString *)campus
                                       subject:(NSString *)subject
                                     attribute:(NSString *)attribute
                                        credit:(NSString *)credit
                                         error:(NSError *__autoreleasing *)error;

@end
