//
//  Folders.m
//
//  Created by C205  on 21/08/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Folders.h"


NSString *const kFoldersRoutesCounts = @"routes_counts";
NSString *const kFoldersId = @"id";
NSString *const kFoldersParentId = @"parent_id";
NSString *const kFoldersSubfoldersCount = @"subfolders_count";
NSString *const kFoldersFolderName = @"folder_name";
NSString *const kFoldersFolderType = @"folder_type";


@interface Folders ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Folders

@synthesize routesCounts = _routesCounts;
@synthesize foldersIdentifier = _foldersIdentifier;
@synthesize parentId = _parentId;
@synthesize subfoldersCount = _subfoldersCount;
@synthesize folderName = _folderName;
@synthesize folderType = _folderType;


+ (Folders *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Folders *instance = [[Folders alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.routesCounts = [[self objectOrNilForKey:kFoldersRoutesCounts fromDictionary:dict] doubleValue];
            self.foldersIdentifier = [[self objectOrNilForKey:kFoldersId fromDictionary:dict] doubleValue];
            self.parentId = [[self objectOrNilForKey:kFoldersParentId fromDictionary:dict] doubleValue];
            self.subfoldersCount = [[self objectOrNilForKey:kFoldersSubfoldersCount fromDictionary:dict] doubleValue];
            self.folderName = [self objectOrNilForKey:kFoldersFolderName fromDictionary:dict];
            self.folderType = [self objectOrNilForKey:kFoldersFolderType fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routesCounts] forKey:kFoldersRoutesCounts];
    [mutableDict setValue:[NSNumber numberWithDouble:self.foldersIdentifier] forKey:kFoldersId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.parentId] forKey:kFoldersParentId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.subfoldersCount] forKey:kFoldersSubfoldersCount];
    [mutableDict setValue:self.folderName forKey:kFoldersFolderName];
    [mutableDict setValue:self.folderType forKey:kFoldersFolderType];

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

    self.routesCounts = [aDecoder decodeDoubleForKey:kFoldersRoutesCounts];
    self.foldersIdentifier = [aDecoder decodeDoubleForKey:kFoldersId];
    self.parentId = [aDecoder decodeDoubleForKey:kFoldersParentId];
    self.subfoldersCount = [aDecoder decodeDoubleForKey:kFoldersSubfoldersCount];
    self.folderName = [aDecoder decodeObjectForKey:kFoldersFolderName];
    self.folderType = [aDecoder decodeObjectForKey:kFoldersFolderType];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_routesCounts forKey:kFoldersRoutesCounts];
    [aCoder encodeDouble:_foldersIdentifier forKey:kFoldersId];
    [aCoder encodeDouble:_parentId forKey:kFoldersParentId];
    [aCoder encodeDouble:_subfoldersCount forKey:kFoldersSubfoldersCount];
    [aCoder encodeObject:_folderName forKey:kFoldersFolderName];
    [aCoder encodeObject:_folderType forKey:kFoldersFolderType];
}


@end
