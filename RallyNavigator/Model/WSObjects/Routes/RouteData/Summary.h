//
//  Summary.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Endlocation, Startlocation;

@interface Summary : NSObject <NSCoding>

@property (nonatomic, assign) double fuelrange;
@property (nonatomic, strong) Endlocation *endlocation;
@property (nonatomic, assign) double totalwaypoints;
@property (nonatomic, assign) double totaldistance;
@property (nonatomic, strong) Startlocation *startlocation;

+ (Summary *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
