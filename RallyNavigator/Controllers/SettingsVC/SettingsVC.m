//
//  SettingsVC.m
//  RallyNavigator
//
//  Created by C205 on 10/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "SettingsVC.h"
#import "GPSSettingsVC.h"
#import "DistanceUnitsVC.h"
#import "NewWayPointVC.h"
#import "HowToUseVC.h"
#import "SettingsCell.h"
#import "CDSyncData.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Crashlytics/Crashlytics.h>
#import "RoadBooksVC.h"
#import "PickRoadBookVC.h"
#import "OfflineMapsVC.h"

typedef enum
{
    SettingsCellTypeSave = 0,
    SettingsCellTypeOverlayTrack,
    SettingsCellTypeOfflineMaps,
    SettingsCellTypeDistanceUnit,
    SettingsCellTypeThemes,
    SettingsCellTypeAutoPhoto,
    SettingsCellTypeHowToUse,
    SettingsCellTypeShare,
    SettingsCellTypeLogout
}SettingsCellType;

@interface SettingsVC () <GPSSettingsVCDelegate>
{
    User *objUser;
    Config *objConfig;
    BOOL isAutoPhoto;
    NSDictionary *dicNewWayPoints;
}
@end

@implementation SettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"cancel_icon") style:UIBarButtonItemStylePlain target:self action:@selector(btnDismissClicked:)];
    self.navigationItem.rightBarButtonItem = btnDismiss;
    
    _tblSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    objUser = GET_USER_OBJ;
    
    [self getConfigWithLoader:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    objUser = GET_USER_OBJ;
    
    [self setUpVC];
    [self setDictionaryFromConfig];
    [_tblSettings reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods

- (void)setDictionaryFromConfig
{
    NSDictionary *dicJson = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
    objConfig = [[Config alloc] initWithDictionary:dicJson];
    NSData *objectData = [objConfig.action dataUsingEncoding:NSUTF8StringEncoding];
    if (objectData)
    {
        NSError *error = nil;
        dicNewWayPoints = [NSJSONSerialization JSONObjectWithData:objectData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
        isAutoPhoto = [[dicNewWayPoints valueForKey:@"autoPhoto"] boolValue];
    }
}

#pragma mark - Set Up

- (void)setUpVC
{
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        self.view.backgroundColor = [UIColor blackColor];
        _tblSettings.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        _tblSettings.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
}

#pragma mark - WS Call

- (void)getConfigWithLoader:(BOOL)showLoader
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:objUser.email forKey:@"email"];
    
    [[WebServiceConnector alloc] init:URLGetConfig
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleConfigResponse:)
                       forServiceType:ServiceTypePOST
                       showDisplayMsg:@""
                           showLoader:showLoader];
}

