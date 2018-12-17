//
//  Route.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Route : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) double length;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *units;
@property (nonatomic, assign) double waypointCount;

@property (nonatomic, assign) double userId;
@property (nonatomic, strong) NSString *endAddress;
@property (nonatomic, assign) double endLatitude;
@property (nonatomic, assign) double startLongitude;
@property (nonatomic, assign) double fuelRange;
@property (nonatomic, assign) double startLatitude;
@property (nonatomic, assign) double folderId;
@property (nonatomic, assign) double routeIdentifier;
@property (nonatomic, assign) double endLongitude;
@property (nonatomic, strong) NSString *deletedAt;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) double sharingLevel;
@property (nonatomic, strong) NSString *startAddress;
@property (nonatomic, strong) NSString *currentStyle;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *lock;
@property (nonatomic, strong) NSString *routeDescription;

+ (Route *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
