//
//  WebHelper.m
//  SQLExample
//
//  Created by iMac on 17/03/14.
//  Copyright (c) 2014 Narola. All rights reserved.
//
//[[FamousFoodWS alloc]initWithDictionary:allvalues];
//[[classname alloc]initWithDictionary:allvalues];
//[[[NSClassFromString(classname) alloc] init] initWithDictionary:allvalues]

#import "WebServiceDataAdaptor.h"
#import <objc/runtime.h>

@implementation WebServiceDataAdaptor

@synthesize arrParsedData;

-(NSArray *)autoParse:(NSDictionary *)allValues forServiceName:(NSString *)requestURL
{
    arrParsedData = [NSArray new];
    
    if (isService(URLLogin) || isService(URLSocialLogin) || isService(URLSignUp) || isService(URLGetConfig) || isService(URLSetConfig))
    {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue])
        {
            arrParsedData = [self processJSONData:allValues
                                         forClass:LoginClass
                                        forEntity:LoginEntity
                                      withJSONKey:LoginKey];
        }
    }
    else if (isService(URLGetMyFolders) || ([requestURL containsString:URLGetMyFolders]))
    {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue])
        {
            arrParsedData = [self processJSONData:allValues
                                         forClass:RoadbooksClass
                                        forEntity:RoadbooksEntity
                                      withJSONKey:RoadbooksKey];
        }
    }
    else if (isService(URLGetMyRoadBooks))
    {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue])
        {
            arrParsedData = [self processJSONData:allValues
                                         forClass:RoadBooksClass
                                        forEntity:RoadBooksEntity
                                      withJSONKey:RoadBooksKey];
        }
    }
    else if ([requestURL containsString:URLGetRouteDetails])
    {
        if ([[allValues valueForKey:SUCCESS_STATUS] boolValue])
        {
            arrParsedData = [self processJSONData:allValues
                                         forClass:RouteClass
                                        forEntity:RouteEntity
                                      withJSONKey:RouteKey];
        }
    }
    
    return arrParsedData;
}

#pragma mark - Helper Method
- (void)processJSONToUserDefaults:(NSDictionary *)dict withJSONKeys:(NSMutableArray *)json_Keys
{
    for (int i =0;i<[json_Keys count];i++)
    {
        [DefaultsValues setStringValueToUserDefaults:[Function getStringForKey:[json_Keys objectAtIndex:i] fromDictionary:dict] ForKey:[json_Keys objectAtIndex:i]];
    }
}


