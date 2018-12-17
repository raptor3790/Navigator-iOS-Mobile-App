//
//  Config.h
//
//  Created by C205  on 10/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Rotation, Accuracy;

@interface Config : NSObject <NSCoding>

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) Rotation *rotation;
@property (nonatomic, strong) NSString *sync;
@property (nonatomic, strong) Accuracy *accuracy;
@property (nonatomic, assign) BOOL autoCamera;
@property (nonatomic, strong) NSString *odo;

+ (Config *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
