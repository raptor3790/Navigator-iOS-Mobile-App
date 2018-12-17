//
//  User.m
//
//  Created by C205  on 30/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "AwsConfig.h"


NSString *const kUserConfig = @"config";
NSString *const kUserId = @"id";
NSString *const kUserRole = @"role";
NSString *const kUserTrialExpiredDate = @"trial_expired_date";
NSString *const kUserEmail = @"email";
NSString *const kUserUsername = @"username";
NSString *const kUserAuthenticationToken = @"authentication_token";
NSString *const kUserGetTempRole = @"get_temp_role";
NSString *const kUserAwsConfig = @"aws_config";
NSString *const kUserFirstLoginMobile = @"first_login_mobile";


@interface User ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation User

@synthesize config = _config;
@synthesize userIdentifier = _userIdentifier;
@synthesize role = _role;
@synthesize trialExpiredDate = _trialExpiredDate;
@synthesize email = _email;
@synthesize username = _username;
@synthesize authenticationToken = _authenticationToken;
@synthesize getTempRole = _getTempRole;
@synthesize awsConfig = _awsConfig;
@synthesize firstLoginMobile = _firstLoginMobile;


+ (User *)modelObjectWithDictionary:(NSDictionary *)dict
{
    User *instance = [[User alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.config = [self objectOrNilForKey:kUserConfig fromDictionary:dict];
            self.userIdentifier = [[self objectOrNilForKey:kUserId fromDictionary:dict] doubleValue];
            self.role = [self objectOrNilForKey:kUserRole fromDictionary:dict];
            self.trialExpiredDate = [self objectOrNilForKey:kUserTrialExpiredDate fromDictionary:dict];
            self.email = [self objectOrNilForKey:kUserEmail fromDictionary:dict];
            self.username = [self objectOrNilForKey:kUserUsername fromDictionary:dict];
            self.authenticationToken = [self objectOrNilForKey:kUserAuthenticationToken fromDictionary:dict];
            self.getTempRole = [self objectOrNilForKey:kUserGetTempRole fromDictionary:dict];
            self.awsConfig = [AwsConfig modelObjectWithDictionary:[dict objectForKey:kUserAwsConfig]];
            self.firstLoginMobile = [[self objectOrNilForKey:kUserFirstLoginMobile fromDictionary:dict] boolValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.config forKey:kUserConfig];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userIdentifier] forKey:kUserId];
    [mutableDict setValue:self.role forKey:kUserRole];
    [mutableDict setValue:self.trialExpiredDate forKey:kUserTrialExpiredDate];
    [mutableDict setValue:self.email forKey:kUserEmail];
    [mutableDict setValue:self.username forKey:kUserUsername];
    [mutableDict setValue:self.authenticationToken forKey:kUserAuthenticationToken];
    [mutableDict setValue:self.getTempRole forKey:kUserGetTempRole];
    [mutableDict setValue:[self.awsConfig dictionaryRepresentation] forKey:kUserAwsConfig];
    [mutableDict setValue:[NSNumber numberWithBool:self.firstLoginMobile] forKey:kUserFirstLoginMobile];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.config = [aDecoder decodeObjectForKey:kUserConfig];
    self.userIdentifier = [aDecoder decodeDoubleForKey:kUserId];
    self.role = [aDecoder decodeObjectForKey:kUserRole];
    self.trialExpiredDate = [aDecoder decodeObjectForKey:kUserTrialExpiredDate];
    self.email = [aDecoder decodeObjectForKey:kUserEmail];
    self.username = [aDecoder decodeObjectForKey:kUserUsername];
    self.authenticationToken = [aDecoder decodeObjectForKey:kUserAuthenticationToken];
    self.getTempRole = [aDecoder decodeObjectForKey:kUserGetTempRole];
    self.awsConfig = [aDecoder decodeObjectForKey:kUserAwsConfig];
    self.firstLoginMobile = [aDecoder decodeBoolForKey:kUserFirstLoginMobile];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_config forKey:kUserConfig];
    [aCoder encodeDouble:_userIdentifier forKey:kUserId];
    [aCoder encodeObject:_role forKey:kUserRole];
    [aCoder encodeObject:_trialExpiredDate forKey:kUserTrialExpiredDate];
    [aCoder encodeObject:_email forKey:kUserEmail];
    [aCoder encodeObject:_username forKey:kUserUsername];
    [aCoder encodeObject:_authenticationToken forKey:kUserAuthenticationToken];
    [aCoder encodeObject:_getTempRole forKey:kUserGetTempRole];
    [aCoder encodeObject:_awsConfig forKey:kUserAwsConfig];
    [aCoder encodeBool:_firstLoginMobile forKey:kUserFirstLoginMobile];
}


@end
