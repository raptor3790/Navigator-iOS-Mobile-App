//
//  SettingsVC.h
//  RallyNavigator
//
//  Created by C205 on 10/01/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"
#import "Config.h"

@protocol SettingsVCDelegate <NSObject>

@optional

- (void)newRecording;
- (void)saveRoadbook;
- (void)clickedOnLogout;
- (void)clearOverlay;
- (void)navigateToOverlayMap;

@end

typedef enum {
    OverlayStatusNotApplicable = 0,
    OverlayStatusShow,
    OverlayStatusHide
} OverlayStatus;

@interface SettingsVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) CurrentMapStyle curMapStyle;

@property (weak, nonatomic) id<SettingsVCDelegate> delegate;

@property (strong, nonatomic) id overlaySender;
@property (assign, nonatomic) BOOL isRecording;
@property (assign, nonatomic) OverlayStatus currentOverlay;

@property (weak, nonatomic) IBOutlet UITableView* tblSettings;

@end
