//
//  OfflineMapsVC.m
//  RallyNavigator
//
//  Created by C205 on 14/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "OfflineMapsVC.h"
#import "OfflineMapCell.h"
#import "DownloadMapVC.h"
#import "AddMapNameVC.h"

#import "Route.h"

@interface OfflineMapsVC () <UITableViewDataSource, UITableViewDelegate, DownloadMapVCDelegate, AddMapNameVCDelegate>
{
    BOOL isNightMode;
    
    UIBarButtonItem *btnAdd;
    NSMutableArray<MGLOfflinePack *> *arrPacks;
}
@end

@implementation OfflineMapsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Offline Maps";
    
    btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(btnAddClicked:)];
    self.navigationItem.rightBarButtonItem = btnAdd;

    [self setUpLayout];

    arrPacks = [[NSMutableArray alloc] init];
    [MGLOfflineStorage sharedOfflineStorage];
    [[MGLOfflineStorage sharedOfflineStorage] setMaximumAllowedMapboxTiles:12000];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchOfflineMapsWithResume:YES];
    });
    
    [self pullToRefreshHeaderSetUpForTableView:_tblOfflineMaps withStatus:@"Get new maps" withRefreshingBlock:^{
        if ([self isHeaderRefreshingForTableView:_tblOfflineMaps])
        {
            [_tblOfflineMaps.mj_header endRefreshing];
        }
        [self fetchOfflineMapsWithResume:NO];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpObservers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Set Up Layout

- (void)setUpLayout
{
    _tblOfflineMaps.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    isNightMode = [DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView];
    
    if (isNightMode)
    {
        self.view.backgroundColor = [UIColor blackColor];
        ((MJRefreshNormalHeader *)_tblOfflineMaps.mj_header).stateLabel.textColor = [UIColor lightGrayColor];
        ((MJRefreshNormalHeader *)_tblOfflineMaps.mj_header).activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _lblProgress.textColor = [UIColor whiteColor];
        _lblInfo.textColor = [UIColor whiteColor];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        ((MJRefreshNormalHeader *)_tblOfflineMaps.mj_header).stateLabel.textColor = [UIColor blackColor];
        ((MJRefreshNormalHeader *)_tblOfflineMaps.mj_header).activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _lblProgress.textColor = [UIColor blackColor];
        _lblInfo.textColor = [UIColor blackColor];
    }
}

#pragma mark - Set Up Observers

- (void)setUpObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlinePackProgressDidChange:)
                                                 name:MGLOfflinePackProgressChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlinePackDidReceiveError:)
                                                 name:MGLOfflinePackErrorNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlinePackDidReceiveMaximumAllowedMapboxTiles:)
                                                 name:MGLOfflinePackMaximumMapboxTilesReachedNotification
                                               object:nil];
}

#pragma mark - Fetch Offline Maps

- (void)fetchOfflineMapsWithResume:(BOOL)isResume
{
    arrPacks = [[[MGLOfflineStorage sharedOfflineStorage] packs] mutableCopy];
    arrPacks = [[[arrPacks reverseObjectEnumerator] allObjects] mutableCopy];
    if (isResume)
    {
        [arrPacks enumerateObjectsUsingBlock:^(MGLOfflinePack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj requestProgress];
            if (obj.state == MGLOfflinePackStateInactive)
            {
                [obj resume];
            }
        }];
    }
    [_tblOfflineMaps reloadData];
}

#pragma mark - Button Click Events

