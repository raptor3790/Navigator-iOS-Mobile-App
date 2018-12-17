//
//  LoginVC.h
//  RallyNavigator
//
//  Created by C205 on 30/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"

typedef enum
{
    LoginCellTypeLogo = 0,
    LoginCellTypeDescription,
    LoginCellTypeLoginInfo,
    LoginCellTypeActions,
    LoginCellTypeForgotPassword,
    LoginCellTypeSocialLogin
}LoginCellType;

@interface LoginVC : BaseVC <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (assign, nonatomic) LoginType loginType;

@property (weak, nonatomic) IBOutlet UITableView *tblLogin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightLogo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTblLogin;

@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strPassword;

@end
