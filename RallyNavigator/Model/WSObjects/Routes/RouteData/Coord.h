//
//  Coord.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Coord : NSObject <NSCoding>

@property (nonatomic, strong) NSString *addressshort;
@property (nonatomic, strong) NSString *addresslong;
@property (nonatomic, assign) double lat;
@property (nonatomic, strong) NSString *addresscustom;
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) double addressoption;

+ (Coord *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
