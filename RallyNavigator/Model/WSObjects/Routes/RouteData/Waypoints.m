//
//  Waypoints.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Waypoints.h"
#import "VoiceNote.h"
#import "GravelLine.h"
#import "Backgroundimage.h"
#import "Td.h"


NSString *const kWaypointsShowStickMarkOnTulip = @"showStickMarkOnTulip";
NSString *const kWaypointsEle = @"ele";
NSString *const kWaypointsLon = @"lon";
NSString *const kWaypointsVoiceNote = @"voiceNote";
NSString *const kWaypointsTrayIcons = @"trayIcons";
NSString *const kWaypointsGravelLine = @"gravelLine";
NSString *const kWaypointsShow = @"show";
NSString *const kWaypointsStreetSignIcons = @"streetSignIcons";
NSString *const kWaypointsBackgroundimage = @"backgroundimage";
NSString *const kWaypointsTd = @"td";
NSString *const kWaypointsLat = @"lat";
NSString *const kWaypointsFreelines = @"freelines";
NSString *const kWaypointsWaypointid = @"waypointid";
NSString *const kWaypointsRoads = @"roads";
NSString *const kWaypointsAlt = @"alt";
NSString *const kWaypointsCellPhoneStage = @"cellPhoneStage";
NSString *const kWaypointsIcons = @"icons";
NSString *const kWaypointsDescription = @"description";


@interface Waypoints ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Waypoints

@synthesize showStickMarkOnTulip = _showStickMarkOnTulip;
@synthesize ele = _ele;
@synthesize lon = _lon;
@synthesize voiceNote = _voiceNote;
@synthesize trayIcons = _trayIcons;
@synthesize gravelLine = _gravelLine;
@synthesize show = _show;
@synthesize streetSignIcons = _streetSignIcons;
@synthesize backgroundimage = _backgroundimage;
@synthesize td = _td;
@synthesize lat = _lat;
@synthesize freelines = _freelines;
@synthesize waypointid = _waypointid;
@synthesize roads = _roads;
@synthesize alt = _alt;
@synthesize cellPhoneStage = _cellPhoneStage;
@synthesize icons = _icons;
@synthesize wayPointDescription = _wayPointDescription;

+ (Waypoints *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Waypoints *instance = [[Waypoints alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.showStickMarkOnTulip = [[self objectOrNilForKey:kWaypointsShowStickMarkOnTulip fromDictionary:dict] boolValue];
            self.ele = [self objectOrNilForKey:kWaypointsEle fromDictionary:dict];
            self.lon = [[self objectOrNilForKey:kWaypointsLon fromDictionary:dict] doubleValue];
            self.voiceNote = [VoiceNote modelObjectWithDictionary:[dict objectForKey:kWaypointsVoiceNote]];
            self.trayIcons = [self objectOrNilForKey:kWaypointsTrayIcons fromDictionary:dict];
            self.gravelLine = [GravelLine modelObjectWithDictionary:[dict objectForKey:kWaypointsGravelLine]];
            self.show = [[self objectOrNilForKey:kWaypointsShow fromDictionary:dict] boolValue];
            self.streetSignIcons = [self objectOrNilForKey:kWaypointsStreetSignIcons fromDictionary:dict];
            self.backgroundimage = [Backgroundimage modelObjectWithDictionary:[dict objectForKey:kWaypointsBackgroundimage]];
            self.td = [Td modelObjectWithDictionary:[dict objectForKey:kWaypointsTd]];
            self.lat = [[self objectOrNilForKey:kWaypointsLat fromDictionary:dict] doubleValue];
            self.freelines = [self objectOrNilForKey:kWaypointsFreelines fromDictionary:dict];
            self.waypointid = [[self objectOrNilForKey:kWaypointsWaypointid fromDictionary:dict] doubleValue];
            self.roads = [self objectOrNilForKey:kWaypointsRoads fromDictionary:dict];
            self.alt = [self objectOrNilForKey:kWaypointsAlt fromDictionary:dict];
            self.cellPhoneStage = [[self objectOrNilForKey:kWaypointsCellPhoneStage fromDictionary:dict] doubleValue];
            self.icons = [self objectOrNilForKey:kWaypointsIcons fromDictionary:dict];
        self.wayPointDescription = [self objectOrNilForKey:kWaypointsDescription fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.showStickMarkOnTulip] forKey:kWaypointsShowStickMarkOnTulip];
    [mutableDict setValue:self.ele forKey:kWaypointsEle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lon] forKey:kWaypointsLon];
    [mutableDict setValue:[self.voiceNote dictionaryRepresentation] forKey:kWaypointsVoiceNote];
NSMutableArray *tempArrayForTrayIcons = [NSMutableArray array];
    for (NSObject *subArrayObject in self.trayIcons) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForTrayIcons addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForTrayIcons addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForTrayIcons] forKey:@"trayIcons"];
    [mutableDict setValue:[self.gravelLine dictionaryRepresentation] forKey:kWaypointsGravelLine];
    [mutableDict setValue:[NSNumber numberWithBool:self.show] forKey:kWaypointsShow];
