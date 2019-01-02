//
//  RouteDetails.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "RouteDetails.h"
#import "Summary.h"
#import "Waypoints.h"
#import "Settings.h"


NSString *const kRouteDetailsTcendnumber = @"tcendnumber";
NSString *const kRouteDetailsAverageTimeOption = @"averageTimeOption";
NSString *const kRouteDetailsSsheaderinfo = @"ssheaderinfo";
NSString *const kRouteDetailsSummary = @"summary";
NSString *const kRouteDetailsCurrentStyle = @"currentStyle";
NSString *const kRouteDetailsTcstart = @"tcstart";
NSString *const kRouteDetailsTcend = @"tcend";
NSString *const kRouteDetailsDay = @"day";
NSString *const kRouteDetailsName = @"name";
NSString *const kRouteDetailsTcEndOption = @"tcEndOption";
NSString *const kRouteDetailsWaypoints = @"waypoints";
NSString *const kRouteDetailsFolderId = @"folder_id";
NSString *const kRouteDetailsId = @"id";
NSString *const kRouteDetailsCustomAverageData = @"customAverageData";
NSString *const kRouteDetailsTimeallowed = @"timeallowed";
NSString *const kRouteDetailsSettings = @"settings";
NSString *const kRouteDetailsTcstartnumber = @"tcstartnumber";
NSString *const kRouteDetailsTcStartOption = @"tcStartOption";
NSString *const kRouteDetailsDataVersion = @"dataVersion";
NSString *const kRouteDetailsSection = @"section";
NSString *const kRouteDetailsDescription = @"description";


@interface RouteDetails ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation RouteDetails

@synthesize tcendnumber = _tcendnumber;
@synthesize averageTimeOption = _averageTimeOption;
@synthesize ssheaderinfo = _ssheaderinfo;
@synthesize summary = _summary;
@synthesize currentStyle = _currentStyle;
@synthesize tcstart = _tcstart;
@synthesize tcend = _tcend;
@synthesize day = _day;
@synthesize name = _name;
@synthesize tcEndOption = _tcEndOption;
@synthesize waypoints = _waypoints;
@synthesize folderId = _folderId;
@synthesize internalBaseClassIdentifier = _internalBaseClassIdentifier;
@synthesize customAverageData = _customAverageData;
@synthesize timeallowed = _timeallowed;
@synthesize settings = _settings;
@synthesize tcstartnumber = _tcstartnumber;
@synthesize tcStartOption = _tcStartOption;
@synthesize dataVersion = _dataVersion;
@synthesize section = _section;
@synthesize internalBaseClassDescription = _internalBaseClassDescription;


