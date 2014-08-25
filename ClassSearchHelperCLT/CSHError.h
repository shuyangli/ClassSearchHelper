//
//  CSHError.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CSHScheduleErrorDomain;
extern NSString * const CSHCourseErrorDomain;

extern NSString * const kCSHErrorDescriptionKey;
extern NSString * const kCSHErrorRawDataKey;

typedef NS_ENUM(NSInteger, CSHScheduleErrorCode) {
    kCSHScheduleErrorOther              = -1,
    kCSHScheduleErrorOverlappingCourses = 1,
    kCSHScheduleErrorDoubleRegister     = 2
};

typedef NS_ENUM(NSInteger, CSHCourseErrorCode) {
    kCSHCourseErrorOther                = -1,
    kCSHCourseErrorYearTooOld           = 1
};