//
//  Backgroundimage.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Backgroundimage.h"


NSString *const kBackgroundimageId = @"id";
NSString *const kBackgroundimageUrl = @"url";


@interface Backgroundimage ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Backgroundimage

@synthesize backgroundimageIdentifier = _backgroundimageIdentifier;
@synthesize url = _url;


+ (Backgroundimage *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Backgroundimage *instance = [[Backgroundimage alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.backgroundimageIdentifier = [[self objectOrNilForKey:kBackgroundimageId fromDictionary:dict] doubleValue];
            self.url = [self objectOrNilForKey:kBackgroundimageUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.backgroundimageIdentifier] forKey:kBackgroundimageId];
    [mutableDict setValue:self.url forKey:kBackgroundimageUrl];

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

    self.backgroundimageIdentifier = [aDecoder decodeDoubleForKey:kBackgroundimageId];
    self.url = [aDecoder decodeObjectForKey:kBackgroundimageUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_backgroundimageIdentifier forKey:kBackgroundimageId];
    [aCoder encodeObject:_url forKey:kBackgroundimageUrl];
}


@end
