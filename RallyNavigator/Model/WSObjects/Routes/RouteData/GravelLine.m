//
//  GravelLine.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "GravelLine.h"


NSString *const kGravelLineTop = @"top";
NSString *const kGravelLineBottom = @"bottom";


@interface GravelLine ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GravelLine

@synthesize top = _top;
@synthesize bottom = _bottom;


+ (GravelLine *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GravelLine *instance = [[GravelLine alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.top = [[self objectOrNilForKey:kGravelLineTop fromDictionary:dict] boolValue];
            self.bottom = [[self objectOrNilForKey:kGravelLineBottom fromDictionary:dict] boolValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.top] forKey:kGravelLineTop];
    [mutableDict setValue:[NSNumber numberWithBool:self.bottom] forKey:kGravelLineBottom];

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

    self.top = [aDecoder decodeBoolForKey:kGravelLineTop];
    self.bottom = [aDecoder decodeBoolForKey:kGravelLineBottom];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_top forKey:kGravelLineTop];
    [aCoder encodeBool:_bottom forKey:kGravelLineBottom];
}


@end
