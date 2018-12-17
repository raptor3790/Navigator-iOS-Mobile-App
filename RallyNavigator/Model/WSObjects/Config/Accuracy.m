//
//  Accuracy.m
//
//  Created by C205  on 10/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Accuracy.h"


NSString *const kAccuracyMinDistanceTrackpoint = @"minDistanceTrackpoint";
NSString *const kAccuracyAngle = @"angle";
NSString *const kAccuracyAccuracy = @"accuracy";
NSString *const kAccuracyDistance = @"distance";


@interface Accuracy ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Accuracy

@synthesize minDistanceTrackpoint = _minDistanceTrackpoint;
@synthesize angle = _angle;
@synthesize accuracy = _accuracy;
@synthesize distance = _distance;


+ (Accuracy *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Accuracy *instance = [[Accuracy alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.minDistanceTrackpoint = [[self objectOrNilForKey:kAccuracyMinDistanceTrackpoint fromDictionary:dict] doubleValue];
            self.angle = [[self objectOrNilForKey:kAccuracyAngle fromDictionary:dict] doubleValue];
            self.accuracy = [[self objectOrNilForKey:kAccuracyAccuracy fromDictionary:dict] doubleValue];
            self.distance = [[self objectOrNilForKey:kAccuracyDistance fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.minDistanceTrackpoint] forKey:kAccuracyMinDistanceTrackpoint];
    [mutableDict setValue:[NSNumber numberWithDouble:self.angle] forKey:kAccuracyAngle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.accuracy] forKey:kAccuracyAccuracy];
    [mutableDict setValue:[NSNumber numberWithDouble:self.distance] forKey:kAccuracyDistance];

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

    self.minDistanceTrackpoint = [aDecoder decodeDoubleForKey:kAccuracyMinDistanceTrackpoint];
    self.angle = [aDecoder decodeDoubleForKey:kAccuracyAngle];
    self.accuracy = [aDecoder decodeDoubleForKey:kAccuracyAccuracy];
    self.distance = [aDecoder decodeDoubleForKey:kAccuracyDistance];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_minDistanceTrackpoint forKey:kAccuracyMinDistanceTrackpoint];
    [aCoder encodeDouble:_angle forKey:kAccuracyAngle];
    [aCoder encodeDouble:_accuracy forKey:kAccuracyAccuracy];
    [aCoder encodeDouble:_distance forKey:kAccuracyDistance];
}


@end
