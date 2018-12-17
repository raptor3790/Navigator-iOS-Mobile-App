//
//  Folders.h
//
//  Created by C205  on 21/08/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Folders : NSObject <NSCoding>

@property (nonatomic, assign) double routesCounts;
@property (nonatomic, assign) double foldersIdentifier;
@property (nonatomic, assign) double parentId;
@property (nonatomic, assign) double subfoldersCount;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *folderType;

+ (Folders *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