NSMutableArray *tempArrayForStreetSignIcons = [NSMutableArray array];
    for (NSObject *subArrayObject in self.streetSignIcons) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForStreetSignIcons addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForStreetSignIcons addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForStreetSignIcons] forKey:@"streetSignIcons"];
    [mutableDict setValue:[self.backgroundimage dictionaryRepresentation] forKey:kWaypointsBackgroundimage];
    [mutableDict setValue:[self.td dictionaryRepresentation] forKey:kWaypointsTd];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lat] forKey:kWaypointsLat];
NSMutableArray *tempArrayForFreelines = [NSMutableArray array];
    for (NSObject *subArrayObject in self.freelines) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForFreelines addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForFreelines addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFreelines] forKey:@"freelines"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.waypointid] forKey:kWaypointsWaypointid];
NSMutableArray *tempArrayForRoads = [NSMutableArray array];
    for (NSObject *subArrayObject in self.roads) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForRoads addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForRoads addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForRoads] forKey:@"roads"];
    [mutableDict setValue:self.alt forKey:kWaypointsAlt];
    [mutableDict setValue:[NSNumber numberWithDouble:self.cellPhoneStage] forKey:kWaypointsCellPhoneStage];
NSMutableArray *tempArrayForIcons = [NSMutableArray array];
    for (NSObject *subArrayObject in self.icons) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForIcons addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForIcons addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForIcons] forKey:@"icons"];
    [mutableDict setValue:self.wayPointDescription forKey:kWaypointsDescription];

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

    self.showStickMarkOnTulip = [aDecoder decodeBoolForKey:kWaypointsShowStickMarkOnTulip];
    self.ele = [aDecoder decodeObjectForKey:kWaypointsEle];
    self.lon = [aDecoder decodeDoubleForKey:kWaypointsLon];
    self.voiceNote = [aDecoder decodeObjectForKey:kWaypointsVoiceNote];
    self.trayIcons = [aDecoder decodeObjectForKey:kWaypointsTrayIcons];
    self.gravelLine = [aDecoder decodeObjectForKey:kWaypointsGravelLine];
    self.show = [aDecoder decodeBoolForKey:kWaypointsShow];
    self.streetSignIcons = [aDecoder decodeObjectForKey:kWaypointsStreetSignIcons];
    self.backgroundimage = [aDecoder decodeObjectForKey:kWaypointsBackgroundimage];
    self.td = [aDecoder decodeObjectForKey:kWaypointsTd];
    self.lat = [aDecoder decodeDoubleForKey:kWaypointsLat];
    self.freelines = [aDecoder decodeObjectForKey:kWaypointsFreelines];
    self.waypointid = [aDecoder decodeDoubleForKey:kWaypointsWaypointid];
    self.roads = [aDecoder decodeObjectForKey:kWaypointsRoads];
    self.alt = [aDecoder decodeObjectForKey:kWaypointsAlt];
    self.cellPhoneStage = [aDecoder decodeDoubleForKey:kWaypointsCellPhoneStage];
    self.icons = [aDecoder decodeObjectForKey:kWaypointsIcons];
    self.wayPointDescription = [aDecoder decodeObjectForKey:kWaypointsDescription];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_showStickMarkOnTulip forKey:kWaypointsShowStickMarkOnTulip];
    [aCoder encodeObject:_ele forKey:kWaypointsEle];
    [aCoder encodeDouble:_lon forKey:kWaypointsLon];
    [aCoder encodeObject:_voiceNote forKey:kWaypointsVoiceNote];
    [aCoder encodeObject:_trayIcons forKey:kWaypointsTrayIcons];
    [aCoder encodeObject:_gravelLine forKey:kWaypointsGravelLine];
    [aCoder encodeBool:_show forKey:kWaypointsShow];
    [aCoder encodeObject:_streetSignIcons forKey:kWaypointsStreetSignIcons];
    [aCoder encodeObject:_backgroundimage forKey:kWaypointsBackgroundimage];
    [aCoder encodeObject:_td forKey:kWaypointsTd];
    [aCoder encodeDouble:_lat forKey:kWaypointsLat];
    [aCoder encodeObject:_freelines forKey:kWaypointsFreelines];
    [aCoder encodeDouble:_waypointid forKey:kWaypointsWaypointid];
    [aCoder encodeObject:_roads forKey:kWaypointsRoads];
    [aCoder encodeObject:_alt forKey:kWaypointsAlt];
    [aCoder encodeDouble:_cellPhoneStage forKey:kWaypointsCellPhoneStage];
    [aCoder encodeObject:_icons forKey:kWaypointsIcons];
    [aCoder encodeObject:_wayPointDescription forKey:kWaypointsDescription];

}


@end
