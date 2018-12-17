//
//  DistanceUnitsVC.h
//  RallyNavigator
//
//  Created by C205 on 11/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@interface DistanceUnitsVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *strDistanceUnit;
@property (weak, nonatomic) IBOutlet UITableView *tblDistance;

@end
