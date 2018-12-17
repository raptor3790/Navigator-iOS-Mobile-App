//
//  DefaultsValues.m
//  MPA
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import "DefaultsValues.h"

@implementation DefaultsValues

#pragma mark -
#pragma mark - Defaults String Values

+ (void)setStringValueToUserDefaults:(NSString *)strValue ForKey:(NSString *)strKey
{
    if ([NSUserDefaults standardUserDefaults]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@", strValue] forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)getStringValueFromUserDefaults_ForKey:(NSString *)strKey
{
    NSString *s = nil;
    if ([NSUserDefaults standardUserDefaults]) {
        s =[[NSUserDefaults standardUserDefaults] valueForKey:strKey];
    }
    return s;
}

#pragma mark - Defaults Integer Values

+ (void)setIntegerValueToUserDefaults:(int)intValue ForKey:(NSString *)intKey
{
    if ([NSUserDefaults standardUserDefaults]) {
        [[NSUserDefaults standardUserDefaults] setInteger:intValue forKey:intKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (int)getIntegerValueFromUserDefaults_ForKey:(NSString *)intKey
{
    int i = 0;
    if ([NSUserDefaults standardUserDefaults]) {
        i = (int) [[NSUserDefaults standardUserDefaults] integerForKey:intKey];
    }
    return i;
}

#pragma mark - Defaults Boolean Values

+ (void)setBooleanValueToUserDefaults:(bool)booleanValue ForKey:(NSString *)booleanKey
{
    if ([NSUserDefaults standardUserDefaults]) {
        [[NSUserDefaults standardUserDefaults] setBool:booleanValue forKey:booleanKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (bool)getBooleanValueFromUserDefaults_ForKey:(NSString *)booleanKey
{
    bool b = false;
    if ([NSUserDefaults standardUserDefaults]) {
        b = [[NSUserDefaults standardUserDefaults] boolForKey:booleanKey];
    }
    return b;
}

#pragma mark - Defaults Object Values

+ (void)setObjectValueToUserDefaults:(id)idValue ForKey:(NSString *)strKey
{
    if ([NSUserDefaults standardUserDefaults]) {
        [[NSUserDefaults standardUserDefaults] setObject:idValue forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (id)getObjectValueFromUserDefaults_ForKey:(NSString *)strKey
{
    id obj = nil;
    if ([NSUserDefaults standardUserDefaults]) {
        obj =[[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    }
    
    return obj;
}

#pragma mark - Defaults Custom Object Values

+ (void)setCustomObjToUserDefaults:(id)CustomeObj ForKey:(NSString *)CustomeObjKey
{
     [[NSUserDefaults standardUserDefaults] setCustomObject:CustomeObj forKey:CustomeObjKey];
}

+ (id)getCustomObjFromUserDefaults_ForKey:(NSString *)CustomeObjKey
{
   return [[NSUserDefaults standardUserDefaults] customObjectForKey:CustomeObjKey];
}

#pragma mark - Remove Defaults Values

+ (void)removeObjectForKey:(NSString *)objectKey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:objectKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Check Key available
+ (BOOL)isKeyAvailbaleInDefault:(NSString *)key
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    
    return [[[defaults dictionaryRepresentation] allKeys] containsObject:key];
}



@end