+ (RouteDetails *)modelObjectWithDictionary:(NSDictionary *)dict
{
    RouteDetails *instance = [[RouteDetails alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.tcendnumber = [[self objectOrNilForKey:kRouteDetailsTcendnumber fromDictionary:dict] doubleValue];
            self.averageTimeOption = [[self objectOrNilForKey:kRouteDetailsAverageTimeOption fromDictionary:dict] doubleValue];
            self.ssheaderinfo = [self objectOrNilForKey:kRouteDetailsSsheaderinfo fromDictionary:dict];
            self.summary = [Summary modelObjectWithDictionary:[dict objectForKey:kRouteDetailsSummary]];
            self.currentStyle = [self objectOrNilForKey:kRouteDetailsCurrentStyle fromDictionary:dict];
            self.tcstart = [self objectOrNilForKey:kRouteDetailsTcstart fromDictionary:dict];
            self.tcend = [self objectOrNilForKey:kRouteDetailsTcend fromDictionary:dict];
            self.day = [self objectOrNilForKey:kRouteDetailsDay fromDictionary:dict];
            self.name = [self objectOrNilForKey:kRouteDetailsName fromDictionary:dict];
            self.tcEndOption = [[self objectOrNilForKey:kRouteDetailsTcEndOption fromDictionary:dict] doubleValue];
    NSObject *receivedWaypoints = [dict objectForKey:kRouteDetailsWaypoints];
    NSMutableArray *parsedWaypoints = [NSMutableArray array];
    if ([receivedWaypoints isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedWaypoints) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedWaypoints addObject:[Waypoints modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedWaypoints isKindOfClass:[NSDictionary class]]) {
       [parsedWaypoints addObject:[Waypoints modelObjectWithDictionary:(NSDictionary *)receivedWaypoints]];
    }

    self.waypoints = [NSArray arrayWithArray:parsedWaypoints];
            self.folderId = [self objectOrNilForKey:kRouteDetailsFolderId fromDictionary:dict];
            self.internalBaseClassIdentifier = [[self objectOrNilForKey:kRouteDetailsId fromDictionary:dict] doubleValue];
            self.customAverageData = [self objectOrNilForKey:kRouteDetailsCustomAverageData fromDictionary:dict];
            self.timeallowed = [self objectOrNilForKey:kRouteDetailsTimeallowed fromDictionary:dict];
            self.settings = [Settings modelObjectWithDictionary:[dict objectForKey:kRouteDetailsSettings]];
            self.tcstartnumber = [self objectOrNilForKey:kRouteDetailsTcstartnumber fromDictionary:dict];
            self.tcStartOption = [[self objectOrNilForKey:kRouteDetailsTcStartOption fromDictionary:dict] doubleValue];
            self.dataVersion = [[self objectOrNilForKey:kRouteDetailsDataVersion fromDictionary:dict] doubleValue];
            self.section = [self objectOrNilForKey:kRouteDetailsSection fromDictionary:dict];
            self.internalBaseClassDescription = [self objectOrNilForKey:kRouteDetailsDescription fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.tcendnumber] forKey:kRouteDetailsTcendnumber];
    [mutableDict setValue:[NSNumber numberWithDouble:self.averageTimeOption] forKey:kRouteDetailsAverageTimeOption];
NSMutableArray *tempArrayForSsheaderinfo = [NSMutableArray array];
    for (NSObject *subArrayObject in self.ssheaderinfo) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForSsheaderinfo addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForSsheaderinfo addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForSsheaderinfo] forKey:@"ssheaderinfo"];
    [mutableDict setValue:[self.summary dictionaryRepresentation] forKey:kRouteDetailsSummary];
    [mutableDict setValue:self.currentStyle forKey:kRouteDetailsCurrentStyle];
    [mutableDict setValue:self.tcstart forKey:kRouteDetailsTcstart];
    [mutableDict setValue:self.tcend forKey:kRouteDetailsTcend];
    [mutableDict setValue:self.day forKey:kRouteDetailsDay];
    [mutableDict setValue:self.name forKey:kRouteDetailsName];
    [mutableDict setValue:[NSNumber numberWithDouble:self.tcEndOption] forKey:kRouteDetailsTcEndOption];