- (NSArray *)processJSONData:(NSDictionary *)dict
                    forClass:(NSString *)classname
                   forEntity:(NSString *)entityname
                 withJSONKey:(NSString *)json_Key
{
    NSMutableArray *arrProcessedData = [NSMutableArray array];
    
    if ([[dict objectForKey:json_Key] isKindOfClass:[NSArray class]])
    {
        if ([entityname isEqualToString:RoadBooksEntity])
        {
            [CoreDataAdaptor deleteAllDataInCoreDB:entityname];
        }
        
        for (int i = 0; i < [[dict objectForKey:json_Key] count]; i++)
        {
            NSDictionary *allvalues = [[dict objectForKey:json_Key] objectAtIndex:i];
            id objClass = [[[NSClassFromString(classname) alloc] init] initWithDictionary:allvalues];
            [arrProcessedData addObject:objClass];
            
            if (![Function stringIsEmpty:entityname])
            {
                if ([entityname isEqualToString:RoadBooksEntity])
                {
                    Routes *objRoute = objClass;
                    
                    NSArray *arrCDUser = [[[CDRoutes query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"routesIdentifier='%f'",objRoute.routesIdentifier]]] all];
                        
                    if([arrCDUser count] > 0)
                    {
                        CDRoutes *objCDUser=[arrCDUser firstObject];
                        objCDUser.name=[NSString stringWithFormat:@"%@",objRoute.name];
                        objCDUser.length=[NSNumber numberWithDouble:objRoute.length];
                        objCDUser.updatedAt=[NSString stringWithFormat:@"%@",objRoute.updatedAt];
                        objCDUser.units=[NSString stringWithFormat:@"%@",objRoute.units];
                        objCDUser.waypointCount=[NSNumber numberWithDouble:objRoute.waypointCount];
                        [CoreDataHelper save];
                    }
                    else
                    {
                        [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objRoute] forEntity:RoadBooksEntity];
                    }
                }
            }
        }
    }
    else
    {
        @try
        {
            id objClass = [[[NSClassFromString(classname) alloc] init] initWithDictionary:[dict objectForKey:json_Key]];
            [arrProcessedData addObject:objClass];
            
            if (![Function stringIsEmpty:entityname])
            {
                if ([entityname isEqualToString:RoadbooksEntity])
                {
                    Roadbooks *objRoadbooks = objClass;
                    
                    [CoreDataAdaptor deleteDataInCoreDB:NSStringFromClass([CDFolders class])
                                          withCondition:[NSString stringWithFormat:@"parentId='%f'", objRoadbooks.parentId]];

                    for (Folders *objFolder in objRoadbooks.folders)
                    {
                        if ([objFolder.folderType isEqualToString:@"default"])
                        {
                            objRoadbooks.parentId = objFolder.foldersIdentifier;
                        }

                        NSArray *arrCDUser = [[[CDFolders query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"foldersIdentifier='%f'",objFolder.foldersIdentifier]]] all];
                        
                        if([arrCDUser count] > 0)
                        {
                            CDFolders *objCDFolder = [arrCDUser firstObject];
                            objCDFolder.folderName = objFolder.folderName;
                            objCDFolder.folderType = objFolder.folderType;
                            objCDFolder.parentId = [NSNumber numberWithDouble:objFolder.parentId];
                            objCDFolder.subfoldersCount = [NSNumber numberWithDouble:objFolder.subfoldersCount];
                            objCDFolder.routesCounts = [NSNumber numberWithDouble:objFolder.routesCounts];
                            [CoreDataHelper save];
                        }
                        else
                        {
                            [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objFolder] forEntity:@"CDFolders"];
                        }
                    }
                    
                    [CoreDataAdaptor deleteDataInCoreDB:NSStringFromClass([CDRoutes class])
                                          withCondition:[NSString stringWithFormat:@"folderId='%f'", objRoadbooks.parentId]];
                    
                    for (Routes *objRoute in objRoadbooks.routes)
                    {
                        NSArray *arrCDUser = [[[CDRoutes query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"routesIdentifier='%f'",objRoute.routesIdentifier]]] all];
                        
                        if([arrCDUser count] > 0)
                        {
                            CDRoutes *objCDUser=[arrCDUser firstObject];
                            objCDUser.name=[NSString stringWithFormat:@"%@",objRoute.name];
                            objCDUser.length=[NSNumber numberWithDouble:objRoute.length];
                            objCDUser.updatedAt=[NSString stringWithFormat:@"%@",objRoute.updatedAt];
                            objCDUser.units=[NSString stringWithFormat:@"%@",objRoute.units];
                            objCDUser.waypointCount=[NSNumber numberWithDouble:objRoute.waypointCount];
                            objCDUser.folderId=[NSNumber numberWithDouble:objRoute.folderId];
                            objCDUser.editable=[NSNumber numberWithBool:objRoute.editable];
                            [CoreDataHelper save];
                        }
                        else
                        {
                            [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objRoute] forEntity:RoadBooksEntity];
                        }
                    }
                }
                else if ([entityname isEqualToString:RouteEntity])
                {
                    Route *objRoute = objClass;

                    NSArray *arrCDUser = [[[CDRoute query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"routeIdentifier='%f'",objRoute.routeIdentifier]]] all];

                    if([arrCDUser count] > 0)
                    {
                        CDRoute *objCDUser=[arrCDUser firstObject];
                        objCDUser.name=[NSString stringWithFormat:@"%@",objRoute.name];
                        objCDUser.length=[NSNumber numberWithDouble:objRoute.length];
                        objCDUser.updatedAt=[NSString stringWithFormat:@"%@",objRoute.updatedAt];
                        objCDUser.units=[NSString stringWithFormat:@"%@",objRoute.units];
                        objCDUser.waypointCount=[NSNumber numberWithDouble:objRoute.waypointCount];
                        objCDUser.routeIdentifier=[NSNumber numberWithDouble:objRoute.routeIdentifier];
                        objCDUser.userId=[NSNumber numberWithDouble:objRoute.userId];
                        objCDUser.endAddress=[NSString stringWithFormat:@"%@",objRoute.endAddress];
                        objCDUser.endLatitude=[NSNumber numberWithDouble:objRoute.endLatitude];
                        objCDUser.startLongitude=[NSNumber numberWithDouble:objRoute.startLongitude];
                        objCDUser.fuelRange=[NSNumber numberWithDouble:objRoute.fuelRange];
                        objCDUser.startLatitude=[NSNumber numberWithDouble:objRoute.startLatitude];
//                        objCDUser.folderId=[NSNumber numberWithDouble:objRoute.folderId];
                        objCDUser.endLongitude=[NSNumber numberWithDouble:objRoute.endLongitude];
                        objCDUser.deletedAt=[NSString stringWithFormat:@"%@",objRoute.deletedAt];
                        objCDUser.token=[NSString stringWithFormat:@"%@",objRoute.token];
                        objCDUser.sharingLevel=[NSNumber numberWithDouble:objRoute.sharingLevel];
                        objCDUser.startAddress=[NSString stringWithFormat:@"%@",objRoute.startAddress];
                        objCDUser.currentStyle=[NSString stringWithFormat:@"%@",objRoute.currentStyle];
                        objCDUser.data=[NSString stringWithFormat:@"%@",objRoute.data];
                        objCDUser.lock=[NSString stringWithFormat:@"%@",objRoute.lock];
                        objCDUser.routeDescription=[NSString stringWithFormat:@"%@",objRoute.routeDescription];

                        [CoreDataHelper save];
                    }
                    else
                    {
                        [CoreDataAdaptor SaveDataInCoreDB:[self processObjectForCoreData:objRoute] forEntity:RouteEntity];
                    }
                }
            }
        } @catch (NSException *exception) { } @finally { }
    }
    
    return arrProcessedData;
}

- (NSDictionary *)processObjectForCoreData:(id)obj
{
    NSArray *aVoidArray =@[@"NSDate"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    for (int i = 0; i < count; i++)
    {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (![aVoidArray containsObject: key] )
        {
            if ([obj valueForKey:key]!=nil)
            {
                [dict setObject:[obj valueForKey:key] forKey:key];
            }
        }
    }
    return dict;
}

@end
