//
//  PickRoadBookVC.m
//  RallyNavigator
//
//  Created by C205 on 10/05/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "PickRoadBookVC.h"
#import "CDSyncData.h"
#import "Config.h"

@interface PickRoadBookVC () {
    User* objUser;
}
@end

@implementation PickRoadBookVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Overlay Track on Map";

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    objUser = GET_USER_OBJ;

    _tblRoadbooks.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        _tblRoadbooks.backgroundColor = [UIColor blackColor];
    } else {
        _tblRoadbooks.backgroundColor = [UIColor whiteColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrRoadbooks.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* strRoadbookId;
    if ([_arrRoadbooks[indexPath.row] isKindOfClass:[CDRoutes class]]) {
        CDRoutes* objRoadBook = _arrRoadbooks[indexPath.row];
        NSLog(@"%@", objRoadBook);
        strRoadbookId = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routesIdentifier doubleValue]];
    } else {
        CDSyncData* objRoadBook = _arrRoadbooks[indexPath.row];
        strRoadbookId = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routeIdentifier doubleValue]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     if ([self.delegate respondsToSelector:@selector(didPickRoadbookWithId:)]) {
                                         [self.delegate didPickRoadbookWithId:strRoadbookId];
                                     }
                                 }];
    });
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"idPickRoadbookCell"];

    if (!cell) {
        cell = [self registerCell:cell
                      inTableView:tableView
                     forClassName:NSStringFromClass([UITableViewCell class])
                       identifier:@"idPickRoadbookCell"];
    }

    if ([_arrRoadbooks[indexPath.row] isKindOfClass:[CDRoutes class]]) {
        CDRoutes* objRoadBook = _arrRoadbooks[indexPath.row];

        NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[objRoadBook.routesIdentifier doubleValue]];
        NSString* strCondition = [NSString stringWithFormat:@"isEdit = 0 AND isActive = 0 AND routeIdentifier = %@", strRouteId];

        NSMutableArray* arrTempData =
            [[NSMutableArray alloc] initWithArray:[CoreDataAdaptor fetchDataFromLocalDB:strCondition
                                                                         sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]
                                                                              forEntity:NSStringFromClass([CDSyncData class])]];

        ((UILabel*)[cell.contentView viewWithTag:2001]).text = objRoadBook.name;

        NSInteger distance = 0;
        NSString* strUnit = @"";

        Config* objConfig;

        if (objUser.config == nil) {
            objConfig.unit = @"Kilometers";
        } else {
            NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
            objConfig = [[Config alloc] initWithDictionary:jsonDict];
        }

        if ([objConfig.unit isEqualToString:@"Kilometers"]) {
            strUnit = @"km";

            if ([objRoadBook.units isEqualToString:@"kilometers"]) {
                distance = (NSInteger)ceilf((arrTempData.count > 0) ? [self getDistanceFromArray:arrTempData] : [objRoadBook.length doubleValue]);
            } else {
                distance = (NSInteger)ceilf((arrTempData.count > 0) ? [self getDistanceFromArray:arrTempData] : [objRoadBook.length doubleValue] / 0.62f);
            }
        } else {
            strUnit = @"mi";

            if ([objRoadBook.units isEqualToString:@"kilometers"]) {
                distance = (NSInteger)ceilf((arrTempData.count > 0) ? [self getDistanceFromArray:arrTempData] : [objRoadBook.length doubleValue] * 0.62f);
            } else {
                distance = (NSInteger)ceilf((arrTempData.count > 0) ? [self getDistanceFromArray:arrTempData] : [objRoadBook.length doubleValue]);
            }
        }

        NSString* strDate = [self convertDateFormatDate:objRoadBook.updatedAt];
        ((UILabel*)[cell.contentView viewWithTag:2003]).text = strDate;
        ((UILabel*)[cell.contentView viewWithTag:2002]).text = [NSString stringWithFormat:@"%ld Way Points | %ld %@", (NSInteger)floorf([objRoadBook.waypointCount doubleValue] + arrTempData.count), distance, strUnit];
    } else {
        CDSyncData* objData = _arrRoadbooks[indexPath.row];
        ((UILabel*)[cell.contentView viewWithTag:2001]).text = objData.name;

        NSString* strRouteId = [NSString stringWithFormat:@"%ld", (long)[objData.routeIdentifier doubleValue]];
        NSString* strCondition = [NSString stringWithFormat:@"isEdit = 0 AND isActive = 0 AND routeIdentifier = %@", strRouteId];

        NSMutableArray* arrTempData =
            [[NSMutableArray alloc] initWithArray:[CoreDataAdaptor fetchDataFromLocalDB:strCondition
                                                                         sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]
                                                                              forEntity:NSStringFromClass([CDSyncData class])]];

        float distance = [self getDistanceFromArray:arrTempData];

        NSString* strUnit = @"";

        if ([objData.distanceUnit isEqualToString:@"Kilometers"]) {
            strUnit = @"km";
            distance = (NSInteger)ceilf(distance);
        } else if ([objData.distanceUnit isEqualToString:@"Miles"]) {
            strUnit = @"mi";
            distance = (NSInteger)ceilf(distance / 0.62f);
        }

        NSString* strDate = [self convertDateFormatDate:objData.updatedAt];
        ((UILabel*)[cell.contentView viewWithTag:2003]).text = strDate;
        ((UILabel*)[cell.contentView viewWithTag:2002]).text = [NSString stringWithFormat:@"%ld Way Points | %ld %@", (NSInteger)floorf(arrTempData.count), (NSInteger)distance, strUnit];
    }

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        ((UILabel*)[cell.contentView viewWithTag:2001]).textColor = [UIColor lightGrayColor];
        ((UILabel*)[cell.contentView viewWithTag:2002]).textColor = [UIColor lightGrayColor];
        ((UILabel*)[cell.contentView viewWithTag:2003]).textColor = [UIColor lightGrayColor];
    } else {
        ((UILabel*)[cell.contentView viewWithTag:2001]).textColor = [UIColor blackColor];
        ((UILabel*)[cell.contentView viewWithTag:2002]).textColor = [UIColor blackColor];
        ((UILabel*)[cell.contentView viewWithTag:2003]).textColor = [UIColor blackColor];
    }

    return cell;
}

- (float)getDistanceFromArray:(NSArray*)arrSync
{
    if (arrSync.count > 0) {
        CDSyncData* objSyncData = [arrSync firstObject];
        id object = [RallyNavigatorConstants convertJsonStringToObject:objSyncData.jsonData];

        if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray* arrOperations = [[NSMutableArray alloc] init];
            arrOperations = [object mutableCopy];

            for (int index = 0; index < arrOperations.count; index++) {
                NSMutableDictionary* dicOp = [[arrOperations objectAtIndex:index] mutableCopy];

                if ([dicOp objectForKey:@"op"]) {
                    if ([[dicOp valueForKey:@"op"] isEqualToString:@"replace"]) {
                        if ([[dicOp valueForKey:@"path"] isEqualToString:@"/summary/totaldistance"]) {
                            NSLog(@"%f", [[dicOp valueForKey:@"value"] floatValue] / 1000.0);
                            return [[dicOp valueForKey:@"value"] floatValue] / 1000.0;
                        }
                    }
                }
            }
        }
    }

    return 0;
}

- (NSString*)convertDateFormatDate:(NSString*)strDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate* date = [formatter dateFromString:strDate];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    NSString* strConvertedDate = [formatter stringFromDate:date];
    return strConvertedDate;
}

@end
