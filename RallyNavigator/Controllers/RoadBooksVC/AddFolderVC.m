//
//  AddFolderVC.m
//  RallyNavigator
//
//  Created by C205 on 27/08/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "AddFolderVC.h"

@interface AddFolderVC ()

@end

@implementation AddFolderVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"New Folder";

    CGFloat fontSize = 20;
    if (SCREEN_WIDTH == 375) {
        fontSize = 24;
    } else if (SCREEN_WIDTH == 414) {
        fontSize = 26;
    } else if (SCREEN_WIDTH >= 768) {
        fontSize = 32;
    }
    _btnAdd.titleLabel.font = [UIFont fontWithName:@"RussoOne" size:fontSize];

    NSAttributedString* str = [[NSAttributedString alloc] initWithString:@"ENTER FOLDER NAME" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    self.txtFolder.attributedPlaceholder = str;
    self.txtFolder.font = [UIFont fontWithName:@"RussoOne" size:fontSize - 2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];

    _btnAdd.layer.masksToBounds = YES;
    _btnAdd.layer.cornerRadius = 5.0;
    _btnAdd.layer.borderWidth = iPadDevice ? 3 : 2;
    _btnAdd.layer.borderColor = UIColor.redColor.CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - Button Click Events

- (IBAction)btnAddFolderClicked:(id)sender
{
    [self.view endEditing:YES];

    if (_txtFolder.text.length > 0) {
        if ([_txtFolder.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            if ([_delegate respondsToSelector:@selector(createFolderNamed:)]) {
                [self.navigationController popViewControllerAnimated:NO];
                [_delegate createFolderNamed:[_txtFolder.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
    }
}

@end
