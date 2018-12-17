//
//  Location.h
//
//  Created by C205  on 22/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Locations : NSObject <NSCoding>

@property (nonatomic, assign) double locationId;
@property (nonatomic, assign) BOOL isWayPoint;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSArray *audios;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *audioUrl;

+ (Locations *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
