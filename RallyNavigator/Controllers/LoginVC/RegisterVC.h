//
//  RegisterVC.h
//  RallyNavigator
//
//  Created by C205 on 02/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@interface RegisterVC : UITableViewController

@property (assign, nonatomic) LoginType loginType;

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;

@end
