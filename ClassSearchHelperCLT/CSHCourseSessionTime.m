//
//  CSHCourseSessionTime.m
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCourseSessionTime.h"
#import "CSHCourseSessionTime_Private.h"
#import "NSDateComponents+directTimeComparison.h"

@implementation CSHCourseSessionTime

- (BOOL)isOverlappingWithSessionTime:(CSHCourseSessionTime *)sessionTime {
    
    // If they are on different weekdays, they won't be overlapping
    if (!(self.weekdays & sessionTime.weekdays)) {
        return NO;
    }
    
    // If they share weekdays, but they're not within the same date range, they won't be overlapping
    NSComparisonResult selfStartOtherEnd = [self.startDate compare:sessionTime.endDate];
    NSComparisonResult selfEndOtherStart = [self.endDate compare:sessionTime.startDate];
    if (selfStartOtherEnd == NSOrderedDescending || selfEndOtherStart == NSOrderedAscending) {
        // Self starts later than other ends, or self ends earlier than other starts, they won't be overlapping
        return NO;
    }
    
    // Otherwise, we compare the times
    if ([self.endTime isEarlierThanDateComponents:sessionTime.startTime] || [sessionTime.endTime isEarlierThanDateComponents:self.startTime]) {
        // Self starts later than other ends, or self ends earlier than other starts, they won't be overlapping
        return NO;
    }
    
    // If nothing matches, they must be overlapping
    return YES;
}

