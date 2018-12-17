//
//  AwsConfig.m
//
//  Created by C205  on 30/12/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "AwsConfig.h"


NSString *const kAwsConfigContentType = @"content_type";
NSString *const kAwsConfigAcl = @"acl";
NSString *const kAwsConfigSignature = @"signature";
NSString *const kAwsConfigAwsAccessKeyId = @"aws_access_key_id";
NSString *const kAwsConfigExpiration = @"expiration";
NSString *const kAwsConfigPolicy = @"policy";


@interface AwsConfig ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation AwsConfig

@synthesize contentType = _contentType;
@synthesize acl = _acl;
@synthesize signature = _signature;
@synthesize awsAccessKeyId = _awsAccessKeyId;
@synthesize expiration = _expiration;
@synthesize policy = _policy;


+ (AwsConfig *)modelObjectWithDictionary:(NSDictionary *)dict
{
    AwsConfig *instance = [[AwsConfig alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.contentType = [self objectOrNilForKey:kAwsConfigContentType fromDictionary:dict];
            self.acl = [self objectOrNilForKey:kAwsConfigAcl fromDictionary:dict];
            self.signature = [self objectOrNilForKey:kAwsConfigSignature fromDictionary:dict];
            self.awsAccessKeyId = [self objectOrNilForKey:kAwsConfigAwsAccessKeyId fromDictionary:dict];
            self.expiration = [self objectOrNilForKey:kAwsConfigExpiration fromDictionary:dict];
            self.policy = [self objectOrNilForKey:kAwsConfigPolicy fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.contentType forKey:kAwsConfigContentType];
    [mutableDict setValue:self.acl forKey:kAwsConfigAcl];
    [mutableDict setValue:self.signature forKey:kAwsConfigSignature];
    [mutableDict setValue:self.awsAccessKeyId forKey:kAwsConfigAwsAccessKeyId];
    [mutableDict setValue:self.expiration forKey:kAwsConfigExpiration];
    [mutableDict setValue:self.policy forKey:kAwsConfigPolicy];

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

    self.contentType = [aDecoder decodeObjectForKey:kAwsConfigContentType];
    self.acl = [aDecoder decodeObjectForKey:kAwsConfigAcl];
    self.signature = [aDecoder decodeObjectForKey:kAwsConfigSignature];
    self.awsAccessKeyId = [aDecoder decodeObjectForKey:kAwsConfigAwsAccessKeyId];
    self.expiration = [aDecoder decodeObjectForKey:kAwsConfigExpiration];
    self.policy = [aDecoder decodeObjectForKey:kAwsConfigPolicy];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_contentType forKey:kAwsConfigContentType];
    [aCoder encodeObject:_acl forKey:kAwsConfigAcl];
    [aCoder encodeObject:_signature forKey:kAwsConfigSignature];
    [aCoder encodeObject:_awsAccessKeyId forKey:kAwsConfigAwsAccessKeyId];
    [aCoder encodeObject:_expiration forKey:kAwsConfigExpiration];
    [aCoder encodeObject:_policy forKey:kAwsConfigPolicy];
}


@end
