//
//  CSHRegistrar.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHRegistrar.h"

@interface CSHRegistrar ()<NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSession *registrationSession;
@property (strong, nonatomic) NSArray *activeCookies;

+ (NSString *)encodedPOSTBodyWithRawHTMLData:(NSData *)HTMLData
                                        term:(NSString *)term
                                        year:(NSString *)year
                                        CRNs:(NSArray *)CRNs;

@end

@implementation CSHRegistrar

- (void)authenticateWithNetID:(NSString *)netID
                     password:(NSString *)password
            completionHandler:(void (^)(BOOL isSuccessful, NSError *error))completionHandler {
    
    self.netID = netID;
    self.password = password;
    
    // Initial authentication
    NSMutableURLRequest *initialAuthRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://inside-p.cc.nd.edu/cp/home/login"]
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:60.0];
    initialAuthRequest.HTTPBody = [[NSString stringWithFormat:@"pass=%@&user=%@", self.password, self.netID] dataUsingEncoding:NSASCIIStringEncoding];
    initialAuthRequest.HTTPMethod = @"POST";
    
    // Kick off initial authentication
    NSURLSessionDataTask *initialAuthDataTask = [self.registrationSession dataTaskWithRequest:initialAuthRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error when authenticating: %@", error);
        }
        
        // Check if login is successful
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:nil];
        NSError *parseHTMLError;
        NSXMLElement *titleElement = [[document nodesForXPath:@"/html/head/title" error:&parseHTMLError] firstObject];
        if (parseHTMLError) {
            // Internal error
            NSLog(@"Error when parsing title: %@", parseHTMLError);
            self.activeCookies = nil;
            if (completionHandler) completionHandler(NO, parseHTMLError);
            return;
            
        } else if ([CSHCleanStringFromXMLElement(titleElement) hasPrefix:@"Error"]) {
            // Authentication arror
            NSLog(@"Retrieved error page");
            NSError *loginError = [NSError errorWithDomain:CSHRegistrarErrorDomain
                                                      code:kCSHRegistrarErrorInvalidCredentials
                                                  userInfo: @{ kCSHErrorDescriptionKey : [NSString stringWithFormat:@"NetID (%@) or password incorrect", self.netID] }];
            self.activeCookies = nil;
            if (completionHandler) completionHandler(NO, loginError);
            return;
            
        } else {
            // Initial login is successful, we attempt to authenticate with Banner (DART page)
            NSMutableURLRequest *initialDARTAuthRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://inside-p.cc.nd.edu/cp/ip/login?sys=sctssb&url=https://ssb.cc.nd.edu/pls/BNRPROD/bwskfreg.P_AltPin"]
                                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                              timeoutInterval:60.0];
            
            // We pass on the cookies from initial authentication to the current authentication
            initialDARTAuthRequest.allHTTPHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:initialAuthRequest.URL]];
            
            // Kick off auth to DART page
            NSURLSessionDataTask *initialDARTAuthDataTask = [self.registrationSession dataTaskWithRequest:initialDARTAuthRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"Error when authenticating with Banner: %@", error);
                    self.activeCookies = nil;
                    if (completionHandler) completionHandler(NO, error);
                    
                } else {
                    // Authentication is successful, we save the received cookies
                    self.activeCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:initialDARTAuthRequest.URL];
                    if (completionHandler) completionHandler(YES, nil);
                }
            }];
            
            // Actually running it!
            [initialDARTAuthDataTask resume];
        }
    }];
    
    // Actually running it!
    [initialAuthDataTask resume];
}

