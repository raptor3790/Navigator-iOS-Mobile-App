//
//  DefaultsValues.h
//  MPA
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSUserDefaults+SaveCustomObject.h"

@interface DefaultsValues : NSObject

+ (void)setStringValueToUserDefaults:(NSString *)strValue ForKey:(NSString *)strKey;
+ (NSString *)getStringValueFromUserDefaults_ForKey:(NSString *)strKey;

+ (void)setIntegerValueToUserDefaults:(int)intValue ForKey:(NSString *)intKey;
+ (int)getIntegerValueFromUserDefaults_ForKey:(NSString *)intKey;

+ (void)setBooleanValueToUserDefaults:(bool)booleanValue ForKey:(NSString *)booleanKey;
+ (bool)getBooleanValueFromUserDefaults_ForKey:(NSString *)booleanKey;

+ (void)setObjectValueToUserDefaults:(id)idValue ForKey:(NSString *)strKey;
+ (id)getObjectValueFromUserDefaults_ForKey:(NSString *)strKey;

+ (void)setCustomObjToUserDefaults:(id)CustomeObj ForKey:(NSString *)CustomeObjKey;
+ (id)getCustomObjFromUserDefaults_ForKey:(NSString *)CustomeObjKey;

+ (void)removeObjectForKey:(NSString *)objectKey;
+ (BOOL)isKeyAvailbaleInDefault:(NSString *)key;

@end
