//
//  GPSSettingsVC.h
//  RallyNavigator
//
//  Created by C205 on 22/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"

@protocol GPSSettingsVCDelegate <NSObject>

@optional

- (void)updateTrackPointRecordingFrequency:(double)newFrequency;
- (void)updateTrackPointAngle:(double)newAngle;
- (void)updateTulipAngleDistance:(double)newDistance;

@end

@interface GPSSettingsVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) id<GPSSettingsVCDelegate> delegate;

@property (assign, nonatomic) double trackPointFrequency;
@property (assign, nonatomic) double trackPointAngle;
@property (assign, nonatomic) double tulipAngle;

@property (weak, nonatomic) IBOutlet UITableView *tblGPSSettings;

@end
