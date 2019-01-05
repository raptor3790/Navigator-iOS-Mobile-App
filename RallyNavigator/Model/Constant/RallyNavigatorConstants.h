//
//  TurnkeyConstants.h
//  Turnkey
//
//  Created by C218 on 07/11/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RallyNavigatorConstants : NSObject

#pragma mark - ENUMs


typedef enum
{
    LoginTypeNormal = 0,
    LoginTypeGoogle
}LoginType;

typedef enum
{
    WayPointTypeNone = 0,
    WayPointTypeNormal,
    WayPointTypeText,
    WayPointTypeImage,
    WayPointTypeAudio
}WayPointType;

typedef enum
{
    ViewTypeListView = 0,
    ViewTypeMapView,
    ViewTypePreview
}ViewType;

typedef enum
{
    ResourceSectionTypeBeingInProgress = 0,
    ResourceSectionTypeDealingWithResistance,
    ResourceSectionTypeExpandingAwareness,
    ResourceSectionTypeImagineTheFuture,
    ResourceSectionTypeInquiries,
    ResourceSectionTypeMovingForward
}ResourceSectionType;

typedef enum
{
    CurrentMapStyleStreets = 0,
    CurrentMapStyleSatellite,
//    CurrentMapStyleDark
}CurrentMapStyle;

typedef enum
{
    DistanceUnitsTypeKilometers = 0,
    DistanceUnitsTypeMiles
}DistanceUnitsType;

typedef enum
{
    DeviceTypeAndroid = 0,
    DeviceType_iOS
}DeviceType;

typedef enum
{
    UserTypeClient = 0,
    UserTypeCoach
}UserType;

typedef enum
{
    MALE = 0,
    FEMALE,
    MIXED
}UserGender;

typedef enum
{
    ConnectionTypeInnerCircle = 0,
    ConnectionTypePersonalBoard,
    ConnectionTypeCoach,
    ConnectionTypeBrainTrust,
    ConnectionTypeProtegeOrMentee,
    ConnectionTypeClient
}ConnectionType;

typedef enum
{
    MapViewTypeTransit = 0,
    MapViewTypeSatellite
}MapViewType;

typedef enum
{
    PayPalPaymentMethodEmailAddress = 0,
    PayPalPaymentMethodPhoneNumber,
    PayPalPaymentMethodAccountId
}PayPalPaymentMethod;

+ (NSArray *)getGenders;
+ (NSString *)getDeviceTypeForKey:(DeviceType)deviceType;
+ (NSString *)getGenderForKey:(UserGender)key;
+ (NSString *)getUserTypeForKey:(UserType)userType;;
+ (UITextField *)setPlaceHolderColor:(UIColor *)color forTextField:(UITextField *)textField;

+ (NSString *)getErrorForErrorCode:(NSInteger)errorCode;

+ (NSString *)createJsonStringFromArray:(NSArray *)arrData;
+ (NSArray *)decodeJsonString:(NSString *)strJson;
+ (id)convertJsonStringToObject:(NSString *)strJson;
+ (NSString *)generateJsonStringFromObject:(id)object;

typedef enum
{
    FROM_CAMERA = 0,
    FROM_PHOTO
}Selection_Images;

typedef enum
{
    ReminderTypeNone = 0,
    ReminderTypeBefore15Minutes,
    ReminderTypeBefore30Minutes,
    ReminderTypeBefore1Hour
}ReminderType;

#pragma mark - Clear Login session
+(void)clearLogginSession;

extern NSString *kDefaultPhone;
extern NSString *kStatusMsg;


extern int kPasswordLenght;
extern int kPasswordMaxLenght;
extern int kNameLenght;
extern int kNameMaxLenght;
extern int kDefaultAgeOFUser;



@end
