//
//  Coord.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Coord.h"


NSString *const kCoordAddressshort = @"addressshort";
NSString *const kCoordAddresslong = @"addresslong";
NSString *const kCoordLat = @"lat";
NSString *const kCoordAddresscustom = @"addresscustom";
NSString *const kCoordLon = @"lon";
NSString *const kCoordAddressoption = @"addressoption";


@interface Coord ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Coord

@synthesize addressshort = _addressshort;
@synthesize addresslong = _addresslong;
@synthesize lat = _lat;
@synthesize addresscustom = _addresscustom;
@synthesize lon = _lon;
@synthesize addressoption = _addressoption;


+ (Coord *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Coord *instance = [[Coord alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.addressshort = [self objectOrNilForKey:kCoordAddressshort fromDictionary:dict];
            self.addresslong = [self objectOrNilForKey:kCoordAddresslong fromDictionary:dict];
            self.lat = [[self objectOrNilForKey:kCoordLat fromDictionary:dict] doubleValue];
            self.addresscustom = [self objectOrNilForKey:kCoordAddresscustom fromDictionary:dict];
            self.lon = [[self objectOrNilForKey:kCoordLon fromDictionary:dict] doubleValue];
            self.addressoption = [[self objectOrNilForKey:kCoordAddressoption fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.addressshort forKey:kCoordAddressshort];
    [mutableDict setValue:self.addresslong forKey:kCoordAddresslong];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lat] forKey:kCoordLat];
    [mutableDict setValue:self.addresscustom forKey:kCoordAddresscustom];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lon] forKey:kCoordLon];
    [mutableDict setValue:[NSNumber numberWithDouble:self.addressoption] forKey:kCoordAddressoption];

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

    self.addressshort = [aDecoder decodeObjectForKey:kCoordAddressshort];
    self.addresslong = [aDecoder decodeObjectForKey:kCoordAddresslong];
    self.lat = [aDecoder decodeDoubleForKey:kCoordLat];
    self.addresscustom = [aDecoder decodeObjectForKey:kCoordAddresscustom];
    self.lon = [aDecoder decodeDoubleForKey:kCoordLon];
    self.addressoption = [aDecoder decodeDoubleForKey:kCoordAddressoption];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_addressshort forKey:kCoordAddressshort];
    [aCoder encodeObject:_addresslong forKey:kCoordAddresslong];
    [aCoder encodeDouble:_lat forKey:kCoordLat];
    [aCoder encodeObject:_addresscustom forKey:kCoordAddresscustom];
    [aCoder encodeDouble:_lon forKey:kCoordLon];
    [aCoder encodeDouble:_addressoption forKey:kCoordAddressoption];
}


@end
