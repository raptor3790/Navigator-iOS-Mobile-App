//
//  TurnkeyConstants.m
//  Turnkey
//
//  Created by C218 on 07/11/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import "RallyNavigatorConstants.h"

@implementation RallyNavigatorConstants

#pragma mark - Gender

+ (NSArray *)getGenders
{
    static NSMutableArray *_genders = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _genders = [NSMutableArray arrayWithCapacity:2];
        [_genders insertObject:@"male" atIndex:MALE];
        [_genders insertObject:@"female" atIndex:FEMALE];
        [_genders insertObject:@"mixed" atIndex:MIXED];
    });
    
    return _genders;
}

+ (NSArray *)getDeviceTypes
{
    static NSMutableArray *_deviceTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _deviceTypes = [NSMutableArray arrayWithCapacity:2];
        [_deviceTypes insertObject:@"0" atIndex:DeviceTypeAndroid];
        [_deviceTypes insertObject:@"1" atIndex:DeviceType_iOS];
    });
    
    return _deviceTypes;
}

+ (NSArray *)getUserTypes
{
    static NSMutableArray *_userTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _userTypes = [NSMutableArray arrayWithCapacity:2];
        [_userTypes insertObject:@"0" atIndex:UserTypeClient];
        [_userTypes insertObject:@"1" atIndex:UserTypeCoach];
    });
    
    return _userTypes;
}

+ (NSString *)getGenderForKey:(UserGender)key
{
    return [[self getGenders] objectAtIndex:key];
}

+ (NSString *)getDeviceTypeForKey:(DeviceType)deviceType
{
    return [[self getDeviceTypes] objectAtIndex:deviceType];
}

+ (NSString *)getUserTypeForKey:(UserType)userType
{
    return [[self getUserTypes] objectAtIndex:userType];
}

+ (UITextField *)setPlaceHolderColor:(UIColor *)color forTextField:(UITextField *)textField
{
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    return textField;
}

+ (NSString *)createJsonStringFromArray:(NSArray *)arrData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrData options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (jsonString == nil || [jsonString isEqual:[NSNull null]])
    {
        jsonString = @"";
    }
    
    jsonString = [[jsonString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    
//    NSLog(@"%@", jsonString);
    
    return jsonString;
}

+ (NSArray *)decodeJsonString:(NSString *)strJson
{
    NSData *data = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arrData = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    
    return arrData;
}

+ (id)convertJsonStringToObject:(NSString *)strJson
{
    NSData *webData = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
}

+ (NSString *)generateJsonStringFromObject:(id)object
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strJsonData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    strJsonData = [[strJsonData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    return strJsonData;
}

+ (NSString *)getErrorForErrorCode:(NSInteger)errorCode
{
    switch (errorCode)
    {
        case 101:
        {
            return @"Invalid Authentication. Please Try Again";
        }
            break;

        case 102:
        {
            return @"This email has already been taken";
        }
            break;

        case 103:
        {
            return @"This username has already been taken";
        }
            break;

        case 104:
        {
            return @"Invalid email or password";
        }
            break;

        case 105:
        {
            return @"Failed to sign out";
        }
            break;

        case 106:
        {
            return @"This email id not found";
        }
            break;

        case 107:
        {
            return @"Invalid password";
        }
            break;

        case 108:
        {
            return @"Please enter valid password";
        }
            break;

        case 1:
        {
            return @"Please enter required details";
        }
            break;

        case 2:
        {
            return @"Failed to validate details";
        }
            break;

        case 3:
        {
            return @"Requested URL not found";
        }
            break;

        case 4:
        {
            return @"Requested record not found";
        }
            break;

        case 5:
        {
            return @"Access denied";
        }
            break;

        case 6002:
        {
            return @"Invalid token";
        }
            break;

        case 7000:
        {
            return @"Route not found";
        }
            break;

        case 7001:
        {
            return @"Failed to save route";
        }
            break;

        case 7002:
        {
            return @"Failed to access route";
        }
            break;

        default:
            break;
    }
    
    return @"Unknown Error";
}

#pragma mark - Clear Login session

+(void)clearLogginSession
{
    [DefaultsValues setBooleanValueToUserDefaults:NO ForKey:kLogIn];
    [DefaultsValues removeObjectForKey:kTokenKey];
}


NSString *kDefaultPhone = @"+91 123547889";
NSString *kStatusMsg = @"Test status message";


int kPasswordLenght = 6;
int kPasswordMaxLenght = 32;
int kNameLenght = 3;
int kNameMaxLenght = 30;
int kDefaultAgeOFUser = -12;

@end
