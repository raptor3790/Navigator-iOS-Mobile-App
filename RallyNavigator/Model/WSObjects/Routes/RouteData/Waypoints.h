//
//  Waypoints.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VoiceNote, GravelLine, Backgroundimage, Td;

@interface Waypoints : NSObject <NSCoding>

@property (nonatomic, assign) BOOL showStickMarkOnTulip;
@property (nonatomic, strong) id ele;
@property (nonatomic, assign) double lon;
@property (nonatomic, strong) VoiceNote *voiceNote;
@property (nonatomic, strong) NSArray *trayIcons;
@property (nonatomic, strong) GravelLine *gravelLine;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NSArray *streetSignIcons;
@property (nonatomic, strong) Backgroundimage *backgroundimage;
@property (nonatomic, strong) Td *td;
@property (nonatomic, assign) double lat;
@property (nonatomic, strong) NSArray *freelines;
@property (nonatomic, assign) double waypointid;
@property (nonatomic, strong) NSArray *roads;
@property (nonatomic, strong) id alt;
@property (nonatomic, assign) double cellPhoneStage;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSString *wayPointDescription;

+ (Waypoints *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
