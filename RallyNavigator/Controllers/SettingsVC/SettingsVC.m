

//
//  SettingsVC.m
//  RallyNavigator
//
//  Created by C205 on 10/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "SettingsVC.h"
#import "HowToUseVC.h"
#import "SettingsCell.h"
#import "CDSyncData.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Crashlytics/Crashlytics.h>
#import "RoadBooksVC.h"

typedef enum {
    SettingsCellTypeTitle = 0,
    SettingsCellTypeNewRecording,
    SettingsCellTypeSave,
    SettingsCellTypeOverlayTrack,
    SettingsCellTypeDistanceUnit,
    SettingsCellTypeThemes,
    SettingsCellTypeAutoPhoto,
    SettingsCellTypeHowToUse,
    SettingsCellTypeShare,
    SettingsCellTypeLogout
} SettingsCellType;

@interface SettingsVC () {
    BOOL isLightView;
    BOOL isAutoPhoto;

    User* objUser;
    Config* objConfig;
    NSDictionary* dicNewWayPoints;
}
@end

@implementation SettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    NSDictionary* dicJson = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
    objConfig = [[Config alloc] initWithDictionary:dicJson];
    NSData* objectData = [objConfig.action dataUsingEncoding:NSUTF8StringEncoding];
    if (objectData) {
        NSError* error = nil;
        dicNewWayPoints = [NSJSONSerialization JSONObjectWithData:objectData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
        isAutoPhoto = [[dicNewWayPoints valueForKey:@"autoPhoto"] boolValue];
    }
}

#pragma mark - Set Up

- (void)setUpVC
{
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        self.view.backgroundColor = [UIColor blackColor];
        _tblSettings.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        _tblSettings.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - WS Call

- (void)getConfigWithLoader:(BOOL)showLoader
{
    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:objUser.email forKey:@"email"];

    [[WebServiceConnector alloc] init:URLGetConfig
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleConfigResponse:)
                       forServiceType:ServiceTypePOST
                       showDisplayMsg:@""
                           showLoader:showLoader];
}

