//
//  RoadBooks.h
//
//  Created by C205  on 29/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RoadBooks : NSObject <NSCoding>

@property (nonatomic, assign) double roadBookId;
@property (nonatomic, strong) NSString *roadBookName;

+ (RoadBooks *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
