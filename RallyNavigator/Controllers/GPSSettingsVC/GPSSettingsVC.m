//
//  GPSSettingsVC.m
//  RallyNavigator
//
//  Created by C205 on 22/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "GPSSettingsVC.h"
#import "GPSSettingsCell.h"
#import "Config.h"
#import "Accuracy.h"

typedef enum {
    GPSRecordingAccuracyTrackPointRecordingFrequency = 0,
    GPSRecordingAccuracyTrackPointAngleFilter,
    GPSRecordingAccuracyTulipAngle
} GPSRecordingAccuracy;

@interface GPSSettingsVC ()

@end

@implementation GPSSettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"GPS Recording Accuracy";

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        _tblGPSSettings.backgroundColor = [UIColor blackColor];
    } else {
        _tblGPSSettings.backgroundColor = [UIColor whiteColor];
    }

    _tblGPSSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton Click Events

- (IBAction)btnDismissClicked:(id)sender
{
    [self.view endEditing:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* strAlertMsg = @"";

    switch (indexPath.row) {
    case GPSRecordingAccuracyTrackPointRecordingFrequency: {
        strAlertMsg = @"Please enter track point recording frequency amount in meters";
        return;
    } break;

    case GPSRecordingAccuracyTrackPointAngleFilter: {
        strAlertMsg = @"Please enter track point angle filter";
        return;
    } break;

    case GPSRecordingAccuracyTulipAngle: {
        strAlertMsg = @"Please enter tulip angle";
    } break;

    default:
        break;
    }

    UIAlertController* alertController =
        [UIAlertController alertControllerWithTitle:@"Update Accuracy"
                                            message:strAlertMsg
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.tag = indexPath.row;
        [self setUpForgotPasswordTextField:textField];
    }];

    UIAlertAction* btnReset =
        [UIAlertAction actionWithTitle:@"Set"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction* action) {
                                   [self.view endEditing:YES];

                                   NSString* strFrequency = ((UITextField*)[alertController.textFields objectAtIndex:0]).text;

                                   if (strFrequency.length == 0) {
                                       return;
                                   }

                                   switch (indexPath.row) {
                                   case GPSRecordingAccuracyTrackPointRecordingFrequency: {
                                       self.trackPointFrequency = [strFrequency doubleValue];

                                       [self.tblGPSSettings beginUpdates];
                                       [self.tblGPSSettings reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:GPSRecordingAccuracyTrackPointRecordingFrequency inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
                                       [self.tblGPSSettings endUpdates];

                                       User* objUser = GET_USER_OBJ;

                                       NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
                                       Config* objConfig = [[Config alloc] initWithDictionary:jsonDict];
                                       objConfig.accuracy.distance = self.trackPointFrequency;

                                       NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
                                       [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];

                                       [[WebServiceConnector alloc] init:URLSetConfig
                                                          withParameters:dicParam
                                                              withObject:self
                                                            withSelector:@selector(handleChangeInConfig:)
                                                          forServiceType:ServiceTypeJSON
                                                          showDisplayMsg:@""
                                                              showLoader:YES];

                                       if ([self.delegate respondsToSelector:@selector(updateTrackPointRecordingFrequency:)]) {
                                           [self.delegate updateTrackPointRecordingFrequency:self.trackPointFrequency];
                                       }
                                   } break;

                                   case GPSRecordingAccuracyTrackPointAngleFilter: {
                                       self.trackPointAngle = [strFrequency doubleValue];

                                       [self.tblGPSSettings beginUpdates];
                                       [self.tblGPSSettings reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:GPSRecordingAccuracyTrackPointAngleFilter inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
                                       [self.tblGPSSettings endUpdates];

                                       User* objUser = GET_USER_OBJ;

                                       NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
                                       Config* objConfig = [[Config alloc] initWithDictionary:jsonDict];
                                       objConfig.accuracy.angle = self.trackPointAngle;
                                       objConfig.autoCamera = TRUE;

                                       NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
                                       [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];

                                       [[WebServiceConnector alloc] init:URLSetConfig
                                                          withParameters:dicParam
                                                              withObject:self
                                                            withSelector:@selector(handleChangeInConfig:)
                                                          forServiceType:ServiceTypeJSON
                                                          showDisplayMsg:@""
                                                              showLoader:YES];

                                       if ([self.delegate respondsToSelector:@selector(updateTrackPointAngle:)]) {
                                           [self.delegate updateTrackPointAngle:self.trackPointAngle];
                                       }
                                   } break;

                                   case GPSRecordingAccuracyTulipAngle: {
                                       self.tulipAngle = [strFrequency doubleValue];

                                       [self.tblGPSSettings beginUpdates];
                                       [self.tblGPSSettings reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:GPSRecordingAccuracyTulipAngle inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
                                       [self.tblGPSSettings endUpdates];

                                       User* objUser = GET_USER_OBJ;

                                       NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
                                       Config* objConfig = [[Config alloc] initWithDictionary:jsonDict];
                                       objConfig.accuracy.minDistanceTrackpoint = self.tulipAngle;
                                       objConfig.autoCamera = TRUE;

                                       NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
                                       [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];

                                       [[WebServiceConnector alloc] init:URLSetConfig
                                                          withParameters:dicParam
                                                              withObject:self
                                                            withSelector:@selector(handleChangeInConfig:)
                                                          forServiceType:ServiceTypeJSON
                                                          showDisplayMsg:@""
                                                              showLoader:YES];

                                       if ([self.delegate respondsToSelector:@selector(updateTulipAngleDistance:)]) {
                                           [self.delegate updateTulipAngleDistance:self.tulipAngle];
                                       }
                                   } break;

                                   default:
                                       break;
                                   }
                               }];

    UIAlertAction* btnCancel =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                               handler:nil];

    [alertController addAction:btnCancel];
    [alertController addAction:btnReset];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (IBAction)handleChangeInConfig:(id)sender
{
    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0) {
        [DefaultsValues setCustomObjToUserDefaults:[arrResponse firstObject] ForKey:kUserObject];
    }
}

- (void)setUpForgotPasswordTextField:(UITextField*)textField
{
    textField.placeholder = @"Enter your accuracy here";
    switch (textField.tag) {
    case GPSRecordingAccuracyTrackPointRecordingFrequency: {
        textField.text = [NSString stringWithFormat:@"%ld", (long)roundf(_trackPointFrequency)];
    } break;

    case GPSRecordingAccuracyTrackPointAngleFilter: {
        textField.text = [NSString stringWithFormat:@"%.1f", _trackPointAngle];
    } break;

    case GPSRecordingAccuracyTulipAngle: {
        textField.text = [NSString stringWithFormat:@"%ld", (long)roundf(_tulipAngle)];
    } break;

    default:
        break;
    }

    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    GPSSettingsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idGPSSettingsCell"];

    if (!cell) {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([GPSSettingsCell class]) identifier:@"idGPSSettingsCell"];
    }

    switch (indexPath.row) {
    case GPSRecordingAccuracyTrackPointRecordingFrequency: {
        cell.lblTitle.text = @"Track Point Recording Frequency:";
        cell.lblValue.text = @"3m";
        //            cell.lblValue.text = [NSString stringWithFormat:@"%dm", (int)roundf(_trackPointFrequency)];
    } break;

    case GPSRecordingAccuracyTrackPointAngleFilter: {
        cell.lblTitle.text = @"Track Point Angle Filter:";
        cell.lblValue.text = @"1°";
        //            cell.lblValue.text = [NSString stringWithFormat:@"%.1f°", _trackPointAngle];
    } break;

    case GPSRecordingAccuracyTulipAngle: {
        cell.lblTitle.text = @"Tulip Angle & CAP Heading Point:";
        cell.lblValue.text = [NSString stringWithFormat:@"%dm", (int)roundf(_tulipAngle)];
    } break;

    default:
        break;
    }

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        cell.lblTitle.textColor = [UIColor whiteColor];
        cell.lblValue.textColor = [UIColor whiteColor];
    } else {
        cell.lblTitle.textColor = [UIColor blackColor];
        cell.lblValue.textColor = [UIColor blackColor];
    }

    return cell;
}

@end
