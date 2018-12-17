//
//  VoiceNote.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface VoiceNote : NSObject <NSCoding>

@property (nonatomic, assign) double voiceNoteIdentifier;
@property (nonatomic, strong) NSString *url;

+ (VoiceNote *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
