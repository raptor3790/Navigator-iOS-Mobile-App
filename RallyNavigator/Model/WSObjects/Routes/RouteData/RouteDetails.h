//
//  RouteDetails.h
//
//  Created by C205  on 01/01/18
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Summary, Settings;

@interface RouteDetails : NSObject <NSCoding>

@property (nonatomic, assign) double tcendnumber;
@property (nonatomic, assign) double averageTimeOption;
@property (nonatomic, strong) NSArray *ssheaderinfo;
@property (nonatomic, strong) Summary *summary;
@property (nonatomic, strong) NSString *currentStyle;
@property (nonatomic, strong) NSString *tcstart;
@property (nonatomic, strong) NSString *tcend;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) double tcEndOption;
@property (nonatomic, strong) NSArray *waypoints;
@property (nonatomic, strong) NSString *folderId;
@property (nonatomic, assign) double internalBaseClassIdentifier;
@property (nonatomic, strong) NSString *customAverageData;
@property (nonatomic, strong) NSString *timeallowed;
@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) NSString *tcstartnumber;
@property (nonatomic, assign) double tcStartOption;
@property (nonatomic, assign) double dataVersion;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSString *internalBaseClassDescription;

+ (RouteDetails *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