- (void)handleConfigResponse:(id)sender
{
    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0) {
        objUser = [arrResponse firstObject];

        if (objUser.config == nil) {
            objUser.config = @"{\"action\":\"{\\\"autoPhoto\\\":false,\\\"voiceToText\\\":true,\\\"takePicture\\\":true,\\\"voiceRecorder\\\":true,\\\"waypointOnly\\\":true,\\\"text\\\":true}\",\"unit\":\"Kilometers\",\"rotation\":{\"value\":\"1\"},\"sync\":\"2\",\"odo\":\"00.00\",\"autoCamera\":true,\"accuracy\":{\"minDistanceTrackpoint\":50,\"angle\":1,\"accuracy\":50,\"distance\":3}}";
        }

        [DefaultsValues setCustomObjToUserDefaults:objUser ForKey:kUserObject];
        [self setDictionaryFromConfig];
        [_tblSettings reloadData];
    } else {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

#pragma mark - Button Click Events

- (IBAction)btnDismissClicked:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleChangeInConfig:(id)sender
{
    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0) {
        [DefaultsValues setCustomObjToUserDefaults:[arrResponse firstObject] ForKey:kUserObject];
        objUser = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserObject];
        NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
        objConfig = [[Config alloc] initWithDictionary:jsonDict];

        [_tblSettings reloadData];
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case SettingsCellTypeNewRecording: {
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          if ([self.delegate respondsToSelector:@selector(newRecording)]) {
                                                              [self.delegate newRecording];
                                                          }
                                                      }];
    } break;

    case SettingsCellTypeSave: {
        if ([self.delegate respondsToSelector:@selector(saveRoadbook)]) {
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                         [self.delegate saveRoadbook];
                                     }];
        }
    } break;

    case SettingsCellTypeOverlayTrack: {
        switch (_currentOverlay) {
        case OverlayStatusShow: {
            if ([AppContext.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController* nav = (UINavigationController*)AppContext.window.rootViewController;

                for (id vc in nav.viewControllers) {
                    if ([vc isKindOfClass:[RoadBooksVC class]]) {
                        RoadBooksVC* vc = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
                        vc.isOverlayTrack = YES;
                        vc.delegate = _delegate;
                        [self.navigationController pushViewController:vc animated:YES];

                        break;
                    }
                }
            }
        } break;

        case OverlayStatusHide: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(clearOverlay)]) {
                    [self dismissViewControllerAnimated:YES
                                             completion:^{
                                                 [self.delegate clearOverlay];
                                             }];
                }
            });
        } break;

        case OverlayStatusNotApplicable: {
            NSLog(@"Hello");
        } break;

        default:
            break;
        }
    } break;

    case SettingsCellTypeShare: {
        [Answers logShareWithMethod:@"App Share"
                        contentName:@"Sharing Rally Navigator App"
                        contentType:@"app"
                          contentId:@"1.1.7"
                   customAttributes:@{}];

        NSString* strUrl = @"https://www.rallynavigator.com";
        NSString* strTitle = [NSString stringWithFormat:@"Join the Rally Revolution.\n\nRally Navigator Streamlines the Process of Creating Rally Navigation Roadbooks Using the Power of Mapbox and GPS.\n\nDesign your Route, add Waypoint Details and Print FIM & FIA Specification Rally Roadbooks for Cross Country and Road Rally events.\n\nCreate. Print. Rally.\n\nLearn more at "];

        NSURL* url = [NSURL URLWithString:strUrl];
        NSArray* dataToShare = @[ strTitle, url ];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[ UIActivityTypeAirDrop ];
        [activityViewController setValue:@"Rally Navigator" forKey:@"subject"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            activityViewController.popoverPresentationController.sourceView = self.view;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityViewController animated:YES completion:nil];
        });
    } break;

    case SettingsCellTypeHowToUse: {
        HowToUseVC* vc = loadViewController(StoryBoard_Settings, kIDHowToUseVC);
        [self.navigationController pushViewController:vc animated:YES];
    } break;

    case SettingsCellTypeLogout: {
        [self.view endEditing:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(clickedOnLogout)]) {
                [self dismissViewControllerAnimated:YES
                                         completion:^{
                                             [self.delegate clickedOnLogout];
                                         }];
            }
        });
    } break;

    default:
        break;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SettingsCell* cell;

    switch (indexPath.row) {
    case SettingsCellTypeTitle: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsNavigationCell"];
        if (SCREEN_WIDTH >= 768) {
            [cell.titleLabel setFont:[cell.titleLabel.font fontWithSize:32.0f]];
            [cell.closeButton setImage:[UIImage imageNamed:@"cross_x"] forState:UIControlStateNormal];
            cell.closeButton.contentEdgeInsets = UIEdgeInsetsZero;
        }
    } break;

    case SettingsCellTypeNewRecording: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.titleLabel.text = @"Record New Roadbook";
    } break;

    case SettingsCellTypeSave: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.titleLabel.text = @"Stop Recording & Save Roadbook";
    } break;

    case SettingsCellTypeOverlayTrack: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.titleLabel.text = _currentOverlay == OverlayStatusHide ? @"Clear Overlay Track" : @"Overlay Track on Map";
    } break;

    case SettingsCellTypeDistanceUnit: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.leftButton setTitle:@"Miles" forState:UIControlStateNormal];
        [cell.rightButton setTitle:@"Kilometers" forState:UIControlStateNormal];

        cell.leftButton.tag = SettingsCellTypeDistanceUnit;
        cell.rightButton.tag = SettingsCellTypeDistanceUnit;

        if (SCREEN_WIDTH >= 768) {
            [cell.leftButton.titleLabel setFont:[cell.leftButton.titleLabel.font fontWithSize:26.0f]];
            [cell.rightButton.titleLabel setFont:[cell.rightButton.titleLabel.font fontWithSize:26.0f]];
        }

        UIColor* color;
        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            color = UIColor.lightGrayColor;
        } else {
            color = UIColor.blackColor;
        }

        if ([objConfig.unit isEqualToString:@"Miles"]) {
            cell.leftButton.tintColor = UIColor.redColor;
            cell.rightButton.tintColor = color;
        } else {
            cell.leftButton.tintColor = color;
            cell.rightButton.tintColor = UIColor.redColor;
        }

        // [cell.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // [cell.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case SettingsCellTypeThemes: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUnitCell"];

        [cell.leftButton setTitle:@"Dark View" forState:UIControlStateNormal];
        [cell.rightButton setTitle:@"Light View" forState:UIControlStateNormal];

        cell.leftButton.tag = SettingsCellTypeThemes;
        cell.rightButton.tag = SettingsCellTypeThemes;

        if (SCREEN_WIDTH >= 768) {
            [cell.leftButton.titleLabel setFont:[cell.leftButton.titleLabel.font fontWithSize:26.0f]];
            [cell.rightButton.titleLabel setFont:[cell.rightButton.titleLabel.font fontWithSize:26.0f]];
        }

        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            cell.leftButton.tintColor = UIColor.redColor;
            cell.rightButton.tintColor = UIColor.lightGrayColor;
        } else {
            cell.leftButton.tintColor = UIColor.blackColor;
            cell.rightButton.tintColor = UIColor.redColor;
        }

        // [cell.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // [cell.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    case SettingsCellTypeAutoPhoto: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsCell"];

        cell.titleLabel.text = @"Auto Photo";
        [cell.switchControl setOn:isAutoPhoto];

        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            [cell.switchControl setThumbTintColor:UIColor.lightGrayColor];
        } else {
            [cell.switchControl setThumbTintColor:UIColor.blackColor];
        }

        // [cell.switchControl addTarget:self action:@selector(handleAutoPhotoValueChanged:) forControlEvents:UIControlEventValueChanged];
    } break;

    case SettingsCellTypeHowToUse: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.titleLabel.text = @"Mobile App - How it Works";
    } break;

    case SettingsCellTypeShare: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.titleLabel.text = @"Share Rally Navigator";
    } break;

    case SettingsCellTypeLogout: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idSettingsUsageCell"];
        cell.titleLabel.text = @"Logout";
        cell.titleLabel.textColor = UIColor.redColor;
    } break;

    default:
        break;
    }

    if (indexPath.row != SettingsCellTypeTitle && indexPath.row != SettingsCellTypeLogout) {
        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            cell.titleLabel.textColor = UIColor.lightGrayColor;
        } else {
            cell.titleLabel.textColor = UIColor.blackColor;
        }
    }

    if (indexPath.row == SettingsCellTypeNewRecording || indexPath.row == SettingsCellTypeSave || indexPath.row == SettingsCellTypeOverlayTrack) {
        if (SCREEN_WIDTH >= 768) {
            [cell.titleLabel setFont:[cell.titleLabel.font fontWithSize:32]];
        } else {
            [cell.titleLabel setFont:[cell.titleLabel.font fontWithSize:26]];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case SettingsCellTypeOverlayTrack: {
        if (!_isRecording || _currentOverlay == OverlayStatusNotApplicable) {
            return 0;
        }
    } break;

    case SettingsCellTypeSave: {
        if (!_isRecording) {
            return 0;
        }
    } break;

    case SettingsCellTypeNewRecording: {
        if (_isRecording || ![self.delegate respondsToSelector:@selector(newRecording)]) {
            return 0;
        }
    } break;

    default:
        break;
    }

    return UITableViewAutomaticDimension;
}

