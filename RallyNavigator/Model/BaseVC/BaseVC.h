//
//  BaseVC.h
//  RallyNavigator
//
//  Created by C205 on 22/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteDetails.h"
#import "Settings.h"
#import "Summary.h"
#import "Startlocation.h"
#import "Endlocation.h"
#import "Coord.h"

@interface BaseVC : UIViewController

typedef void (^RefreshBlock) (void);

- (id _Nonnull)registerCell:(nullable id)cell
                inTableView:(nullable UITableView *)tableView
               forClassName:(nonnull NSString *)className
                 identifier:(nonnull NSString *)identifier;

- (void)presentConfirmationAlertWithTitle:(nonnull NSString *)strTitle
                              withMessage:(nonnull NSString *)strMessage
                    withCancelButtonTitle:(nonnull NSString *)strCancelTitle
                             withYesTitle:(nonnull NSString *)strYes
                       withExecutionBlock:(nonnull RefreshBlock)block;

- (void)showErrorInObject:(nullable id)object forDict:(NSDictionary * _Nullable)dicResponse;

- (RouteDetails *_Nullable)generateBasicRoute;

- (NSArray * _Nullable)validateResponse:(nullable id)sender
                             forKeyName:(nonnull NSString *)keyName
                              forObject:(nullable id)object
                              showError:(BOOL)showError;

- (void)performShakeGesture:(nullable UIView *)vwShake;

- (UIView * _Nullable)getCellForClassName:(nonnull NSString *)classname
                               withSender:(nullable id)sender;

- (BOOL)isHeaderRefreshingForTableView:(nullable UITableView *)tableView;
- (BOOL)isFooterRefreshingForTableView:(nullable UITableView *)tableView;

- (void)pullToRefreshHeaderSetUpForTableView:(nullable UITableView *)tableView withStatus:(nonnull NSString *)strPlaceholder withRefreshingBlock:(nonnull RefreshBlock)block;

- (void)loadMoreFooterSetUpForTableView:(nullable UITableView *)tableView withRefreshingBlock:(nonnull RefreshBlock)block;

@end
