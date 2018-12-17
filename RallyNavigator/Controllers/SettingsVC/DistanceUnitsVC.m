//
//  DistanceUnitsVC.m
//  RallyNavigator
//
//  Created by C205 on 11/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "DistanceUnitsVC.h"
#import "Config.h"

@interface DistanceUnitsVC ()

@end

@implementation DistanceUnitsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Distance Units";
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _tblDistance.backgroundColor = [UIColor blackColor];
    }
    else
    {
        _tblDistance.backgroundColor = [UIColor whiteColor];
    }

    _tblDistance.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _strDistanceUnit = cell.textLabel.text;
    [_tblDistance reloadData];
    
    User *objUser = GET_USER_OBJ;
    NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
    Config *objConfig = [[Config alloc] initWithDictionary:jsonDict];
    objConfig.unit = _strDistanceUnit;
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setValue:[objConfig dictionaryRepresentation] forKey:@"config"];
    
    [[WebServiceConnector alloc] init:URLSetConfig
                       withParameters:dicParam
                           withObject:self
                         withSelector:@selector(handleChangeInConfig:)
                       forServiceType:ServiceTypeJSON
                       showDisplayMsg:@""
                           showLoader:YES];
}

- (IBAction)handleChangeInConfig:(id)sender
{
    NSArray *arrResponse = [self validateResponse:sender
                                       forKeyName:LoginKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0)
    {
        [DefaultsValues setCustomObjToUserDefaults:[arrResponse firstObject] ForKey:kUserObject];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idDistanceUnitCell"];
    
    switch (indexPath.row)
    {
        case DistanceUnitsTypeKilometers:
        {
            cell.textLabel.text = @"Kilometers";
        }
            break;

        case DistanceUnitsTypeMiles:
        {
            cell.textLabel.text = @"Miles";
        }
            break;

        default:
            break;
    }
    
    if ([cell.textLabel.text isEqualToString:_strDistanceUnit])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.tintColor = [UIColor whiteColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.tintColor = [UIColor blackColor];
    }

    return cell;
}

@end
