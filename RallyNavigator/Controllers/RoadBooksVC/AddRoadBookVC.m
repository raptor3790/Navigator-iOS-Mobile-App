//
//  AddRoadBookVC.m
//  RallyNavigator
//
//  Created by C205 on 29/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "AddRoadBookVC.h"
#import "SettingsVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AddRoadBookVC () <SettingsVCDelegate>

@end

@implementation AddRoadBookVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _btnAdd.layer.masksToBounds = YES;
    _btnAdd.layer.cornerRadius = 5.0;
    _btnAdd.layer.masksToBounds = NO;
    _btnAdd.layer.borderWidth = 2;
    _btnAdd.layer.borderColor = [[UIColor redColor] CGColor];//[UIColor colorWithRed:218/255 green:0/255 blue:17/255 alpha:1.0].CGColor;
    
    _btnAdd.titleLabel.minimumScaleFactor = 0.5f;
    _btnAdd.titleLabel.numberOfLines = 1;
    _btnAdd.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _btnAdd.titleEdgeInsets = UIEdgeInsetsMake(0, 10, SCREEN_WIDTH == 320.0f ? 10 : 3, 10);
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Enter Roadbook Name" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    self.txtRoadBookName.attributedPlaceholder = str;
    
    self.title = @"New Roadbook";
    
    UIBarButtonItem *btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"drawer") style:UIBarButtonItemStyleDone target:self action:@selector(btnDrawerAction:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)clickedOnLogout
{
    [self presentConfirmationAlertWithTitle:@"Confirm Logout"
                                withMessage:@"Are you sure you want to log out?"
                      withCancelButtonTitle:@"Cancel"
                               withYesTitle:@"Yes"
                         withExecutionBlock:^{
                             
                             FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
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
    
    SettingsVC *vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.currentOverlay = OverlayStatusNotApplicable;
    vc.isRecording = NO;
    vc.delegate = self;
    vc.curMapStyle = CurrentMapStyleSatellite;
    NavController *nav = [[NavController alloc] initWithRootViewController:vc];
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = [UIColor lightGrayColor];
        [nav.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    }
    else
    {
        nav.navigationBar.barStyle = UIBarStyleDefault;
        nav.navigationBar.translucent = YES;
        nav.navigationBar.tintColor = [UIColor blackColor];
        [nav.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnAddRoadBookClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if (_txtRoadBookName.text.length > 0)
    {
        if ([_txtRoadBookName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
        {
            if ([_delegate respondsToSelector:@selector(createRoadBookNamed:)])
            {
                [self.navigationController popViewControllerAnimated:NO];
                [_delegate createRoadBookNamed:[_txtRoadBookName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
    }
}

@end
