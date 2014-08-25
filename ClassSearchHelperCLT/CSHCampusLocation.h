//
//  CSHCampusLocation.h
//  ClassSearchHelper
//
//  Created by Shuyang Li on 8/24/14.
//  Copyright (c) 2014 Shuyang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  The CSHCampusLocation class represents a location on campus, including a building and a room.
 *
 */
@interface CSHCampusLocation : NSObject

/*!
 *  The name of the building.
 *
 */
@property (strong, nonatomic) NSString *building;

/*!
 *  The room number.
 *
 */
@property (strong, nonatomic) NSString *room;

/*!
 *  Returns an initialized CSHCampusLocation object with a given string representing a location. The string needs to include a building and a room.
 *
 *  For example, a given string @"Main Building 300" would be parsed as: building = @"Main Building", room = @"300".
 *
 *  @param string
 *  Formatted string representing a location. Format: Building Name Room#.
 *
 */
- (instancetype)initWithFormattedString:(NSString *)string;

/*!
 *  Returns a new CSHCampusLocation object with a given string representing a location. The string needs to include a building and a room.
 *
 *  For example, a given string @"Main Building 300" would be parsed as: building = @"Main Building", room = @"300".
 *
 *  @param string
 *  Formatted string representing a location. Format: Building Name Room#.
 *
 */
+ (instancetype)locationWithFormattedString:(NSString *)string;

@end
