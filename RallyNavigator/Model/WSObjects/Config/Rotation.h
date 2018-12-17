//
//  Rotation.h
//
//  Created by C205  on 10/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Rotation : NSObject <NSCoding>

@property (nonatomic, strong) NSString *value;

+ (Rotation *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
