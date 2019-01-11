

//
//  AppDelegate.m
//  RallyNavigator
//
//  Created by C205 on 19/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "AppDelegate.h"
#import "AwsConfig.h"
#import "Reachability.h"
#import "CDSyncData.h"
#import "Route.h"
#import "Waypoints.h"
#import "Backgroundimage.h"
#import "VoiceNote.h"
#import "RoadBooksVC.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "LocationsVC.h"

@interface AppDelegate () {
    CDSyncData* objSyncData;
    NetworkStatus currentNetworkStatus;

    void (^_normalImageCompletionHandler)(BOOL completed);
    void (^_normalAudioCompletionHandler)(BOOL completed);

    void (^imageCompleteHandler)(BOOL completed);
    void (^_audioCompletionHandler)(BOOL completed);
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    if ([application applicationState] != UIApplicationStateBackground) {
        [NSThread sleepForTimeInterval:2.0];
    }

    [NSNotificationCenter.defaultCenter removeObserver:self name:kReachabilityChangedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(checkForReachability) name:kReachabilityChangedNotification object:nil];

    [self setUpAWSS3];
    [self progressView];

    [Fabric with:@[ [Crashlytics class] ]];

    //    [GMSServices provideAPIKey:@"AIzaSyDl0nFtbQA-PvT3mwxuI6TJjXVauVOVSlo"];

    // Google Login Configuration
    [GIDSignIn sharedInstance].clientID = @"1047391793931-ke1vikkcqhhkatgf8o8rd09o14h68uip.apps.googleusercontent.com";

    return YES;
}

#pragma mark - Reachability Change Event Handling

- (void)checkForReachability
{
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];

    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];

    if (remoteHostStatus == NotReachable) {
        if (currentNetworkStatus != NotReachable) {
            currentNetworkStatus = remoteHostStatus;
        }
    } else if (remoteHostStatus == ReachableViaWiFi || remoteHostStatus == ReachableViaWWAN) {
        currentNetworkStatus = remoteHostStatus;

        if (!_isWebServiceIsCalling) {
            _isWebServiceIsCalling = YES;
            NSArray* arrCDUser = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:@"isActive = 0"]] all];
            _totalWayPoints = arrCDUser.count;
            _syncedWayPoints = 0;
            [self checkForSyncData];
        }
    } else {
        currentNetworkStatus = remoteHostStatus;
    }
}

#pragma mark - Check If Any Data To Sync

- (void)checkForSyncData
{
    NSArray* arrCDUser = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:@"isActive = 0"]] all];

    if (!_isWebServiceIsCalling) {
        _isWebServiceIsCalling = YES;
        _totalWayPoints = arrCDUser.count;
        _syncedWayPoints = 0;
    }

    if (arrCDUser.count > 0 && currentNetworkStatus != NotReachable) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"SYNC_STARTED" object:self];
        objSyncData = [arrCDUser firstObject];

        if ([objSyncData.isEdit boolValue]) {
            _arrEditData = [[NSMutableArray alloc] init];
            [self uploadDataForEdit];
        } else {
            if ([objSyncData.routeIdentifier doubleValue] > 0) {
                NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[objSyncData.routeIdentifier doubleValue]];

                [[WebServiceConnector alloc] init:[[URLGetRouteDetails stringByAppendingString:@"/"] stringByAppendingString:strRouteId]
                                   withParameters:nil
                                       withObject:self
                                     withSelector:@selector(handleRouteDetailsResponse:)
                                   forServiceType:ServiceTypeGET
                                   showDisplayMsg:@""
                                       showLoader:NO];
            } else {
                [self processForData];
            }
        }
    } else {
        _totalWayPoints = 0;
        _syncedWayPoints = 0;
        _isWebServiceIsCalling = NO;
        [NSNotificationCenter.defaultCenter postNotificationName:@"SYNC_COMPLETE" object:self];
    }
    //    });
}