- (instancetype)initWithFormattedTimeString:(NSString *)timeString
                            startDateString:(NSString *)startDateString
                              endDateString:(NSString *)endDateString {
    
    if (self = [super init]) {
        if (![timeString isEqualToString:@"TBA"]) {
            
            // timeString is either @"TBA" or with format @"D D( D D D) - X:XXM - X:XXM"
            // D: M, T, W, R, F, S, U; X:XXM: 8:20A, 9:25A, 2:00P, etc
            NSArray *dateTimeStringParts = [timeString componentsSeparatedByString:@"-"];
            _weekdays = [CSHCourseSessionTime weekdaysWithFormattedString:[dateTimeStringParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            _startTime = [CSHCourseSessionTime dateComponentsWithFormattedTimeString:[dateTimeStringParts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            _endTime = [CSHCourseSessionTime dateComponentsWithFormattedTimeString:[dateTimeStringParts[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        
        _startDate = [CSHCourseSessionTime dateWithFormattedString:startDateString];
        _endDate = [CSHCourseSessionTime dateWithFormattedString:endDateString];
    }
    
    return self;
    
}

+ (instancetype)sessionTimeWithFormattedTimeString:(NSString *)timeString
                                   startDateString:(NSString *)startDateString
                                     endDateString:(NSString *)endDateString {
    return [[self alloc] initWithFormattedTimeString:timeString startDateString:startDateString endDateString:endDateString];
}

- (NSString *)description {
    
    if (self.weekdays || self.startTime || self.endTime || self.startDate || self.endDate) {
        return [NSString stringWithFormat:@"%@ %@ - %@, %@ - %@",
                [CSHCourseSessionTime stringWithWeekdays:self.weekdays],
                [CSHCourseSessionTime stringWithTimeComponents:self.startTime],
                [CSHCourseSessionTime stringWithTimeComponents:self.endTime],
                [CSHCourseSessionTime stringWithDate:self.startDate],
                [CSHCourseSessionTime stringWithDate:self.endDate]];
        
    } else {
        return @"TBA";
    }
}

@end


#pragma mark - Private Extensions

@implementation CSHCourseSessionTime (NSDateExt)

+ (NSDate *)dateWithFormattedString:(NSString *)string {
    
    // Cached NSDateFormatter
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    return [formatter dateFromString:string];
}

+ (NSString *)stringWithDate:(NSDate *)date {
    
    // Cached NSDateFormatter
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.locale = [NSLocale autoupdatingCurrentLocale];
    }
    
    return [formatter stringFromDate:date];
}

@end

@implementation CSHCourseSessionTime (NSDateComponentsExt)

+ (NSDateComponents *)dateComponentsWithFormattedTimeString:(NSString *)string {
    // String is with format: X:XXM
    // M: 'A' / 'P'
    
    NSDateComponents *timeComponents = [[NSDateComponents alloc] init];
    
    NSMutableString *timeString = [string mutableCopy];
    if ([timeString characterAtIndex:[timeString length] - 1] == 'A') {
        // It's AM
        [timeString deleteCharactersInRange:NSMakeRange([timeString length] - 1, 1)];
        NSArray *timeArray = [timeString componentsSeparatedByString:@":"];
        timeComponents.hour = [timeArray[0] integerValue] % 12;
        timeComponents.minute = [timeArray[1] integerValue];
    } else {
        // It's PM
        [timeString deleteCharactersInRange:NSMakeRange([timeString length] - 1, 1)];
        NSArray *timeArray = [timeString componentsSeparatedByString:@":"];
        timeComponents.hour = [timeArray[0] integerValue] % 12 + 12;
        timeComponents.minute = [timeArray[1] integerValue];
    }
    
    return timeComponents;
}

+ (NSString *)stringWithTimeComponents:(NSDateComponents *)timeComponents {
    
    // Cache NSDateFormatter and NSCalendar
    static NSDateFormatter *timeFormatter;
    if (!timeFormatter) {
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateStyle = NSDateFormatterNoStyle;
        timeFormatter.timeStyle = NSDateFormatterShortStyle;
        timeFormatter.locale = [NSLocale currentLocale];
    }
    
    static NSCalendar *timeFormattingCalendar;
    if (!timeFormattingCalendar) {
        timeFormattingCalendar = [NSCalendar currentCalendar];
    }
    
    NSString *timeString;
    if (timeComponents) {
        // Preventing [NSCalendar dateFromComponents:nil] from throwing out really weird warning message
        timeString = [timeFormatter stringFromDate:[timeFormattingCalendar dateFromComponents:timeComponents]];
    }
    
    return timeString;
}

@end

@implementation CSHCourseSessionTime (CSHWeekdayOptionsExt)

+ (CSHWeekdayOptions)weekdaysWithFormattedString:(NSString *)string {
    
    CSHWeekdayOptions weekdays = kCSHWeekdayNotSet;
    NSArray *weekdaysArray = [string componentsSeparatedByString:@" "];
    
    if ([weekdaysArray containsObject:@"M"]) weekdays |= kCSHWeekdayMonday;
    if ([weekdaysArray containsObject:@"T"]) weekdays |= kCSHWeekdayTuesday;
    if ([weekdaysArray containsObject:@"W"]) weekdays |= kCSHWeekdayWednesday;
    if ([weekdaysArray containsObject:@"R"]) weekdays |= kCSHWeekdayThursday;
    if ([weekdaysArray containsObject:@"F"]) weekdays |= kCSHWeekdayFriday;
    if ([weekdaysArray containsObject:@"S"]) weekdays |= kCSHWeekdaySaturday;
    if ([weekdaysArray containsObject:@"U"]) weekdays |= kCSHWeekdaySunday;
    
    return weekdays;
}

+ (NSString *)stringWithWeekdays:(CSHWeekdayOptions)weekdays {
    
    NSMutableString *weekdaysString = [[NSMutableString alloc] init];
    if (weekdays & kCSHWeekdayMonday)       [weekdaysString appendString:@"M"];
    if (weekdays & kCSHWeekdayTuesday)      [weekdaysString appendString:@"T"];
    if (weekdays & kCSHWeekdayWednesday)    [weekdaysString appendString:@"W"];
    if (weekdays & kCSHWeekdayThursday)     [weekdaysString appendString:@"R"];
    if (weekdays & kCSHWeekdayFriday)       [weekdaysString appendString:@"F"];
    if (weekdays & kCSHWeekdaySaturday)     [weekdaysString appendString:@"S"];
    if (weekdays & kCSHWeekdaySunday)       [weekdaysString appendString:@"U"];
    
    return weekdaysString;
}

@end
