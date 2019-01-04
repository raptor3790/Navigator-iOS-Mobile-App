

//
//  AddRoadBookVC.m
//  RallyNavigator
//
//  Created by C205 on 29/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "AddRoadBookVC.h"
#import "SettingsVC.h"
#import "LocationsVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AddRoadBookVC () <SettingsVCDelegate>

@end

@implementation AddRoadBookVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"";

    // Adjust font size for labels & buttons
    CGFloat fontSize = 20;
    if (SCREEN_WIDTH == 375) {
        fontSize = 24;
    } else if (SCREEN_WIDTH == 414) {
        fontSize = 26;
    } else if (SCREEN_WIDTH >= 768) {
        fontSize = 32;
    }
    UIFont* font = [UIFont fontWithName:@"RussoOne" size:fontSize];
    _recordLabel.font = font;
    _continueLabel.font = font;
    _btnStartRecording.titleLabel.font = font;
    _btnSelectRoadbook.titleLabel.font = font;
    _descriptionLabel.font = font;
    _webSiteLabel.font = [UIFont fontWithName:@"RussoOne" size:fontSize - 4];

    // Custom placeholder
    NSAttributedString* str
        = [[NSAttributedString alloc] initWithString:@"ENTER ROADBOOK NAME" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    self.txtRoadBookName.attributedPlaceholder = str;
    self.txtRoadBookName.font = [UIFont fontWithName:@"RussoOne" size:fontSize - 2];

    // Add Setting menu
    UIBarButtonItem* btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(iPadDevice ? @"drawer_x" : @"drawer")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(btnDrawerAction:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];

    self.navigationItem.hidesBackButton = YES;

    [self borderButton:_btnStartRecording];
    [self borderButton:_btnSelectRoadbook];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)borderButton:(UIButton*)button
{
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = iPadDevice ? 3 : 2;
    button.layer.borderColor = UIColor.redColor.CGColor;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];

    return YES;
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

#pragma mark - UIButton Click Events

- (IBAction)btnDrawerAction:(id)sender
{
    [self.view endEditing:YES];

    SettingsVC* vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.currentOverlay = OverlayStatusNotApplicable;
    vc.isRecording = NO;
    vc.delegate = self;
    
    NavController* nav = [[NavController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnSelectRoadBookClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnStartRecordClicked:(id)sender
{
    [self.view endEditing:YES];

    if (_txtRoadBookName.text.length > 0) {
        if ([_txtRoadBookName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            NSString* roadbookName = [_txtRoadBookName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self createRoadBookNamed:roadbookName];
            _txtRoadBookName.text = @"";
        }
    }
}

- (void)createRoadBookNamed:(NSString*)strRoadBookName
{
    LocationsVC* vc = loadViewController(StoryBoard_Main, kIDLocationsVC);
    vc.isFirstTime = YES;
    vc.strRouteName = strRoadBookName;
    
    User *objUser = GET_USER_OBJ;
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


@end
