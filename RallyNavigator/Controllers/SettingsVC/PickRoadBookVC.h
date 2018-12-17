//
//  PickRoadBookVC.h
//  RallyNavigator
//
//  Created by C205 on 10/05/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@protocol PickRoadBookVCDelegate <NSObject>

@optional

- (void)didPickRoadbookWithId:(NSString *)strRoadbookId;

@end

@interface PickRoadBookVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) id<PickRoadBookVCDelegate> delegate;

@property (assign, nonatomic) CurrentMapStyle curMapStyle;

@property (strong, nonatomic) NSMutableArray *arrRoadbooks;
@property (weak, nonatomic) IBOutlet UITableView *tblRoadbooks;

@end
