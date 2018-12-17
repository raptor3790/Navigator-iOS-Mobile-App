//
//  Config.m
//
//  Created by C205  on 10/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Config.h"
#import "Rotation.h"
#import "Accuracy.h"


NSString *const kConfigAction = @"action";
NSString *const kConfigUnit = @"unit";
NSString *const kConfigRotation = @"rotation";
NSString *const kConfigSync = @"sync";
NSString *const kConfigAccuracy = @"accuracy";
NSString *const kConfigAutoCamera = @"autoCamera";
NSString *const kConfigOdo = @"odo";


@interface Config ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Config

@synthesize action = _action;
@synthesize unit = _unit;
@synthesize rotation = _rotation;
@synthesize sync = _sync;
@synthesize accuracy = _accuracy;
@synthesize autoCamera = _autoCamera;
@synthesize odo = _odo;


+ (Config *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Config *instance = [[Config alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.action = [self objectOrNilForKey:kConfigAction fromDictionary:dict];
            self.unit = [self objectOrNilForKey:kConfigUnit fromDictionary:dict];
            self.rotation = [Rotation modelObjectWithDictionary:[dict objectForKey:kConfigRotation]];
            self.sync = [self objectOrNilForKey:kConfigSync fromDictionary:dict];
            self.accuracy = [Accuracy modelObjectWithDictionary:[dict objectForKey:kConfigAccuracy]];
            self.autoCamera = [[self objectOrNilForKey:kConfigAutoCamera fromDictionary:dict] boolValue];
            self.odo = [self objectOrNilForKey:kConfigOdo fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.action forKey:kConfigAction];
    [mutableDict setValue:self.unit forKey:kConfigUnit];
    [mutableDict setValue:[self.rotation dictionaryRepresentation] forKey:kConfigRotation];
    [mutableDict setValue:self.sync forKey:kConfigSync];
    [mutableDict setValue:[self.accuracy dictionaryRepresentation] forKey:kConfigAccuracy];
    [mutableDict setValue:[NSNumber numberWithBool:self.autoCamera] forKey:kConfigAutoCamera];
    [mutableDict setValue:self.odo forKey:kConfigOdo];

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

    self.action = [aDecoder decodeObjectForKey:kConfigAction];
    self.unit = [aDecoder decodeObjectForKey:kConfigUnit];
    self.rotation = [aDecoder decodeObjectForKey:kConfigRotation];
    self.sync = [aDecoder decodeObjectForKey:kConfigSync];
    self.accuracy = [aDecoder decodeObjectForKey:kConfigAccuracy];
    self.autoCamera = [aDecoder decodeBoolForKey:kConfigAutoCamera];
    self.odo = [aDecoder decodeObjectForKey:kConfigOdo];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_action forKey:kConfigAction];
    [aCoder encodeObject:_unit forKey:kConfigUnit];
    [aCoder encodeObject:_rotation forKey:kConfigRotation];
    [aCoder encodeObject:_sync forKey:kConfigSync];
    [aCoder encodeObject:_accuracy forKey:kConfigAccuracy];
    [aCoder encodeBool:_autoCamera forKey:kConfigAutoCamera];
    [aCoder encodeObject:_odo forKey:kConfigOdo];
}


@end