- (void)handleRouteDetailsResponse:(id)sender
{
    NSDictionary* dic = [sender responseDict];

    if ([dic valueForKey:RouteKey] && [[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        [self processForData];
    } else {
        [self checkForSyncData];
    }
}

- (void)processForData
{
    if (objSyncData.imageData.length > 0) {
        [self saveImageOverServer:^(BOOL success) {
            if (success) {
                if (self->objSyncData.voiceData.length > 0) {
                    [self saveAudioOverServer:^(BOOL success) {
                        if (success) {
                            [self uploadData];
                        } else {
                            [self checkForSyncData];
                        }
                    }];
                } else {
                    [self uploadData];
                }
            } else {
                [self checkForSyncData];
            }
        }];
    } else if (objSyncData.voiceData.length > 0) {
        [self saveAudioOverServer:^(BOOL success) {
            if (success) {
                [self uploadData];
            } else {
                [self checkForSyncData];
                return;
            }
        }];
    } else {
        [self uploadData];
    }
}

- (void)saveImageOverServer:(void (^)(BOOL))handler
{
    _normalImageCompletionHandler = [handler copy];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:objSyncData.imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString* strCurrentTimeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] * 1000];
    NSString* strRandomString = [NSString stringWithFormat:@"%ld", (long)1 + arc4random() % (1000 - 1)];
    NSString* strFilePath = [NSString stringWithFormat:@"tmp/%@_%@/%@_%@.jpg", strCurrentTimeStamp, strRandomString, strCurrentTimeStamp, strRandomString];

    if ([self checkIfFileAvailableForWayPointType:WayPointTypeImage]) {
        [self deleteFileForWayPointType:WayPointTypeImage];
    }

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"Hello.jpg"];
    [data writeToFile:savedImagePath atomically:YES];

    AWSS3TransferUtility* transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility uploadFile:[NSURL fileURLWithPath:savedImagePath]
                         bucket:BUCKET_NAME
                            key:strFilePath
                    contentType:@"image/jpeg"
                     expression:NULL
              completionHandler:^(AWSS3TransferUtilityUploadTask* _Nonnull task, NSError* _Nullable error) {
                  if (error) {
//                      self->_normalImageCompletionHandler(NO);
//                      self->_normalImageCompletionHandler = NULL;
                      return;
                  }

                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                          NSString* strJsonData = self->objSyncData.jsonData;

                          if (strJsonData == NULL) {
                              [self checkForSyncData];
                              return;
                          }

                          id object = [RallyNavigatorConstants convertJsonStringToObject:strJsonData];

                          if ([object isKindOfClass:[NSDictionary class]]) {
                              NSMutableDictionary* dicRoute = [object mutableCopy];

                              RouteDetails* objDetails = [[RouteDetails alloc] initWithDictionary:dicRoute];
                              Waypoints* objRoute = objDetails.waypoints[0];
                              objRoute.backgroundimage.url = [NSString stringWithFormat:@"%@%@", URLUploadImage, strFilePath];
                              objDetails.waypoints = @[ objRoute ];

                              NSMutableDictionary* dic = [[objDetails dictionaryRepresentation] mutableCopy];
                              NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:dic];
                              self->objSyncData.jsonData = strJsonData;
                              [CoreDataHelper save];
                          } else if ([object isKindOfClass:[NSArray class]]) {
                              NSMutableArray* arrOperations = [[NSMutableArray alloc] init];
                              arrOperations = [object mutableCopy];

                              NSUInteger index = 0;
                              for (NSMutableDictionary* dicOp in arrOperations) {
                                  if ([dicOp objectForKey:@"op"] && ![[dicOp valueForKey:@"op"] isEqualToString:@"add"]) {
                                      NSMutableDictionary* dicAddOp = [[arrOperations objectAtIndex:(index - 1)] mutableCopy];

                                      Waypoints* objWP = [[Waypoints alloc] initWithDictionary:[dicAddOp valueForKey:@"value"]];
                                      objWP.backgroundimage.url = [NSString stringWithFormat:@"%@%@", URLUploadImage, strFilePath];
                                      objWP.backgroundimage.backgroundimageIdentifier = -2;

                                      [dicAddOp setObject:[objWP dictionaryRepresentation] forKey:@"value"];
                                      [arrOperations replaceObjectAtIndex:(index - 1) withObject:dicAddOp];
                                      NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:arrOperations];
                                      self->objSyncData.jsonData = strJsonData;
                                      [CoreDataHelper save];

                                      break;
                                  }
                                  index++;
                              }
                          }

                          self->_normalImageCompletionHandler(YES);
                          self->_normalImageCompletionHandler = nil;
                      }];
                  });
              }];
}

