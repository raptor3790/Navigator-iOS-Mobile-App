//
//  VoiceNote.m
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "VoiceNote.h"


NSString *const kVoiceNoteId = @"id";
NSString *const kVoiceNoteUrl = @"url";


@interface VoiceNote ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation VoiceNote

@synthesize voiceNoteIdentifier = _voiceNoteIdentifier;
@synthesize url = _url;


+ (VoiceNote *)modelObjectWithDictionary:(NSDictionary *)dict
{
    VoiceNote *instance = [[VoiceNote alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.voiceNoteIdentifier = [[self objectOrNilForKey:kVoiceNoteId fromDictionary:dict] doubleValue];
            self.url = [self objectOrNilForKey:kVoiceNoteUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.voiceNoteIdentifier] forKey:kVoiceNoteId];
    [mutableDict setValue:self.url forKey:kVoiceNoteUrl];

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

    self.voiceNoteIdentifier = [aDecoder decodeDoubleForKey:kVoiceNoteId];
    self.url = [aDecoder decodeObjectForKey:kVoiceNoteUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_voiceNoteIdentifier forKey:kVoiceNoteId];
    [aCoder encodeObject:_url forKey:kVoiceNoteUrl];
}


@end
