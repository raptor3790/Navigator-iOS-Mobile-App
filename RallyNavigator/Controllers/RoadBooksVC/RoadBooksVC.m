//
//  RoadBooksVC.m
//  RallyNavigator
//
//  Created by C205 on 29/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "RoadBooksVC.h"
#import "AddFolderVC.h"
#import "LocationsVC.h"
#import "SettingsVC.h"
#import "RoadBooksCell.h"
#import "RoadBooks.h"
#import "CDSyncData.h"
#import "CDSyncFolders.h"
#import "Routes.h"
#import "Route.h"
#import "Folders.h"
#import "RouteDetails.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Crashlytics/Crashlytics.h>

@interface RoadBooksVC () <SettingsVCDelegate, AddFolderVCDelegate, UIScrollViewDelegate> {
    BOOL isLoaded;
    BOOL isPullToRefresh;

    NSString* strRoadBookId;

    User* objUser;
}
@end

@implementation RoadBooksVC
@synthesize arrRoadBooks;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    if (_strRoadbookPageName) {
        self.title = _strRoadbookPageName;
    }

    _btnAddRoute.hidden = _isAddRouteHidden || _isOverlayTrack;
    _btnAddFolder.hidden = _isAddRouteHidden || _isOverlayTrack;

    if (!_isOverlayTrack) {
        UIBarButtonItem* btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"drawer") style:UIBarButtonItemStyleDone target:self action:@selector(btnSettingsClicked:)];
        self.navigationItem.rightBarButtonItem = btnDrawer;
    }

    _tblRoadBooks.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    objUser = GET_USER_OBJ;

    [self pullToRefreshHeaderSetUpForTableView:_tblRoadBooks
                                    withStatus:@"Get new roadbooks"
                           withRefreshingBlock:^{
                               [self getMyRoadBooksWithLoader:NO];
                           }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"objectRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SYNC_STARTED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SYNC_COMPLETE" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerAction:) name:@"objectRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStarted:) name:@"SYNC_STARTED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleted:) name:@"SYNC_COMPLETE" object:nil];

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
        [self.navigationController.navigationBar setTitleTextAttributes:
                                                     @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];

        self.view.backgroundColor = [UIColor blackColor];
        _tblRoadBooks.backgroundColor = [UIColor blackColor];

        ((MJRefreshNormalHeader*)_tblRoadBooks.mj_header).stateLabel.textColor = [UIColor lightGrayColor];
        ((MJRefreshNormalHeader*)_tblRoadBooks.mj_header).activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        [self.navigationController.navigationBar setTitleTextAttributes:
                                                     @{ NSForegroundColorAttributeName : [UIColor blackColor] }];

        self.view.backgroundColor = [UIColor whiteColor];
        _tblRoadBooks.backgroundColor = [UIColor whiteColor];

        ((MJRefreshNormalHeader*)_tblRoadBooks.mj_header).stateLabel.textColor = [UIColor blackColor];
        ((MJRefreshNormalHeader*)_tblRoadBooks.mj_header).activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }

    [self getRoadBooks];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Fetch Roadbooks

- (void)getRoadBooks
{
    objUser = GET_USER_OBJ;

    [self callWSWithLoader:!isLoaded];

    isLoaded = YES;
}

- (void)callWSWithLoader:(BOOL)showLoader
{
    [self fetchRoadBooks];

    if ([[WebServiceConnector alloc] checkNetConnection]) {
        [self getMyRoadBooksWithLoader:showLoader];
    }
}

#pragma mark -  WS Call

- (void)getMyRoadBooksWithLoader:(BOOL)showLoader
{
    NSString* strAppendURL = URLGetMyFolders;

    if (_strFolderId) {
        strAppendURL = [strAppendURL stringByAppendingString:[NSString stringWithFormat:@"?folder_id=%@", _strFolderId]];
    }

    [[WebServiceConnector alloc] init:strAppendURL
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleMyRoadBooksResponse:)
                       forServiceType:ServiceTypeGET
                       showDisplayMsg:@""
                           showLoader:NO];
}

