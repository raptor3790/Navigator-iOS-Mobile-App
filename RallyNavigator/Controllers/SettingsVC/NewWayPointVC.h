//
//  NewWayPointVC.h
//  RallyNavigator
//
//  Created by C205 on 12/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"
#import "Config.h"

typedef enum
{
    WaypointCellTypeWaypointOnly = 0,
    WaypointCellTypeText,
    WaypointCellTypeTakePicture,
    WaypointCellTypeStartRecorder,
    WaypointCellTypeAutoPhoto
}WaypointCellType;

@interface NewWayPointVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Config *objConfig;

@property (weak, nonatomic) IBOutlet UIButton *btnRestore;
@property (weak, nonatomic) IBOutlet UITableView *tblSettings;

@end
