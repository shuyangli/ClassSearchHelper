//
//  CSHInstructor.h
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  The CSHInstructor class represents an instructor, currently containing a first name and a last name.
 *
 */
@interface CSHInstructor : NSObject

@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *firstName;

/*!
 *  Returns an initialized CSHInstructor object with a given string representing the instructor's name. The string needs to include both the instructor's first and last name.
 *
 *  For example, a given string @"Malloy, Edward" would be interpreted as: lastName = @"Malloy", firstName = @"Edward".
 *
 *  @param string
 *  Formatted string representing a name. Format: Last Name, First Name.
 *
 */
- (instancetype)initWithFormattedString:(NSString *)string;

/*!
 *  Returns a new CSHInstructor object with a given string representing the instructor's name. The string needs to include both the instructor's first and last name.
 *
 *  For example, a given string @"Malloy, Edward" would be interpreted as: lastName = @"Malloy", firstName = @"Edward".
 *
 *  @param string
 *  Formatted string representing a name. Format: Last Name, First Name.
 *
 */
+ (instancetype)instructorWithFormattedString:(NSString *)string;

/*!
 *  Returns an NSArray of CSHInstructor objects with a given string representing the instructors' names. Each instructor name is separated with a line break.
 *
 *  @param string
 *  Formatted string representing instructor names.
 *
 */
+ (NSArray *)instructorsWithFormattedString:(NSString *)string;

@end
