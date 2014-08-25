//
//  CSHCourseListFetcher.m
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourseListFetcher.h"

@implementation CSHCourseListFetcher

+ (void)fetchCoursesWithYear:(NSString *)year
                        term:(NSString *)term
                    division:(NSString *)division
                      campus:(NSString *)campus
                     subject:(NSString *)subject
                   attribute:(NSString *)attribute
                      credit:(NSString *)credit
           completionHandler:(void (^)(NSArray *courses, NSError *error))completionHandler {
    
    // First error check with year: the earliest the system supports is 2005
    if ([year integerValue] < 2005) {
        NSError *yearTooOldError = [NSError errorWithDomain:CSHCourseErrorDomain code:kCSHCourseErrorYearTooOld userInfo:@{ kCSHErrorDescriptionKey : [NSString stringWithFormat:@"Given year (%@) is too old; Class Search system only contains course information as early as 2005.", year]}];
        if (completionHandler) completionHandler(nil, yearTooOldError);
        return;
    }
    
    // Generate request
    NSURL *classSearchURL = [CSHCourseFetcherHelper classSearchURLWithYear:year term:term division:division campus:campus subject:subject attribute:attribute credit:credit];
    NSMutableURLRequest *searchRequest = [NSMutableURLRequest requestWithURL:classSearchURL
                                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                             timeoutInterval:10.0];
    searchRequest.HTTPMethod = @"GET";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            // Error occured
            if (completionHandler) completionHandler(nil, error);
            return;
        }
        
        // If there's no error and we received data, we start to parse returned HTML
        NSError *parseError;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&parseError];
        
        NSArray *allCoursesArray = [document nodesForXPath:@"/html/body/div/table/tbody/tr" error:&parseError];
        if (parseError) {
            // Parsing error
            if (completionHandler) completionHandler(nil, parseError);
            return;
        }
        
        // Analyze parse result
        NSMutableArray *courses = [[NSMutableArray alloc] init];
        for (NSXMLElement *courseElement in allCoursesArray) {
            CSHCourse *currentCourse = [[CSHCourse alloc] init];
            NSArray *courseAttributes = [courseElement elementsForName:@"td"];
            
            currentCourse.year = year;
            currentCourse.term = term;
            [currentCourse setSubjectCourseSectionWithFormattedString:CSHCleanStringFromXMLElement([courseAttributes[0] elementsForName:@"a"][0])];
            currentCourse.isApprovalRequired = [CSHCleanStringFromXMLElement(courseAttributes[0]) rangeOfString:@"*"].location != NSNotFound;
            currentCourse.conciseTitle = CSHCleanStringFromXMLElement(courseAttributes[1]);
            currentCourse.credit = CSHCleanStringFromXMLElement(courseAttributes[2]);
            [currentCourse setCourseRegistrationStatusWithString:CSHCleanStringFromXMLElement(courseAttributes[3])];
            currentCourse.maxSeats = [CSHCleanStringFromXMLElement(courseAttributes[4]) integerValue];
            currentCourse.openseats = [CSHCleanStringFromXMLElement(courseAttributes[5]) integerValue];
            currentCourse.CRN = CSHCleanStringFromXMLElement(courseAttributes[7]);
            currentCourse.instructors = [CSHInstructor instructorsWithFormattedString:CSHCleanStringFromXMLElement(courseAttributes[9])];
            currentCourse.sessions = [CSHCourseSession multipleSessionsWithTimeString:CSHCleanStringFromXMLElement(courseAttributes[10])
                                                                      startDateString:CSHCleanStringFromXMLElement(courseAttributes[11])
                                                                        endDateString:CSHCleanStringFromXMLElement(courseAttributes[12])
                                                                       locationString:CSHCleanStringFromXMLElement(courseAttributes[13])];
            
            [courses addObject:currentCourse];
        }
        
        // All good, call completion handler
        if (completionHandler) completionHandler(courses, nil);
        
    }] resume];
}

+ (NSArray *)fetchCoursesSynchronouslyWithYear:(NSString *)year
                                          term:(NSString *)term
                                      division:(NSString *)division
                                        campus:(NSString *)campus
                                       subject:(NSString *)subject
                                     attribute:(NSString *)attribute
                                        credit:(NSString *)credit
                                         error:(NSError *__autoreleasing *)error {
    // If we need to authenticate synchronously, we use a semaphore to block the thread until completion handler is called
    dispatch_semaphore_t fetchSemaphore = dispatch_semaphore_create(0);
    
    // Capture the returned array from completion handler
    __block NSArray *capturingReturnArray;
    
    [self fetchCoursesWithYear:year
                          term:term
                      division:division
                        campus:campus
                       subject:subject
                     attribute:attribute
                        credit:credit
             completionHandler:^(NSArray *courses, NSError *asyncError) {
                 
                 // If the user wants an error param, we pass it on
                 if (error) {
                     *error = asyncError;
                 }
                 capturingReturnArray = courses;
                 
                 // Done running, signal semaphore
                 dispatch_semaphore_signal(fetchSemaphore);
             }];
    
    // Wait until semaphore is signaled
    dispatch_semaphore_wait(fetchSemaphore, DISPATCH_TIME_FOREVER);
    
    // Then return the captured array from the completion handler
    return capturingReturnArray;
}

@end
