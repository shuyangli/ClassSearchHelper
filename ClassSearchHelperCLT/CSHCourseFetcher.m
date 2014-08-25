//
//  CSHCourseFetcher.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourseFetcher.h"

NSInteger const kCSHCourseFetcherError = INT_MIN;

@implementation CSHCourseFetcher

+ (void)fetchRemainingSeatsForCourseWithYear:(NSString *)year
                                        term:(NSString *)term
                                         CRN:(NSString *)CRN
                           completionHandler:(void (^)(NSInteger numSeats, NSError *error))completionHandler {
    
    // First error check with year: the earliest the system supports is 2005
    if ([year integerValue] < 2005) {
        NSError *yearTooOldError = [NSError errorWithDomain:CSHCourseErrorDomain code:kCSHCourseErrorYearTooOld userInfo:@{ kCSHErrorDescriptionKey : [NSString stringWithFormat:@"Given year (%@) is too old; Class Search system only contains course information as early as 2005.", year]}];
        if (completionHandler) completionHandler(kCSHCourseFetcherError, yearTooOldError);
        return;
    }
    
    // Generate request
    NSURL *classSummaryURL = [CSHCourseFetcherHelper classSummaryURLWithYear:year term:term CRN:CRN];
    NSMutableURLRequest *searchRequest = [NSMutableURLRequest requestWithURL:classSummaryURL
                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                             timeoutInterval:10.0];
    searchRequest.HTTPMethod = @"GET";
    
    // Send request
    NSError *__autoreleasing connectionError;
    NSURLResponse *searchResponse;
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:searchRequest
                                                 returningResponse:&searchResponse
                                                             error:&connectionError];
    if (connectionError) {
        NSLog(@"Connection error to %@: %@", classSummaryURL, connectionError);
        if (completionHandler) completionHandler(kCSHCourseFetcherError, connectionError);
        return;
    }
    
    // Parse returned HTML
    NSError *__autoreleasing parseError;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:returnedData options:NSXMLDocumentTidyHTML error:&parseError];
    //    if (parseError) {
    //        // Commenting this out because I get a lot of warnings but no error
    //        error = &parseError;
    //        return nil;
    //    }
    
    // Check title
    NSXMLElement *titleElement = [[document nodesForXPath:@"/html/head/title" error:&parseError] firstObject];
    if (parseError) {
        NSLog(@"Error when parsing title: %@", parseError);
        if (completionHandler) completionHandler(kCSHCourseFetcherError, parseError);
        return;
    } else if ([CSHCleanStringFromXMLElement(titleElement) hasPrefix:@"Error"]) {
        NSLog(@"Retrieved error page");
        NSError *errorPageError = [NSError errorWithDomain:CSHCourseErrorDomain code:kCSHCourseErrorOther userInfo:@{ kCSHErrorDescriptionKey : @"Server returned error page." , kCSHErrorRawDataKey : returnedData}];
        if (completionHandler) completionHandler(kCSHCourseFetcherError, errorPageError);
        return;
    }
    
    // Find result
    NSArray *allFieldsArray = [document nodesForXPath:@"/html/body/div[@id='tabsMain']/div[@id='basicInfo']/table[2]/tr/td/table/tr/td" error:&parseError];
    if (parseError) {
        NSError *incorrectFormatError = [NSError errorWithDomain:CSHCourseErrorDomain code:kCSHCourseErrorOther userInfo:@{ kCSHErrorDescriptionKey : @"Returned data has incorrect format." , kCSHErrorRawDataKey : returnedData}];
        if (completionHandler) completionHandler(kCSHCourseFetcherError, incorrectFormatError);
        return;
    }
    
    // Everything is fine, we call the completion handler
    if (completionHandler) completionHandler([CSHCleanStringFromXMLElement(allFieldsArray[2]) integerValue], nil);
    return;
}

+ (NSInteger)fetchRemainingSeatsSynchronouslyForCourseWithYear:(NSString *)year
                                                          term:(NSString *)term
                                                           CRN:(NSString *)CRN
                                                         error:(NSError *__autoreleasing *)error {
    // If we need to authenticate synchronously, we use a semaphore to block the thread until completion handler is called
    dispatch_semaphore_t fetchSemaphore = dispatch_semaphore_create(0);
    
    // Capture the returned array from completion handler
    __block NSInteger capturingNumSeats;
    
    [self fetchRemainingSeatsForCourseWithYear:year term:term CRN:CRN completionHandler:^(NSInteger numSeats, NSError *asyncError) {
        
        // If the user wants an error param, we pass it on
        if (error) {
            *error = asyncError;
        }
        capturingNumSeats = numSeats;
        
        // Done running, signal semaphore
        dispatch_semaphore_signal(fetchSemaphore);
    }];
    
    // Wait until semaphore is signaled
    dispatch_semaphore_wait(fetchSemaphore, DISPATCH_TIME_FOREVER);
    
    // Then return the captured array from the completion handler
    return capturingNumSeats;
}

@end
