//
//  Route.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Route.h"


NSString *const kRouteUserId = @"user_id";
NSString *const kRouteUpdatedAt = @"updated_at";
NSString *const kRouteEndAddress = @"end_address";
NSString *const kRouteEndLatitude = @"end_latitude";
NSString *const kRouteWaypointCount = @"waypoint_count";
NSString *const kRouteStartLongitude = @"start_longitude";
NSString *const kRouteFuelRange = @"fuel_range";
NSString *const kRouteName = @"name";
NSString *const kRouteStartLatitude = @"start_latitude";
NSString *const kRouteFolderId = @"folder_id";
NSString *const kRouteId = @"id";
NSString *const kRouteLength = @"length";
NSString *const kRouteUnits = @"units";
NSString *const kRouteEndLongitude = @"end_longitude";
NSString *const kRouteDeletedAt = @"deleted_at";
NSString *const kRouteToken = @"token";
NSString *const kRouteSharingLevel = @"sharing_level";
NSString *const kRouteStartAddress = @"start_address";
NSString *const kRouteCurrentStyle = @"current_style";
NSString *const kRouteData = @"data";
NSString *const kRouteLock = @"lock";
NSString *const kRouteDescription = @"description";


@interface Route ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Route

@synthesize userId = _userId;
@synthesize updatedAt = _updatedAt;
@synthesize endAddress = _endAddress;
@synthesize endLatitude = _endLatitude;
@synthesize waypointCount = _waypointCount;
@synthesize startLongitude = _startLongitude;
@synthesize fuelRange = _fuelRange;
@synthesize name = _name;
@synthesize startLatitude = _startLatitude;
@synthesize folderId = _folderId;
@synthesize routeIdentifier = _routeIdentifier;
@synthesize length = _length;
@synthesize units = _units;
@synthesize endLongitude = _endLongitude;
@synthesize deletedAt = _deletedAt;
@synthesize token = _token;
@synthesize sharingLevel = _sharingLevel;
@synthesize startAddress = _startAddress;
@synthesize currentStyle = _currentStyle;
@synthesize data = _data;
@synthesize lock = _lock;
@synthesize routeDescription = _routeDescription;


