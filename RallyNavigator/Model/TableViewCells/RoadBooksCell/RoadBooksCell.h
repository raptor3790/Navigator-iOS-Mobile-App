//
//  RoadBooksCell.h
//  RallyNavigator
//
//  Created by C205 on 29/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoadBooksCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (strong, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;

@end
