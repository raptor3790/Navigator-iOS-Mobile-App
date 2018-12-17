//
//  Settings.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"


NSString *const kSettingsShowheadings = @"showheadings";
NSString *const kSettingsShowAlternateDistance = @"showAlternateDistance";
NSString *const kSettingsUnits = @"units";
NSString *const kSettingsShowStickMarkOnTulips = @"showStickMarkOnTulips";
NSString *const kSettingsShowcoordinates = @"showcoordinates";


@interface Settings ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Settings

@synthesize showheadings = _showheadings;
@synthesize showAlternateDistance = _showAlternateDistance;
@synthesize units = _units;
@synthesize showStickMarkOnTulips = _showStickMarkOnTulips;
@synthesize showcoordinates = _showcoordinates;


+ (Settings *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Settings *instance = [[Settings alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.showheadings = [[self objectOrNilForKey:kSettingsShowheadings fromDictionary:dict] boolValue];
            self.showAlternateDistance = [[self objectOrNilForKey:kSettingsShowAlternateDistance fromDictionary:dict] boolValue];
            self.units = [self objectOrNilForKey:kSettingsUnits fromDictionary:dict];
            self.showStickMarkOnTulips = [[self objectOrNilForKey:kSettingsShowStickMarkOnTulips fromDictionary:dict] boolValue];
            self.showcoordinates = [[self objectOrNilForKey:kSettingsShowcoordinates fromDictionary:dict] boolValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.showheadings] forKey:kSettingsShowheadings];
    [mutableDict setValue:[NSNumber numberWithBool:self.showAlternateDistance] forKey:kSettingsShowAlternateDistance];
    [mutableDict setValue:self.units forKey:kSettingsUnits];
    [mutableDict setValue:[NSNumber numberWithBool:self.showStickMarkOnTulips] forKey:kSettingsShowStickMarkOnTulips];
    [mutableDict setValue:[NSNumber numberWithBool:self.showcoordinates] forKey:kSettingsShowcoordinates];

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

    self.showheadings = [aDecoder decodeBoolForKey:kSettingsShowheadings];
    self.showAlternateDistance = [aDecoder decodeBoolForKey:kSettingsShowAlternateDistance];
    self.units = [aDecoder decodeObjectForKey:kSettingsUnits];
    self.showStickMarkOnTulips = [aDecoder decodeBoolForKey:kSettingsShowStickMarkOnTulips];
    self.showcoordinates = [aDecoder decodeBoolForKey:kSettingsShowcoordinates];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_showheadings forKey:kSettingsShowheadings];
    [aCoder encodeBool:_showAlternateDistance forKey:kSettingsShowAlternateDistance];
    [aCoder encodeObject:_units forKey:kSettingsUnits];
    [aCoder encodeBool:_showStickMarkOnTulips forKey:kSettingsShowStickMarkOnTulips];
    [aCoder encodeBool:_showcoordinates forKey:kSettingsShowcoordinates];
}


@end
