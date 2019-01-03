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

    self.title = @"";

    // Adjust font size for labels & buttons
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:SCREEN_WIDTH == 320 ? 20 : 24];
    _recordLabel.font = font;
    _continueLabel.font = font;
    _btnStartRecording.titleLabel.font = font;
    _btnSelectRoadbook.titleLabel.font = font;

    // Custom placeholder
    NSAttributedString* str
        = [[NSAttributedString alloc] initWithString:@"Enter Roadbook Name" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    self.txtRoadBookName.attributedPlaceholder = str;

    // Add Setting menu
    UIBarButtonItem* btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"drawer") style:UIBarButtonItemStyleDone target:self action:@selector(btnDrawerAction:)];
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

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)borderButton:(UIButton*)button
{
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 2;
    button.layer.borderColor = [[UIColor redColor] CGColor];
}

#pragma mark - Orientation Delegate Methods

- (IBAction)orientationChanged:(id)sender
{
    if (iPadDevice) {
        return;
    }

    BOOL hidden = UIScreen.mainScreen.bounds.size.width > UIScreen.mainScreen.bounds.size.height;
    _separatorView.hidden = hidden;
    _logoImage.hidden = hidden;
    _logoLabel.hidden = hidden;
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
    vc.curMapStyle = CurrentMapStyleSatellite;
    
    NavController* nav = [[NavController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES animated:NO];

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
            if ([_delegate respondsToSelector:@selector(createRoadBookNamed:)]) {
                [self.navigationController popViewControllerAnimated:NO];
                [_delegate createRoadBookNamed:[_txtRoadBookName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
    }
}

@end
