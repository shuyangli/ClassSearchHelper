//
//  CSHCourseFetcherHelper.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourseFetcherHelper.h"

#pragma mark - NSString Constant Definitions

NSString * const kCSHCourseCreditAll                = @"A";
NSString * const kCSHCourseCredit0To1               = @"0";
NSString * const kCSHCourseCredit1To2               = @"1";
NSString * const kCSHCourseCredit2To3               = @"2";
NSString * const kCSHCourseCredit3OrMore            = @"3";
NSString * const kCSHCourseCreditVariable           = @"V";

NSString * const kCSHCourseTermSummer               = @"00";
NSString * const kCSHCourseTermFall                 = @"10";
NSString * const kCSHCourseTermSpring               = @"20";
NSString * const kCSHCourseTermYear                 = @"50";

NSString * const kCSHCourseDivisionAll              = @"A";
NSString * const kCSHCourseDivisionGraduateBusiness = @"GB";
NSString * const kCSHCourseDivisionGraduateSchool   = @"GR";
NSString * const kCSHCourseDivisionLawSchool        = @"LW";
NSString * const kCSHCourseDivisionStMarys          = @"SM";
NSString * const kCSHCourseDivisionUndergrad        = @"UG";

NSString * const kCSHCourseCampusMain               = @"M";

NSString * const kCSHCourseAttributeAny             = @"0ANY";

NSString * const kCSHClassSearchHostURL             = @"https://class-search.nd.edu/reg/srch/ClassSearchServlet";


@implementation CSHCourseFetcherHelper

+ (NSURL *)classSearchURLWithYear:(NSString *)year
                             term:(NSString *)term
                         division:(NSString *)division
                           campus:(NSString *)campus
                          subject:(NSString *)subject
                        attribute:(NSString *)attribute
                           credit:(NSString *)credit {
    
    NSString *classSearchURLString = [NSString stringWithFormat:@"%@?TERM=%@%@&DIVS=%@&CAMPUS=%@&SUBJ=%@&ATTR=%@&CREDIT=%@", kCSHClassSearchHostURL, year, term, division, campus, subject, attribute, credit];
    return [NSURL URLWithString:classSearchURLString];
}

+ (NSURL *)classSummaryURLWithYear:(NSString *)year
                              term:(NSString *)term
                               CRN:(NSString *)CRN {
    
    NSString *classSummaryURLString = [NSString stringWithFormat:@"%@?CRN=%@&TERM=%@%@", kCSHClassSearchHostURL, CRN, year, term];
    return [NSURL URLWithString:classSummaryURLString];
}

+ (NSURL *)classSummaryURLWithCourseInfo:(CSHCourse *)courseInfo {
    return [self classSummaryURLWithYear:courseInfo.year term:courseInfo.term CRN:courseInfo.CRN];
}

@end
