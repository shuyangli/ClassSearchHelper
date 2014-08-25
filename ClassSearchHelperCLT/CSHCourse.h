//
//  CSHCourse.h
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHCampusLocation.h"
#import "CSHInstructor.h"
#import "CSHCourseSessionTime.h"
#import "CSHCourseSession.h"

/*!
 *  Type representing course registration status.
 *
 *  - kCSHCourseRegistrationClosed: Course registration is closed.
 *
 *  - kCSHCourseRegistrationOpen: Course registration is still open.
 *
 */
typedef NS_ENUM(BOOL, CSHCourseRegistrationStatus) {
    kCSHCourseRegistrationClosed  = NO,
    kCSHCourseRegistrationOpen    = YES
};

/*!
 *  The CSHCourse class contains the detailed information for a course on the Class Search system.
 *
 */
@interface CSHCourse : NSObject

@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *term;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *courseNumber;
@property (strong, nonatomic) NSString *section;
@property (strong, nonatomic) NSString *conciseTitle;
@property (strong, nonatomic) NSString *CRN;
@property (strong, nonatomic) NSArray *instructors;             // of CSHInstructor's
@property (strong, nonatomic) NSString *credit;
@property (assign, nonatomic) CSHCourseRegistrationStatus status;
@property (assign, nonatomic) BOOL isApprovalRequired;
@property (assign, nonatomic) NSInteger maxSeats;
@property (assign, nonatomic) NSInteger openseats;
@property (strong, nonatomic) NSArray *sessions;                // The sessions where the course meets; a course may have multiple sessions

/*!
 *  Returns if the course is overlapping with another given course.
 *
 *  @param course
 *  Another course to compare against.
 *
 */
- (BOOL)isOverlappingWithCourse:(CSHCourse *)course;

/*!
 *  Sets the subject, course number, and section number of the course with a given formatted string.
 *
 *  For example, a given string @"CSE20211 - 01" would be interpreted as: subject = @"CSE", course = @"20211", section = @"01".
 *
 *  @param string
 *  Formatted string representing the subject, course number, and section number of the course.
 *
 */
- (void)setSubjectCourseSectionWithFormattedString:(NSString *)string;

/*!
 *  Sets the course registration status with a given string.
 *
 *  @param string
 *  String with value @"OP", meaning Open, or @"CL", meaning Closed.
 *
 */
- (void)setCourseRegistrationStatusWithString:(NSString *)string;

@end
