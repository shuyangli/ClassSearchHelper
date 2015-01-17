//
//  CSHRegistrar.h
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHSchedule.h"
#import "CSHCourseFetcherHelper.h"
#import "CSHError.h"

/*!
 *  The CSHRegistrar class represents objects that facilitate automatic registration for given courses. It communicates with the Notre Dame Banner server and simulates the actions a student will take when he or she is registering for courses.
 *
 *  @warning
 *  It is very hacky, use with caution.
 *
 */
@interface CSHRegistrar : NSObject

@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *term;
@property (strong, nonatomic) NSString *netID;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *regPin;

#pragma mark - Instance methods
/*!
 *  Authenticate a student with a given NetID and password.
 *
 *  @warning
 *  You must call this method or the synchronous authentication method before registering for courses, or the registration will fail.
 *
 *  @param netID
 *  NetID of the student.
 *
 *  @param password
 *  The student's password when logging into InsideND.
 *
 *  @param completionHandler
 *  Do check the error parameter in the completionHandler with every method call, because registration is risky business.
 *
 */
- (void)authenticateWithNetID:(NSString *)netID
                     password:(NSString *)password
            completionHandler:(void (^)(BOOL isSuccessful, NSError *error))completionHandler;

/*!
 *  Authenticate a student with a given NetID and password synchronously.
 *
 *  @warning
 *  You must call this method or the asynchronous authentication method before registering for courses, or the registration will fail.
 *
 *  @param netID
 *  NetID of the student.
 *
 *  @param password
 *  The student's password when logging into InsideND.
 *
 *  @param error
 *  Out parameter. Do check the error parameter in the completionHandler with every method call, because registration is risky business.
 *
 */
- (void)authenticateSynchronouslyWithNetID:(NSString *)netID
                                  password:(NSString *)password
                                     error:(NSError *__autoreleasing *)error;

/*!
 *  After authenticating, register courses with given CRNs to the authenticated student.
 *
 *  @param CRNs
 *  Array of NSString objects representing the CRNs of courses to be registered.
 *
 *  @param completionHandler
 *  Do check the error parameter in the completionHandler with every method call, because registration is risky business.
 *
 */
- (void)registerCoursesWithCRNs:(NSArray *)CRNs
              completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

/*!
 *  After authenticating, register courses synchronously with given CRNs to the authenticated student.
 *
 *  @param CRNs
 *  Array of NSString objects representing the CRNs of courses to be registered.
 *
 *  @param error
 *  Out parameter. Do check the error parameter in the completionHandler with every method call, because registration is risky business.
 *
 */
- (NSData *)registerCoursesSynchronouslyWithCRNs:(NSArray *)CRNs
                                           error:(NSError *__autoreleasing *)error;

#pragma mark - Creation methods
/*!
 *  Returns an initialized CSHRegistrar object with a given year and term to register for, as well as a PIN code, if needed.
 *
 */
- (instancetype)initWithYear:(NSString *)year
                        term:(NSString *)term
                         pin:(NSString *)pin;

@end