- (void)authenticateSynchronouslyWithNetID:(NSString *)netID
                                  password:(NSString *)password
                                     error:(NSError *__autoreleasing *)error {
    
    // If we need to authenticate synchronously, we use a semaphore to block the thread until completion handler is called
    dispatch_semaphore_t syncSemaphore = dispatch_semaphore_create(0);
    
    [self authenticateWithNetID:netID password:password completionHandler:^(BOOL isSuccessful, NSError *asyncError) {
        if (error) {
            *error = asyncError;
        }
        
        // Done running, signal semaphore
        dispatch_semaphore_signal(syncSemaphore);
    }];
    
    // Wait until semaphore is signaled
    dispatch_semaphore_wait(syncSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)registerCoursesWithCRNs:(NSArray *)CRNs
              completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    
    if (!self.activeCookies) {
        // We have not authenticated yet
        if (completionHandler) completionHandler(nil, nil, [NSError errorWithDomain:CSHRegistrarErrorDomain code:kCSHRegistrarErrorNotAuthenticated userInfo:nil]);
        
        return;
    }
    
    // First select which semester. This step gives us crucial information for registration.
    NSMutableURLRequest *termSelectURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssb.cc.nd.edu/pls/BNRPROD/bwskfreg.P_AltPin"]
                                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                    timeoutInterval:60.0];
    termSelectURLRequest.allHTTPHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:self.activeCookies];
    termSelectURLRequest.HTTPBody = [[NSString stringWithFormat:@"term_in=%@%@", self.year, self.term] dataUsingEncoding:NSASCIIStringEncoding];
    termSelectURLRequest.HTTPMethod = @"POST";
    NSURLSessionDataTask *termSelectDataTask = [self.registrationSession dataTaskWithRequest:termSelectURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error when POSTing term: %@", error);
            if (completionHandler) {
                completionHandler(nil, nil, error);
            }
            
            return;
        }
        
        // Get cookies from DART auth
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:termSelectURLRequest.URL];
        
        // Check if we need a Pin
        NSError *parseAltPinError;
        NSXMLDocument *verifyAltPinDocument = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&parseAltPinError];
        NSArray *verifyAltPinFormArray = [verifyAltPinDocument nodesForXPath:@"/html/body/div/form/table/tr/td/label/span[@class=\"fieldlabeltext\"]" error:&parseAltPinError];
        
        if (parseAltPinError) {
            NSLog(@"Error when parsing AltPin document: %@", parseAltPinError);
            if (completionHandler) {
                completionHandler(nil, nil, parseAltPinError);
            }
            
            return;
        }
        
        if ([verifyAltPinFormArray count] > 0) {
            // We need a Pin!
            // Post for the pin
            NSMutableURLRequest *verifyPinRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssb.cc.nd.edu/pls/BNRPROD/bwskfreg.P_CheckAltPin"]
                                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                        timeoutInterval:60.0];
            verifyPinRequest.allHTTPHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
            
            // Form the request
            verifyPinRequest.HTTPBody = [[NSString stringWithFormat:@"pin=%@", self.regPin] dataUsingEncoding:NSASCIIStringEncoding];
            verifyPinRequest.HTTPMethod = @"POST";
            
            NSURLSessionTask *verifyPinDataTask = [self.registrationSession dataTaskWithRequest:verifyPinRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"Error when POSTing pin: %@", error);
                    if (completionHandler) {
                        completionHandler(nil, nil, error);
                    }
                    
                    return;
                }
                
#warning This is bad: duplicated registration code!
                // Actual registration!
                NSMutableURLRequest *registrationAuthRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssb.cc.nd.edu/pls/BNRPROD/bwckcoms.P_Regs"]
                                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                                   timeoutInterval:60.0];
                registrationAuthRequest.allHTTPHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                
                // Form the request string
                NSString *encodedRequestBodyString = [CSHRegistrar encodedPOSTBodyWithRawHTMLData:data
                                                                                             term:self.term
                                                                                             year:self.year
                                                                                             CRNs:CRNs];
                
                registrationAuthRequest.HTTPBody = [encodedRequestBodyString dataUsingEncoding:NSASCIIStringEncoding];
                
                registrationAuthRequest.HTTPMethod = @"POST";
                
                NSURLSessionDataTask *registrationDataTask = [self.registrationSession dataTaskWithRequest:registrationAuthRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    // Finished registration, we continue saving the cookie
                    NSLog(@"Error: %@", error);
                    NSLog(@"Response: %@", response);
                    NSLog(@"Cookies: %@", cookies);
                    NSLog(@"Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    
                    self.activeCookies = cookies;
                    
                    if (completionHandler) completionHandler(data, response, error);
                }];
                
                [registrationDataTask resume];
                
                
            }];
            
            [verifyPinDataTask resume];
            
        } else {
            // We don't need a pin
            
#warning This is bad: duplicated registration code!
            // Actual registration!
            NSMutableURLRequest *registrationAuthRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssb.cc.nd.edu/pls/BNRPROD/bwckcoms.P_Regs"]
                                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                               timeoutInterval:60.0];
            registrationAuthRequest.allHTTPHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
            
            // Form the request string
            NSString *encodedRequestBodyString = [CSHRegistrar encodedPOSTBodyWithRawHTMLData:data
                                                                                         term:self.term
                                                                                         year:self.year
                                                                                         CRNs:CRNs];
            
            registrationAuthRequest.HTTPBody = [encodedRequestBodyString dataUsingEncoding:NSASCIIStringEncoding];
            
            registrationAuthRequest.HTTPMethod = @"POST";
            
            NSURLSessionDataTask *registrationDataTask = [self.registrationSession dataTaskWithRequest:registrationAuthRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                // Finished registration, we continue saving the cookie
                NSLog(@"Error: %@", error);
                NSLog(@"Response: %@", response);
                NSLog(@"Cookies: %@", cookies);
                NSLog(@"Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                self.activeCookies = cookies;
                
                if (completionHandler) completionHandler(data, response, error);
            }];
            
            [registrationDataTask resume];
        }
    }];
    
    [termSelectDataTask resume];
}

