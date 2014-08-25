//
//  CSHCourseSession.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourseSession.h"

@implementation CSHCourseSession

- (instancetype)initWithSessionTime:(CSHCourseSessionTime *)sessionTime
                           location:(CSHCampusLocation *)location {
    if (self = [super init]) {
        _sessionTime = sessionTime;
        _location = location;
    }
    
    return self;
}

- (instancetype)initWithTimeString:(NSString *)timeString
                   startDateString:(NSString *)startDateString
                     endDateString:(NSString *)endDateString locationString:(NSString *)locationString {
    if (self = [super init]) {
        _sessionTime = [CSHCourseSessionTime sessionTimeWithFormattedTimeString:timeString
                                                                startDateString:startDateString
                                                                  endDateString:endDateString];
        _location = [CSHCampusLocation locationWithFormattedString:locationString];
    }
    
    return self;
}

+ (instancetype)sessionWithSessionTime:(CSHCourseSessionTime *)sessionTime location:(CSHCampusLocation *)location {
    return [[self alloc] initWithSessionTime:sessionTime location:location];
}

+ (instancetype)sessionWithTimeString:(NSString *)timeString startDateString:(NSString *)startDateString endDateString:(NSString *)endDateString locationString:(NSString *)locationString {
    return [[self alloc] initWithTimeString:timeString startDateString:startDateString endDateString:endDateString locationString:locationString];
}

+ (NSArray *)multipleSessionsWithTimeString:(NSString *)timeString
                            startDateString:(NSString *)startDateString
                              endDateString:(NSString *)endDateString
                             locationString:(NSString *)locationString {
    if ([timeString hasPrefix:@"("]) {
        // There are multiple sessions
        NSMutableArray *multipleSessions = [[NSMutableArray alloc] init];
        
        NSError *regexError;
        NSRegularExpression *deleteParensRegex = [NSRegularExpression regularExpressionWithPattern:@"\\(.+?\\)" options:NSRegularExpressionDotMatchesLineSeparators error:&regexError];
        if (regexError) {
            NSLog(@"%@", regexError);
            return nil;
        }
        
#warning THIS IS SO UGLY
        
        // Separate the given strings into multiple components
        NSMutableArray *allTimes = [[NSMutableArray alloc] init];
        for (NSString *item in [timeString componentsSeparatedByString:@"\n"]) {
            [allTimes addObject:[deleteParensRegex stringByReplacingMatchesInString:item
                                                                           options:0
                                                                             range:NSRangeFromString(item)
                                                                      withTemplate:@""]];
        }
        
        NSMutableArray *allStartDates = [[NSMutableArray alloc] init];
        for (NSString *item in [startDateString componentsSeparatedByString:@"\n"]) {
            [allStartDates addObject:[deleteParensRegex stringByReplacingMatchesInString:item
                                                                            options:0
                                                                              range:NSRangeFromString(item)
                                                                       withTemplate:@""]];
        }
        
        NSMutableArray *allEndDates = [[NSMutableArray alloc] init];
        for (NSString *item in [endDateString componentsSeparatedByString:@"\n"]) {
            [allEndDates addObject:[deleteParensRegex stringByReplacingMatchesInString:item
                                                                                 options:0
                                                                                   range:NSRangeFromString(item)
                                                                            withTemplate:@""]];
        }
        
        NSArray *allLocations = [locationString componentsSeparatedByString:@"\n"];
        
        NSUInteger numItems = [allTimes count];
        for (int i = 0; i < numItems; ++i) {
            [multipleSessions addObject:[self sessionWithTimeString:allTimes[i]
                                                    startDateString:allStartDates[i]
                                                      endDateString:allEndDates[i]
                                                     locationString:allLocations[i]]];
        }
        
        return multipleSessions;
        
    } else {
        return @[[self sessionWithTimeString:timeString
                             startDateString:startDateString
                               endDateString:endDateString
                              locationString:locationString]];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", self.sessionTime, self.location];
}

@end
