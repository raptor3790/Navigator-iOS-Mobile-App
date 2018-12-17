//
//  AwsConfig.h
//
//  Created by C205  on 30/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AwsConfig : NSObject <NSCoding>

@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *acl;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) NSString *awsAccessKeyId;
@property (nonatomic, strong) NSString *expiration;
@property (nonatomic, strong) NSString *policy;

+ (AwsConfig *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
