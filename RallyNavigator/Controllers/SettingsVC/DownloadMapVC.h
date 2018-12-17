//
//  DownloadMapVC.h
//  RallyNavigator
//
//  Created by C205 on 14/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"
@import Mapbox;

@protocol DownloadMapVCDelegate <NSObject>

@optional

- (void)didDownloadedMap;

@end

@interface DownloadMapVC : BaseVC

@property (strong, nonatomic) id<DownloadMapVCDelegate> delegate;

@property (strong, nonatomic) MGLOfflinePack *currentPack;
@property (assign, nonatomic) CurrentMapStyle curMapStyle;

@property (assign, nonatomic) double maxZoomLevel;

@property (strong, nonatomic) NSString *strMapName;
@property (strong, nonatomic) NSString *strRoadbookId;

@property (strong, nonatomic) id overlaySender;

@property (weak, nonatomic) IBOutlet UILabel *lblOverlay1;
@property (weak, nonatomic) IBOutlet UILabel *lblOverlay2;
@property (weak, nonatomic) IBOutlet UILabel *lblOverlay3;
@property (weak, nonatomic) IBOutlet UILabel *lblOverlay4;

@property (weak, nonatomic) IBOutlet UILabel *lblRedOverlay1;
@property (weak, nonatomic) IBOutlet UILabel *lblRedOverlay2;
@property (weak, nonatomic) IBOutlet UILabel *lblRedOverlay3;
@property (weak, nonatomic) IBOutlet UILabel *lblRedOverlay4;

@property (weak, nonatomic) IBOutlet UIButton *btnStyle;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDownload;

@property (weak, nonatomic) IBOutlet UILabel *lblDownloadProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@end