- (IBAction)handleMyRoadBooksResponse:(id)sender
{
    if ([self isHeaderRefreshingForTableView:_tblRoadBooks]) {
        [_tblRoadBooks.mj_header endRefreshing];
    }

    [self fetchRoadBooks];
}

#pragma mark - Update Existing Records

- (IBAction)triggerAction:(id)sender
{
    [self callWSWithLoader:NO];
}

#pragma mark - Sync Bar Handler

- (IBAction)syncStarted:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{

        CGFloat synced = (CGFloat)AppContext.syncedWayPoints;
        CGFloat total = (CGFloat)AppContext.totalWayPoints;

        CGFloat percentage = synced / total;

        self.lblSync.text = [NSString stringWithFormat:@"Saving Roadbooks to Server - %d%%", ((int)(percentage * 100))];

        self.heightLblSync.constant = 30.0f;
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    });
}

- (IBAction)syncCompleted:(id)sender
{
    _lblSync.text = @"Saved to www.RallyNavigator.com";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.heightLblSync.constant = 0.0f;
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    });
}

#pragma mark - Delete Roadbook Web Service

- (void)deleteRoadbookWithRoadbookId:(NSString*)strRoadbookId
{
    strRoadBookId = strRoadbookId;

    [[WebServiceConnector alloc] init:[NSString stringWithFormat:@"%@%@", URLDeleteRoadBook, strRoadbookId]
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleDeleteRoadbookResponse:)
                       forServiceType:ServiceTypeDELETE
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)handleDeleteRoadbookResponse:(id)sender
{
    NSDictionary* dictResponse = [sender responseDict];

    if ([[dictResponse valueForKey:SUCCESS_STATUS] boolValue]) {
        //        [CoreDataAdaptor deleteDataInCoreDB:NSStringFromClass([CDSyncData class])
        //                              withCondition:[NSString stringWithFormat:@"routeIdentifier = %@", strRoadBookId]];
        //        [CoreDataHelper save];
        [self getMyRoadBooksWithLoader:YES];
        //        [_tblRoadBooks reloadData];
    } else {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

#pragma mark - Fetch Routes From Core Data

- (void)fetchRoadBooks
{
    @autoreleasepool {
        NSString* predicateFolder;

        if (_strFolderId) {
            predicateFolder = [NSString stringWithFormat:@"parentId = %@", _strFolderId];
        } else {
            predicateFolder = @"parentId = 0";
        }

        NSMutableArray* arrSyncFolders =
            [[NSMutableArray alloc] initWithArray:[CoreDataAdaptor fetchDataFromLocalDB:predicateFolder
                                                                         sortDescriptor:nil
                                                                              forEntity:NSStringFromClass([CDFolders class])]];

        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(CDFolders* objFolder, NSDictionary<NSString*, id>* _Nullable bindings) {
            return (![objFolder.folderType isEqualToString:@"rally_roadbook_recorder_GPS"]) && (![objFolder.folderType isEqualToString:@"deleted_routes"]);
        }];

        _arrFolders = [[NSMutableArray alloc] init];
        _arrFolders = [[arrSyncFolders filteredArrayUsingPredicate:predicate] mutableCopy];

        predicate = [NSPredicate predicateWithBlock:^BOOL(CDFolders* objFolder, NSDictionary<NSString*, id>* _Nullable bindings) {
            return [objFolder.folderType isEqualToString:@"default"];
        }];

        NSString* parentId;

        if (_strFolderId) {
            parentId = _strFolderId;
        } else {
            NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
            arrWayPoints = [[_arrFolders filteredArrayUsingPredicate:predicate] mutableCopy];

            if (arrWayPoints.count > 0) {
                CDFolders* objFolder = arrWayPoints[0];
                parentId = [NSString stringWithFormat:@"%ld", (long)[objFolder.foldersIdentifier doubleValue]];
            } else {
                return;
            }
        }

        NSMutableArray* arrSyncData =
            [[NSMutableArray alloc] initWithArray:[CoreDataAdaptor fetchDataFromLocalDB:parentId ? [NSString stringWithFormat:@"folderId = %@", parentId] : parentId
                                                                         sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]
                                                                              forEntity:NSStringFromClass([CDRoutes class])]];

        NSArray* arrNonSyncData = [CoreDataAdaptor distinctValueFromEntity:[CDSyncData class]
                                                             withPredicate:[NSPredicate predicateWithFormat:@"isEdit = 0 AND isActive = 0 AND routeIdentifier < 0"]
                                                             attributeName:@"routeIdentifier"
                                                                     error:nil];

        NSMutableArray* arrIds = [[NSMutableArray alloc] init];

        for (NSDictionary* data in arrNonSyncData) {
            [arrIds addObject:[CoreDataAdaptor fetchData1FromLocalDB:[NSString stringWithFormat:@"isEdit = 0 AND isActive = 0 AND routeIdentifier = %@", [data valueForKey:@"routeIdentifier"]]
                                                      sortDescriptor:nil
                                                           forEntity:NSStringFromClass([CDSyncData class])]];
        }

        NSMutableArray* arrCombined = [[NSMutableArray alloc] init];
        [arrCombined addObjectsFromArray:arrSyncData];
        [arrCombined addObjectsFromArray:arrIds];

        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
        NSArray* sortDescriptors = @[ sortDescriptor ];
        NSArray* sortedArray = [arrCombined sortedArrayUsingDescriptors:sortDescriptors];

        arrRoadBooks = [[NSMutableArray alloc] init];
        arrRoadBooks = [sortedArray mutableCopy];

        NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
        arrWayPoints = [[_arrFolders filteredArrayUsingPredicate:predicate] mutableCopy];

        if (arrWayPoints.count > 0) {
            [_arrFolders removeObject:arrWayPoints[0]];
        }

        [_tblRoadBooks reloadData];
    }
}

