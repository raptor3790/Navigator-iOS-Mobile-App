//
//  NewWayPointVC.m
//  RallyNavigator
//
//  Created by C205 on 12/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "NewWayPointVC.h"

@import StoreKit;

@interface NewWayPointVC () <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    BOOL isTrialPeriodExpired;

    BOOL isWayPointsOnly;
    BOOL isText;
    BOOL isTakePicture;
    BOOL isStartVoiceRecorder;
    BOOL isAutoPhoto;

    NSMutableArray<SKProduct*>* arrProducts;
    NSDictionary* dicNewWayPoints;

    User* objUser;
}
@end

@implementation NewWayPointVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"New Waypoint Functions";

    UIBarButtonItem* btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(clickedOnSaveChanges:)];
    self.navigationItem.rightBarButtonItem = btnSave;

    //* LAYOUT SET UP *//

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        self.view.backgroundColor = [UIColor blackColor];
        [_btnRestore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _tblSettings.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        [_btnRestore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _tblSettings.backgroundColor = [UIColor whiteColor];
    }

    _tblSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    //* IN-APP PURCHASE SET UP *//

    //    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    //    arrProducts = [[NSMutableArray alloc] init];
    //    [self getProductInfo];

    //* CHECK FOR TRIAL PERIOD *//

    objUser = GET_USER_OBJ;

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSDate* trialDate = [dateFormatter dateFromString:objUser.trialExpiredDate];

    if ([trialDate compare:[NSDate date]] == NSOrderedAscending) {
        isTrialPeriodExpired = YES;
    }

    //* OBJECT SER UP *//

    dicNewWayPoints = @{
        @"waypointOnly" : [NSNumber numberWithBool:NO],
        @"text" : [NSNumber numberWithBool:NO],
        @"takePicture" : [NSNumber numberWithBool:NO],
        @"voiceRecorder" : [NSNumber numberWithBool:NO],
        @"autoPhoto" : [NSNumber numberWithBool:NO]
    };

    NSError* jsonError = nil;
    NSData* objectData = [_objConfig.action dataUsingEncoding:NSUTF8StringEncoding];

    if (objectData) {
        dicNewWayPoints = [NSJSONSerialization JSONObjectWithData:objectData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&jsonError];

        isWayPointsOnly = [[dicNewWayPoints valueForKey:@"waypointOnly"] boolValue];
        isText = [[dicNewWayPoints valueForKey:@"text"] boolValue];
        isTakePicture = [[dicNewWayPoints valueForKey:@"takePicture"] boolValue];
        isStartVoiceRecorder = [[dicNewWayPoints valueForKey:@"voiceRecorder"] boolValue];
        isAutoPhoto = [[dicNewWayPoints valueForKey:@"autoPhoto"] boolValue];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - In-App Purchase Handling Methods

- (void)getProductInfo
{
    if ([SKPaymentQueue canMakePayments]) {
        [SVProgressHUD show];

        NSSet<NSString*>* setInApp = [NSSet setWithObjects:@"com.rallynavigator.premiumuser", @"com.rallynavigator.prouser", nil];
        SKProductsRequest* request =
            [[SKProductsRequest alloc] initWithProductIdentifiers:setInApp];
        request.delegate = self;
        [request start];
    } else {
        NSLog(@"Cannot perform In App Purchases");
    }
}

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
    [SVProgressHUD dismiss];

    if (response.products.count != 0) {
        arrProducts = [[NSMutableArray alloc] init];

        for (SKProduct* product in response.products) {
            NSLog(@"%@", product.localizedTitle);
            [arrProducts addObject:product];
        }
    } else {
        NSLog(@"There are no products");
    }
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error
{
    [SVProgressHUD dismiss];

    NSLog(@"%@", error.localizedDescription);
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray<SKPaymentTransaction*>*)transactions
{
    [SVProgressHUD dismiss];

    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased: {
            NSLog(@"Transaction completed successfully");
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } break;

        case SKPaymentTransactionStateFailed: {
            NSLog(@"Transaction Failed");
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } break;

        case SKPaymentTransactionStatePurchasing: {
            [SVProgressHUD show];
            NSLog(@"Transaction Purchasing");
        } break;

        default: {
            NSLog(@"%ld", transaction.transactionState);
        } break;
        }
    }
}

#pragma mark - Button Click Events

