//
//  Location.m
//
//  Created by C205  on 22/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "Locations.h"


NSString *const kLocationLocationId = @"locationId";
NSString *const kLocationIsWayPoint = @"isWayPoint";
NSString *const kLocationLongitude = @"longitude";
NSString *const kLocationLatitude = @"latitude";
NSString *const kLocationText = @"text";
NSString *const kLocationImageUrl = @"imageUrl";
NSString *const kLocationAudioUrl = @"audioUrl";


@interface Locations ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Locations

@synthesize locationId = _locationId;
@synthesize isWayPoint = _isWayPoint;
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize text = _text;
@synthesize imageUrl = _imageUrl;
@synthesize audioUrl = _audioUrl;

+ (Locations *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Locations *instance = [[Locations alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.locationId = [[self objectOrNilForKey:kLocationLocationId fromDictionary:dict] doubleValue];
            self.isWayPoint = [[self objectOrNilForKey:kLocationIsWayPoint fromDictionary:dict] boolValue];
            self.longitude = [[self objectOrNilForKey:kLocationLongitude fromDictionary:dict] doubleValue];
            self.latitude = [[self objectOrNilForKey:kLocationLatitude fromDictionary:dict] doubleValue];
            self.text = [self objectOrNilForKey:kLocationText fromDictionary:dict];
        self.imageUrl = [self objectOrNilForKey:kLocationImageUrl fromDictionary:dict];
        self.audioUrl = [self objectOrNilForKey:kLocationAudioUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locationId] forKey:kLocationLocationId];
    [mutableDict setValue:[NSNumber numberWithBool:self.isWayPoint] forKey:kLocationIsWayPoint];
    [mutableDict setValue:[NSNumber numberWithDouble:self.longitude] forKey:kLocationLongitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.latitude] forKey:kLocationLatitude];
    [mutableDict setValue:self.text forKey:kLocationText];
    [mutableDict setValue:self.imageUrl forKey:kLocationImageUrl];
    [mutableDict setValue:self.audioUrl forKey:kLocationAudioUrl];

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

    self.locationId = [aDecoder decodeDoubleForKey:kLocationLocationId];
    self.isWayPoint = [aDecoder decodeBoolForKey:kLocationIsWayPoint];
    self.longitude = [aDecoder decodeDoubleForKey:kLocationLongitude];
    self.latitude = [aDecoder decodeDoubleForKey:kLocationLatitude];
    self.text = [aDecoder decodeObjectForKey:kLocationText];
    self.imageUrl = [aDecoder decodeObjectForKey:kLocationImageUrl];
    self.audioUrl = [aDecoder decodeObjectForKey:kLocationAudioUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:_locationId forKey:kLocationLocationId];
    [aCoder encodeBool:_isWayPoint forKey:kLocationIsWayPoint];
    [aCoder encodeDouble:_longitude forKey:kLocationLongitude];
    [aCoder encodeDouble:_latitude forKey:kLocationLatitude];
    [aCoder encodeObject:_text forKey:kLocationText];
    [aCoder encodeObject:_imageUrl forKey:kLocationImageUrl];
    [aCoder encodeObject:_audioUrl forKey:kLocationAudioUrl];
}


@end