#pragma mark - Auto Photo Web Service

- (IBAction)handleAutoPhotoValueChanged:(id)sender
{
    isAutoPhoto = !isAutoPhoto;

    NSDictionary* dicSaveNewWayPoints = [[NSDictionary alloc] init];

    dicSaveNewWayPoints = @{
        @"waypointOnly" : [dicNewWayPoints valueForKey:@"waypointOnly"],
        @"voiceToText" : [NSNumber numberWithBool:0],
        @"text" : [dicNewWayPoints valueForKey:@"text"],
        @"takePicture" : [dicNewWayPoints valueForKey:@"takePicture"],
        @"voiceRecorder" : [dicNewWayPoints valueForKey:@"voiceRecorder"],
        @"autoPhoto" : [NSNumber numberWithBool:isAutoPhoto]
    };

    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dicSaveNewWayPoints
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    NSString* strJson = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    strJson = [[strJson componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];

    objConfig.action = strJson;

    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];

    [[WebServiceConnector alloc] init:URLSetConfig
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleChangeInConfig:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)leftButtonAction:(UIButton*)sender
{
    if (sender.tag == SettingsCellTypeDistanceUnit) {
        User* objUser = GET_USER_OBJ;
        NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
        Config* objConfig = [[Config alloc] initWithDictionary:jsonDict];
        objConfig.unit = @"Miles";

        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];

        [[WebServiceConnector alloc] init:URLSetConfig
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleChangeInConfig:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    } else {
        [DefaultsValues setBooleanValueToUserDefaults:![DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView] ForKey:kIsNightView];
        [self setUpVC];
        [_tblSettings reloadData];
    }
}

- (IBAction)rightButtonAction:(UIButton*)sender
{
    if (sender.tag == SettingsCellTypeDistanceUnit) {
        User* objUser = GET_USER_OBJ;
        NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
        Config* objConfig = [[Config alloc] initWithDictionary:jsonDict];
        objConfig.unit = @"Kilometers";

        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];

        [[WebServiceConnector alloc] init:URLSetConfig
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleChangeInConfig:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    } else {
        [DefaultsValues setBooleanValueToUserDefaults:![DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView] ForKey:kIsNightView];
        [self setUpVC];
        [_tblSettings reloadData];
    }
}

@end