- (void)saveAudioOverServer:(void (^)(BOOL))handler
{
    _normalAudioCompletionHandler = [handler copy];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:objSyncData.voiceData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString* strCurrentTimeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] * 1000];
    NSString* strRandomString = [NSString stringWithFormat:@"%ld", (long)1 + arc4random() % (1000 - 1)];
    NSString* strFilePath = [NSString stringWithFormat:@"tmp/%@_%@/%@_%@.m4a", strCurrentTimeStamp, strRandomString, strCurrentTimeStamp, strRandomString];

    if ([self checkIfFileAvailableForWayPointType:WayPointTypeImage]) {
        [self deleteFileForWayPointType:WayPointTypeImage];
    }

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"Hello.m4a"];
    [data writeToFile:savedImagePath atomically:YES];

    AWSS3TransferUtility* transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility uploadFile:[NSURL fileURLWithPath:savedImagePath]
                         bucket:BUCKET_NAME
                            key:strFilePath
                    contentType:@"video/m4a"
                     expression:NULL
              completionHandler:^(AWSS3TransferUtilityUploadTask* _Nonnull task, NSError* _Nullable error) {
                  if (error) {
//                      self->_normalAudioCompletionHandler(NO);
//                      self->_normalAudioCompletionHandler = nil;
                      return;
                  }
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                          NSString* strJsonData = self->objSyncData.jsonData;

                          if (strJsonData == NULL) {
                              [self checkForSyncData];
                              return;
                          }

                          id object = [RallyNavigatorConstants convertJsonStringToObject:strJsonData];

                          if ([object isKindOfClass:[NSDictionary class]]) {
                              NSMutableDictionary* dicRoute = [object mutableCopy];

                              RouteDetails* objDetails = [[RouteDetails alloc] initWithDictionary:dicRoute];
                              Waypoints* objRoute = objDetails.waypoints[0];
                              objRoute.voiceNote.url = [NSString stringWithFormat:@"%@%@", URLUploadImage, strFilePath];
                              objDetails.waypoints = @[ objRoute ];

                              NSMutableDictionary* dic = [[objDetails dictionaryRepresentation] mutableCopy];
                              NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:dic];
                              self->objSyncData.jsonData = strJsonData;
                              [CoreDataHelper save];

                          } else if ([object isKindOfClass:[NSArray class]]) {

                              NSMutableArray* arrOperations = [[NSMutableArray alloc] init];
                              arrOperations = [object mutableCopy];

                              NSUInteger index = 0;

                              for (NSMutableDictionary* dicOp in arrOperations) {
                                  if ([dicOp objectForKey:@"op"]) {
                                      if (![[dicOp valueForKey:@"op"] isEqualToString:@"add"]) {
                                          NSMutableDictionary* dicAddOp = [[arrOperations objectAtIndex:(index - 1)] mutableCopy];

                                          Waypoints* objWP = [[Waypoints alloc] initWithDictionary:[dicAddOp valueForKey:@"value"]];
                                          objWP.voiceNote.url = [NSString stringWithFormat:@"%@%@", URLUploadImage, strFilePath];
                                          objWP.voiceNote.voiceNoteIdentifier = -2;
                                          [dicAddOp setObject:[objWP dictionaryRepresentation] forKey:@"value"];
                                          [arrOperations replaceObjectAtIndex:(index - 1) withObject:dicAddOp];
                                          NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:arrOperations];
                                          self->objSyncData.jsonData = strJsonData;
                                          [CoreDataHelper save];
                                          break;
                                      }
                                  }
                                  index++;
                              }
                          }

                          self->_normalAudioCompletionHandler(YES);
                          self->_normalAudioCompletionHandler = nil;
                      }];
                  });
              }];
}