NSMutableArray *tempArrayForWaypoints = [NSMutableArray array];
    for (NSObject *subArrayObject in self.waypoints) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForWaypoints addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForWaypoints addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForWaypoints] forKey:@"waypoints"];
    [mutableDict setValue:self.folderId forKey:kRouteDetailsFolderId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.internalBaseClassIdentifier] forKey:kRouteDetailsId];
    [mutableDict setValue:self.customAverageData forKey:kRouteDetailsCustomAverageData];
    [mutableDict setValue:self.timeallowed forKey:kRouteDetailsTimeallowed];
    [mutableDict setValue:[self.settings dictionaryRepresentation] forKey:kRouteDetailsSettings];
    [mutableDict setValue:self.tcstartnumber forKey:kRouteDetailsTcstartnumber];
    [mutableDict setValue:[NSNumber numberWithDouble:self.tcStartOption] forKey:kRouteDetailsTcStartOption];
    [mutableDict setValue:[NSNumber numberWithDouble:self.dataVersion] forKey:kRouteDetailsDataVersion];
    [mutableDict setValue:self.section forKey:kRouteDetailsSection];
    [mutableDict setValue:self.internalBaseClassDescription forKey:kRouteDetailsDescription];

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

    self.tcendnumber = [aDecoder decodeDoubleForKey:kRouteDetailsTcendnumber];
    self.averageTimeOption = [aDecoder decodeDoubleForKey:kRouteDetailsAverageTimeOption];
    self.ssheaderinfo = [aDecoder decodeObjectForKey:kRouteDetailsSsheaderinfo];
    self.summary = [aDecoder decodeObjectForKey:kRouteDetailsSummary];
    self.currentStyle = [aDecoder decodeObjectForKey:kRouteDetailsCurrentStyle];
    self.tcstart = [aDecoder decodeObjectForKey:kRouteDetailsTcstart];
    self.tcend = [aDecoder decodeObjectForKey:kRouteDetailsTcend];
    self.day = [aDecoder decodeObjectForKey:kRouteDetailsDay];
    self.name = [aDecoder decodeObjectForKey:kRouteDetailsName];
    self.tcEndOption = [aDecoder decodeDoubleForKey:kRouteDetailsTcEndOption];
    self.waypoints = [aDecoder decodeObjectForKey:kRouteDetailsWaypoints];
    self.folderId = [aDecoder decodeObjectForKey:kRouteDetailsFolderId];
    self.internalBaseClassIdentifier = [aDecoder decodeDoubleForKey:kRouteDetailsId];
    self.customAverageData = [aDecoder decodeObjectForKey:kRouteDetailsCustomAverageData];
    self.timeallowed = [aDecoder decodeObjectForKey:kRouteDetailsTimeallowed];
    self.settings = [aDecoder decodeObjectForKey:kRouteDetailsSettings];
    self.tcstartnumber = [aDecoder decodeObjectForKey:kRouteDetailsTcstartnumber];
    self.tcStartOption = [aDecoder decodeDoubleForKey:kRouteDetailsTcStartOption];
    self.dataVersion = [aDecoder decodeDoubleForKey:kRouteDetailsDataVersion];
    self.section = [aDecoder decodeObjectForKey:kRouteDetailsSection];
    self.internalBaseClassDescription = [aDecoder decodeObjectForKey:kRouteDetailsDescription];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_tcendnumber forKey:kRouteDetailsTcendnumber];
    [aCoder encodeDouble:_averageTimeOption forKey:kRouteDetailsAverageTimeOption];
    [aCoder encodeObject:_ssheaderinfo forKey:kRouteDetailsSsheaderinfo];
    [aCoder encodeObject:_summary forKey:kRouteDetailsSummary];
    [aCoder encodeObject:_currentStyle forKey:kRouteDetailsCurrentStyle];
    [aCoder encodeObject:_tcstart forKey:kRouteDetailsTcstart];
    [aCoder encodeObject:_tcend forKey:kRouteDetailsTcend];
    [aCoder encodeObject:_day forKey:kRouteDetailsDay];
    [aCoder encodeObject:_name forKey:kRouteDetailsName];
    [aCoder encodeDouble:_tcEndOption forKey:kRouteDetailsTcEndOption];
    [aCoder encodeObject:_waypoints forKey:kRouteDetailsWaypoints];
    [aCoder encodeObject:_folderId forKey:kRouteDetailsFolderId];
    [aCoder encodeDouble:_internalBaseClassIdentifier forKey:kRouteDetailsId];
    [aCoder encodeObject:_customAverageData forKey:kRouteDetailsCustomAverageData];
    [aCoder encodeObject:_timeallowed forKey:kRouteDetailsTimeallowed];
    [aCoder encodeObject:_settings forKey:kRouteDetailsSettings];
    [aCoder encodeObject:_tcstartnumber forKey:kRouteDetailsTcstartnumber];
    [aCoder encodeDouble:_tcStartOption forKey:kRouteDetailsTcStartOption];
    [aCoder encodeDouble:_dataVersion forKey:kRouteDetailsDataVersion];
    [aCoder encodeObject:_section forKey:kRouteDetailsSection];
    [aCoder encodeObject:_internalBaseClassDescription forKey:kRouteDetailsDescription];
}


@end
