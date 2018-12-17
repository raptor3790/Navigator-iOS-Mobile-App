//
//  RoadBooks.m
//
//  Created by C205  on 29/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "RoadBooks.h"


NSString *const kRoadBooksId = @"roadBookId";
NSString *const kRoadBooksRoadBookName = @"roadBookName";


@interface RoadBooks ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation RoadBooks

@synthesize roadBookId = _roadBookId;
@synthesize roadBookName = _roadBookName;


+ (RoadBooks *)modelObjectWithDictionary:(NSDictionary *)dict
{
    RoadBooks *instance = [[RoadBooks alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.roadBookId = [[self objectOrNilForKey:kRoadBooksId fromDictionary:dict] doubleValue];
            self.roadBookName = [self objectOrNilForKey:kRoadBooksRoadBookName fromDictionary:dict];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.roadBookId] forKey:kRoadBooksId];
    [mutableDict setValue:self.roadBookName forKey:kRoadBooksRoadBookName];

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

    self.roadBookId = [aDecoder decodeDoubleForKey:kRoadBooksId];
    self.roadBookName = [aDecoder decodeObjectForKey:kRoadBooksRoadBookName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_roadBookId forKey:kRoadBooksId];
    [aCoder encodeObject:_roadBookName forKey:kRoadBooksRoadBookName];
}


@end
