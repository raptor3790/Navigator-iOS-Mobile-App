//
//  Backgroundimage.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Backgroundimage : NSObject <NSCoding>

@property (nonatomic, assign) double backgroundimageIdentifier;
@property (nonatomic, strong) NSString *url;

+ (Backgroundimage *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
