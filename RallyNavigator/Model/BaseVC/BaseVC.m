//
//  BaseVC.m
//  RallyNavigator
//
//  Created by C205 on 22/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"
#import "ReachabilityManager.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id _Nonnull)registerCell:(nullable id)cell
                inTableView:(nullable UITableView *)tableView
               forClassName:(nonnull NSString *)className
                 identifier:(nonnull NSString *)identifier
{
    [tableView registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:identifier];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    return [nib objectAtIndex:0];
}

- (void)presentConfirmationAlertWithTitle:(nonnull NSString *)strTitle
                              withMessage:(nonnull NSString *)strMessage
                    withCancelButtonTitle:(nonnull NSString *)strCancelTitle
                             withYesTitle:(nonnull NSString *)strYes
                       withExecutionBlock:(nonnull RefreshBlock)block
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strTitle
                                                                             message:strMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:strCancelTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
//                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:strYes
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              block();
                                                          });
//                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:yesAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)showErrorInObject:(nullable id)object forDict:(NSDictionary * _Nullable)dicResponse
{
    if ([dicResponse objectForKey:SUCCESS_STATUS])
    {
        if (![[dicResponse valueForKey:SUCCESS_STATUS] boolValue])
        {
            if ([dicResponse objectForKey:ERROR_CODE])
            {
                NSInteger errorCode = [[dicResponse valueForKey:ERROR_CODE] integerValue];
                [UIAlertController showAlertInViewController:object
                                                   withTitle:@"Error"
                                                     message:[RallyNavigatorConstants getErrorForErrorCode:errorCode]
                                           cancelButtonTitle:@"OK"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil
                                                    tapBlock:nil];
            }
        }
    }
}

#pragma mark - Generate Basic JSOn

- (RouteDetails *)generateBasicRoute
{
    RouteDetails *objRoute = [[RouteDetails alloc] init];
    objRoute.averageTimeOption = 1;
    objRoute.currentStyle = @"cross_country";
    objRoute.customAverageData = @"";
    objRoute.dataVersion = 1;
    objRoute.day = @"";
    objRoute.internalBaseClassDescription = @"";
    objRoute.folderId = @"";
    objRoute.name = @""; // set name
    objRoute.section = @"";
    
    Settings *objSettings = [[Settings alloc] init];
    objSettings.showAlternateDistance = false;
    objSettings.showStickMarkOnTulips = true;
    objSettings.showcoordinates = false;
    objSettings.showheadings = false;
    objSettings.units = @""; // set units
    
    objRoute.settings = objSettings;
    objRoute.ssheaderinfo = @[];
    
    Coord *objCoord = [[Coord alloc] init];
    objCoord.lat = 0;
    objCoord.lon = 0;
    objCoord.addresslong = @"";
    objCoord.addressshort = @"";
    objCoord.addresscustom = @"";
    objCoord.addressoption = 0;

    Startlocation *objStartLocation = [[Startlocation alloc] init];
    objStartLocation.coord = objCoord;

    Endlocation *objEndLocation = [[Endlocation alloc] init];
    objEndLocation.coord = objCoord;

    Summary *objSummary = [[Summary alloc] init];
    objSummary.startlocation = objStartLocation;
    objSummary.endlocation = objEndLocation;
    objSummary.totalwaypoints = 1;
    objSummary.fuelrange = 0;
    objSummary.totaldistance = 0;
    
    objRoute.summary = objSummary;
    
    objRoute.tcEndOption = 0;
    objRoute.tcStartOption = 0;
    objRoute.tcend = @"";
    objRoute.tcendnumber = 1;
    objRoute.tcstart = @"";
    objRoute.tcstartnumber = @"0";
    objRoute.timeallowed = @"";
    objRoute.waypoints = @[];

    return objRoute;
}

#pragma mark - Shake Gesture

- (void)performShakeGesture:(nullable UIView *)vwShake
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.06];
    [animation setRepeatCount:6];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([vwShake center].x - 20.0f, [vwShake center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([vwShake center].x + 20.0f, [vwShake center].y)]];
    [[vwShake layer] addAnimation:animation forKey:@"position"];
}

- (NSArray * _Nullable)validateResponse:(nullable id)sender
                             forKeyName:(nonnull NSString *)keyName
                              forObject:(nullable id)object
                              showError:(BOOL)showError
{
    NSDictionary *dic = [sender responseDict];
    
    if ([dic valueForKey:keyName] && [[dic valueForKey:SUCCESS_STATUS] boolValue])
    {
        if ([sender responseArray].count > 0)
        {
            return [sender responseArray];
        }
    }
//    else if([[dic valueForKey:STATUS] isEqualToString:FAILED_STATUS] && [dic valueForKey:MESSAGE])
//    {
//        if (showError)
//        {
//            [UIAlertController showAlertInViewController:object
//                                               withTitle:APP_NAME
//                                                 message:[dic valueForKey:MESSAGE]
//                                       cancelButtonTitle:@"Ok"
//                                  destructiveButtonTitle:nil
//                                       otherButtonTitles:nil
//                                                tapBlock:nil];
//        }
//    }
    return @[];
}

// GET CELL FROM THE BUTTON(SENDER)

- (UIView * _Nullable)getCellForClassName:(nonnull NSString *)classname
                               withSender:(nullable id)sender
{
    UIView *superview = [sender superview];
    
    while (![superview isKindOfClass:NSClassFromString(classname)])
    {
        superview = [superview superview];
    }
    
    return superview;
}

#pragma mark - Pull to Refresh and Load More Management

- (void)pullToRefreshHeaderSetUpForTableView:(nullable UITableView *)tableView
                                  withStatus:(nonnull NSString *)strPlaceholder
                         withRefreshingBlock:(nonnull RefreshBlock)block
{
    tableView.bounces = YES;
    //Header-Refresh
    MJRefreshNormalHeader *mainHeader = [[MJRefreshNormalHeader alloc] init];
    mainHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        block();
    }];
    mainHeader.lastUpdatedTimeLabel.hidden = YES;
    mainHeader.automaticallyChangeAlpha = YES;
    [mainHeader setTitle:strPlaceholder forState:MJRefreshStateIdle];
    [mainHeader setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [mainHeader setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
    tableView.mj_header = mainHeader;
   
}

- (void)loadMoreFooterSetUpForTableView:(nullable UITableView *)tableView
                    withRefreshingBlock:(nonnull RefreshBlock)block
{
    tableView.bounces = YES;
    
    MJRefreshBackNormalFooter *footer = [[MJRefreshBackNormalFooter alloc] init];
    footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        block();
    }];
    footer.automaticallyChangeAlpha = YES;
    tableView.mj_footer = footer;
}

// Check Header Refreshing

- (BOOL)isHeaderRefreshingForTableView:(nullable UITableView *)tableView
{
    if (tableView.mj_header)
    {
        return [tableView.mj_header isRefreshing];
    }
    return NO;
}

- (BOOL)isFooterRefreshingForTableView:(nullable UITableView *)tableView
{
    if (tableView.mj_footer)
    {
        return [tableView.mj_footer isRefreshing];
    }
    return NO;
}

@end