- (IBAction)btnAddClicked:(id)sender
{
    [self.view endEditing:YES];
    
    AddMapNameVC *vc = loadViewController(StoryBoard_Settings, kIDAddMapNameVC);
    
    vc.delegate = self;
    
    if (_overlaySender)
    {
        NSArray *arrResponse = [self validateResponse:_overlaySender
                                           forKeyName:RouteKey
                                            forObject:self
                                            showError:YES];
        if (arrResponse.count > 0)
        {
            Route *objRoute = [arrResponse firstObject];
            vc.strMapName = objRoute.name;
        }
    }
    
    NavController *nav = [[NavController alloc] initWithRootViewController:vc];
    
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor lightGrayColor];
    [nav.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didSelectMapName:(NSString *)strMapName
{
    DownloadMapVC *vc = loadViewController(StoryBoard_Settings, kIDDownloadMapVC);
    vc.curMapStyle = _curMapStyle;
    vc.strMapName = strMapName;
    vc.delegate = self;
    
    if (_overlaySender)
    {
        vc.overlaySender = _overlaySender;
    }
    
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - Download Map Delegate Methods

- (void)didDownloadedMap
{
    [SVProgressHUD showSuccessWithStatus:@"Map Downloaded Successfully"];
}

#pragma mark - Delete Offline Map

- (void)deleteOfflineMap:(MGLOfflinePack *)offlinePack
{
    [SVProgressHUD show];
    [[MGLOfflineStorage sharedOfflineStorage] removePack:offlinePack
                                   withCompletionHandler:^(NSError * _Nullable error) {
                                       [SVProgressHUD dismiss];
                                       if (!error)
                                       {
                                           NSUInteger index = [arrPacks indexOfObject:offlinePack];
                                           NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                           [arrPacks removeObjectAtIndex:indexPath.row];
                                           [_tblOfflineMaps beginUpdates];
                                           [_tblOfflineMaps deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                           [_tblOfflineMaps endUpdates];
                                           [self manageProgress];
                                       }
                                       else
                                       {
                                           NSLog(@"Error : %@", [error localizedDescription]);
                                           [SVProgressHUD showInfoWithStatus:@"Failed to Delete Offline Map Pack"];
                                       }
                                   }];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPacks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGLOfflinePack *pack = arrPacks[indexPath.row];
    
    switch (editingStyle)
    {
        case UITableViewCellEditingStyleDelete:
        {
            [self presentConfirmationAlertWithTitle:@"Delete Map"
                                        withMessage:@"Are you sure you want to delete this map?"
                              withCancelButtonTitle:@"Cancel"
                                       withYesTitle:@"Yes"
                                 withExecutionBlock:^{
                                     [self deleteOfflineMap:pack];
                                 }];
        }
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadMapVC *vc = loadViewController(StoryBoard_Settings, kIDDownloadMapVC);
    MGLOfflinePack *pack = [arrPacks objectAtIndex:indexPath.row];
    vc.currentPack = pack;
    NSDictionary *dicData = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    
    if (dicData)
    {
        if ([dicData objectForKey:@"name"])
        {
            vc.strMapName = [dicData valueForKey:@"name"];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OfflineMapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idOfflineMapCell"];
    
    if (!cell)
    {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([OfflineMapCell class]) identifier:@"idOfflineMapCell"];
    }
    
    MGLOfflinePack *pack = [arrPacks objectAtIndex:indexPath.row];
    
    cell.lblTitle.text = @"Unknown Map";
    
    NSDictionary *dicData = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    
    if (dicData)
    {
        if ([dicData objectForKey:@"name"])
        {
            cell.lblTitle.text = [dicData valueForKey:@"name"];
        }
    }
    
    [self manageCell:cell withOfflinePack:pack];
    
    if (isNightMode)
    {
        cell.lblTitle.textColor = [UIColor lightGrayColor];
        cell.lblDetails.textColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.lblTitle.textColor = [UIColor blackColor];
        cell.lblDetails.textColor = [UIColor blackColor];
    }

    return cell;
}

- (void)manageCell:(OfflineMapCell *)cell withOfflinePack:(MGLOfflinePack *)pack
{
    MGLOfflinePackProgress progress = pack.progress;
    
    uint64_t completedResources = progress.countOfResourcesCompleted;
    uint64_t expectedResources = progress.countOfResourcesExpected;
    
    float progressPercentage = (float)completedResources / expectedResources;
    
    NSString *strDetails = [NSString stringWithFormat:@"%ld MB", (NSInteger)(pack.progress.countOfBytesCompleted / 1024 / 1024)];
    
    strDetails = [strDetails stringByAppendingString:[NSString stringWithFormat:@" \u2022 %.0f%%", isnan(progressPercentage) ? 0 : progressPercentage * 100]];
    
    MGLTilePyramidOfflineRegion *region = (MGLTilePyramidOfflineRegion *)pack.region;
    
    if ([region.styleURL isEqual:[MGLStyle streetsStyleURL]])
    {
        strDetails = [strDetails stringByAppendingString:@" \u2022 Map"];
//        [cell.btnCellLogo setTitle:@"M" forState:UIControlStateNormal];
//        cell.imgCellLogo.image = Set_Local_Image(@"mountain_view");
    }
    else if ([region.styleURL isEqual:[MGLStyle satelliteStreetsStyleURL]])
    {
        strDetails = [strDetails stringByAppendingString:@" \u2022 Satellite"];
//        [cell.btnCellLogo setTitle:@"S" forState:UIControlStateNormal];
//        cell.imgCellLogo.image = Set_Local_Image(@"satellite_view");
    }
    else
    {
        strDetails = [strDetails stringByAppendingString:@" \u2022 Unknown"];
//        [cell.btnCellLogo setTitle:@"M" forState:UIControlStateNormal];
//        cell.imgCellLogo.image = Set_Local_Image(@"mountain_view");
    }
    
    strDetails = [strDetails stringByAppendingString:[NSString stringWithFormat:@" \u2022 %llu Tiles", progress.countOfTilesCompleted]];

    cell.lblDetails.text = strDetails;
}

#pragma mark - Manage Progress

- (void)manageProgress
{
    NSInteger totalTiles = 0;
    
    for (MGLOfflinePack *pack in arrPacks)
    {
        MGLOfflinePackProgress progress = pack.progress;
        totalTiles += progress.countOfTilesCompleted;
    }
    
    if (totalTiles > 12000)
    {
        totalTiles = 12000;
    }
    
    _slider.value = totalTiles;
    _lblProgress.text = [NSString stringWithFormat:@"%.0f%%", ((double)totalTiles/12000.0f) * 100.0f];
}

#pragma mark - MGLOfflinePack Notification Handlers

- (void)offlinePackProgressDidChange:(NSNotification *)notification
{
    MGLOfflinePack *pack = notification.object;

    if ([arrPacks containsObject:pack])
    {
        NSUInteger index = [arrPacks indexOfObject:pack];
        OfflineMapCell *cell = [_tblOfflineMaps cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [self manageCell:cell withOfflinePack:pack];
    }
    else
    {
        [arrPacks insertObject:pack atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tblOfflineMaps insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    
    [self manageProgress];
}

- (void)offlinePackDidReceiveError:(NSNotification *)notification
{
    MGLOfflinePack *pack = notification.object;
    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    NSError *error = notification.userInfo[MGLOfflinePackUserInfoKeyError];
    NSLog(@"Offline pack “%@” received error: %@", userInfo[@"name"], error.localizedFailureReason);
}

- (void)offlinePackDidReceiveMaximumAllowedMapboxTiles:(NSNotification *)notification
{
    MGLOfflinePack *pack = notification.object;
    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    uint64_t maximumCount = [notification.userInfo[MGLOfflinePackUserInfoKeyMaximumCount] unsignedLongLongValue];
    NSLog(@"Offline pack “%@” reached limit of %llu tiles.", userInfo[@"name"], maximumCount);
}

@end
