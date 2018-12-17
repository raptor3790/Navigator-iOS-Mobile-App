//
//  SettingsCell.h
//  RallyNavigator
//
//  Created by C205 on 10/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UISwitch *switchAutoPhoto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpaceSwitch;

@end
