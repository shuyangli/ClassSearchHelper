//
//  CSHCourseFetcherHelper.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCourse.h"

#pragma mark - Macros
#define CSHCleanStringFromXMLElement(_XML_ELEMENT_) [[_XML_ELEMENT_ stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

#pragma mark NSString Constant Declarations

extern NSString * const kCSHCourseCreditAll;
extern NSString * const kCSHCourseCredit0To1;
extern NSString * const kCSHCourseCredit1To2;
extern NSString * const kCSHCourseCredit2To3;
extern NSString * const kCSHCourseCredit3OrMore;
extern NSString * const kCSHCourseCreditVariable;

extern NSString * const kCSHCourseTermSummer;
extern NSString * const kCSHCourseTermFall;
extern NSString * const kCSHCourseTermSpring;
extern NSString * const kCSHCourseTermYear;

extern NSString * const kCSHCourseDivisionAll;
extern NSString * const kCSHCourseDivisionGraduateBusiness;
extern NSString * const kCSHCourseDivisionGraduateSchool;
extern NSString * const kCSHCourseDivisionLawSchool;
extern NSString * const kCSHCourseDivisionStMarys;
extern NSString * const kCSHCourseDivisionUndergrad;

extern NSString * const kCSHCourseCampusMain;

extern NSString * const kCSHCourseAttributeAny;

/*!
 *  The CSHCourseFetcherHelper class generates parameters for CSHCourseFetcher and CSHCourseListFetcher classes.
 *
 */
@interface CSHCourseFetcherHelper : NSObject

/*!
 *  Returns the Class Search URL used to query for courses.
 *
 *  @return
 *  NSURL ready for an HTTP request, with the given parameters filled in.
 *
 */
+ (NSURL *)classSearchURLWithYear:(NSString *)year
                             term:(NSString *)term
                         division:(NSString *)division
                           campus:(NSString *)campus
                          subject:(NSString *)subject
                        attribute:(NSString *)attribute
                           credit:(NSString *)credit;

/*!
 *  Returns the Class Summary URL used to query for the given course.
 *
 *  @return
 *  NSURL ready for an HTTP request, with the given parameters filled in.
 *
 */
+ (NSURL *)classSummaryURLWithYear:(NSString *)year
                              term:(NSString *)term
                               CRN:(NSString *)CRN;

/*!
 *  Returns the Class Summary URL used to query for the given course.
 *
 *  @return
 *  NSURL ready for an HTTP request, with the given parameters filled in.
 *
 */
+ (NSURL *)classSummaryURLWithCourseInfo:(CSHCourse *)courseInfo;

@end