- (IBAction)handleConfigResponse:(id)sender
{
    NSArray *arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0)
    {
        objUser = [arrResponse firstObject];
        
        if (objUser.config == nil)
        {
            objUser.config = @"{\"action\":\"{\\\"autoPhoto\\\":false,\\\"voiceToText\\\":true,\\\"takePicture\\\":true,\\\"voiceRecorder\\\":true,\\\"waypointOnly\\\":true,\\\"text\\\":true}\",\"unit\":\"Kilometers\",\"rotation\":{\"value\":\"1\"},\"sync\":\"2\",\"odo\":\"00.00\",\"autoCamera\":true,\"accuracy\":{\"minDistanceTrackpoint\":50,\"angle\":1,\"accuracy\":50,\"distance\":3}}";
        }
        
        [DefaultsValues setCustomObjToUserDefaults:objUser ForKey:kUserObject];
        [self setDictionaryFromConfig];
        [_tblSettings reloadData];
    }
    else
    {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

#pragma mark - Button Click Events

- (IBAction)btnDismissClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleChangeInConfig:(id)sender
{
    NSArray *arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0)
    {
        [DefaultsValues setCustomObjToUserDefaults:[arrResponse firstObject] ForKey:kUserObject];
        objUser = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserObject];
        NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
        objConfig = [[Config alloc] initWithDictionary:jsonDict];
        
        [_tblSettings reloadData];
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case SettingsCellTypeOfflineMaps:
        {
            OfflineMapsVC *vc = loadViewController(StoryBoard_Settings, kIDOfflineMapsVC);
            vc.curMapStyle = _curMapStyle;
            if (_overlaySender) {
                vc.overlaySender = _overlaySender;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case SettingsCellTypeOverlayTrack:
        {
            switch (_currentOverlay)
            {
                case OverlayStatusShow:
                {
                    if ([AppContext.window.rootViewController isKindOfClass:[UINavigationController class]])
                    {
                        UINavigationController *nav = (UINavigationController *)AppContext.window.rootViewController;
                        
                        for (id vc in nav.viewControllers)
                        {
                            if ([vc isKindOfClass:[RoadBooksVC class]])
                            {
//                                RoadBooksVC *l_VC = vc;
//                                PickRoadBookVC *vc = loadViewController(StoryBoard_Settings, kIDPickRoadBookVC);
//                                vc.curMapStyle = _curMapStyle;
//                                vc.delegate = _delegate;
//                                vc.arrRoadbooks = [[NSMutableArray alloc] init];
//                                NSLog(@"%ld", [l_VC.arrRoadBooks count]);
//                                vc.arrRoadbooks = l_VC.arrRoadBooks;
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [self.navigationController pushViewController:vc animated:YES];
//                                });
                                RoadBooksVC *vc = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
                                vc.isOverlayTrack = YES;
                                vc.delegate = _delegate;
                                [self.navigationController pushViewController:vc animated:YES];

                                break;
                            }
                        }
                    }
                }
                    break;

                case OverlayStatusHide:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([_delegate respondsToSelector:@selector(clearOverlay)])
                        {
                            [self dismissViewControllerAnimated:YES completion:^{
                                [_delegate clearOverlay];
                            }];
                        }
                    });
                }
                    break;

                case OverlayStatusNotApplicable:
                {
                    NSLog(@"Hello");
                }
                    break;

                default:
                    break;
            }
        }
            break;
            
        case SettingsCellTypeShare:
        {
            [Answers logShareWithMethod:@"App Share"
                            contentName:@"Sharing Rally Navigator App"
                            contentType:@"app"
                              contentId:@"1.1.7"
                       customAttributes:@{}];
            
            NSString *strUrl = @"https://www.rallynavigator.com";
            NSString *strTitle = [NSString stringWithFormat:@"Join the Rally Revolution.\n\nRally Navigator Streamlines the Process of Creating Rally Navigation Roadbooks Using the Power of Mapbox and GPS.\n\nDesign your Route, add Waypoint Details and Print FIM & FIA Specification Rally Roadbooks for Cross Country and Road Rally events.\n\nCreate. Print. Rally.\n\nLearn more at "];
            
            NSURL *url = [NSURL URLWithString:strUrl];
            NSArray *dataToShare = @[strTitle, url];
            UIActivityViewController *activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
            activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
            [activityViewController setValue:@"Rally Navigator" forKey:@"subject"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                activityViewController.popoverPresentationController.sourceView = self.view;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:activityViewController animated:YES completion:nil];
            });
        }
            break;
            
        case SettingsCellTypeSave:
        {
            if ([_delegate respondsToSelector:@selector(saveRoadbook)])
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    [_delegate saveRoadbook];
                }];
            }
        }
            break;
            
            
        case SettingsCellTypeLogout:
        {
            [self.view endEditing:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(clickedOnLogout)])
                {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [_delegate clickedOnLogout];
                    }];
                }
            });
        }
            break;
            
        case SettingsCellTypeHowToUse:
        {
            HowToUseVC *vc = loadViewController(StoryBoard_Settings, kIDHowToUseVC);
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell;
    
    switch (indexPath.row)
    {
        case SettingsCellTypeSave:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = @"Stop Recording & Save Roadbook";
            cell.horizontalSpaceSwitch.constant = 0.0f;
            cell.widthSwitch.constant = 0.0f;
            cell.switchAutoPhoto.hidden = YES;
        }
            break;

        case SettingsCellTypeOverlayTrack:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = _currentOverlay == OverlayStatusHide ? @"Clear Overlay Track" : @"Overlay Track on Map";
            cell.horizontalSpaceSwitch.constant = 0.0f;
            cell.widthSwitch.constant = 0.0f;
            cell.switchAutoPhoto.hidden = YES;
        }
            break;

        case SettingsCellTypeOfflineMaps:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = @"Offline Maps";
            cell.horizontalSpaceSwitch.constant = 0.0f;
            cell.widthSwitch.constant = 0.0f;
            cell.switchAutoPhoto.hidden = YES;
        }
            break;

        case SettingsCellTypeDistanceUnit:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingOptionsCell"];
            [cell.btnLeft setTitle:@"Miles" forState:UIControlStateNormal];
            [cell.btnRight setTitle:@"Kilometers" forState:UIControlStateNormal];
            cell.btnLeft.tag = SettingsCellTypeDistanceUnit;
            cell.btnRight.tag = SettingsCellTypeDistanceUnit;
            
            UIColor *color;
            
            if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
            {
                color = [UIColor lightGrayColor];
            }
            else
            {
                color = [UIColor blackColor];
            }
            
            if ([objConfig.unit isEqualToString:cell.btnLeft.titleLabel.text])
            {
                [cell.btnLeft setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnRight setTitleColor:color forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnRight setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnLeft setTitleColor:color forState:UIControlStateNormal];
            }
            
            [cell.btnLeft addTarget:self action:@selector(btnLeftAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnRight addTarget:self action:@selector(btnRightAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;

        case SettingsCellTypeThemes:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingOptionsCell"];
            [cell.btnLeft setTitle:@"Dark View" forState:UIControlStateNormal];
            [cell.btnRight setTitle:@"Light View" forState:UIControlStateNormal];
            cell.btnLeft.tag = SettingsCellTypeThemes;
            cell.btnRight.tag = SettingsCellTypeThemes;
            
            if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
            {
                [cell.btnLeft setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnRight setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnRight setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [cell.btnLeft setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
            [cell.btnLeft addTarget:self action:@selector(btnLeftAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnRight addTarget:self action:@selector(btnRightAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;

        case SettingsCellTypeAutoPhoto:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = @"Auto Photo";
            cell.horizontalSpaceSwitch.constant = 8.0f;
            cell.widthSwitch.constant = 49.0f;
            cell.switchAutoPhoto.hidden = NO;
            [cell.switchAutoPhoto setOn:isAutoPhoto];
            [cell.switchAutoPhoto setOnTintColor:[UIColor redColor]];

            UIColor *color;
            if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
            {
                color = [UIColor lightGrayColor];
            }
            else
            {
                color = [UIColor blackColor];
            }
            [cell.switchAutoPhoto setThumbTintColor:color];
            
            [cell.switchAutoPhoto addTarget:self action:@selector(handleAutoPhotoValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
            break;

        case SettingsCellTypeHowToUse:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = @"Mobile App - How it Works";
            cell.horizontalSpaceSwitch.constant = 0.0f;
            cell.widthSwitch.constant = 0.0f;
            cell.switchAutoPhoto.hidden = YES;
        }
            break;

        case SettingsCellTypeShare:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = @"Share Rally Navigator";
            cell.horizontalSpaceSwitch.constant = 0.0f;
            cell.widthSwitch.constant = 0.0f;
            cell.switchAutoPhoto.hidden = YES;
        }
            break;

        case SettingsCellTypeLogout:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];
            cell.lblTitle.text = @"Logout";
            cell.horizontalSpaceSwitch.constant = 0.0f;
            cell.widthSwitch.constant = 0.0f;
            cell.switchAutoPhoto.hidden = YES;
        }
            break;

        default:
            break;
    }

    if (iPadDevice)
    {
        cell.lblTitle.font = [UIFont boldSystemFontOfSize:32.0f];
        cell.btnLeft.titleLabel.font = [UIFont boldSystemFontOfSize:32.0f];
        cell.btnRight.titleLabel.font = [UIFont boldSystemFontOfSize:32.0f];
    }
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        cell.lblTitle.textColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.lblTitle.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalValue = 7.0f;
    
    if (_currentOverlay == OverlayStatusNotApplicable)
    {
        if (indexPath.row == SettingsCellTypeOverlayTrack)
        {
            return 0.0f;
        }

//        totalValue--;
    }
    
    if (!_isRecording)
    {
        if (indexPath.row == SettingsCellTypeSave)
        {
            return 0.0f;
        }
        
//        totalValue--;
    }
    
    return (SCREEN_HEIGHT - 64.0f) / totalValue;
}

#pragma mark - Auto Photo Web Service

- (IBAction)handleAutoPhotoValueChanged:(id)sender
{
    isAutoPhoto = !isAutoPhoto;
    
    NSDictionary *dicSaveNewWayPoints = [[NSDictionary alloc] init];
    
    dicSaveNewWayPoints = @{
                            @"waypointOnly" : [dicNewWayPoints valueForKey:@"waypointOnly"],
                            @"voiceToText" : [NSNumber numberWithBool:0],
                            @"text" : [dicNewWayPoints valueForKey:@"text"],
                            @"takePicture" : [dicNewWayPoints valueForKey:@"takePicture"],
                            @"voiceRecorder" : [dicNewWayPoints valueForKey:@"voiceRecorder"],
                            @"autoPhoto" : [NSNumber numberWithBool:isAutoPhoto]
                            };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicSaveNewWayPoints
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    strJson = [[strJson componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    
    objConfig.action = strJson;
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];
    
    [[WebServiceConnector alloc] init:URLSetConfig
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleChangeInConfig:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)btnLeftAction:(UIButton *)sender
{
    NSString *strBtnTitle = sender.titleLabel.text;
    if ([strBtnTitle isEqualToString:@"Miles"])
    {
        User *objUser = GET_USER_OBJ;
        NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
        Config *objConfig = [[Config alloc] initWithDictionary:jsonDict];
        objConfig.unit = strBtnTitle;
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];
        
        [[WebServiceConnector alloc] init:URLSetConfig
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleChangeInConfig:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    }
    else
    {
        [DefaultsValues setBooleanValueToUserDefaults:![DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView] ForKey:kIsNightView];
        [self setUpVC];
        [_tblSettings reloadData];
    }
}

- (IBAction)btnRightAction:(UIButton *)sender
{
    NSString *strBtnTitle = sender.titleLabel.text;
    if ([strBtnTitle isEqualToString:@"Kilometers"])
    {
        User *objUser = GET_USER_OBJ;
        NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
        Config *objConfig = [[Config alloc] initWithDictionary:jsonDict];
        objConfig.unit = strBtnTitle;
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];
        
        [[WebServiceConnector alloc] init:URLSetConfig
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleChangeInConfig:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    }
    else
    {
        [DefaultsValues setBooleanValueToUserDefaults:![DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView] ForKey:kIsNightView];
        [self setUpVC];
        [_tblSettings reloadData];
    }
}

@end
