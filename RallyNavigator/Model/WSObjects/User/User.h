//
//  User.h
//
//  Created by C205  on 30/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AwsConfig;

@interface User : NSObject <NSCoding>

@property (nonatomic, strong) NSString *config;
@property (nonatomic, assign) double userIdentifier;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *trialExpiredDate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *authenticationToken;
@property (nonatomic, strong) NSString *getTempRole;
@property (nonatomic, strong) AwsConfig *awsConfig;
@property (nonatomic, assign) BOOL firstLoginMobile;

+ (User *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