#pragma mark - AddRoadBook Delegate Methods

- (void)createRoadBookNamed:(NSString*)strRoadBookName
{
    LocationsVC* vc = loadViewController(StoryBoard_Main, kIDLocationsVC);
    vc.isFirstTime = YES;
    vc.strRouteName = strRoadBookName;

    if (objUser == nil) {
        objUser = GET_USER_OBJ;
    }

    NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
    Config* objConfig = [[Config alloc] initWithDictionary:jsonDict];

    if ([objConfig.unit isEqualToString:@"Kilometers"]) {
        vc.currentDistanceUnitsType = DistanceUnitsTypeKilometers;
    } else {
        vc.currentDistanceUnitsType = DistanceUnitsTypeMiles;
    }

    vc.strFolderId = _strFolderId;

    [self.navigationController pushViewController:vc animated:NO];
}

- (void)createFolderNamed:(NSString*)strFolderName
{
    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:strFolderName forKey:@"folder_name"];

    if (_strFolderId) {
        [dicParam setValue:_strFolderId forKey:@"parent_id"];
    }

    [[WebServiceConnector alloc] init:URLGetMyFolders
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleCreateFolderResponse:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];

    /*Folders *objFolder = [[Folders alloc] init];
    objFolder.folderName = strFolderName;
    
    NSArray *arrSyncData = [[[[CDSyncFolders query] where:nil]
                             order:[NSSortDescriptor sortDescriptorWithKey:@"foldersIdentifier" ascending:YES]] all];
    
    if (arrSyncData.count > 0)
    {
        CDSyncFolders *objSyncData = [arrSyncData firstObject];
     
        if ([objSyncData.foldersIdentifier doubleValue] > 0)
        {
            objFolder.foldersIdentifier = -1;
        }
        else
        {
            objFolder.foldersIdentifier = [objSyncData.foldersIdentifier doubleValue] - 1;
        }
    }
    else
    {
        objFolder.foldersIdentifier = -1;
    }

    objFolder.folderType = @"normal";
    
    if (_strFolderId)
    {
        objFolder.parentId = [_strFolderId integerValue];
    }
    else
    {
        objFolder.parentId = 0;
    }

    objFolder.routesCounts = 0;
    objFolder.subfoldersCount = 0;
    
    [CoreDataAdaptor SaveDataInCoreDB:[[WebServiceDataAdaptor alloc] processObjectForCoreData:objFolder] forEntity:NSStringFromClass([CDSyncFolders class])];
    
    [self fetchRoadBooks];*/
}

