//
//  Settings.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Settings : NSObject <NSCoding>

@property (nonatomic, assign) BOOL showheadings;
@property (nonatomic, assign) BOOL showAlternateDistance;
@property (nonatomic, strong) NSString *units;
@property (nonatomic, assign) BOOL showStickMarkOnTulips;
@property (nonatomic, assign) BOOL showcoordinates;

+ (Settings *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