- (IBAction)clickedOnSaveChanges:(id)sender
{
    dicNewWayPoints = @{
        @"waypointOnly" : [NSNumber numberWithBool:isWayPointsOnly],
        @"voiceToText" : [NSNumber numberWithBool:0],
        @"text" : [NSNumber numberWithBool:isText],
        @"takePicture" : [NSNumber numberWithBool:isTakePicture],
        @"voiceRecorder" : [NSNumber numberWithBool:isStartVoiceRecorder],
        @"autoPhoto" : [NSNumber numberWithBool:isAutoPhoto]
    };

    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dicNewWayPoints
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    NSString* strJson = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    strJson = [[strJson componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];

    _objConfig.action = strJson;

    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:[_objConfig dictionaryRepresentation] forKey:@"config"];

    [[WebServiceConnector alloc] init:URLSetConfig
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleChangeInConfig:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)handleChangeInConfig:(id)sender
{
    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0) {
        [DefaultsValues setCustomObjToUserDefaults:[arrResponse firstObject] ForKey:kUserObject];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)btnRestoreClicked:(id)sender
{
    [self.view endEditing:YES];

    [AlertManager confirm:@"Are you sure you want to restore all your purchases?"
                    title:@"Confirm Restore"
                 negative:@"CANCEL"
                 positive:@"YES"
               onNegative:NULL
               onPositive:NULL];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case WaypointCellTypeWaypointOnly: {
        isWayPointsOnly = !isWayPointsOnly;
        [_tblSettings beginUpdates];
        [_tblSettings reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [_tblSettings endUpdates];
    } break;

    case WaypointCellTypeText: {
        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    dispatch_async(dispatch_get_main_queue(), ^{
        //                        SKProduct *product = nil;
        //
        //                        for (SKProduct *pro in arrProducts)
        //                        {
        //                            if ([pro.localizedTitle isEqualToString:@"Premium User"])
        //                            {
        //                                product = pro;
        //                            }
        //                        }
        //
        //                        if (product != nil) {
        //                            SKPayment *payment = [SKPayment paymentWithProduct:product];
        //                            [[SKPaymentQueue defaultQueue] addPayment:payment];
        //                        }
        //                    });
        //                }
        //                else if ([objUser.role isEqualToString:@"premium"] || [objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    isText = !isText;
        //                    [_tblSettings beginUpdates];
        //                    [_tblSettings reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //                    [_tblSettings endUpdates];
        //                }
        //            }
        //            else
        //            {
        isText = !isText;
        [_tblSettings beginUpdates];
        [_tblSettings reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [_tblSettings endUpdates];
        //            }
    } break;

    case WaypointCellTypeTakePicture: {
        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    dispatch_async(dispatch_get_main_queue(), ^{
        //                        SKProduct *product = nil;
        //
        //                        for (SKProduct *pro in arrProducts)
        //                        {
        //                            if ([pro.localizedTitle isEqualToString:@"Premium User"])
        //                            {
        //                                product = pro;
        //                            }
        //                        }
        //
        //                        if (product != nil) {
        //                            SKPayment *payment = [SKPayment paymentWithProduct:product];
        //                            [[SKPaymentQueue defaultQueue] addPayment:payment];
        //                        }
        //                    });
        //                }
        //                else if ([objUser.role isEqualToString:@"premium"] || [objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    isTakePicture = !isTakePicture;
        //                    [_tblSettings beginUpdates];
        //                    [_tblSettings reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //                    [_tblSettings endUpdates];
        //                }
        //            }
        //            else
        //            {
        isTakePicture = !isTakePicture;
        [_tblSettings beginUpdates];
        [_tblSettings reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [_tblSettings endUpdates];
        //            }
    } break;

    case WaypointCellTypeStartRecorder: {
        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    dispatch_async(dispatch_get_main_queue(), ^{
        //                        SKProduct *product = nil;
        //
        //                        for (SKProduct *pro in arrProducts)
        //                        {
        //                            if ([pro.localizedTitle isEqualToString:@"Pro User"])
        //                            {
        //                                product = pro;
        //                            }
        //                        }
        //
        //                        if (product != nil) {
        //                            SKPayment *payment = [SKPayment paymentWithProduct:product];
        //                            [[SKPaymentQueue defaultQueue] addPayment:payment];
        //                        }
        //                    });
        //                }
        //                else if ([objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    isStartVoiceRecorder = !isStartVoiceRecorder;
        //                    [_tblSettings beginUpdates];
        //                    [_tblSettings reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //                    [_tblSettings endUpdates];
        //                }
        //            }
        //            else
        //            {
        isStartVoiceRecorder = !isStartVoiceRecorder;
        [_tblSettings beginUpdates];
        [_tblSettings reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [_tblSettings endUpdates];

        //            }
    } break;

    case WaypointCellTypeAutoPhoto: {
        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    dispatch_async(dispatch_get_main_queue(), ^{
        //                        SKProduct *product = nil;
        //
        //                        for (SKProduct *pro in arrProducts)
        //                        {
        //                            if ([pro.localizedTitle isEqualToString:@"Pro User"])
        //                            {
        //                                product = pro;
        //                            }
        //                        }
        //
        //                        if (product != nil) {
        //                            SKPayment *payment = [SKPayment paymentWithProduct:product];
        //                            [[SKPaymentQueue defaultQueue] addPayment:payment];
        //                        }
        //                    });
        //                }
        //                else if ([objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    isAutoPhoto = !isAutoPhoto;
        //                    [_tblSettings beginUpdates];
        //                    [_tblSettings reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //                    [_tblSettings endUpdates];
        //                }
        //            }
        //            else
        //            {
        isAutoPhoto = !isAutoPhoto;
        [_tblSettings beginUpdates];
        [_tblSettings reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        [_tblSettings endUpdates];
        //            }
    } break;

    default:
        break;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idNewWayPointCell"];

    //    UIImageView *imgVW = [[UIImageView alloc] initWithImage:Set_Local_Image(@"lockIcon")];

    switch (indexPath.row) {
    case WaypointCellTypeWaypointOnly: {
        cell.textLabel.text = @"Waypoint Only";
        //            cell.accessoryView = nil;
        cell.accessoryType = isWayPointsOnly ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } break;

    case WaypointCellTypeText: {
        cell.textLabel.text = @"Text (Premium Feature)";

        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    cell.accessoryType = UITableViewCellAccessoryNone;
        //                    cell.accessoryView = imgVW;
        //                    [cell.accessoryView setFrame:CGRectMake(0, 0, 15, 15)];
        //                }
        //                else if ([objUser.role isEqualToString:@"premium"] || [objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    cell.accessoryView = nil;
        //                    cell.accessoryType = isText ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //                }
        //            }
        //            else
        //            {
        //                cell.accessoryView = nil;
        cell.accessoryType = isText ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //            }
    } break;

    case WaypointCellTypeTakePicture: {
        cell.textLabel.text = @"Take Picture (Premium Feature)";

        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    cell.accessoryType = UITableViewCellAccessoryNone;
        //                    cell.accessoryView = imgVW;
        //                    [cell.accessoryView setFrame:CGRectMake(0, 0, 15, 15)];
        //                }
        //                else if ([objUser.role isEqualToString:@"premium"] || [objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    cell.accessoryView = nil;
        //                    cell.accessoryType = isTakePicture ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //                }
        //            }
        //            else
        //            {
        //                cell.accessoryView = nil;
        cell.accessoryType = isTakePicture ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //            }
    } break;

    case WaypointCellTypeStartRecorder: {
        cell.textLabel.text = @"Start Voice Recorder (Pro Feature)";

        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    cell.accessoryType = UITableViewCellAccessoryNone;
        //                    cell.accessoryView = imgVW;
        //                    [cell.accessoryView setFrame:CGRectMake(0, 0, 15, 15)];
        //                }
        //                else if ([objUser.role isEqualToString:@"premium"] || [objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    cell.accessoryView = nil;
        //                    cell.accessoryType = isStartVoiceRecorder ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //                }
        //            }
        //            else
        //            {
        //                cell.accessoryView = nil;
        cell.accessoryType = isStartVoiceRecorder ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //            }
    } break;

    case WaypointCellTypeAutoPhoto: {
        cell.textLabel.text = @"Auto Photo (Pro Feature)";

        //            if (isTrialPeriodExpired)
        //            {
        //                if ([objUser.role isEqualToString:@"user"])
        //                {
        //                    cell.accessoryType = UITableViewCellAccessoryNone;
        //                    cell.accessoryView = imgVW;
        //                    [cell.accessoryView setFrame:CGRectMake(0, 0, 15, 15)];
        //                }
        //                else if ([objUser.role isEqualToString:@"premium"] || [objUser.role isEqualToString:@"pro_rally"])
        //                {
        //                    cell.accessoryView = nil;
        //                    cell.accessoryType = isAutoPhoto ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //                }
        //            }
        //            else
        //            {
        //                cell.accessoryView = nil;
        cell.accessoryType = isAutoPhoto ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        //            }
    } break;

    default:
        break;
    }

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.tintColor = [UIColor whiteColor];
        //        imgVW.tintColor = [UIColor whiteColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.tintColor = [UIColor blackColor];
        //        imgVW.tintColor = [UIColor blackColor];
    }

    return cell;
}

@end
