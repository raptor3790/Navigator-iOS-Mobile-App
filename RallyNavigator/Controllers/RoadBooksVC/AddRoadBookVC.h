//
//  AddRoadBookVC.h
//  RallyNavigator
//
//  Created by C205 on 29/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"

@protocol AddRoadBookVCDelegate <NSObject>

@optional

- (void)createRoadBookNamed:(NSString *)strRoadBookName;

@end

@interface AddRoadBookVC : BaseVC <UITextFieldDelegate>

@property (strong, nonatomic) id<AddRoadBookVCDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *txtRoadBookName;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UILabel *lblAddBookDetail;

@end
