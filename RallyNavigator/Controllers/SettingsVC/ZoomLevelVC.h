//
//  ZoomLevelVC.h
//  RallyNavigator
//
//  Created by C205 on 19/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@protocol ZoomLevelVCDelegate <NSObject>
@end

@interface ZoomLevelVC : BaseVC

@property (strong, nonatomic) id<ZoomLevelVCDelegate> delegate;

@property (assign, nonatomic) double curZoomLevel;
@property (assign, nonatomic) double maxZoomLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblCurZoom;
@property (weak, nonatomic) IBOutlet UISlider *curZoomProgessView;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxZoom;
@property (weak, nonatomic) IBOutlet UISlider *maxZoomProgressView;

@end
