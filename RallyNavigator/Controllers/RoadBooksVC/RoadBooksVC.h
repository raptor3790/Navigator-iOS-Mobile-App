//
//  RoadBooksVC.h
//  RallyNavigator
//
//  Created by C205 on 29/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"
#import "AddRoadBookVC.h"

typedef enum
{
    MyRoadbooksSectionFolders = 0,
    MyRoadbooksSectionRoadbooks
}MyRoadbooksSection;

@protocol RoadBooksVCDelegate <NSObject>

@optional

- (void)didPickRoadbookWithId:(NSString *)strRoadbookId;

@end

@interface RoadBooksVC : BaseVC <UITableViewDataSource, UITableViewDelegate, AddRoadBookVCDelegate>

@property (strong, nonatomic) id<RoadBooksVCDelegate> delegate;

@property (assign, nonatomic) BOOL isAddRouteHidden;
@property (assign, nonatomic) BOOL isOverlayTrack;
@property (strong, nonatomic) NSString *strFolderId;
@property (strong, nonatomic) NSString *strRoadbookPageName;

@property (strong, nonatomic) NSMutableArray *arrFolders;
@property (strong, nonatomic) NSMutableArray *arrRoadBooks;

@property (strong, nonatomic) IBOutlet UILabel *lblSync;
@property (weak, nonatomic) IBOutlet UITableView *tblRoadBooks;
@property (weak, nonatomic) IBOutlet UIButton *btnAddRoute;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLblSync;

- (void)getRoadBooks;

@end