- (IBAction)handleCreateFolderResponse:(id)sender
{
    [self fetchRoadBooks];
}

- (void)clickedOnLogout
{
    [AlertManager confirm:@"Are you sure you want to log out?"
                    title:@"Confirm Logout"
                 negative:@"CANCEL"
                 positive:@"YES"
               onNegative:NULL
               onPositive:^{
                   FBSDKLoginManager* login = [[FBSDKLoginManager alloc] init];
                   [login logOut];

                   [[GIDSignIn sharedInstance] signOut];
                   [DefaultsValues setBooleanValueToUserDefaults:NO ForKey:kLogIn];
                   [self.navigationController popToRootViewControllerAnimated:YES];
               }];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        if (scrollView.contentOffset.y >= -30 && _heightLblSync.constant == 0.0f) {
            isPullToRefresh = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.heightLblSync.constant = 30.0f;
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     [self.view layoutIfNeeded];
                                 }];
            });
        }
    }

    if (scrollView.contentOffset.y >= 0 && isPullToRefresh) {
        if (scrollView.contentOffset.y <= 30) {
            isPullToRefresh = !isPullToRefresh;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.heightLblSync.constant = 0.0f;
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     [self.view layoutIfNeeded];
                                 }];
            });
        }
    }
}

#pragma mark - Button Click Events

