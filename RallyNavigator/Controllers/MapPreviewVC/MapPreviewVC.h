//
//  MapPreviewVC.h
//  RallyNavigator
//
//  Created by C205 on 27/03/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"
@import Mapbox;

@interface MapPreviewVC : BaseVC

@property (strong, nonatomic) NSString *strRoadbookId;
@property (strong, nonatomic) NSMutableArray *arrLocations;

@end
