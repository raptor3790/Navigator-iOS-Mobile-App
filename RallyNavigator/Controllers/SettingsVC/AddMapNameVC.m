//
//  AddMapNameVC.m
//  RallyNavigator
//
//  Created by C205 on 26/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "AddMapNameVC.h"

@interface AddMapNameVC ()

@end

@implementation AddMapNameVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Map Name";
    
    //UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnDismissClicked:)];
    
    UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"cancel_icon") style:UIBarButtonItemStylePlain target:self action:@selector(btnDismissClicked:)];
    self.navigationItem.rightBarButtonItem = btnDismiss;
    
    _btnAdd.layer.masksToBounds = YES;
    _btnAdd.layer.cornerRadius = 5.0;
    _btnAdd.layer.masksToBounds = NO;
    _btnAdd.layer.borderWidth = 2;
    _btnAdd.layer.borderColor = [[UIColor redColor] CGColor];
    
    _btnAdd.titleLabel.minimumScaleFactor = 0.5f;
    _btnAdd.titleLabel.numberOfLines = 1;
    _btnAdd.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _btnAdd.titleEdgeInsets = UIEdgeInsetsMake(0, 10, SCREEN_WIDTH == 320.0f ? 10 : 3, 10);
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Enter Map Name" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    _txtMapName.attributedPlaceholder = str;
    
    if (_strMapName) {
        _txtMapName.text = _strMapName;
    }
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

- (IBAction)btnDismissClicked:(id)sender
{
    [self.view endEditing:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnAddMapNameClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if (_txtMapName.text.length > 0)
    {
        if ([_txtMapName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
        {
            if ([_delegate respondsToSelector:@selector(didSelectMapName:)])
            {
                [self dismissViewControllerAnimated:NO completion:^{
                    [_delegate didSelectMapName:[_txtMapName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                }];
            }
        }
    }
}

@end
