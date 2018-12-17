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
    
    _btnAdd.layer.masksToBounds = YES;
    _btnAdd.layer.cornerRadius = 5.0;
    _btnAdd.layer.masksToBounds = NO;
    _btnAdd.layer.borderWidth = 2;
    _btnAdd.layer.borderColor = [[UIColor redColor] CGColor];//[UIColor colorWithRed:218/255 green:0/255 blue:17/255 alpha:1.0].CGColor;
    
    _btnAdd.titleLabel.minimumScaleFactor = 0.5f;
    _btnAdd.titleLabel.numberOfLines = 1;
    _btnAdd.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _btnAdd.titleEdgeInsets = UIEdgeInsetsMake(0, 10, SCREEN_WIDTH == 320.0f ? 10 : 3, 10);
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Enter Folder Name" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    self.txtFolder.attributedPlaceholder = str;
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

#pragma mark - Button Click Events

- (IBAction)btnAddFolderClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if (_txtFolder.text.length > 0)
    {
        if ([_txtFolder.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
        {
            if ([_delegate respondsToSelector:@selector(createFolderNamed:)])
            {
                [self.navigationController popViewControllerAnimated:NO];
                [_delegate createFolderNamed:[_txtFolder.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
    }
}

@end