- (void)uploadData
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString* strURL = URLGetRouteDetails;

        if ([self->objSyncData.routeIdentifier doubleValue] > 0) {
            id object = [RallyNavigatorConstants convertJsonStringToObject:self->objSyncData.jsonData];

            if ([object isKindOfClass:[NSArray class]]) {
                //                NSLog(@"ARRAY");

                NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[self->objSyncData.routeIdentifier doubleValue]];
                NSString* strRoadBookId = [NSString stringWithFormat:@"routeIdentifier = %@", strRouteId];
                NSArray* arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];
                CDRoute* objRoute = arrSyncedData[0];
                NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objRoute.data];
                RouteDetails* objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];

                NSUInteger count = objRouteDetails.waypoints.count;

                NSMutableArray* arrOperations = [[NSMutableArray alloc] init];
                arrOperations = [object mutableCopy];

                for (int index = 0; index < arrOperations.count; index++) {
                    NSMutableDictionary* dicOp = [[arrOperations objectAtIndex:index] mutableCopy];

                    if ([dicOp objectForKey:@"op"]) {
                        if ([[dicOp valueForKey:@"op"] isEqualToString:@"add"]) {
                            NSMutableDictionary* dicAddOp = [[arrOperations objectAtIndex:index] mutableCopy];
                            [dicAddOp setObject:[NSString stringWithFormat:@"/waypoints/%ld", (long)count] forKey:@"path"];
                            count++;
                            Waypoints* objWayPoint = [[Waypoints alloc] initWithDictionary:[dicAddOp valueForKey:@"value"]];
                            objWayPoint.waypointid = count;
                            [dicAddOp setObject:[objWayPoint dictionaryRepresentation] forKey:@"value"];
                            [arrOperations replaceObjectAtIndex:index withObject:dicAddOp];
                            NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:arrOperations];
                            self->objSyncData.jsonData = strJsonData;
                        }
                    }
                }
                [CoreDataHelper save];
            }
        }

        NSData* data = [self->objSyncData.jsonData dataUsingEncoding:NSUTF8StringEncoding];
        NSString* strBase64Encoded = [data base64EncodedStringWithOptions:0];
        NSMutableDictionary* dicData = [[NSMutableDictionary alloc] init];
        [dicData setValue:strBase64Encoded forKey:@"data"];
        if ([self->objSyncData.routeIdentifier doubleValue] > 0) {
            NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[self->objSyncData.routeIdentifier doubleValue]];
            [dicData setValue:strRouteId forKey:@"id"];
            strURL = [[strURL stringByAppendingString:@"/"] stringByAppendingString:strRouteId];
        }
        NSMutableDictionary* dicRoute = [[NSMutableDictionary alloc] init];
        [dicRoute setValue:dicData forKey:@"route"];

        [[WebServiceConnector alloc] init:strURL
                           withParameters:dicRoute
                               withObject:self
                             withSelector:@selector(handleWayPointResponse:)
                           forServiceType:(ServiceType)[self->objSyncData.serviceType integerValue]
                           showDisplayMsg:@""
                               showLoader:NO];
    });
}

