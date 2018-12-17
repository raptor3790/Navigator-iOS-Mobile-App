//
//  RegisterVC.h
//  RallyNavigator
//
//  Created by C205 on 02/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@interface RegisterVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) LoginType loginType;

@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strUsername;
@property (strong, nonatomic) NSString *strPassword;
@property (strong, nonatomic) NSString *strConfirmPassword;

@property (assign, nonatomic) NSInteger currentTextFieldTag;

@property (weak, nonatomic) IBOutlet UITableView *tblRegister;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightLogo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTblRegister;

@end
