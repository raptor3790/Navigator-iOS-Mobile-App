//
//  PaginationInfo.h
//
//  Created by C205  on 21/08/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PaginationInfo : NSObject <NSCoding>

@property (nonatomic, assign) double totalEntries;
@property (nonatomic, assign) double totalPages;
@property (nonatomic, assign) double currentPage;

+ (PaginationInfo *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