- (void)handleWayPointResponse:(id)sender
{
    NSDictionary* dic = [sender responseDict];

    if ([dic valueForKey:RouteKey] && [[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        self->objSyncData.isActive = [NSNumber numberWithInteger:1];
        [CoreDataHelper save];

        if ([self->objSyncData.routeIdentifier doubleValue] < 0) {
            NSString* strOldRouteId = [NSString stringWithFormat:@"%ld", (long)[self->objSyncData.routeIdentifier doubleValue]];
            NSString* strNewRouteId;

            NSArray* arrResponse = [sender responseArray];

            if (arrResponse.count > 0) {
                Route* objWSRoute = [arrResponse firstObject];

                strNewRouteId = [NSString stringWithFormat:@"%ld", (long)objWSRoute.routeIdentifier];

                NSArray* arrCDUser = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"routeIdentifier='%ld'", (long)[self->objSyncData.routeIdentifier doubleValue]]]] all];

                if (self.window.rootViewController && [self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController* nav = (UINavigationController*)self.window.rootViewController;

                    for (id vc in nav.viewControllers) {
                        if ([vc isKindOfClass:[LocationsVC class]]) {
                            LocationsVC* l_VC = vc;
                            if ([l_VC.strRouteIdentifier isEqualToString:strOldRouteId]) {
                                l_VC.strRouteIdentifier = strNewRouteId;
                            }
                        }
                    }
                }

                for (CDSyncData* obj in arrCDUser) {
                    obj.routeIdentifier = [NSNumber numberWithDouble:objWSRoute.routeIdentifier];
                    [CoreDataHelper save];
                }
            }
        }

        [NSNotificationCenter.defaultCenter postNotificationName:@"objectRefreshed" object:self userInfo:nil];

        _syncedWayPoints++;
        [self checkForSyncData];
    } else {
        [self checkForSyncData];
    }
}

#pragma mark - Edit Feature Integration

- (void)uploadDataForEdit
{
    NSDictionary* dic = [RallyNavigatorConstants convertJsonStringToObject:objSyncData.jsonData];
    NSString* strWayPointId = [dic valueForKey:@"wayPointId"];
    NSString* strWayPointDesc = [dic valueForKey:@"wayPointDesc"];

    if (objSyncData.imageData.length > 0) {
        [self uploadImageForEdit:^(BOOL success) {
            //             NSLog(@"Uploaded");
            if (self->objSyncData.voiceData.length > 0) {
                [self uploadVoiceForEdit:^(BOOL success) {
                    //                     NSLog(@"Uploaded");

                    NSMutableDictionary* dicAdd1 =
                        [self getSaveWayPointDictionaryForOperation:@"replace"
                                                               path:[NSString stringWithFormat:@"/waypoints/%@/description", strWayPointId]
                                                              value:strWayPointDesc];
                    [self.arrEditData addObject:dicAdd1];

                    [self uploadEditedDataOnServer];
                }];
            } else {
                NSMutableDictionary* dicAdd1 =
                    [self getSaveWayPointDictionaryForOperation:@"replace"
                                                           path:[NSString stringWithFormat:@"/waypoints/%@/description", strWayPointId]
                                                          value:strWayPointDesc];
                [self.arrEditData addObject:dicAdd1];

                [self uploadEditedDataOnServer];
            }
        }];
    } else if (objSyncData.voiceData.length > 0) {
        [self uploadVoiceForEdit:^(BOOL success) {
            //            NSLog(@"Uploaded");

            NSMutableDictionary* dicAdd1 =
                [self getSaveWayPointDictionaryForOperation:@"replace"
                                                       path:[NSString stringWithFormat:@"/waypoints/%@/description", strWayPointId]
                                                      value:strWayPointDesc];
            [self.arrEditData addObject:dicAdd1];

            [self uploadEditedDataOnServer];
        }];
    } else {
        NSMutableDictionary* dicAdd1 =
            [self getSaveWayPointDictionaryForOperation:@"replace"
                                                   path:[NSString stringWithFormat:@"/waypoints/%@/description", strWayPointId]
                                                  value:strWayPointDesc];
        [self.arrEditData addObject:dicAdd1];

        [self uploadEditedDataOnServer];
    }
}

