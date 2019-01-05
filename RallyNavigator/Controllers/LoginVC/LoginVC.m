//
//  LoginVC.m
//  RallyNavigator
//
//  Created by C205 on 30/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"
#import "AddRoadBookVC.h"
#import "RoadBooksVC.h"
#import "User.h"
#import "CDSyncData.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <Crashlytics/Crashlytics.h>

@interface LoginVC () <GIDSignInDelegate, GIDSignInUIDelegate, UITextFieldDelegate> {
}
@end

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapRecognizer];
    self.view.backgroundColor = UIColor.blackColor;

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kLogIn]) {
        // RoadbooksVC
        RoadBooksVC* roadbooksVC = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
        roadbooksVC.navigationItem.hidesBackButton = YES;
        [roadbooksVC getRoadBooks];
        [self.navigationController pushViewController:roadbooksVC animated:NO];

        // AddRoadbookVC
        AddRoadBookVC* addRoadbookVC = loadViewController(StoryBoard_Main, kIDAddRoadBookVC);
        [self.navigationController pushViewController:addRoadbookVC animated:NO];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL portrait = UIScreen.mainScreen.bounds.size.width < UIScreen.mainScreen.bounds.size.height;

    if (indexPath.row == 0) {
        if (iPadDevice || portrait) {
            if (UIScreen.mainScreen.bounds.size.width == 320) {
                return 240;
            } else {
                return UIScreen.mainScreen.bounds.size.height * 0.45;
            }
        } else {
            return UIScreen.mainScreen.bounds.size.height * 0.65;
        }
    }

    return UITableViewAutomaticDimension;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == _emailText) {
        [_passwordText becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - Validation

- (BOOL)validateUserInput
{
    _emailText.text = [_emailText.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    if (_emailText.text.length == 0) {
        [AlertManager alert:NULL title:@"Please Enter Email Address" imageName:@"ic_error" onConfirm:NULL];
        return NO;
    }

    if (!_emailText.text.isValidEmail) {
        [AlertManager alert:NULL title:@"Please Enter Valid Email Address" imageName:@"ic_error" onConfirm:NULL];
        return NO;
    }

    if (_passwordText.text.length == 0) {
        [AlertManager alert:NULL title:@"Please Enter Password" imageName:@"ic_error" onConfirm:NULL];
        return NO;
    }

    return YES;
}

#pragma mark - Google Delegate Method

- (void)signIn:(GIDSignIn*)signIn didSignInForUser:(GIDGoogleUser*)user withError:(NSError*)error
{
    NSString* strUserId = user.userID;
    NSString* strEmail = user.profile.email;
    NSString* strFullName = user.profile.name;
    NSString* strTokenId = user.authentication.accessToken;

    if (!error) {
        NSMutableDictionary* dicAuth = [[NSMutableDictionary alloc] init];

        NSMutableDictionary* dicInfo = [[NSMutableDictionary alloc] init];
        [dicInfo setValue:strEmail forKey:@"email"];
        [dicInfo setValue:strFullName forKey:@"name"];

        [dicAuth setValue:dicInfo forKey:@"info"];
        [dicAuth setValue:strUserId forKey:@"uid"];

        NSMutableDictionary* dicCredentials = [[NSMutableDictionary alloc] init];
        [dicCredentials setValue:strTokenId forKey:@"token"];

        [dicAuth setValue:dicCredentials forKey:@"credentials"];

        [dicAuth setValue:@"google_oauth2" forKey:@"provider"];

        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setValue:dicAuth forKey:@"auth"];
        [dicParam setValue:@YES forKey:@"send_email"];

        _loginType = LoginTypeGoogle;

        [[WebServiceConnector alloc] init:URLSocialLogin
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleLoginResponse:)
                           forServiceType:ServiceTypeJSON
                           showDisplayMsg:@""
                               showLoader:YES];
    }
}

#pragma mark - Button Click Events

- (IBAction)btnLogInClicked:(id)sender
{
    [self hideKeyBoard];

    if (![self validateUserInput]) {
        return;
    }

    if ([[WebServiceConnector alloc] checkNetConnection]) {
        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];

        [dicParam setValue:_emailText.text forKey:@"email"];
        [dicParam setValue:_passwordText.text forKey:@"password"];
        [dicParam setValue:@YES forKey:@"send_email"];

        _loginType = LoginTypeNormal;

        [[WebServiceConnector alloc] init:URLLogin
                           withParameters:dicParam
                               withObject:self
                             withSelector:@selector(handleLoginResponse:)
                           forServiceType:ServiceTypePOST
                           showDisplayMsg:@""
                               showLoader:YES];
    } else if ([DefaultsValues isKeyAvailbaleInDefault:kUserObject]) {
        User* objUser = GET_USER_OBJ;
        if ([objUser.email isEqualToString:_emailText.text] &&
            [[DefaultsValues getStringValueFromUserDefaults_ForKey:kUserPassword] isEqualToString:_passwordText.text]) {

            [DefaultsValues setBooleanValueToUserDefaults:YES ForKey:kLogIn];

            // RoadbooksVC
            RoadBooksVC* roadbooksVC = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
            roadbooksVC.navigationItem.hidesBackButton = YES;
            [roadbooksVC getRoadBooks];

            // AddRoadbookVC
            AddRoadBookVC* addRoadbookVC = loadViewController(StoryBoard_Main, kIDAddRoadBookVC);

            NSMutableArray* controllers = [self.navigationController.viewControllers mutableCopy];
            [controllers addObject:roadbooksVC];
            [controllers addObject:addRoadbookVC];
            [self.navigationController setViewControllers:controllers animated:YES];
        }
    }
}

