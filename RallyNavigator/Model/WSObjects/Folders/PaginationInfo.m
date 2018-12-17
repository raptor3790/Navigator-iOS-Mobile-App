//
//  PaginationInfo.m
//
//  Created by C205  on 21/08/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "PaginationInfo.h"


NSString *const kPaginationInfoTotalEntries = @"total_entries";
NSString *const kPaginationInfoTotalPages = @"total_pages";
NSString *const kPaginationInfoCurrentPage = @"current_page";


@interface PaginationInfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation PaginationInfo

@synthesize totalEntries = _totalEntries;
@synthesize totalPages = _totalPages;
@synthesize currentPage = _currentPage;


+ (PaginationInfo *)modelObjectWithDictionary:(NSDictionary *)dict
{
    PaginationInfo *instance = [[PaginationInfo alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.totalEntries = [[self objectOrNilForKey:kPaginationInfoTotalEntries fromDictionary:dict] doubleValue];
            self.totalPages = [[self objectOrNilForKey:kPaginationInfoTotalPages fromDictionary:dict] doubleValue];
            self.currentPage = [[self objectOrNilForKey:kPaginationInfoCurrentPage fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.totalEntries] forKey:kPaginationInfoTotalEntries];
    [mutableDict setValue:[NSNumber numberWithDouble:self.totalPages] forKey:kPaginationInfoTotalPages];
    [mutableDict setValue:[NSNumber numberWithDouble:self.currentPage] forKey:kPaginationInfoCurrentPage];

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

    self.totalEntries = [aDecoder decodeDoubleForKey:kPaginationInfoTotalEntries];
    self.totalPages = [aDecoder decodeDoubleForKey:kPaginationInfoTotalPages];
    self.currentPage = [aDecoder decodeDoubleForKey:kPaginationInfoCurrentPage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_totalEntries forKey:kPaginationInfoTotalEntries];
    [aCoder encodeDouble:_totalPages forKey:kPaginationInfoTotalPages];
    [aCoder encodeDouble:_currentPage forKey:kPaginationInfoCurrentPage];
}


@end
