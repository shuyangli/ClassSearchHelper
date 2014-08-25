//
//  CSHInstructor.m
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "CSHInstructor.h"

@implementation CSHInstructor

- (instancetype)initWithFormattedString:(NSString *)string {
    // Name is either @"TBA" or @"LastName, FirstName"
    
    if (self = [super init]) {
        if (![string isEqualToString:@"TBA"]) {
            NSArray *nameParts = [string componentsSeparatedByString:@", "];
            _lastName = nameParts[0];
            _firstName = nameParts[1];
        }
    }
    
    return self;
}

+ (instancetype)instructorWithFormattedString:(NSString *)string {
    return [[self alloc] initWithFormattedString:string];
}

+ (NSArray *)instructorsWithFormattedString:(NSString *)string {
    NSArray *instructorNameArray = [string componentsSeparatedByString:@"\n"];
    NSMutableArray *instructorObjectsArray = [[NSMutableArray alloc] init];
    
    for (NSString *instructorName in instructorNameArray) {
        [instructorObjectsArray addObject:[self instructorWithFormattedString:instructorName]];
    }
    
    return instructorObjectsArray;
}

- (NSString *)description {
    if (self.firstName || self.lastName) return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    else return @"TBA";
}

@end
