//
//  AppDelegate.h
//  RallyNavigator
//
//  Created by C205 on 19/12/17.
//  Copyright © 2017 C205. All rights reserved.
//
@import AVFoundation;

#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "RallyNavigator-Swift.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property BOOL isInternetAvailable;
@property BOOL isWebServiceIsCalling;

@property (assign, nonatomic) NSInteger totalWayPoints;
@property (assign, nonatomic) NSInteger syncedWayPoints;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSMutableArray *arrEditData;

- (void)checkForSyncData;

@end

