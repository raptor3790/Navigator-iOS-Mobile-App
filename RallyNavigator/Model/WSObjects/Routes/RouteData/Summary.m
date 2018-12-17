//
//  Summary.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Summary.h"
#import "Endlocation.h"
#import "Startlocation.h"


NSString *const kSummaryFuelrange = @"fuelrange";
NSString *const kSummaryEndlocation = @"endlocation";
NSString *const kSummaryTotalwaypoints = @"totalwaypoints";
NSString *const kSummaryTotaldistance = @"totaldistance";
NSString *const kSummaryStartlocation = @"startlocation";


@interface Summary ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Summary

@synthesize fuelrange = _fuelrange;
@synthesize endlocation = _endlocation;
@synthesize totalwaypoints = _totalwaypoints;
@synthesize totaldistance = _totaldistance;
@synthesize startlocation = _startlocation;


+ (Summary *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Summary *instance = [[Summary alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.fuelrange = [[self objectOrNilForKey:kSummaryFuelrange fromDictionary:dict] doubleValue];
            self.endlocation = [Endlocation modelObjectWithDictionary:[dict objectForKey:kSummaryEndlocation]];
            self.totalwaypoints = [[self objectOrNilForKey:kSummaryTotalwaypoints fromDictionary:dict] doubleValue];
            self.totaldistance = [[self objectOrNilForKey:kSummaryTotaldistance fromDictionary:dict] doubleValue];
            self.startlocation = [Startlocation modelObjectWithDictionary:[dict objectForKey:kSummaryStartlocation]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.fuelrange] forKey:kSummaryFuelrange];
    [mutableDict setValue:[self.endlocation dictionaryRepresentation] forKey:kSummaryEndlocation];
    [mutableDict setValue:[NSNumber numberWithDouble:self.totalwaypoints] forKey:kSummaryTotalwaypoints];
    [mutableDict setValue:[NSNumber numberWithDouble:self.totaldistance] forKey:kSummaryTotaldistance];
    [mutableDict setValue:[self.startlocation dictionaryRepresentation] forKey:kSummaryStartlocation];

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

    self.fuelrange = [aDecoder decodeDoubleForKey:kSummaryFuelrange];
    self.endlocation = [aDecoder decodeObjectForKey:kSummaryEndlocation];
    self.totalwaypoints = [aDecoder decodeDoubleForKey:kSummaryTotalwaypoints];
    self.totaldistance = [aDecoder decodeDoubleForKey:kSummaryTotaldistance];
    self.startlocation = [aDecoder decodeObjectForKey:kSummaryStartlocation];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_fuelrange forKey:kSummaryFuelrange];
    [aCoder encodeObject:_endlocation forKey:kSummaryEndlocation];
    [aCoder encodeDouble:_totalwaypoints forKey:kSummaryTotalwaypoints];
    [aCoder encodeDouble:_totaldistance forKey:kSummaryTotaldistance];
    [aCoder encodeObject:_startlocation forKey:kSummaryStartlocation];
}


@end
