//
//  Action.m
//
//  Created by C205  on 12/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "Action.h"


NSString *const kActionWaypointOnly = @"waypointOnly";
NSString *const kActionTakePicture = @"takePicture";
NSString *const kActionVoiceToText = @"voiceToText";
NSString *const kActionVoiceRecorder = @"voiceRecorder";
NSString *const kActionAutoPhoto = @"autoPhoto";
NSString *const kActionText = @"text";


@interface Action ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Action

@synthesize waypointOnly = _waypointOnly;
@synthesize takePicture = _takePicture;
@synthesize voiceToText = _voiceToText;
@synthesize voiceRecorder = _voiceRecorder;
@synthesize autoPhoto = _autoPhoto;
@synthesize text = _text;


+ (Action *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Action *instance = [[Action alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.waypointOnly = [[self objectOrNilForKey:kActionWaypointOnly fromDictionary:dict] boolValue];
            self.takePicture = [[self objectOrNilForKey:kActionTakePicture fromDictionary:dict] boolValue];
            self.voiceToText = [[self objectOrNilForKey:kActionVoiceToText fromDictionary:dict] boolValue];
            self.voiceRecorder = [[self objectOrNilForKey:kActionVoiceRecorder fromDictionary:dict] boolValue];
            self.autoPhoto = [[self objectOrNilForKey:kActionAutoPhoto fromDictionary:dict] boolValue];
            self.text = [[self objectOrNilForKey:kActionText fromDictionary:dict] boolValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.waypointOnly] forKey:kActionWaypointOnly];
    [mutableDict setValue:[NSNumber numberWithBool:self.takePicture] forKey:kActionTakePicture];
    [mutableDict setValue:[NSNumber numberWithBool:self.voiceToText] forKey:kActionVoiceToText];
    [mutableDict setValue:[NSNumber numberWithBool:self.voiceRecorder] forKey:kActionVoiceRecorder];
    [mutableDict setValue:[NSNumber numberWithBool:self.autoPhoto] forKey:kActionAutoPhoto];
    [mutableDict setValue:[NSNumber numberWithBool:self.text] forKey:kActionText];

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

    self.waypointOnly = [aDecoder decodeBoolForKey:kActionWaypointOnly];
    self.takePicture = [aDecoder decodeBoolForKey:kActionTakePicture];
    self.voiceToText = [aDecoder decodeBoolForKey:kActionVoiceToText];
    self.voiceRecorder = [aDecoder decodeBoolForKey:kActionVoiceRecorder];
    self.autoPhoto = [aDecoder decodeBoolForKey:kActionAutoPhoto];
    self.text = [aDecoder decodeBoolForKey:kActionText];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_waypointOnly forKey:kActionWaypointOnly];
    [aCoder encodeBool:_takePicture forKey:kActionTakePicture];
    [aCoder encodeBool:_voiceToText forKey:kActionVoiceToText];
    [aCoder encodeBool:_voiceRecorder forKey:kActionVoiceRecorder];
    [aCoder encodeBool:_autoPhoto forKey:kActionAutoPhoto];
    [aCoder encodeBool:_text forKey:kActionText];
}


@end
