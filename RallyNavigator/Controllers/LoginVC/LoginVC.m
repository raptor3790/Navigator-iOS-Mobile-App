//
//  LoginVC.m
//  RallyNavigator
//
//  Created by C205 on 30/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "LoginVC.h"
#import "RoadBooksVC.h"
#import "RegisterVC.h"
#import "User.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Crashlytics/Crashlytics.h>

#import "AddRoadBookVC.h"
#import "CDSyncData.h"

static const int HEIGHT_DESCRIPTION_CELL = 104;
static const int HEIGHT_LOGIN_INFO_CELL = 126;
static const int HEIGHT_ACTIONS_CELL = 35;
static const int HEIGHT_FORGOT_PASSWORD_CELL = 46;
static const int HEIGHT_SOCIAL_LOGIN_CELL = 80;

@interface LoginVC () <GIDSignInDelegate, GIDSignInUIDelegate> {
    BOOL isSignUp;

    CGFloat heightLogoCell, height_Logo;
}
@end

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapRecognizer];

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

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (!isSignUp) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        isSignUp = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - KeyBoard Handling Methods

- (void)registerForKeyboardNotifications
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    _bottomTblLogin.constant = kbSize.height;
    [self.view layoutIfNeeded];

    [_tblLogin scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LoginCellTypeLoginInfo inSection:0]
                     atScrollPosition:UITableViewScrollPositionTop
                             animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    _bottomTblLogin.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)didOrientationChanged:(NSNotification*)notification
{
    //    [_tblLogin reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField.tag == 3001) {
        UITableViewCell* cell = [_tblLogin cellForRowAtIndexPath:[NSIndexPath indexPathForRow:LoginCellTypeLoginInfo inSection:0]];
        [[cell.contentView viewWithTag:3002] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)updateLabelUsingContentsOfTextField:(id)sender
{
    UITextField* txtInfo = (UITextField*)sender;

    switch (txtInfo.tag) {
    case 3001: {
        _strEmail = txtInfo.text;
    } break;

    case 3002: {
        _strPassword = txtInfo.text;
    } break;

    default:
        break;
    }
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - Validation

- (BOOL)validateUserInput
{
    if (_strEmail.length == 0) {
        [AlertManager alert:NULL title:@"Please Enter Email Address" imageName:@"ic_error" onConfirm:NULL];
        return NO;
    }

    if (![_strEmail isValidEmail]) {
        [AlertManager alert:NULL title:@"Please Enter Valid Email Address" imageName:@"ic_error" onConfirm:NULL];
        return NO;
    }

    if (_strPassword.length == 0) {
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

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case LoginCellTypeLogo: {
        double val = (SCREEN_HEIGHT / 2) - (HEIGHT_LOGIN_INFO_CELL / 2) - HEIGHT_DESCRIPTION_CELL;

        heightLogoCell = val < 100 ? 100 : val;

        if (_heightLogo) {
            val = val < 100 ? 100 : val > 250 ? 250 : val;
            height_Logo = (val > heightLogoCell) ? heightLogoCell : val;
            _heightLogo.constant = height_Logo;
        }

        return heightLogoCell;
    } break;

    case LoginCellTypeDescription: {
        return HEIGHT_DESCRIPTION_CELL;
    } break;

    case LoginCellTypeLoginInfo: {
        return HEIGHT_LOGIN_INFO_CELL;
    } break;

    case LoginCellTypeActions: {
        return HEIGHT_ACTIONS_CELL;
    } break;

    case LoginCellTypeForgotPassword: {
        return HEIGHT_FORGOT_PASSWORD_CELL;
    } break;

    case LoginCellTypeSocialLogin: {
        return HEIGHT_SOCIAL_LOGIN_CELL;
    } break;

    default:
        break;
    }

    return 0.0f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;

    switch (indexPath.row) {
    case LoginCellTypeLogo: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginLogoCell"];

        NSLayoutConstraint* heightConstraint;
        for (NSLayoutConstraint* constraint in [cell.contentView viewWithTag:2001].constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                break;
            }
        }

        if (_heightLogo) {
            _heightLogo.constant = height_Logo;
            [cell.contentView layoutIfNeeded];
        } else {
            _heightLogo = heightConstraint;
        }
    } break;

    case LoginCellTypeDescription: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginDescriptionCell"];
    } break;

    case LoginCellTypeLoginInfo: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginDataCell"];

        ((UITextField*)[cell.contentView viewWithTag:3001]).delegate = self;
        ((UITextField*)[cell.contentView viewWithTag:3002]).delegate = self;

        [[cell.contentView viewWithTag:3001] addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
        [[cell.contentView viewWithTag:3002] addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd];
    } break;

    case LoginCellTypeActions: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginActionCell"];
    } break;

    case LoginCellTypeForgotPassword: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginForgotPasswordCell"];
    } break;

    case LoginCellTypeSocialLogin: {
        cell = [tableView dequeueReusableCellWithIdentifier:@"idLoginSocialCell"];
    } break;

    default:
        break;
    }

    return cell;
}