- (NSData *)registerCoursesSynchronouslyWithCRNs:(NSArray *)CRNs
                                           error:(NSError *__autoreleasing *)error {
    
    dispatch_semaphore_t registerSemaphore = dispatch_semaphore_create(0);
    
    __block NSData *capturingData;
    
    [self registerCoursesWithCRNs:CRNs
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *asyncError) {
                    if (error) {
                        *error = asyncError;
                    }
                    
                    capturingData = data;
                    dispatch_semaphore_signal(registerSemaphore);
                }];
    
    dispatch_semaphore_wait(registerSemaphore, DISPATCH_TIME_FOREVER);
    return capturingData;
}

#pragma mark - Private helpers
+ (NSString *)encodedPOSTBodyWithRawHTMLData:(NSData *)HTMLData term:(NSString *)term year:(NSString *)year CRNs:(NSArray *)CRNs {
    
    // All dummy things go in the front
    NSMutableString *requestBodyString = [NSMutableString stringWithFormat:@"term_in=%@%@", year, term];
    [requestBodyString appendString:@"&RSTS_IN=DUMMY&assoc_term_in=DUMMY&CRN_IN=DUMMY&start_date_in=DUMMY&end_date_in=DUMMY&SUBJ=DUMMY&CRSE=DUMMY&SEC=DUMMY&LEVL=DUMMY&CRED=DUMMY&GMOD=DUMMY&TITLE=DUMMY&MESG=DUMMY&REG_BTN=DUMMY"];
    
    // Parse document and fill in the already registered courses
    NSError *error;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:HTMLData options:NSXMLDocumentTidyHTML error:&error];
    // Commenting out because I'm getting a lot of warnings
    //    if (error) return nil;
    
    // Grab all registered courses, and fill in the "registered courses" part
    NSArray *allRegisteredCourses = [document nodesForXPath:@"/html/body/div[@class='pagebodydiv']/form/table[@class='datadisplaytable']/tr" error:&error];
    if (error) return nil;
    NSUInteger registeredCourseCount = [allRegisteredCourses count] - 1;
    
    for (NSXMLElement *courseElement in allRegisteredCourses) {
        // Grab all items in one course
        NSArray *courseDetails = [courseElement nodesForXPath:@"./td" error:&error];
        if (error) return nil;
        
        // Take the input forms out
        for (NSXMLElement *courseDetailItem in courseDetails) {
            NSArray *courseAttributeItems = [courseDetailItem nodesForXPath:@"./input|select" error:&error];
            if (error) return nil;
            
            // Append "NAME=VALUE"
            for (NSXMLElement *courseAttributeItemNode in courseAttributeItems) {
                NSString *itemAttributeName = [[courseAttributeItemNode attributeForName:@"name"] stringValue];
                NSString *itemAttributeValue = [[courseAttributeItemNode attributeForName:@"value"] stringValue];
                
                if (itemAttributeName) {
                    [requestBodyString appendString:[NSString stringWithFormat:@"&%@=", itemAttributeName]];
                }
                if (itemAttributeValue) {
                    if ([itemAttributeName isEqualToString:@"CRED"]) {
                        [requestBodyString appendString:[NSString stringWithFormat:@"   %@", itemAttributeValue]];
                    } else {
                        [requestBodyString appendString:itemAttributeValue];
                    }
                }
            }
        }
    }
    
    for (NSUInteger i = 0; i < 10; ++i) {
        // Append "&RSTS_IN=RW&CRN_IN=&assoc_term_in=&start_date_in=&end_date_in=" 10 times
        if (i <[CRNs count]) {
            [requestBodyString appendString:[NSString stringWithFormat:@"&RSTS_IN=RW&CRN_IN=%@&assoc_term_in=&start_date_in=&end_date_in=", CRNs[i]]];
        } else {
            [requestBodyString appendString:@"&RSTS_IN=RW&CRN_IN=&assoc_term_in=&start_date_in=&end_date_in="];
        }
    }
    
    // Append the last bits of the request
    [requestBodyString appendString:[NSString stringWithFormat:@"&regs_row=%ld&wait_row=0&add_row=10&REG_BTN=Submit+Changes", registeredCourseCount]];
    
    NSMutableString *encodedRequestBodyString = [[requestBodyString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] mutableCopy];
    
    return encodedRequestBodyString;
}

#pragma mark - Creation methods

- (instancetype)initWithYear:(NSString *)year
                        term:(NSString *)term
                         pin:(NSString *)pin {
    if (self = [super init]) {
        _year = year;
        _term = term;
        _regPin = pin;
    }
    return self;
}

#pragma mark - NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    // This method is needed, as the system request cookies and the cookies are changed per request/redirect
    
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:request.URL];
    NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:60.0];
    [newRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    
    completionHandler(newRequest);
}

#pragma mark - Lazy instantiation

- (NSURLSession *)registrationSession {
    // Configure a custom session, so we can leverage the NSURLSessionTaskDelegate's redirect delegate method
    if (!_registrationSession) {
        _registrationSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                             delegate:self
                                                        delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _registrationSession;
}

@end
