//
//  CSHCampusLocation.m
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHCampusLocation.h"

@implementation CSHCampusLocation

- (instancetype)initWithFormattedString:(NSString *)string {
    // String is either @"TBA", @"DEPARTMENTAL BY_INSTRUCTOR", or "Building Name DDD" where DDD is room number
    
    if (self = [super init]) {
        if (![string isEqualToString:@"TBA"]) {
            NSMutableArray *locationStringParts = [[string componentsSeparatedByString:@" "] mutableCopy];
            _room = [[locationStringParts lastObject] capitalizedString];
            [locationStringParts removeLastObject];
            _building = [[locationStringParts componentsJoinedByString:@" "] capitalizedString];
        }
    }
    
    return self;
}

+ (instancetype)locationWithFormattedString:(NSString *)string {
    return [[self alloc] initWithFormattedString:string];
}

- (NSString *)description {
    if (self.building || self.room) return [NSString stringWithFormat:@"%@ %@", self.building, self.room];
    else return @"TBA";
}

@end