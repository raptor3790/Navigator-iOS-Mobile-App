//
//  Roadbooks.m
//
//  Created by C205  on 21/08/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Roadbooks.h"
#import "Folders.h"
#import "PaginationInfo.h"
#import "Routes.h"


NSString *const kRoadbooksFolders = @"folders";
NSString *const kRoadbooksPaginationInfo = @"pagination_info";
NSString *const kRoadbooksRoutes = @"routes";
NSString *const kRoadbooksParentId = @"parent_id";


@interface Roadbooks ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Roadbooks

@synthesize folders = _folders;
@synthesize paginationInfo = _paginationInfo;
@synthesize routes = _routes;
@synthesize parentId = _parentId;

+ (Roadbooks *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Roadbooks *instance = [[Roadbooks alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
    NSObject *receivedFolders = [dict objectForKey:kRoadbooksFolders];
    NSMutableArray *parsedFolders = [NSMutableArray array];
    if ([receivedFolders isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedFolders) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedFolders addObject:[Folders modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedFolders isKindOfClass:[NSDictionary class]]) {
       [parsedFolders addObject:[Folders modelObjectWithDictionary:(NSDictionary *)receivedFolders]];
    }

    self.folders = [NSArray arrayWithArray:parsedFolders];
            self.paginationInfo = [PaginationInfo modelObjectWithDictionary:[dict objectForKey:kRoadbooksPaginationInfo]];
    NSObject *receivedRoutes = [dict objectForKey:kRoadbooksRoutes];
    NSMutableArray *parsedRoutes = [NSMutableArray array];
    if ([receivedRoutes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedRoutes) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedRoutes addObject:[Routes modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedRoutes isKindOfClass:[NSDictionary class]]) {
       [parsedRoutes addObject:[Routes modelObjectWithDictionary:(NSDictionary *)receivedRoutes]];
    }

    self.routes = [NSArray arrayWithArray:parsedRoutes];
        self.parentId = [[self objectOrNilForKey:kRoadbooksParentId fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
NSMutableArray *tempArrayForFolders = [NSMutableArray array];
    for (NSObject *subArrayObject in self.folders) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForFolders addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForFolders addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFolders] forKey:@"kRoadbooksFolders"];
    [mutableDict setValue:[self.paginationInfo dictionaryRepresentation] forKey:kRoadbooksPaginationInfo];
NSMutableArray *tempArrayForRoutes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.routes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForRoutes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForRoutes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForRoutes] forKey:@"kRoadbooksRoutes"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.parentId] forKey:kRoadbooksParentId];

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

    self.folders = [aDecoder decodeObjectForKey:kRoadbooksFolders];
    self.paginationInfo = [aDecoder decodeObjectForKey:kRoadbooksPaginationInfo];
    self.routes = [aDecoder decodeObjectForKey:kRoadbooksRoutes];
    self.parentId = [aDecoder decodeDoubleForKey:kRoadbooksParentId];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_folders forKey:kRoadbooksFolders];
    [aCoder encodeObject:_paginationInfo forKey:kRoadbooksPaginationInfo];
    [aCoder encodeObject:_routes forKey:kRoadbooksRoutes];
    [aCoder encodeDouble:_parentId forKey:kRoadbooksParentId];
}


@end
