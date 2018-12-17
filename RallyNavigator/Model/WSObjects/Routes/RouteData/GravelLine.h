//
//  GravelLine.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GravelLine : NSObject <NSCoding>

@property (nonatomic, assign) BOOL top;
@property (nonatomic, assign) BOOL bottom;

+ (GravelLine *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