- (void)uploadEditedDataOnServer
{
    NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[objSyncData.routeIdentifier doubleValue]];

    NSMutableDictionary* dicAdd1 =
        [self getSaveWayPointDictionaryForOperation:@"add"
                                               path:@"/id"
                                              value:strRouteId];
    [_arrEditData addObject:dicAdd1];

    NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:_arrEditData];
    NSData* data = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSString* strBase64Encoded = [data base64EncodedStringWithOptions:0];

    NSMutableDictionary* dicData = [[NSMutableDictionary alloc] init];
    [dicData setValue:strBase64Encoded forKey:@"data"];
    [dicData setValue:strRouteId forKey:@"id"];

    NSMutableDictionary* dicRoute = [[NSMutableDictionary alloc] init];
    [dicRoute setValue:dicData forKey:@"route"];

    [[WebServiceConnector alloc] init:[[URLGetRouteDetails stringByAppendingString:@"/"] stringByAppendingString:strRouteId]
                       withParameters:dicRoute
                           withObject:self
                         withSelector:@selector(handleWayPointResponse:)
                       forServiceType:ServiceTypePUT
                       showDisplayMsg:@""
                           showLoader:NO];
}

- (void)uploadImageForEdit:(void (^)(BOOL))handler
{
    NSDictionary* dic = [RallyNavigatorConstants convertJsonStringToObject:objSyncData.jsonData];
    NSString* strWayPointId = [dic valueForKey:@"wayPointId"];

    imageCompleteHandler = [handler copy];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:objSyncData.imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString* strCurrentTimeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] * 1000];
    NSString* strRandomString = [NSString stringWithFormat:@"%ld", (long)1 + arc4random() % (1000 - 1)];
    NSString* strFilePath = [NSString stringWithFormat:@"tmp/%@_%@/%@_%@.jpg", strCurrentTimeStamp, strRandomString, strCurrentTimeStamp, strRandomString];

    if ([self checkIfFileAvailableForWayPointType:WayPointTypeImage]) {
        [self deleteFileForWayPointType:WayPointTypeImage];
    }

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"Hello.jpg"];
    [data writeToFile:savedImagePath atomically:YES];

    AWSS3TransferUtility* transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility uploadFile:[NSURL fileURLWithPath:savedImagePath]
                         bucket:BUCKET_NAME
                            key:strFilePath
                    contentType:@"image/jpeg"
                     expression:NULL
              completionHandler:^(AWSS3TransferUtilityUploadTask* _Nonnull task, NSError* _Nullable error) {
                  if (error) {
                      return;
                  }

                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                          NSMutableDictionary* dicAdd1 =
                              [self getSaveWayPointDictionaryForOperation:@"replace"
                                                                     path:[NSString stringWithFormat:@"/waypoints/%@/backgroundimage/id", strWayPointId]
                                                                    value:[NSNumber numberWithInteger:-2]];

                          NSMutableDictionary* dicAdd2 =
                              [self getSaveWayPointDictionaryForOperation:@"replace"
                                                                     path:[NSString stringWithFormat:@"/waypoints/%@/backgroundimage/url", strWayPointId]
                                                                    value:[NSString stringWithFormat:@"%@%@", URLUploadImage, strFilePath]];

                          [self.arrEditData addObject:dicAdd1];
                          [self.arrEditData addObject:dicAdd2];

                          self->imageCompleteHandler(YES);
                          self->imageCompleteHandler = nil;
                      }];
                  });
              }];
}

