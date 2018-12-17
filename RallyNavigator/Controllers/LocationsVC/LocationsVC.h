//
//  ViewController.h
//  RallyNavigator
//
//  Created by C205 on 19/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Route.h"
#import "CDRoute.h"

@import Mapbox;

typedef enum
{
    TableViewSectionCurrentState = 0,
    TableViewSectionWayPoints,
    TableViewSectionFooter
}TableViewSection;

typedef enum
{
    ViewingPreferenceCurrentLocationNorthUp = 0,
    ViewingPreferenceCurrentLocationTrackUp,
    ViewingPreferenceRouteNorthUp
}ViewingPreference;

@interface LocationsVC : BaseVC <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate>

@property (assign, nonatomic) ViewType currentViewType;
@property (assign, nonatomic) ViewingPreference currentPreference;

@property (nonatomic, strong) NSURL *myMapBoxType;

@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tblLocations;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnAddWayPoint;
@property (weak, nonatomic) IBOutlet MGLMapView *mapBoxView;
@property (weak, nonatomic) IBOutlet UIButton *btnViewPreference;
@property (weak, nonatomic) IBOutlet UIButton *btnMapType;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeView;

@property (strong, nonatomic) NSString *strFolderId;
@property (strong, nonatomic) NSString *strRouteIdentifier;
@property (strong, nonatomic) CDRoute *objRoute;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMapView;

@property (assign, nonatomic) WayPointType currentWayPointType;
@property (assign, nonatomic) DistanceUnitsType currentDistanceUnitsType;

@property (assign, nonatomic) BOOL isFirstTime;
@property (strong, nonatomic) NSString *strRouteName;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) AVAudioPlayer *player;

@property (strong, nonatomic) IBOutlet UIButton *btnRecording;
@property (strong, nonatomic) IBOutlet UIButton *btnCamera;
@property (strong, nonatomic) IBOutlet UIButton *btnText;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthBtnAdd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthBtnText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthBtnImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthBtnRecording;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (weak, nonatomic) NSString *recorderFilePath;

- (void)saveRoadBookForLocation:(CLLocation *)location
                forWayPointType:(WayPointType)wpType
                      withValue:(NSUInteger)value
                  withImageData:(NSData *)imageData
                  withAudioData:(NSData *)audData
                  isWSFirstTime:(BOOL)isWSFirstTime
                       withDesc:(NSString *)strDes;

- (void)didCapturedImage:(NSData *)imageData;
- (void)didPickRoadbookWithId:(NSString *)strRoadbookId;

@end

