//
//  OfflineMapsVC.h
//  RallyNavigator
//
//  Created by C205 on 14/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@import Mapbox;

@interface OfflineMapsVC : BaseVC

@property (assign, nonatomic) CurrentMapStyle curMapStyle;

@property (strong, nonatomic) id overlaySender;
@property (weak, nonatomic) IBOutlet UITableView *tblOfflineMaps;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *lblProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@end
