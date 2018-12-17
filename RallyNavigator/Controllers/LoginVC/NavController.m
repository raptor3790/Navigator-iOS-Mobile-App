//
//  NavController.m
//  RallyNavigator
//
//  Created by C205 on 07/02/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//#pragma mark - Handle Orientation
//
//- (BOOL)shouldAutorotate
//{
//    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kLogIn])
//    {
//        User *objUser = GET_USER_OBJ;
//        
//        if(objUser.config != nil)
//        {
//            NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
//            Config *objConfig = [[Config alloc] initWithDictionary:jsonDict];
//            
//            if (![objConfig.rotation.value boolValue])
//            {
//                [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
//                return [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait;
//            }
//        }
//    }
//    
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kLogIn])
//    {
//        User *objUser = GET_USER_OBJ;
//        
//        if(objUser.config != nil)
//        {
//            NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
//            Config *objConfig = [[Config alloc] initWithDictionary:jsonDict];
//            
//            if (![objConfig.rotation.value boolValue])
//            {
//                return UIInterfaceOrientationMaskPortrait;
//            }
//        }
//    }
//    
//    return UIInterfaceOrientationMaskAll;
//}

@end