- (void)uploadVoiceForEdit:(void (^)(BOOL))handler
{
    NSDictionary* dic = [RallyNavigatorConstants convertJsonStringToObject:objSyncData.jsonData];
    NSString* strWayPointId = [dic valueForKey:@"wayPointId"];

    _audioCompletionHandler = [handler copy];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:objSyncData.voiceData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString* strCurrentTimeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] * 1000];
    NSString* strRandomString = [NSString stringWithFormat:@"%ld", (long)1 + arc4random() % (1000 - 1)];
    NSString* strFilePath = [NSString stringWithFormat:@"tmp/%@_%@/%@_%@.m4a", strCurrentTimeStamp, strRandomString, strCurrentTimeStamp, strRandomString];

    if ([self checkIfFileAvailableForWayPointType:WayPointTypeAudio]) {
        [self deleteFileForWayPointType:WayPointTypeAudio];
    }

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"Hello.m4a"];
    [data writeToFile:savedImagePath atomically:YES];

    AWSS3TransferUtility* transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility uploadFile:[NSURL fileURLWithPath:savedImagePath]
                         bucket:BUCKET_NAME
                            key:strFilePath
                    contentType:@"video/m4a"
                     expression:NULL
              completionHandler:^(AWSS3TransferUtilityUploadTask* _Nonnull task, NSError* _Nullable error) {
                  if (error) {
                      return;
                  }

                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                          NSMutableDictionary* dicAdd1 =
                              [self getSaveWayPointDictionaryForOperation:@"replace"
                                                                     path:[NSString stringWithFormat:@"/waypoints/%@/voiceNote/id", strWayPointId]
                                                                    value:[NSNumber numberWithInteger:-2]];

                          NSMutableDictionary* dicAdd2 =
                              [self getSaveWayPointDictionaryForOperation:@"replace"
                                                                     path:[NSString stringWithFormat:@"/waypoints/%@/voiceNote/url", strWayPointId]
                                                                    value:[NSString stringWithFormat:@"%@%@", URLUploadImage, strFilePath]];

                          [self.arrEditData addObject:dicAdd1];
                          [self.arrEditData addObject:dicAdd2];

                          self->_audioCompletionHandler(YES);
                          self->_audioCompletionHandler = nil;
                      }];
                  });
              }];
}

- (NSMutableDictionary*)getSaveWayPointDictionaryForOperation:(NSString*)strOperation path:(NSString*)strPath value:(id)value
{
    NSMutableDictionary* dicWayPointOperation = [[NSMutableDictionary alloc] init];

    [dicWayPointOperation setValue:strOperation forKey:@"op"];
    [dicWayPointOperation setValue:strPath forKey:@"path"];
    [dicWayPointOperation setValue:value forKey:@"value"];

    return dicWayPointOperation;
}

- (BOOL)checkIfFileAvailableForWayPointType:(WayPointType)wpType
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* strMediaFile = nil;

    switch (wpType) {
    case WayPointTypeImage: {
        strMediaFile = [documentsDirectory stringByAppendingPathComponent:@"Hello.jpg"];
    } break;

    case WayPointTypeAudio: {
        strMediaFile = [documentsDirectory stringByAppendingPathComponent:@"Hello.m4a"];
    } break;

    default: {
        return NO;
    } break;
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:strMediaFile];
}

- (void)deleteFileForWayPointType:(WayPointType)wpType
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* strMediaFile = nil;

    switch (wpType) {
    case WayPointTypeImage: {
        strMediaFile = [documentsDirectory stringByAppendingPathComponent:@"Hello.jpg"];
    } break;

    case WayPointTypeAudio: {
        strMediaFile = [documentsDirectory stringByAppendingPathComponent:@"Hello.m4a"];
    } break;

    default:
        break;
    }

    NSError* error = nil;

    NSURL* url = [NSURL fileURLWithPath:strMediaFile];

    //    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&error];

    //    if(!audioData)
    //        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);

    NSFileManager* fileManager = [NSFileManager defaultManager];

    error = nil;

    [fileManager removeItemAtPath:[url path] error:&error];

    //    if (error)
    //        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

#pragma mark - Amazon S3 Integration

- (void)setUpAWSS3
{
    AWSStaticCredentialsProvider* credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAJEDWHUWT2SAFLXXA" secretKey:@"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"];
    AWSServiceConfiguration* configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}

- (void)applicationWillResignActive:(UIApplication*)application {}

- (void)applicationDidEnterBackground:(UIApplication*)application {}

- (void)applicationWillEnterForeground:(UIApplication*)application {}

- (void)applicationDidBecomeActive:(UIApplication*)application {}

- (void)applicationWillTerminate:(UIApplication*)application {}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options
{
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

#pragma mark - Loader View Set Up

- (void)progressView
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:0.4f];
    [SVProgressHUD setMaximumDismissTimeInterval:0.8f];
    [SVProgressHUD setFont:THEME_FONT_Medium(16)];
}

@end
