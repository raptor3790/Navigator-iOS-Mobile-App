//
//  Action.h
//
//  Created by C205  on 12/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Action : NSObject <NSCoding>

@property (nonatomic, assign) BOOL waypointOnly;
@property (nonatomic, assign) BOOL takePicture;
@property (nonatomic, assign) BOOL voiceToText;
@property (nonatomic, assign) BOOL voiceRecorder;
@property (nonatomic, assign) BOOL autoPhoto;
@property (nonatomic, assign) BOOL text;

+ (Action *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