- (IBAction)btnSettingsClicked:(id)sender
{
    [self.view endEditing:YES];

    SettingsVC* vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.currentOverlay = OverlayStatusNotApplicable;
    vc.isRecording = NO;
    vc.delegate = self;
    vc.curMapStyle = CurrentMapStyleSatellite;
    NavController* nav = [[NavController alloc] initWithRootViewController:vc];

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = [UIColor lightGrayColor];
        [nav.navigationBar setTitleTextAttributes:
                               @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    } else {
        nav.navigationBar.barStyle = UIBarStyleDefault;
        nav.navigationBar.translucent = YES;
        nav.navigationBar.tintColor = [UIColor blackColor];
        [nav.navigationBar setTitleTextAttributes:
                               @{ NSForegroundColorAttributeName : [UIColor blackColor] }];
    }

    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnAddRoadBookClicked:(id)sender
{
    [self.view endEditing:YES];

    AddRoadBookVC* vc = loadViewController(StoryBoard_Main, kIDAddRoadBookVC);
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnAddFolderClicked:(id)sender
{
    [self.view endEditing:YES];

    AddFolderVC* vc = loadViewController(StoryBoard_Settings, kIDAddFolderVC);
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
    case MyRoadbooksSectionFolders: {
        return _arrFolders.count;
    } break;

    case MyRoadbooksSectionRoadbooks: {
        return arrRoadBooks.count;
    } break;

    default:
        break;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 105.0f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.view endEditing:YES];

    switch (indexPath.section) {
    case MyRoadbooksSectionFolders: {
        RoadBooksVC* vc = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
        vc.delegate = _delegate;
        CDFolders* objFolder = _arrFolders[indexPath.row];
        vc.strFolderId = [NSString stringWithFormat:@"%ld", (long)[objFolder.foldersIdentifier doubleValue]];
        vc.strRoadbookPageName = objFolder.folderName;
        vc.isOverlayTrack = _isOverlayTrack;

        if ([objFolder.folderType isEqualToString:@"shared_with_me"] || [objFolder.folderType isEqualToString:@"deleted_routes"]) {
            vc.isAddRouteHidden = YES;
        }

        [self.navigationController pushViewController:vc animated:YES];
    } break;

    case MyRoadbooksSectionRoadbooks: {
        if (_isOverlayTrack) {
            NSString* strRoadbookId;
            if ([arrRoadBooks[indexPath.row] isKindOfClass:[CDRoutes class]]) {
                CDRoutes* objRoadBook = arrRoadBooks[indexPath.row];
                strRoadbookId = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routesIdentifier doubleValue]];
            } else {
                CDSyncData* objRoadBook = arrRoadBooks[indexPath.row];
                strRoadbookId = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routeIdentifier doubleValue]];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES
                                         completion:^{

                                             if ([self.delegate respondsToSelector:@selector(didPickRoadbookWithId:)]) {
                                                 [self.delegate didPickRoadbookWithId:strRoadbookId];
                                             }
                                         }];
            });
        } else {
            LocationsVC* vc = loadViewController(StoryBoard_Main, kIDLocationsVC);

            if ([arrRoadBooks[indexPath.row] isKindOfClass:[CDRoutes class]]) {
                CDRoutes* objRoadBook = arrRoadBooks[indexPath.row];

                if (![objRoadBook.editable boolValue]) {
                    [AlertManager alert:@"" title:@"This route can not be edited" imageName:@"ic_error" onConfirm:NULL];
                    return;
                }

                if ([objRoadBook.units isEqualToString:@"kilometers"]) {
                    vc.currentDistanceUnitsType = DistanceUnitsTypeKilometers;
                } else {
                    vc.currentDistanceUnitsType = DistanceUnitsTypeMiles;
                }

                vc.strFolderId = _strFolderId;
                vc.strRouteIdentifier = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routesIdentifier doubleValue]];
                vc.strRouteName = objRoadBook.name;
            } else {
                CDSyncData* objRoadBook = arrRoadBooks[indexPath.row];

                if ([objRoadBook.distanceUnit isEqualToString:@"Kilometers"]) {
                    vc.currentDistanceUnitsType = DistanceUnitsTypeKilometers;
                } else {
                    vc.currentDistanceUnitsType = DistanceUnitsTypeMiles;
                }

                vc.strRouteIdentifier = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routeIdentifier doubleValue]];
                vc.strRouteName = objRoadBook.name;
            }

            [Answers logContentViewWithName:[NSString stringWithFormat:@"Visited Roadbook %@", vc.strRouteName]
                                contentType:@"Roadbook Visit"
                                  contentId:vc.strRouteIdentifier
                           customAttributes:@{}];

            [self.navigationController pushViewController:vc animated:YES];
        }
    } break;

    default:
        break;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    RoadBooksCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idRoadBooksCell"];

    if (!cell) {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([RoadBooksCell class]) identifier:@"idRoadBooksCell"];
    }

    switch (indexPath.section) {
    case MyRoadbooksSectionFolders: {
        CDFolders* objFolder = _arrFolders[indexPath.row];

        cell.lblTitle.text = objFolder.folderName;

        if ([objFolder.routesCounts doubleValue] > 1) {
            cell.lblDetails.text = [NSString stringWithFormat:@"%ld routes", (long)[objFolder.routesCounts doubleValue]];
        } else {
            cell.lblDetails.text = [NSString stringWithFormat:@"%ld route", (long)[objFolder.routesCounts doubleValue]];
        }

        if ([objFolder.subfoldersCount doubleValue] > 1) {
            cell.lblDateTime.text = [NSString stringWithFormat:@"%ld sub-folders", (long)[objFolder.subfoldersCount doubleValue]];
        } else {
            cell.lblDateTime.text = [NSString stringWithFormat:@"%ld sub-folder", (long)[objFolder.subfoldersCount doubleValue]];
        }

        cell.imgIcon.image = Set_Local_Image(@"folder_icon");
    } break;

    case MyRoadbooksSectionRoadbooks: {
        if ([arrRoadBooks[indexPath.row] isKindOfClass:[CDRoutes class]]) {
            CDRoutes* objRoadBook = arrRoadBooks[indexPath.row];

            NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routesIdentifier doubleValue]];
            NSString* strCondition = [NSString stringWithFormat:@"isEdit = 0 AND isActive = 0 AND routeIdentifier = %@", strRouteId];

            NSInteger count = [CoreDataAdaptor getCountOfSyncData:strCondition sortDescriptor:nil forEntity:NSStringFromClass([CDSyncData class])];

            cell.lblTitle.text = objRoadBook.name;

            NSInteger distance = 0;
            NSString* strUnit = @"";

            Config* objConfig;

            if (objUser.config == nil) {
                objConfig.unit = @"Kilometers";
            } else {
                NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
                objConfig = [[Config alloc] initWithDictionary:jsonDict];
            }

            if ([objConfig.unit isEqualToString:@"Kilometers"]) {
                strUnit = @"km";

                if ([objRoadBook.units isEqualToString:@"kilometers"]) {
                    distance = (NSInteger)ceilf([objRoadBook.length doubleValue]);
                } else {
                    distance = (NSInteger)ceilf([objRoadBook.length doubleValue] / 0.62f);
                }
            } else {
                strUnit = @"mi";

                if ([objRoadBook.units isEqualToString:@"kilometers"]) {
                    distance = (NSInteger)ceilf([objRoadBook.length doubleValue] * 0.62f);
                } else {
                    distance = (NSInteger)ceilf([objRoadBook.length doubleValue]);
                }
            }

            NSString* strDate = [self convertDateFormatDate:objRoadBook.updatedAt];
            cell.lblDateTime.text = strDate;
            cell.lblDetails.text = [NSString stringWithFormat:@"%ld Way Points | %ld %@", (NSInteger)floorf([objRoadBook.waypointCount doubleValue] + count), distance, strUnit];
        } else {
            CDSyncData* objData = arrRoadBooks[indexPath.row];
            cell.lblTitle.text = objData.name;

            NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[objData.routeIdentifier doubleValue]];
            NSString* strCondition = [NSString stringWithFormat:@"isEdit = 0 AND isActive = 0 AND routeIdentifier = %@", strRouteId];

            NSInteger count = [CoreDataAdaptor getCountOfSyncData:strCondition sortDescriptor:nil forEntity:NSStringFromClass([CDSyncData class])];

            float distance = 0;

            NSString* strUnit = @"";

            if ([objData.distanceUnit isEqualToString:@"Kilometers"]) {
                strUnit = @"km";
                distance = (NSInteger)ceilf(distance);
            } else if ([objData.distanceUnit isEqualToString:@"Miles"]) {
                strUnit = @"mi";
                distance = (NSInteger)ceilf(distance / 0.62f);
            }

            NSString* strDate = [self convertDateFormatDate:objData.updatedAt];
            cell.lblDateTime.text = strDate;
            cell.lblDetails.text = [NSString stringWithFormat:@"%ld Way Points | %ld %@", count /*(NSInteger)floorf(arrTempData.count)*/, (NSInteger)distance, strUnit];
        }
        cell.imgIcon.image = Set_Local_Image(@"route_icon");
    } break;

    default:
        break;
    }

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        cell.lblTitle.textColor = [UIColor lightGrayColor];
        cell.lblDetails.textColor = [UIColor lightGrayColor];
        cell.lblDateTime.textColor = [UIColor lightGrayColor];
    } else {
        cell.lblTitle.textColor = [UIColor blackColor];
        cell.lblDetails.textColor = [UIColor blackColor];
        cell.lblDateTime.textColor = [UIColor blackColor];
    }

    return cell;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == MyRoadbooksSectionRoadbooks) {
        [tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (nullable NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ((indexPath.section == MyRoadbooksSectionFolders)) {
        CDFolders* objFolder = _arrFolders[indexPath.row];

        if ([objFolder.folderType isEqualToString:@"normal"]) {
            UITableViewRowAction* delete =
                [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                   title:@""
                                                 handler:^(UITableViewRowAction* _Nonnull action, NSIndexPath* _Nonnull indexPath) {
                                                     RoadBooksCell* cell = [tableView cellForRowAtIndexPath:indexPath];

                                                     [AlertManager confirm:[NSString stringWithFormat:@"Are you sure you want to delete %@ folder?", cell.lblTitle.text]
                                                                     title:@"Delete Folder"
                                                                  negative:@"CANCEL"
                                                                  positive:@"YES"
                                                                onNegative:NULL
                                                                onPositive:^{
                                                                    CDFolders* objRoadBook = self.arrFolders[indexPath.row];

                                                                    [[WebServiceConnector alloc] init:[NSString stringWithFormat:@"%@/%@", URLGetMyFolders, [NSString stringWithFormat:@"%@", objRoadBook.foldersIdentifier]]
                                                                                       withParameters:nil
                                                                                           withObject:self
                                                                                         withSelector:@selector(handleDeleteRoadbookResponse:)
                                                                                       forServiceType:ServiceTypeDELETE
                                                                                       showDisplayMsg:@""
                                                                                           showLoader:YES];
                                                                }];
                                                 }];

            [delete setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Delete"]]];
            return [[NSArray alloc] initWithObjects:delete, nil];
        }
    } else if (indexPath.section == MyRoadbooksSectionRoadbooks) {
        CDRoutes* objRoadBook = arrRoadBooks[indexPath.row];

        if ([objRoadBook.editable boolValue]) {
            UITableViewRowAction* delete =
                [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                   title:@""
                                                 handler:^(UITableViewRowAction* _Nonnull action, NSIndexPath* _Nonnull indexPath) {
                                                     RoadBooksCell* cell = [tableView cellForRowAtIndexPath:indexPath];

                                                     [AlertManager confirm:[NSString stringWithFormat:@"Are you sure you want to delete %@ roadbook?", cell.lblTitle.text]
                                                                     title:@"Delete Roadbook"
                                                                  negative:@"CANCEL"
                                                                  positive:@"YES"
                                                                onNegative:NULL
                                                                onPositive:^{
                                                                    NSString* strId = @"";
                                                                    if ([self.arrRoadBooks[indexPath.row] isKindOfClass:[CDRoutes class]]) {
                                                                        CDRoutes* objRoadBook = self.arrRoadBooks[indexPath.row];
                                                                        strId = [NSString stringWithFormat:@"%@", objRoadBook.routesIdentifier];
                                                                    } else {
                                                                        CDSyncData* objData = self.arrRoadBooks[indexPath.row];
                                                                        strId = [NSString stringWithFormat:@"%@", objData.routeIdentifier];
                                                                    }
                                                                    [self deleteRoadbookWithRoadbookId:strId];
                                                                }];
                                                 }];

            [delete setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Delete"]]];
            return [[NSArray alloc] initWithObjects:delete, nil];
        }
    }

    return @[];
}

#pragma mark - Userdefined Functions

- (NSString*)convertDateFormatDate:(NSString*)strDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate* date = [formatter dateFromString:strDate];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];

    NSString* strConvertedDate = [formatter stringFromDate:date];

    return strConvertedDate;
}

- (float)getDistanceFromArray:(NSArray*)arrSync
{
    if (arrSync.count > 0) {
        CDSyncData* objSyncData = [arrSync firstObject];
        id object = [RallyNavigatorConstants convertJsonStringToObject:objSyncData.jsonData];

        if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray* arrOperations = [[NSMutableArray alloc] init];
            arrOperations = [object mutableCopy];

            for (int index = 0; index < arrOperations.count; index++) {
                NSMutableDictionary* dicOp = [[arrOperations objectAtIndex:index] mutableCopy];

                if ([dicOp objectForKey:@"op"]) {
                    if ([[dicOp valueForKey:@"op"] isEqualToString:@"replace"]) {
                        if ([[dicOp valueForKey:@"path"] isEqualToString:@"/summary/totaldistance"]) {
                            return [[dicOp valueForKey:@"value"] floatValue] / 1000.0;
                        }
                    }
                }
            }
        }
    }

    return 0;
}

@end
