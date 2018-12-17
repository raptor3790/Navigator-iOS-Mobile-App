//
//  Routes.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Routes : NSObject <NSCoding>

@property (nonatomic, assign) double routesIdentifier;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) double folderId;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *units;
@property (nonatomic, assign) double waypointCount;

+ (Routes *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
