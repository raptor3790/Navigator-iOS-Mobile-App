//
//  Constant.h
//  RallyNavigator
//
//  Created by C205 on 25/08/16.
//  Copyright © 2016 C205. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define DEBUG_LOGS 1

#if DEBUG_LOGS
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

#define USER_REG_EXP @"^[A-Za-z0-9_-]{3,15}$"
#define EMAIL_REG_EXP @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}"



#define iPadDevice                  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define iPhoneDevice                UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define isRetina                    ([[UIScreen mainScreen] scale] == 2.0)


#define AppContext ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define Set_Local_Image(ImageName)      [UIImage imageNamed:[NSString stringWithFormat:@"%@", ImageName]]

#define getStoryboard(StoryboardWithName) [UIStoryboard storyboardWithName:StoryboardWithName bundle:NULL]
#define loadViewController(StoryBoardName, VCIdentifier) [getStoryboard(StoryBoardName)instantiateViewControllerWithIdentifier:VCIdentifier]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

#define ROUND_TO_NEAREST(value) (int)roundf(value)

#define GET_USER_OBJ [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserObject]

#define APP_NAME    @"RallyNavigator"


//fonts
#define THEME_FONT(Size)                          [UIFont fontWithName:@"Roboto-Regular" size:Size]
#define THEME_FONT_Light(Size)                [UIFont fontWithName:@"Roboto-Light" size:Size]
#define THEME_FONT_Bold(Size)                 [UIFont fontWithName:@"Roboto-Bold" size:Size]
#define THEME_FONT_Medium(Size)           [UIFont fontWithName:@"Roboto-Medium" size:Size]



//colors
#define CLEAR_COLOR [UIColor clearColor]
#define BLACK_COLOR [UIColor blackColor]
#define WHITE_COLOR [UIColor whiteColor]
#define LIGHT_GRAY_COLOR [UIColor lightGrayColor]

#define NAVIGATION_BACK_COLOR [UIColor colorWithRed:250.0f/255.0f green:117.0f/255.0f blue:10.0f/255.0f alpha:1]
#define APP_DARK_GRAY_COLOR [UIColor colorWithRed:91.0f/255.0f green:91.0f/255.0f blue:91.0f/255.0f alpha:1]

#define RGB(R, G, B)            [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define RGBA(R, G, B, A)            [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define APP_BLACK_COLOR  [UIColor colorWithRed:17.0f/255.0f green:24.0f/255.0f blue:30.0f/255.0f alpha:1.0f]
#define APP_BLUE_COLOR  [UIColor colorWithRed:72.0f/255.0f green:119.0f/255.0f blue:227.0f/255.0f alpha:1.0f]
#define APP_GRAY_COLOR  [UIColor colorWithRed:151.0f/255.0f green:147.0f/255.0f blue:143.0f/255.0f alpha:1.0f]

#define IOS_OLDER_THAN_X(XX)            ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] < XX )
#define IOS_NEWER_OR_EQUAL_TO_X(XX)    ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= XX )

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

#define SCREEN_WIDTH                ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIApplication sharedApplication].keyWindow bounds].size.width : [[UIApplication sharedApplication].keyWindow bounds].size.height)

#define SCREEN_HEIGHT               ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIApplication sharedApplication].keyWindow bounds].size.height : [[UIApplication sharedApplication].keyWindow bounds].size.width)

#else

#define SCREEN_WIDTH                ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define SCREEN_HEIGHT               ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#endif


//Storyboard

#define StoryBoard_Main     @"Main"
#define StoryBoard_Settings @"Settings"



#define kIDRegisterVC @"idRegisterVC"
#define kIDRoadBooksVC @"idRoadBooksVC"
#define kIDAddRoadBookVC @"idAddRoadBookVC"
#define kIDLocationsVC @"idLocationsVC"
#define kIDImagePreviewVC @"idImagePreviewVC"
#define kIDSettingsVC @"idSettingsVC"
#define kIDHowToUseVC @"idHowToUseVC"
#define kIDAddFolderVC @"idAddFolderVC"


//Default Key
#define kWelCome @"WELCOME KEY"
#define kLogIn @"Already LogIn"
#define kIsNightView @"Is Night View"
#define kUserObject @"UserObject"
#define kUserPassword @"UserPassword"
#define kUserEmailId @"User Email"
#define kTokenKey @"TOKEN"


#endif /* Constant_h */
