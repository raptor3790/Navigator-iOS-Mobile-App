//
//  RegisterCell.h
//  RallyNavigator
//
//  Created by C205 on 02/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *txtInputPlaceHolder;
@property (weak, nonatomic) IBOutlet UITextField *txtInput;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnSocialLogin;

@end