+ (Route *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Route *instance = [[Route alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.userId = [[self objectOrNilForKey:kRouteUserId fromDictionary:dict] doubleValue];
            self.updatedAt = [self objectOrNilForKey:kRouteUpdatedAt fromDictionary:dict];
            self.endAddress = [self objectOrNilForKey:kRouteEndAddress fromDictionary:dict];
            self.endLatitude = [[self objectOrNilForKey:kRouteEndLatitude fromDictionary:dict] doubleValue];
            self.waypointCount = [[self objectOrNilForKey:kRouteWaypointCount fromDictionary:dict] doubleValue];
            self.startLongitude = [[self objectOrNilForKey:kRouteStartLongitude fromDictionary:dict] doubleValue];
            self.fuelRange = [[self objectOrNilForKey:kRouteFuelRange fromDictionary:dict] doubleValue];
            self.name = [self objectOrNilForKey:kRouteName fromDictionary:dict];
            self.startLatitude = [[self objectOrNilForKey:kRouteStartLatitude fromDictionary:dict] doubleValue];
            self.folderId = [[self objectOrNilForKey:kRouteFolderId fromDictionary:dict] doubleValue];
            self.routeIdentifier = [[self objectOrNilForKey:kRouteId fromDictionary:dict] doubleValue];
            self.length = [[self objectOrNilForKey:kRouteLength fromDictionary:dict] doubleValue];
            self.units = [self objectOrNilForKey:kRouteUnits fromDictionary:dict];
            self.endLongitude = [[self objectOrNilForKey:kRouteEndLongitude fromDictionary:dict] doubleValue];
            self.deletedAt = [self objectOrNilForKey:kRouteDeletedAt fromDictionary:dict];
            self.token = [self objectOrNilForKey:kRouteToken fromDictionary:dict];
            self.sharingLevel = [[self objectOrNilForKey:kRouteSharingLevel fromDictionary:dict] doubleValue];
            self.startAddress = [self objectOrNilForKey:kRouteStartAddress fromDictionary:dict];
            self.currentStyle = [self objectOrNilForKey:kRouteCurrentStyle fromDictionary:dict];
            self.data = [self objectOrNilForKey:kRouteData fromDictionary:dict];
            self.lock = [self objectOrNilForKey:kRouteLock fromDictionary:dict];
            self.routeDescription = [self objectOrNilForKey:kRouteDescription fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userId] forKey:kRouteUserId];
    [mutableDict setValue:self.updatedAt forKey:kRouteUpdatedAt];
    [mutableDict setValue:self.endAddress forKey:kRouteEndAddress];
    [mutableDict setValue:[NSNumber numberWithDouble:self.endLatitude] forKey:kRouteEndLatitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.waypointCount] forKey:kRouteWaypointCount];
    [mutableDict setValue:[NSNumber numberWithDouble:self.startLongitude] forKey:kRouteStartLongitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.fuelRange] forKey:kRouteFuelRange];
    [mutableDict setValue:self.name forKey:kRouteName];
    [mutableDict setValue:[NSNumber numberWithDouble:self.startLatitude] forKey:kRouteStartLatitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.folderId] forKey:kRouteFolderId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routeIdentifier] forKey:kRouteId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.length] forKey:kRouteLength];
    [mutableDict setValue:self.units forKey:kRouteUnits];
    [mutableDict setValue:[NSNumber numberWithDouble:self.endLongitude] forKey:kRouteEndLongitude];
    [mutableDict setValue:self.deletedAt forKey:kRouteDeletedAt];
    [mutableDict setValue:self.token forKey:kRouteToken];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sharingLevel] forKey:kRouteSharingLevel];
    [mutableDict setValue:self.startAddress forKey:kRouteStartAddress];
    [mutableDict setValue:self.currentStyle forKey:kRouteCurrentStyle];
    [mutableDict setValue:self.data forKey:kRouteData];
    [mutableDict setValue:self.lock forKey:kRouteLock];
    [mutableDict setValue:self.routeDescription forKey:kRouteDescription];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.userId = [aDecoder decodeDoubleForKey:kRouteUserId];
    self.updatedAt = [aDecoder decodeObjectForKey:kRouteUpdatedAt];
    self.endAddress = [aDecoder decodeObjectForKey:kRouteEndAddress];
    self.endLatitude = [aDecoder decodeDoubleForKey:kRouteEndLatitude];
    self.waypointCount = [aDecoder decodeDoubleForKey:kRouteWaypointCount];
    self.startLongitude = [aDecoder decodeDoubleForKey:kRouteStartLongitude];
    self.fuelRange = [aDecoder decodeDoubleForKey:kRouteFuelRange];
    self.name = [aDecoder decodeObjectForKey:kRouteName];
    self.startLatitude = [aDecoder decodeDoubleForKey:kRouteStartLatitude];
    self.folderId = [aDecoder decodeDoubleForKey:kRouteFolderId];
    self.routeIdentifier = [aDecoder decodeDoubleForKey:kRouteId];
    self.length = [aDecoder decodeDoubleForKey:kRouteLength];
    self.units = [aDecoder decodeObjectForKey:kRouteUnits];
    self.endLongitude = [aDecoder decodeDoubleForKey:kRouteEndLongitude];
    self.deletedAt = [aDecoder decodeObjectForKey:kRouteDeletedAt];
    self.token = [aDecoder decodeObjectForKey:kRouteToken];
    self.sharingLevel = [aDecoder decodeDoubleForKey:kRouteSharingLevel];
    self.startAddress = [aDecoder decodeObjectForKey:kRouteStartAddress];
    self.currentStyle = [aDecoder decodeObjectForKey:kRouteCurrentStyle];
    self.data = [aDecoder decodeObjectForKey:kRouteData];
    self.lock = [aDecoder decodeObjectForKey:kRouteLock];
    self.routeDescription = [aDecoder decodeObjectForKey:kRouteDescription];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_userId forKey:kRouteUserId];
    [aCoder encodeObject:_updatedAt forKey:kRouteUpdatedAt];
    [aCoder encodeObject:_endAddress forKey:kRouteEndAddress];
    [aCoder encodeDouble:_endLatitude forKey:kRouteEndLatitude];
    [aCoder encodeDouble:_waypointCount forKey:kRouteWaypointCount];
    [aCoder encodeDouble:_startLongitude forKey:kRouteStartLongitude];
    [aCoder encodeDouble:_fuelRange forKey:kRouteFuelRange];
    [aCoder encodeObject:_name forKey:kRouteName];
    [aCoder encodeDouble:_startLatitude forKey:kRouteStartLatitude];
    [aCoder encodeDouble:_folderId forKey:kRouteFolderId];
    [aCoder encodeDouble:_routeIdentifier forKey:kRouteId];
    [aCoder encodeDouble:_length forKey:kRouteLength];
    [aCoder encodeObject:_units forKey:kRouteUnits];
    [aCoder encodeDouble:_endLongitude forKey:kRouteEndLongitude];
    [aCoder encodeObject:_deletedAt forKey:kRouteDeletedAt];
    [aCoder encodeObject:_token forKey:kRouteToken];
    [aCoder encodeDouble:_sharingLevel forKey:kRouteSharingLevel];
    [aCoder encodeObject:_startAddress forKey:kRouteStartAddress];
    [aCoder encodeObject:_currentStyle forKey:kRouteCurrentStyle];
    [aCoder encodeObject:_data forKey:kRouteData];
    [aCoder encodeObject:_lock forKey:kRouteLock];
    [aCoder encodeObject:_routeDescription forKey:kRouteDescription];
}


@end
