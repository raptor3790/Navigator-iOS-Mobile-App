//
//  LoginVC.h
//  RallyNavigator
//
//  Created by C205 on 30/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"

@interface LoginVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@property (assign, nonatomic) LoginType loginType;

@end
