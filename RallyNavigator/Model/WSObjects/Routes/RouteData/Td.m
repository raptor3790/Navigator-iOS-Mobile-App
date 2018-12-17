//
//  Td.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Td.h"


NSString *const kTdTicY = @"ticY";
NSString *const kTdTixX = @"tixX";


@interface Td ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Td

@synthesize ticY = _ticY;
@synthesize tixX = _tixX;


+ (Td *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Td *instance = [[Td alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.ticY = [self objectOrNilForKey:kTdTicY fromDictionary:dict];
            self.tixX = [self objectOrNilForKey:kTdTixX fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.ticY forKey:kTdTicY];
    [mutableDict setValue:self.tixX forKey:kTdTixX];

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

    self.ticY = [aDecoder decodeObjectForKey:kTdTicY];
    self.tixX = [aDecoder decodeObjectForKey:kTdTixX];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_ticY forKey:kTdTicY];
    [aCoder encodeObject:_tixX forKey:kTdTixX];
}


@end
