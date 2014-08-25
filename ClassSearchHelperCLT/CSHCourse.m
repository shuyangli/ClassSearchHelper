//
//  CSHCourse.m
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourse.h"

@implementation CSHCourse

- (BOOL)isOverlappingWithCourse:(CSHCourse *)course {
    for (CSHCourseSession *selfSession in self.sessions) {
        for (CSHCourseSession *otherSession in course.sessions) {
            if ([selfSession.sessionTime isOverlappingWithSessionTime:otherSession.sessionTime]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)setSubjectCourseSectionWithFormattedString:(NSString *)string {
    // String format: @"SUBJCCCCC - SS"
    // SUBJ: subject (not necessarily 4 characters
    // CCCCC: course number
    // SS: section number
    
    NSMutableString *formattedString = [string mutableCopy];
    self.section = [formattedString substringFromIndex:[formattedString length] - 2];
    [formattedString deleteCharactersInRange:NSMakeRange([formattedString length] - 5, 5)];
    self.courseNumber = [formattedString substringFromIndex:[formattedString length] - 5];
    [formattedString deleteCharactersInRange:NSMakeRange([formattedString length] - 5, 5)];
    self.subject = formattedString;
}

- (void)setCourseRegistrationStatusWithString:(NSString *)string {
    // String is either @"OP" or @"CL"
    self.status = [string isEqualToString:@"OP"] ? kCSHCourseRegistrationClosed : kCSHCourseRegistrationOpen;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ - %@ (%@), Term: %@%@, CRN: %@, Instructor: %@, Credit: %@, Status: %d, Approval: %d, Max Seats: %ld, Open Seats: %ld, Sessions: %@",
            self.subject, self.courseNumber, self.section, self.conciseTitle, self.year, self.term, self.CRN,
            self.instructors, self.credit, self.status, self.isApprovalRequired, self.maxSeats, self.openseats,
            self.sessions];
}

@end