#pragma mark - Button Click Events

- (IBAction)btnLogInClicked:(id)sender
{
    [self.view endEditing:YES];

    //    [[Crashlytics sharedInstance] crash];

    if ([self validateUserInput]) {
        if ([[WebServiceConnector alloc] checkNetConnection]) {
            NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];

            [dicParam setValue:_strEmail forKey:@"email"];
            [dicParam setValue:_strPassword forKey:@"password"];
            [dicParam setValue:@YES forKey:@"send_email"];

            _loginType = LoginTypeNormal;

            [[WebServiceConnector alloc] init:URLLogin
                               withParameters:dicParam
                                   withObject:self
                                 withSelector:@selector(handleLoginResponse:)
                               forServiceType:ServiceTypePOST
                               showDisplayMsg:@""
                                   showLoader:YES];
        } else {
            if ([DefaultsValues isKeyAvailbaleInDefault:kUserObject]) {
                User* objUser = GET_USER_OBJ;
                if ([objUser.email isEqualToString:_strEmail]) {
                    if ([[DefaultsValues getStringValueFromUserDefaults_ForKey:kUserPassword] isEqualToString:_strPassword]) {
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
        }
    }
}

- (IBAction)handleLoginResponse:(id)sender
{
    NSString* strLoginType = @"";

    switch (_loginType) {
    case LoginTypeNormal: {
        strLoginType = @"Normal";
    } break;

    case LoginTypeGoogle: {
        strLoginType = @"Google";
    } break;

    case LoginTypeFacebook: {
        strLoginType = @"Facebook";
    } break;

    default:
        break;
    }

    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];

    [Answers logLoginWithMethod:strLoginType
                        success:@(arrResponse.count > 0)
               customAttributes:@{}];

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
        [DefaultsValues setStringValueToUserDefaults:_strPassword ForKey:kUserPassword];

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
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

- (IBAction)btnSignUpClicked:(id)sender
{
    [self.view endEditing:YES];

    isSignUp = YES;

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

- (IBAction)handleResetResponse:(id)sender
{
    NSDictionary* dic = [sender responseDict];

    if ([[dic valueForKey:SUCCESS_STATUS] boolValue]) {
        [AlertManager alert:@"Check your email for the link to reset your password" title:@"Password Request Sent" imageName:@"ic_success" onConfirm:NULL];
    } else {
        [self showErrorInObject:self forDict:[sender responseDict]];
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

- (IBAction)btnLogInFacebookClicked:(id)sender
{
    [self.view endEditing:YES];

    FBSDKLoginManager* login = [[FBSDKLoginManager alloc] init];

    login.loginBehavior = FBSDKLoginBehaviorNative;

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"id, name, link, first_name, last_name, picture.type(large), email, birthday, location, friends, hometown, gender, friendlists", @"fields", nil];

    [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult* result, NSError* error) {
                                if (error) {
                                } else if (result.isCancelled) {
                                } else {
                                    if ([result.grantedPermissions containsObject:@"public_profile"]) {
                                        if ([FBSDKAccessToken currentAccessToken]) {
                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                               parameters:params]
                                                startWithCompletionHandler:^(FBSDKGraphRequestConnection* connection, id result, NSError* error) {

                                                    if (!error) {
                                                        NSMutableDictionary* dicAuth = [[NSMutableDictionary alloc] init];

                                                        NSMutableDictionary* dicInfo = [[NSMutableDictionary alloc] init];
                                                        [dicInfo setValue:[result valueForKey:@"email"] forKey:@"email"];
                                                        [dicInfo setValue:[result valueForKey:@"name"] forKey:@"name"];

                                                        [dicAuth setValue:dicInfo forKey:@"info"];
                                                        [dicAuth setValue:[NSString stringWithFormat:@"%@", [result valueForKey:@"id"]] forKey:@"uid"];

                                                        NSMutableDictionary* dicCredentials = [[NSMutableDictionary alloc] init];
                                                        [dicCredentials setValue:[[FBSDKAccessToken currentAccessToken] tokenString] forKey:@"token"];

                                                        [dicAuth setValue:dicCredentials forKey:@"credentials"];

                                                        [dicAuth setValue:@"facebook" forKey:@"provider"];

                                                        NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];
                                                        [dicParam setValue:dicAuth forKey:@"auth"];
                                                        [dicParam setValue:@YES forKey:@"send_email"];

                                                        self.loginType = LoginTypeFacebook;

                                                        [[WebServiceConnector alloc] init:URLSocialLogin
                                                                           withParameters:dicParam
                                                                               withObject:self
                                                                             withSelector:@selector(handleLoginResponse:)
                                                                           forServiceType:ServiceTypeJSON
                                                                           showDisplayMsg:@""
                                                                               showLoader:YES];
                                                    }
                                                }];
                                        }
                                    }
                                }
                            }];
}
@end
