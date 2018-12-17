//
//  AddFolderVC.h
//  RallyNavigator
//
//  Created by C205 on 27/08/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@protocol AddFolderVCDelegate <NSObject>

@optional

- (void)createFolderNamed:(NSString *)strFolderName;

@end

@interface AddFolderVC : BaseVC

@property (strong, nonatomic) id<AddFolderVCDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UITextField *txtFolder;

@end
