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

@property (weak, nonatomic) id<AddRoadBookVCDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *txtRoadBookName;
@property (weak, nonatomic) IBOutlet UIButton *btnStartRecording;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectRoadbook;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UILabel *continueLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *logoLabel;

@end
