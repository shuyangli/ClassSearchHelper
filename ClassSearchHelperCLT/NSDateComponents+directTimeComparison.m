//
//  NSDateComponents+directTimeComparison.m
//  ClassSearchHelperCLT
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import "NSDateComponents+directTimeComparison.h"

@implementation NSDateComponents (directTimeComparison)

- (BOOL)isEarlierThanDateComponents:(NSDateComponents *)dateComponents {
    if (self.hour < dateComponents.hour) return YES;
    else if (self.hour > dateComponents.hour) return NO;
    else {
        if (self.minute < dateComponents.minute) return YES;
        else return NO;
    }
}

- (BOOL)isEqualToDateComponents:(NSDateComponents *)dateComponents {
    return (self.hour == dateComponents.hour && self.minute == dateComponents.minute);
}

@end
