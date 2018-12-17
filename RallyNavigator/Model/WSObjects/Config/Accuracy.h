//
//  Accuracy.h
//
//  Created by C205  on 10/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Accuracy : NSObject <NSCoding>

@property (nonatomic, assign) double minDistanceTrackpoint;
@property (nonatomic, assign) double angle;
@property (nonatomic, assign) double accuracy;
@property (nonatomic, assign) double distance;

+ (Accuracy *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
