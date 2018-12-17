//
//  Roadbooks.h
//
//  Created by C205  on 21/08/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaginationInfo;

@interface Roadbooks : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) PaginationInfo *paginationInfo;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, assign) double parentId;

+ (Roadbooks *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