- (void)handleLoginResponse:(id)sender
{
    NSString* strLoginType = _loginType == LoginTypeGoogle ? @"Google" : @"Normal";

    NSDictionary* dic = [sender responseDict];
    NSArray* arrResponse = [dic valueForKey:LoginKey] && [[dic valueForKey:SUCCESS_STATUS] boolValue] ? [sender responseArray] : @[];
    [Answers logLoginWithMethod:strLoginType success:@(arrResponse.count > 0) customAttributes:@{}];

    if (arrResponse.count > 0) {
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDFolders class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoutes class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDRoute class])];
        [CoreDataAdaptor deleteAllDataInCoreDB:NSStringFromClass([CDSyncData class])];

        User* objUser = [arrResponse firstObject];

        if (objUser.config == nil) {
            objUser.config = @"{\"action\":\"{\\\"autoPhoto\\\":false,\\\"voiceToText\\\":true,\\\"takePicture\\\":true,\\\"voiceRecorder\\\":true,\\\"waypointOnly\\\":true,\\\"text\\\":true}\",\"unit\":\"Kilometers\",\"rotation\":{\"value\":\"1\"},\"sync\":\"2\",\"odo\":\"00.00\",\"autoCamera\":true,\"accuracy\":{\"minDistanceTrackpoint\":50,\"angle\":1,\"accuracy\":50,\"distance\":3}}";
        }

        [DefaultsValues setCustomObjToUserDefaults:objUser ForKey:kUserObject];
        [DefaultsValues setBooleanValueToUserDefaults:YES ForKey:kLogIn];
        [DefaultsValues setStringValueToUserDefaults:_passwordText.text ForKey:kUserPassword];

        // RoadbooksVC
        RoadBooksVC* roadbooksVC = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
        roadbooksVC.navigationItem.hidesBackButton = YES;
        [roadbooksVC getRoadBooks];

        // AddRoadbookVC
        AddRoadBookVC* addRoadbookVC = loadViewController(StoryBoard_Main, kIDAddRoadBookVC);

        NSMutableArray* controllers = [self.navigationController.viewControllers mutableCopy];
        [controllers addObject:roadbooksVC];
        [controllers addObject:addRoadbookVC];

        [self.navigationController setViewControllers:controllers animated:YES];

    } else {

        NSDictionary* dicResponse = [sender responseDict];
        BOOL isStatusFalse = [dicResponse objectForKey:SUCCESS_STATUS] && ![[dicResponse valueForKey:SUCCESS_STATUS] boolValue];
        if (isStatusFalse && [dicResponse objectForKey:ERROR_CODE]) {
            NSInteger errorCode = [[dicResponse valueForKey:ERROR_CODE] integerValue];
            [AlertManager alert:[RallyNavigatorConstants getErrorForErrorCode:errorCode] title:@"Error" imageName:@"ic_error" onConfirm:NULL];
        }
    }
}

- (IBAction)btnSignUpClicked:(id)sender
{
    [self.view endEditing:YES];

    RegisterVC* vc = loadViewController(StoryBoard_Main, kIDRegisterVC);
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnForgotPasswordClicked:(id)sender
{
    [self.view endEditing:YES];

    [AlertManager showWithImage:NULL
                         labels:@[
                             [AlertManager labelWithText:@"Forgot password?"
                                                   color:UIColor.whiteColor
                                                    size:1],
                             [AlertManager labelWithText:@"Please enter your email address to reset your password"
                                                   color:UIColor.lightGrayColor
                                                    size:0]
                         ]
                     textFields:@[
                         [AlertManager emailWithText:NULL
                                         placeHolder:@"Email Address"
                                            validate:^BOOL(NSString* _Nonnull email) {
                                                return !email.isEmpty && email.isValidEmail;
                                            }
                                            delegate:NULL]
                     ]
                        buttons:@[
                            [AlertManager buttonWithTitle:@"CANCEL"
                                                   action:NULL
                                                isDefault:NO
                                             needValidate:NO],
                            [AlertManager buttonWithTitle:@"SEND"
                                                   action:^(NSArray<NSString*>* _Nonnull values) {
                                                       [self.view endEditing:YES];
                                                       [self resetPasswordForEmailID:values.firstObject];
                                                   }
                                                isDefault:YES
                                             needValidate:YES],
                        ]];
}

- (void)resetPasswordForEmailID:(NSString*)strEmail
{
    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:strEmail forKey:@"email"];

    [[WebServiceConnector alloc] init:URLForgotPassword
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleResetResponse:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (void)handleResetResponse:(id)sender
{
    NSDictionary* dic = [sender responseDict];

    if ([[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        [AlertManager alert:@"Check your email for the link to reset your password" title:@"Password Request Sent" imageName:@"ic_success" onConfirm:NULL];
    } else {
        NSDictionary* dicResponse = [sender responseDict];
        BOOL isStatusFalse = [dicResponse objectForKey:SUCCESS_STATUS] && ![[dicResponse valueForKey:SUCCESS_STATUS] boolValue];
        if (isStatusFalse && [dicResponse objectForKey:ERROR_CODE]) {
            NSInteger errorCode = [[dicResponse valueForKey:ERROR_CODE] integerValue];
            [AlertManager alert:[RallyNavigatorConstants getErrorForErrorCode:errorCode] title:@"Error" imageName:@"ic_error" onConfirm:NULL];
        }
    }
}

- (IBAction)btnSignInGoogleClicked:(id)sender
{
    [self.view endEditing:YES];

    GIDSignIn* signInGoogle = [GIDSignIn sharedInstance];
    [signInGoogle setScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/plus.login"]];
    signInGoogle.delegate = self;
    signInGoogle.uiDelegate = self;
    [signInGoogle signIn];
}

@end
