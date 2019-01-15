//
//  ViewController.m
//  RallyNavigator
//
//  Created by C205 on 19/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

@import AVFoundation;

#import "LocationsVC.h"
#import "ImagePreviewVC.h"
#import "LocationCell.h"
#import "AVCamPreviewView.h"
#import "AVCamPhotoCaptureDelegate.h"
#import "TrojanAudioRecorder.h"
#import "UIViewController+MJPopupViewController.h"
#import "Locations.h"
#import "RouteDetails.h"
#import "Waypoints.h"
#import "GravelLine.h"
#import "Td.h"
#import "VoiceNote.h"
#import "Backgroundimage.h"
#import "Config.h"
#import "Accuracy.h"
#import "CDSyncData.h"
#import "ReachabilityManager.h"
#import "LocationArrayHandler.h"
#import "SettingsVC.h"
#import "RoadBooksVC.h"
#import "AddRoadBookVC.h"
#import <AudioToolbox/AudioToolbox.h>

#import <Speech/Speech.h>

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees) / 180.0)
#define RADIANS_TO_DEGREES(radians) ((radians * 180.0) / M_PI)
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

static void* SessionRunningContext = &SessionRunningContext;
static const int WAYPOINT_DISTANCE = 50;

typedef NS_ENUM(NSInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

typedef NS_ENUM(NSInteger, AVCamLivePhotoMode) {
    AVCamLivePhotoModeOn,
    AVCamLivePhotoModeOff
};

typedef NS_ENUM(NSInteger, AVCamDepthDataDeliveryMode) {
    AVCamDepthDataDeliveryModeOn,
    AVCamDepthDataDeliveryModeOff
};

@interface AVCaptureDeviceDiscoverySession (Utilities)

- (NSInteger)uniqueDevicePositionsCount;

@end

@implementation AVCaptureDeviceDiscoverySession (Utilities)

- (NSInteger)uniqueDevicePositionsCount
{
    NSMutableArray<NSNumber*>* uniqueDevicePositions = [NSMutableArray array];

    for (AVCaptureDevice* device in self.devices) {
        if (![uniqueDevicePositions containsObject:@(device.position)]) {
            [uniqueDevicePositions addObject:@(device.position)];
        }
    }

    return uniqueDevicePositions.count;
}

@end

@interface CustomUserLocationAnnotationView : MGLUserLocationAnnotationView

@property (nonatomic) CGFloat size;
@property (nonatomic) UIImageView* imgView;

@end

@implementation CustomUserLocationAnnotationView

- (instancetype)init
{
    self.size = 20;
    self = [super initWithFrame:CGRectMake(0, 0, self.size, self.size)];

    return self;
}

- (void)update
{
    if (CLLocationCoordinate2DIsValid(self.userLocation.coordinate)) {
    }
}

- (void)setupLayers
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.image = [UIImage imageNamed:@"imgWay_Point"];
        [self addSubview:_imgView];
    }
}

@end

@interface LocationsVC () <TrojanAudioRecorderDelegate, AVCapturePhotoCaptureDelegate, SettingsVCDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, RoadBooksVCDelegate, MGLMapViewDelegate> {
    NSUInteger counter;
    CGFloat curZoomLevel;

    User* objUser;
    Config* objConfig;
    MGLPointAnnotation* userLocationMarker;

//    BOOL isAdd; // defines whether to add location as way point or it will be track point
    BOOL isStart; // defines whether to start recording track
    BOOL isLoaded; // defines whether the old data is loaded
    BOOL isCapturing;
    BOOL isAutoPhotoEnabled;
    BOOL isBack;
    BOOL isEditEnabled;
    BOOL isWayPointAdded; // Used to identify Tulip Angle
    BOOL isTempWayPointAdded; // Used to identify Tulip Angle
    BOOL isViewLoadFirstTime;
    BOOL isRecordingStarted;
    BOOL isAddWayPointClick;
    BOOL isPaused;
    BOOL isLocationAllowed;
    BOOL isAddedWayPointForPolyline;
    BOOL isRegisteredAsCaptureObserver;

    AVAudioSession* audioSession;

    id overlaySender;
    NSString* overlayName;

    double totalDistance;
    double preDistance;
    UIButton* btnFlashing;

    UIImage* imgCaptured;
    NSData* audioData;
    NSString* strWayPointDescription;

    UIImage* imgEditCaptured;
    NSData* audioEditData;
    NSString* strEditWayPointDescription;

    CLLocation* currentLocation;
    CLLocation* tempCurrentLocation;

    NSIndexPath* selectedIndexPath;
    AVCaptureSession* photoSession;

    NSMutableArray* arrAllLocations;
    NSMutableArray* arrAllTempLocations;
    NSMutableArray* arrRemainingTracks;
    NSMutableArray* arrTempRemainingTracks;

    NSMutableArray* arrMapBoxMarkers;
    NSMutableArray* arrMapBoxMarkers1;

    CLLocationDirection bearingDirection;
    UIBarButtonItem* btnStopAndSave;

    RouteDetails* objRouteDetails;

    MGLPolyline* poly_Line;

    MGLPolylineFeature* polylineMapBox;
    MGLPolylineFeature* o_polylineMapBox;
    MGLMapCamera* mCamera;

    //Audio Recording variable
    BOOL isRecording, isAnimate, isManual, isCancelled, isStopped;
    NSString* strMediaPath;
    NSString* strMainMediaPath;
}

@property (nonatomic, weak) IBOutlet AVCamPreviewView* previewView;
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession* session;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) AVCaptureDeviceInput* videoDeviceInput;
@property (nonatomic) AVCaptureDeviceDiscoverySession* videoDeviceDiscoverySession;
@property (nonatomic) AVCamLivePhotoMode livePhotoMode;
@property (nonatomic) AVCamDepthDataDeliveryMode depthDataDeliveryMode;
@property (nonatomic) AVCapturePhotoOutput* photoOutput;
@property (nonatomic) NSMutableDictionary<NSNumber*, AVCamPhotoCaptureDelegate*>* inProgressPhotoCaptureDelegates;
@property (nonatomic) NSInteger inProgressLivePhotoCapturesCount;
@property (nonatomic, strong) AVCaptureMovieFileOutput* movieFileOutput;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@implementation LocationsVC

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    isRecordingStarted = NO;

    self.title = _strRouteName;

    _tblLocations.transform = CGAffineTransformMakeRotation(-M_PI);
    _tblLocations.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    _btnMapType.layer.borderColor = UIColor.lightGrayColor.CGColor;
    _btnMapType.layer.borderWidth = 2.0f;
    _btnMapType.layer.cornerRadius = CGRectGetHeight(_btnMapType.frame) / 2.0f;
    _btnMapType.clipsToBounds = YES;

    objUser = GET_USER_OBJ;

    _myMapBoxType = [MGLStyle satelliteStreetsStyleURL];
    _mapBoxView.styleURL = _myMapBoxType;
    _mapBoxView.delegate = self;
    _mapBoxView.compassView.hidden = YES;
    _mapBoxView.attributionButton.hidden = YES;
    _mapBoxView.showsUserLocation = NO;
    [_mapBoxView setMinimumZoomLevel:4];
    [_mapBoxView setMaximumZoomLevel:18];

    [_mapBoxView setUserTrackingMode:MGLUserTrackingModeFollow animated:NO];

    _btnViewPreference.layer.cornerRadius = CGRectGetHeight(_btnViewPreference.frame) / 2.0f;
    _btnViewPreference.clipsToBounds = YES;
    _btnViewPreference.layer.borderColor = UIColor.lightGrayColor.CGColor;
    _btnViewPreference.layer.borderWidth = 2.0f;

    UIBarButtonItem* btnDrawer = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(iPadDevice ? @"drawer_x" : @"drawer")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(btnDrawerAction:)];
    self.navigationItem.rightBarButtonItem = btnDrawer;

    UIImage* toggleIcon = Set_Local_Image(@"icon_map_app_logo");
    UIBarButtonItem* btnToggleMap = [[UIBarButtonItem alloc] initWithImage:[toggleIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(btnToggelMapClicked:)];
    self.navigationItem.leftBarButtonItem = btnToggleMap;

    [self setUpVC];
    [self callWSToUpdate];

    dispatch_async(dispatch_get_main_queue(), ^{

        [self btnToggelMapClicked:nil];
        [self btnTogglePreferrenceClicked:nil];
        if (self.isFirstTime) {
            [self.mapBoxView setZoomLevel:16 animated:NO];
        } else {
            [self btnTogglePreferrenceClicked:nil];
        }
        self->curZoomLevel = 16.0;

        self.btnMapType.hidden = self.currentViewType == ViewTypeListView;
        self.mapBoxView.styleURL = self.myMapBoxType;
    });

    UILongPressGestureRecognizer* loGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showFullRoute)];
    [_btnViewPreference addGestureRecognizer:loGest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    isViewLoadFirstTime = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        self.view.backgroundColor = UIColor.blackColor;
        _tblLocations.backgroundColor = UIColor.blackColor;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = UIColor.lightGrayColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.lightGrayColor }];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        _tblLocations.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault; // optional
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.tintColor = UIColor.blackColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.blackColor }];
    }

    self.navigationItem.hidesBackButton = YES;

    if (arrAllLocations.count > 0) {
        [_tblLocations reloadData];
    }

    objUser = [DefaultsValues getCustomObjFromUserDefaults_ForKey:kUserObject];
    NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objUser.config];
    objConfig = [[Config alloc] initWithDictionary:jsonDict];

    NSError* error = nil;
    NSData* objectData = [objConfig.action dataUsingEncoding:NSUTF8StringEncoding];

    if (objectData) {
        NSDictionary* dicNewWayPoints = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
        isAutoPhotoEnabled = [[dicNewWayPoints valueForKey:@"autoPhoto"] boolValue];
        [self viewDidLayoutSubviews];
    }

    if (self.sessionQueue != nil) {
        [self startCameraSession];
    }

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onKeyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    if ([self isMovingFromParentViewController]) {
        if (!TARGET_OS_SIMULATOR) {
            [NSNotificationCenter.defaultCenter removeObserver:self];
            
            if (isRegisteredAsCaptureObserver) {
                [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
                isRegisteredAsCaptureObserver = NO;
            }

            if ([AppContext.audioPlayer isPlaying]) {
                [AppContext.audioPlayer stop];
                AppContext.audioPlayer = nil;
            }

            if (isRecordingStarted) {
                isCancelled = YES;
                isManual = YES;
                [self stopRecording];
            }

            self.session = nil;
            _previewView.session = nil;

            [_locationManager stopUpdatingLocation];
            [_locationManager stopUpdatingHeading];
            _locationManager = nil;
            _mapBoxView = nil;
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (_currentPreference != ViewingPreferenceRouteNorthUp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapBoxView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
        });
    }

    @autoreleasepool {
        NSError* jsonError = nil;
        NSData* objectData = [objConfig.action dataUsingEncoding:NSUTF8StringEncoding];

        if (objectData) {
            NSDictionary* dicNewWayPoints = [NSJSONSerialization JSONObjectWithData:objectData
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&jsonError];
            _btnAdd.hidden = ![[dicNewWayPoints valueForKey:@"waypointOnly"] boolValue];
            _btnText.hidden = ![[dicNewWayPoints valueForKey:@"text"] boolValue];
            _btnRecording.hidden = ![[dicNewWayPoints valueForKey:@"voiceRecorder"] boolValue];
            _btnCamera.hidden = ![[dicNewWayPoints valueForKey:@"takePicture"] boolValue] || [[dicNewWayPoints valueForKey:@"autoPhoto"] boolValue];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showFullRoute
{
    if (_currentPreference == ViewingPreferenceRouteNorthUp) {
        mCamera = nil;
        [self focusMapToShowAllMarkersWithAnimate:YES];
        [_mapBoxView resetNorth];
        MGLMapCamera* camera = _mapBoxView.camera;
        camera.pitch = 0;
        _mapBoxView.camera = camera;
    }
}

#pragma mark - WS Call

- (void)callWSToUpdate
{
    if (_strRouteIdentifier == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.btnAdd.enabled = !self.isFirstTime;
            self.btnRecording.enabled = !self.isFirstTime;
            self.btnText.enabled = !self.isFirstTime;
            self.btnCamera.enabled = !self.isFirstTime;
        });
        return;
    }

    if ([_strRouteIdentifier doubleValue] < 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.btnAdd.enabled = YES;
            self.btnRecording.enabled = YES;
            self.btnText.enabled = YES;
            self.btnCamera.enabled = YES;
        });
        return;
    }

    [[WebServiceConnector alloc] init:[[URLGetRouteDetails stringByAppendingString:@"/"] stringByAppendingString:_strRouteIdentifier]
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleRouteDetailsResponse:)
                       forServiceType:ServiceTypeGET
                       showDisplayMsg:@""
                           showLoader:NO];
}

- (void)handleRouteDetailsResponse:(id)sender
{
    @autoreleasepool {

        NSArray* arrResponse = [self validateResponse:sender
                                           forKeyName:RouteKey
                                            forObject:self
                                            showError:YES];
        if (arrResponse.count > 0) {
            Route* objRoute = [arrResponse firstObject];

            NSString* strRoadBookId = [NSString stringWithFormat:@"routeIdentifier='%f'", objRoute.routeIdentifier];
            NSArray* arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];
            NSArray* arrNonSyncData = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND isActive = 0 AND isEdit = 0", strRoadBookId]]] all];
            NSMutableArray* arrLocalNonSyncData = [self processForLocalLocationsForArray:arrNonSyncData];

            if (arrSyncedData.count > 0) {
                _objRoute = [arrSyncedData firstObject];
                [self processForLocations];

                arrAllLocations = [[NSMutableArray alloc] init];
                arrMapBoxMarkers = [[NSMutableArray alloc] init];
                [_mapBoxView removeAnnotations:_mapBoxView.annotations];

                userLocationMarker = nil;
                userLocationMarker = [[MGLPointAnnotation alloc] init];
                userLocationMarker.title = @"User Location";
                userLocationMarker.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
                [_mapBoxView addAnnotation:userLocationMarker];

                for (Waypoints* objWP in objRouteDetails.waypoints) {
                    Locations* objLocation = [[Locations alloc] init];
                    objLocation.locationId = arrAllLocations.count;
                    objLocation.latitude = objWP.lat;
                    objLocation.longitude = objWP.lon;
                    objLocation.text = objWP.wayPointDescription;
                    objLocation.isWayPoint = objWP.show;
                    objLocation.imageUrl = objWP.backgroundimage.url;
                    objLocation.audioUrl = objWP.voiceNote.url;
                    [arrAllLocations addObject:objLocation];
                    if (objLocation.isWayPoint) {
                        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                        marker1.coordinate = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);
                        marker1.title = @"Test Name";
                        [_mapBoxView addAnnotation:marker1];
                        [arrMapBoxMarkers addObject:marker1];
                    }
                }
            }

            NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [arrLocalNonSyncData count])];
            [arrAllLocations insertObjects:[[arrLocalNonSyncData reverseObjectEnumerator] allObjects] atIndexes:indexes];
            [self setUpLocationId];
            [self setLocationDistance];
            [self focusMapToShowAllMarkersWithAnimate:YES];

            [self managePolyline];

            counter = arrAllLocations.count;
            isViewLoadFirstTime = YES;
            [_tblLocations reloadData];
        } else {
            [self showErrorInObject:self forDict:[sender responseDict]];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnAdd.enabled = YES;
        self.btnRecording.enabled = YES;
        self.btnText.enabled = YES;
        self.btnCamera.enabled = YES;
    });
}

#pragma mark - Set Up

- (void)setUpVC
{
    arrAllLocations = [[NSMutableArray alloc] init];
    arrAllTempLocations = [[NSMutableArray alloc] init];
    arrRemainingTracks = [[NSMutableArray alloc] init];
    arrTempRemainingTracks = [[NSMutableArray alloc] init];
    arrMapBoxMarkers = [[NSMutableArray alloc] init];

    [_mapBoxView removeAnnotations:_mapBoxView.annotations];
    userLocationMarker = nil;
    userLocationMarker = [[MGLPointAnnotation alloc] init];
    userLocationMarker.title = @"User Location";
    userLocationMarker.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [_mapBoxView addAnnotation:userLocationMarker];

    @autoreleasepool {

        NSMutableArray* arrLocalNonSyncData = [[NSMutableArray alloc] init];

        if (!_isFirstTime) {
            NSString* strRoadBookId = [NSString stringWithFormat:@"routeIdentifier = %@", _strRouteIdentifier];
            NSArray* arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];
            NSArray* arrNonSyncData = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND isActive = 0 AND isEdit = 0", strRoadBookId]]] all];
            arrLocalNonSyncData = [self processForLocalLocationsForArray:arrNonSyncData];

            if (arrSyncedData.count > 0) {
                _objRoute = arrSyncedData[0];
                [self processForLocations];
            }
        }

        if (!isLoaded) {
            isLoaded = YES;

            for (Waypoints* objWP in objRouteDetails.waypoints) {
                Locations* objLocation = [[Locations alloc] init];
                objLocation.locationId = arrAllLocations.count;
                objLocation.latitude = objWP.lat;
                objLocation.longitude = objWP.lon;
                objLocation.text = objWP.wayPointDescription;
                objLocation.isWayPoint = objWP.show;
                objLocation.imageUrl = objWP.backgroundimage.url;
                objLocation.audioUrl = objWP.voiceNote.url;
                [arrAllLocations addObject:objLocation];
                if (objLocation.isWayPoint) {
                    MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                    marker1.coordinate = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);
                    marker1.title = @"Test Name";
                    [_mapBoxView addAnnotation:marker1];
                    [arrMapBoxMarkers addObject:marker1];
                }
            }

            counter = arrAllLocations.count;
        }

        NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [arrLocalNonSyncData count])];
        [arrAllLocations insertObjects:[[arrLocalNonSyncData reverseObjectEnumerator] allObjects] atIndexes:indexes];
        [self setUpLocationId];
        [self setLocationDistance];
        [self startStandardUpdates];
        [self focusMapToShowAllMarkersWithAnimate:YES];
        [self managePolyline];

        if (![[WebServiceConnector alloc] checkNetConnection] && !_isFirstTime) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.btnAdd.enabled = YES;
                self.btnRecording.enabled = YES;
                self.btnText.enabled = YES;
                self.btnCamera.enabled = YES;
            });
        }
    }
}

- (void)setUpLocationId
{
    if (arrAllLocations.count == 0) {
        return;
    }

    for (int i = 0; i < arrAllLocations.count; i++) {
        Locations* objLocation = [arrAllLocations objectAtIndex:i];
        objLocation.locationId = (arrAllLocations.count - i - 1);
        [arrAllLocations replaceObjectAtIndex:i withObject:objLocation];
    }

    @autoreleasepool {
        NSString* strRoadBookId = [NSString stringWithFormat:@"routeIdentifier='%@'", _strRouteIdentifier];
        NSArray* arrNonSyncData = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND isActive = 0 AND isEdit = 1", strRoadBookId]]] all];

        for (CDSyncData* objData in arrNonSyncData) {
            NSDictionary* dic = [RallyNavigatorConstants convertJsonStringToObject:objData.jsonData];
            NSString* strWayPointId = [dic valueForKey:@"wayPointId"];
            NSString* strWayPointDesc = [dic valueForKey:@"wayPointDesc"];

            NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
                return objLocation.locationId == [strWayPointId doubleValue];
            }];

            NSMutableArray* arrSearchResults = [[NSMutableArray alloc] init];
            arrSearchResults = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

            if (arrSearchResults.count > 0) {
                NSUInteger index = [arrAllLocations indexOfObject:[arrSearchResults firstObject]];

                Locations* objLocation = [arrSearchResults firstObject];
                objLocation.text = strWayPointDesc;

                @try {
                    if (objData.imageData.length > 0) {
                        NSData* data = [[NSData alloc] initWithBase64EncodedString:objData.imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        UIImage* img = [UIImage imageWithData:data];
                        objLocation.photos = @[ img ];
                    }

                    if (objData.voiceData.length > 0) {
                        NSData* data = [[NSData alloc] initWithBase64EncodedString:objData.voiceData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        objLocation.audios = @[ data ];
                    }
                } @catch (NSException* exception) {
                } @finally {
                }

                [arrAllLocations replaceObjectAtIndex:index withObject:objLocation];
            }
        }
    }
}

- (void)setLocationDistance
{
    totalDistance = 0.0;
    preDistance = 0.0;

    for (NSInteger i = arrAllLocations.count - 1; i > 0; i--) {
        Locations* objLocation1 = arrAllLocations[i];
        Locations* objLocation2 = arrAllLocations[i - 1];

        CLLocation* objLoc1 = [[CLLocation alloc] initWithLatitude:objLocation1.latitude longitude:objLocation1.longitude];
        CLLocation* objLoc2 = [[CLLocation alloc] initWithLatitude:objLocation2.latitude longitude:objLocation2.longitude];

        totalDistance += [objLoc1 distanceFromLocation:objLoc2];
        preDistance += [objLoc1 distanceFromLocation:objLoc2];

        if (objLocation2.isWayPoint) {
            preDistance = 0.0;
        }
    }

    if (preDistance > 0) {
        totalDistance -= preDistance;
    }

    if (arrAllLocations.count > 0) {
        Locations* objLoca1 = arrAllLocations[0];

        CLLocation* objLoc1 = [[CLLocation alloc] initWithLatitude:objLoca1.latitude longitude:objLoca1.longitude];

        if (currentLocation != nil) {
            preDistance += [objLoc1 distanceFromLocation:currentLocation];
        }

        totalDistance += preDistance;
    }

    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    double val = 0;

    if ([objConfig.unit isEqualToString:@"Kilometers"]) {
        val = 1.0f;
    } else {
        val = 0.62f;
    }

    cell.lblDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:totalDistance * val] doubleValue]];
    cell.lblPerDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:preDistance * val] doubleValue]];
}

- (void)processForLocations
{
    NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:_objRoute.data];
    objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];
    objRouteDetails.waypoints = [[objRouteDetails.waypoints reverseObjectEnumerator] allObjects];
}

- (NSMutableArray*)processForLocalLocationsForArray:(NSArray*)arrLocalLocations
{
    @autoreleasepool {
        NSMutableArray* arrLData = [[NSMutableArray alloc] init];

        for (int i = 0; i < arrLocalLocations.count; i++) {
            // TO DO: MAKE CHANGES
            CDSyncData* objSync = [arrLocalLocations objectAtIndex:i];

            id object = [[RallyNavigatorConstants convertJsonStringToObject:objSync.jsonData] mutableCopy];

            if ([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary* arrOperations = object;
                RouteDetails* obj = [[RouteDetails alloc] initWithDictionary:arrOperations];
                Waypoints* objRoute = obj.waypoints[0];
                Locations* objLocation = [[Locations alloc] init];
                objLocation.locationId = arrAllLocations.count;
                objLocation.latitude = objRoute.lat;
                objLocation.longitude = objRoute.lon;
                objLocation.text = objRoute.wayPointDescription;
                objLocation.isWayPoint = objRoute.show;
                objLocation.imageUrl = objRoute.backgroundimage.url;
                objLocation.audioUrl = objRoute.voiceNote.url;

                @try {
                    if (objSync.imageData.length > 0) {
                        NSData* data = [[NSData alloc] initWithBase64EncodedString:objSync.imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        UIImage* img = [UIImage imageWithData:data];
                        objLocation.photos = @[ img ];
                    }

                    if (objSync.voiceData.length > 0) {
                        NSData* data = [[NSData alloc] initWithBase64EncodedString:objSync.voiceData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        objLocation.audios = @[ data ];
                    }
                } @catch (NSException* exception) {
                } @finally {
                }

                [arrLData addObject:objLocation];

                if (objLocation.isWayPoint) {
                    MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                    marker1.coordinate = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);
                    marker1.title = @"Test Name";
                    [_mapBoxView addAnnotation:marker1];
                    [arrMapBoxMarkers addObject:marker1];
                }
            } else {
                NSMutableArray* arrOperations = [object mutableCopy];
                for (NSDictionary* dic in arrOperations) {
                    if ([dic objectForKey:@"op"]) {
                        if ([[dic valueForKey:@"op"] isEqualToString:@"add"]) {
                            Waypoints* objRoute = [[Waypoints alloc] initWithDictionary:[dic valueForKey:@"value"]];
                            Locations* objLocation = [[Locations alloc] init];
                            objLocation.locationId = arrAllLocations.count;
                            objLocation.latitude = objRoute.lat;
                            objLocation.longitude = objRoute.lon;
                            objLocation.text = objRoute.wayPointDescription;
                            objLocation.isWayPoint = objRoute.show;
                            objLocation.imageUrl = objRoute.backgroundimage.url;
                            objLocation.audioUrl = objRoute.voiceNote.url;

                            @try {
                                if (objSync.imageData.length > 0) {
                                    NSData* data = [[NSData alloc] initWithBase64EncodedString:objSync.imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                    UIImage* img = [UIImage imageWithData:data];
                                    objLocation.photos = @[ img ];
                                }

                                if (objSync.voiceData.length > 0) {
                                    NSData* data = [[NSData alloc] initWithBase64EncodedString:objSync.voiceData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                    objLocation.audios = @[ data ];
                                }
                            } @catch (NSException* exception) {
                            } @finally {
                            }

                            [arrLData addObject:objLocation];

                            if (objLocation.isWayPoint) {
                                MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                                marker1.coordinate = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);
                                marker1.title = @"Test Name";
                                [_mapBoxView addAnnotation:marker1];
                                [arrMapBoxMarkers addObject:marker1];
                            }
                        }
                    }
                }
            }
        }

        return arrLData;
    }
}

- (IBAction)triggerAction:(NSNotification*)sender
{
    //    dispatch_async(dispatch_get_main_queue(), ^{

    if (_strRouteIdentifier == nil) {
        return;
    }

    NSDictionary* dicUserInfo = sender.userInfo;

    if ([[dicUserInfo valueForKey:@"oldId"] isEqualToString:_strRouteIdentifier]) {
        _strRouteIdentifier = [dicUserInfo valueForKey:@"newId"];
    }
    //    });
}

- (void)managePolyline
{
    if (poly_Line) {
        [_mapBoxView removeAnnotation:poly_Line];
    }

    poly_Line = nil;

    if (isPaused) {
        CLLocationCoordinate2D coord[1];
        coord[0] = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);

        if (poly_Line) {
            [poly_Line appendCoordinates:coord count:1];
        } else {
            poly_Line = [MGLPolyline polylineWithCoordinates:coord count:1];
            [_mapBoxView addAnnotation:poly_Line];
        }

        for (Locations* objLocation in arrAllTempLocations) {
            CLLocationCoordinate2D coord[1];

            coord[0] = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);

            if (poly_Line) {
                [poly_Line appendCoordinates:coord count:1];
            } else {
                poly_Line = [MGLPolyline polylineWithCoordinates:coord count:1];
                [_mapBoxView addAnnotation:poly_Line];
            }
        }
    }

    if (currentLocation != nil) {
        CLLocationCoordinate2D coord[1];

        coord[0] = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);

        if (poly_Line) {
            [poly_Line appendCoordinates:coord count:1];
        } else {
            poly_Line = [MGLPolyline polylineWithCoordinates:coord count:1];
            [_mapBoxView addAnnotation:poly_Line];
        }
    }

    for (Locations* objLocation in arrAllLocations) {
        CLLocationCoordinate2D coord[1];

        coord[0] = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);

        if (poly_Line) {
            [poly_Line appendCoordinates:coord count:1];
        } else {
            poly_Line = [MGLPolyline polylineWithCoordinates:coord count:1];
            [_mapBoxView addAnnotation:poly_Line];
        }
    }
}

- (void)focusMapToShowAllMarkersWithAnimate:(BOOL)isAnimate
{
    switch (_currentPreference) {
    case ViewingPreferenceCurrentLocationNorthUp:
    case ViewingPreferenceCurrentLocationTrackUp: {
        if (isAnimate) {
            if (_currentPreference == ViewingPreferenceCurrentLocationTrackUp) {
                [_mapBoxView setUserTrackingMode:MGLUserTrackingModeFollowWithHeading animated:NO];
            } else {
                [_mapBoxView setUserTrackingMode:MGLUserTrackingModeFollow animated:NO];
            }

            [_mapBoxView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
        }
    } break;

    case ViewingPreferenceRouteNorthUp: {
        if (isAnimate) {
            [_mapBoxView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];

            [_mapBoxView setUserTrackingMode:MGLUserTrackingModeNone animated:NO];

            if (mCamera) {
                [_mapBoxView setCamera:mCamera];
            } else {
                @autoreleasepool {
                    NSMutableArray* arrCopy = [[NSMutableArray alloc] init];
                    [arrCopy addObjectsFromArray:arrMapBoxMarkers];
                    [arrCopy addObjectsFromArray:arrMapBoxMarkers1];

                    MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                    marker1.coordinate = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
                    marker1.title = @"Test Name";
                    [arrCopy addObject:marker1];

                    [_mapBoxView showAnnotations:arrCopy animated:NO];
                }
            }
        }
    } break;

    default:
        break;
    }
}

#pragma mark - Orientation Delegate Methods

- (IBAction)orientationChanged:(id)sender
{
    @autoreleasepool {
        NSArray* arrVisibleRows = [_tblLocations visibleCells];

        for (LocationCell* cell in arrVisibleRows) {
            NSIndexPath* indexPath = [_tblLocations indexPathForCell:cell];
            [self positionShapeLayerForCell:cell andIndexPath:indexPath];
        }
    }
}

#pragma mark - KeyBoard Handling Methods

- (void)onKeyboardShow:(NSNotification*)notification
{
    if (isRecordingStarted) {
        [self btnRecordClicked:nil];
    }

    NSDictionary* userInfo = notification.userInfo;
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    CGFloat offset = 75;
    if (iPhoneDevice && SCREEN_HEIGHT == 812) {
        offset += 34;
    }
    _bottomBtnAddWayPoint.constant = kbSize.height - offset;
    [self.view layoutIfNeeded];
    [_btnMapType setHidden:YES];
    [_btnViewPreference setHidden:YES];
}

- (void)onKeyboardHidden:(NSNotification*)notification
{
    _bottomBtnAddWayPoint.constant = 0;
    [self.view layoutIfNeeded];
    _btnMapType.hidden = _currentViewType == ViewTypeListView;
    _btnViewPreference.hidden = _currentViewType == ViewTypeListView;
}

#pragma mark - Custom Methods

- (NSString*)calculateDistanceFor:(double)distance
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 2;
    formatter.roundingMode = NSNumberFormatterRoundHalfEven;

    NSString* numberString = [formatter stringFromNumber:@(distance / 1000)];

    return [numberString stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (double)angleFromCoordinate:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2
{
    lat1 = DEGREES_TO_RADIANS(lat1);
    lon1 = DEGREES_TO_RADIANS(lon1);

    lat2 = DEGREES_TO_RADIANS(lat2);
    lon2 = DEGREES_TO_RADIANS(lon2);

    double dLon = lon2 - lon1;

    double dPhi = log(tan(lat2 / 2.0 + M_PI / 4.0) / tan(lat1 / 2.0 + M_PI / 4.0));

    if (fabs(dLon) > M_PI) {
        if (dLon > 0.0) {
            dLon = -(2.0 * M_PI - dLon);
        } else {
            dLon = (2.0 * M_PI + dLon);
        }
    }

    return fmodf(RADIANS_TO_DEGREES(atan2(dLon, dPhi)) + 360.0, 360.0);
}

- (NSArray*)convertToDegreeThroughLat:(double)latitude andLong:(double)longitude
{
    int latSeconds = (int)floorf(latitude * 3600);
    int latDegrees = (int)floorf(latSeconds / 3600);
    latSeconds = abs(latSeconds % 3600);
    int latMinutes = (int)floorf(latSeconds / 60);
    latSeconds %= 60;
    int longSeconds = (int)floorf(longitude * 3600);
    int longDegrees = (int)floorf(longSeconds / 3600);

    longSeconds = abs(longSeconds % 3600);
    int longMinutes = (int)floorf(longSeconds / 60);
    longSeconds %= 60;

    NSString* str1 = [NSString stringWithFormat:@"%d°%d.%d\'%s", abs(latDegrees), latMinutes, latSeconds, latDegrees >= 0 ? "N" : "S"];
    NSString* str2 = [NSString stringWithFormat:@"%d°%d.%d\'%s", abs(longDegrees), longMinutes, longSeconds, longDegrees >= 0 ? "E" : "W"];

    return @[ str1, str2 ];
}

- (BOOL)checkForLocationPermission
{
    if (![CLLocationManager locationServicesEnabled]) {
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusRestricted:
    case kCLAuthorizationStatusDenied: {
        [AlertManager confirm:@"Turn on Location Services in Settings > Privacy to allow Rally Navigator to determine your current location"
                        title:@"Location Service Off"
                     negative:@"SETTINGS"
                     positive:@"OK"
                   onNegative:^{
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                              options:@{}
                                                    completionHandler:nil];
                       });
                   }
                   onPositive:NULL];

        return NO;
    } break;

    default:
        break;
    }

    return YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    if (isEditEnabled) {
        return;
    }

    isViewLoadFirstTime = NO;
    NSArray* arrV_Cells = [self visibleIndexPathIncludingPartials:NO];

    NSIndexPath* lastIndexPath = [arrV_Cells firstObject];

    if (lastIndexPath.section == TableViewSectionCurrentState) {
        if (selectedIndexPath != nil) {
            LocationCell* cell = [_tblLocations cellForRowAtIndexPath:selectedIndexPath];
            [cell.btnEdit setHidden:YES];
            [cell.lblDistanceUnit setHidden:YES];
        }

        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
            return objLocation.isWayPoint;
        }];

        NSMutableArray* arrSearchResults = [[NSMutableArray alloc] init];
        arrSearchResults = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

        if (arrSearchResults.count > 0) {
            selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:TableViewSectionWayPoints];
            LocationCell* cell = [_tblLocations cellForRowAtIndexPath:selectedIndexPath];
            [cell.btnEdit setHidden:NO];
            [cell.lblDistanceUnit setHidden:YES];
        }

        return;
    }

    if (selectedIndexPath != nil) {
        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:selectedIndexPath];
        [cell.btnEdit setHidden:YES];
    }

    selectedIndexPath = lastIndexPath;
    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:lastIndexPath];
    [cell.btnEdit setHidden:NO];
    [cell.lblDistanceUnit setHidden:YES];
}

- (NSArray*)visibleIndexPathIncludingPartials:(BOOL)includePartials
{
    NSArray* result = [_tblLocations indexPathsForVisibleRows];

    if (includePartials) {
        return result;
    }

    NSMutableArray* mutableResult = [NSMutableArray array];

    for (NSIndexPath* indexPath in result) {
        CGRect cellRect = [_tblLocations rectForRowAtIndexPath:indexPath];

        if (!CGRectIsEmpty(cellRect)) {
            CGRect rectInTableView = [_tblLocations convertRect:cellRect toView:_tblLocations.superview];

            if (rectInTableView.origin.y < 0.0) {
                continue;
            }

            if (self.navigationController && !self.navigationController.navigationBar.isHidden) {
                if (rectInTableView.origin.y < CGRectGetMaxY(self.navigationController.navigationBar.frame)) {
                    continue;
                }
            }

            if (CGRectGetMaxY(rectInTableView) > CGRectGetMaxY(_tblLocations.superview.bounds)) {
                continue;
            }
        } else {
            continue;
        }

        [mutableResult addObject:indexPath];
    }

    result = mutableResult;
    return result;
}

- (void)playAudio:(NSString*)strFileName fileType:(NSString*)strFileType
{
    [self.session stopRunning];

    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:strFileName ofType:strFileType];
    NSURL* soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];

    if (error != nil) {
        NSLog(@"ERROR: %@", error.localizedDescription);
        return;
    }

    self.player.numberOfLoops = 0;
    self.player.delegate = self;
    self.player.volume = 1.0;

    AVAudioSession* audioSession = [AVAudioSession sharedInstance];

    [audioSession setCategory:AVAudioSessionCategoryAmbient error:NULL];
    [audioSession setActive:YES error:NULL];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];

    [self.player play];
    @try {
        [self.session startRunning];
    } @catch (NSException* exception) {
    } @finally {
    }
}

- (NSAttributedString*)moveDegreeSymbolUp:(NSString*)str
{
    CGFloat fontSize = iPadDevice ? 16.0f : 13.0f;

    UIFont* fnt = [UIFont systemFontOfSize:fontSize];
    NSString* strAngel = [NSString stringWithFormat:@" %@", str];
    NSCharacterSet* characterset = [NSCharacterSet characterSetWithCharactersInString:@"°"];
    NSRange range = [strAngel rangeOfCharacterFromSet:characterset];
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", str]
                                                                                         attributes:@{ NSFontAttributeName : [fnt fontWithSize:fontSize] }];
    [attributedString setAttributes:@{ NSFontAttributeName : [fnt fontWithSize:fontSize],
        NSBaselineOffsetAttributeName : @5 }
                              range:NSMakeRange(range.location, 1)];

    return attributedString;
}

#pragma mark - Audio Recording Methods

- (void)ConfigureAudioRecord:(double)locationId
{
    strMainMediaPath = [NSString stringWithFormat:@"%@/%ld.m4a", DOCUMENTS_FOLDER, (long)locationId];
    strMediaPath = [NSString stringWithFormat:@"%@/%ld_temp.m4a", DOCUMENTS_FOLDER, (long)locationId];

    if ([self isFileExists]) {
        [self removeFile];
    }

    if ([self isMainFileExists]) {
        [self removeMainFile];
    }

    [self RecordClicked];
}

- (BOOL)isFileExists
{
    NSString* filePath = strMediaPath;

    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (BOOL)isMainFileExists
{
    NSString* filePath = strMainMediaPath;

    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (void)removeFile
{
    NSError* error = nil;

    NSURL* url = [NSURL fileURLWithPath:strMediaPath];

    NSData* audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&error];

    if (!audioData)
        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);

    NSFileManager* fileManager = [NSFileManager defaultManager];

    error = nil;

    [fileManager removeItemAtPath:[url path] error:&error];

    if (error)
        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

- (void)removeMainFile
{
    NSError* error = nil;

    NSURL* url = [NSURL fileURLWithPath:strMainMediaPath];

    NSData* audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&error];

    if (!audioData)
        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);

    NSFileManager* fileManager = [NSFileManager defaultManager];

    error = nil;

    [fileManager removeItemAtPath:[url path] error:&error];

    if (error)
        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

- (void)RecordClicked
{
    [self.view endEditing:YES];

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {

        if (granted) {
            self->isRecording = !self->isRecording;
            self->isAnimate = self->isRecording;

            if (self->isRecording) {
                [self startRecording];
            } else {
                self->isManual = YES;
                [self stopRecording];
            }
        } else {
            return;
        }
    }];
}

- (void)startRecording
{
    if ([self isFileExists]) {
        [self removeFile];
    }

    NSError* error = nil;

    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];

    if (error) {
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }

    [audioSession setActive:YES error:&error];

    error = nil;

    if (error) {
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }

    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];

    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    // Create a new dated file
    _recorderFilePath = strMediaPath;

    error = nil;

    NSURL* url = [NSURL fileURLWithPath:_recorderFilePath];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    if (!_recorder) {
        NSLog(@"recorder: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);

        [AlertManager alert:[error localizedDescription] title:@"Warning" imageName:@"ic_error" onConfirm:NULL];
        return;
    }

    [_recorder setDelegate:self];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder recordForDuration:(NSTimeInterval)10];
}

- (void)stopRecording
{
    [_recorder stop];
}

#pragma mark - UITextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView*)textView
{
    LocationCell* cell = (LocationCell*)[self getCellForClassName:NSStringFromClass([LocationCell class]) withSender:textView];
    [_tblLocations scrollToRowAtIndexPath:[_tblLocations indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    if (!isPaused && [[_tblLocations indexPathForCell:cell] compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        isPaused = YES;
        isTempWayPointAdded = YES;

        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
        marker1.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        marker1.title = @"Test Name";
        [_mapBoxView addAnnotation:marker1];
        [arrMapBoxMarkers addObject:marker1];
        isAddedWayPointForPolyline = YES;

        [self focusMapToShowAllMarkersWithAnimate:YES];
    }
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([[textView text] length] - range.length + text.length > 64) {
        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView*)textView
{
    if (textView.tag == -1) {
        strWayPointDescription = textView.text;

        LocationCell* cell = (LocationCell*)[self getCellForClassName:NSStringFromClass([LocationCell class]) withSender:textView];
        cell.imgWayPoint.hidden = NO;

        if ([[_tblLocations indexPathForCell:cell] isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
            [_btnAdd setEnabled:FALSE];

            [cell.lblDistanceUnit setHidden:YES];
            [cell.btnEdit setHidden:NO];
            [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        }
    } else {
        strEditWayPointDescription = textView.text;
    }

    LocationCell* cell = (LocationCell*)[self getCellForClassName:NSStringFromClass([LocationCell class]) withSender:textView];
    cell.imgWayPoint.hidden = textView.text.length > 0;
}

- (void)textViewDidEndEditing:(UITextView*)textView
{
    LocationCell* cell = (LocationCell*)[self getCellForClassName:NSStringFromClass([LocationCell class]) withSender:textView];
    cell.imgWayPoint.hidden = NO;

    if ([[_tblLocations indexPathForCell:cell] isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        [_btnAdd setEnabled:FALSE];

        [cell.lblDistanceUnit setHidden:YES];
        [cell.btnEdit setHidden:NO];
        [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
    }
}

#pragma mark - MapBox Events

- (void)mapViewDidFinishLoadingMap:(MGLMapView*)mapView
{
    if (_isFirstTime) {
        [_mapBoxView setZoomLevel:curZoomLevel animated:YES];
    }
}

- (void)mapView:(MGLMapView*)mapView regionIsChangingWithReason:(MGLCameraChangeReason)reason
{
    if (_currentPreference == ViewingPreferenceRouteNorthUp) {
        CGFloat angle = 360 - _mapBoxView.camera.heading;
        _btnViewPreference.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
    } else {
        [_mapBoxView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
    }
}

- (void)mapView:(MGLMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_currentPreference == ViewingPreferenceRouteNorthUp) {
        CGFloat angle = 360 - _mapBoxView.camera.heading;
        _btnViewPreference.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
    }
}

- (MGLAnnotationImage*)mapView:(MGLMapView*)mapView imageForAnnotation:(id<MGLAnnotation>)annotation
{
    MGLAnnotationImage* annotationImage;

    if ([annotation.title isEqualToString:@"Test Name"]) {
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"pisa"];
        if (!annotationImage) {
            UIImage* image = [UIImage imageNamed:@"imgWay_Point"];
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height / 2, 0)];
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"pisa"];
        }
    } else if ([annotation.title isEqualToString:@"User Location"]) {
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"pisa2"];
        if (!annotationImage) {
            UIImage* image = [UIImage imageNamed:@"Current_Location"];
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height / 2, 0)];
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"pisa2"];
        }
    } else {
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"pisa1"];
        if (!annotationImage) {
            UIImage* image = [UIImage imageNamed:@"imgHexa_Point"];
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height / 2, 0)];
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"pisa1"];
        }
    }

    return annotationImage;
}

- (BOOL)mapView:(MGLMapView*)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation
{
    return NO;
}

- (MGLAnnotationView*)mapView:(MGLMapView*)mapView viewForAnnotation:(id<MGLAnnotation>)annotation
{
    // Substitute our custom view for the user location annotation. This custom view is defined above.
    if ([annotation isKindOfClass:[MGLUserLocation class]]) {
        return [[CustomUserLocationAnnotationView alloc] init];
    }

    if (![annotation isKindOfClass:[MGLPointAnnotation class]]) {
        return nil;
    } else if (annotation != userLocationMarker) {
        return nil;
    }

    NSString* reuseIdentifier = [NSString stringWithFormat:@"%f", annotation.coordinate.longitude];

    MGLAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];

    if (!annotationView) {
        annotationView = [[MGLAnnotationView alloc] initWithReuseIdentifier:reuseIdentifier];
        annotationView.bounds = CGRectMake(0, 0, 40, 40);

        UIImageView* imgView = [[UIImageView alloc] initWithFrame:annotationView.bounds];
        imgView.image = [UIImage imageNamed:@"Current_Location"];
        [annotationView addSubview:imgView];
    }

    return annotationView;
}

- (CGFloat)mapView:(MGLMapView*)mapView alphaForShapeAnnotation:(MGLShape*)annotation
{
    return 1.0f;
}

- (CGFloat)mapView:(MGLMapView*)mapView lineWidthForPolylineAnnotation:(MGLPolyline*)annotation
{
    return 3.0f;
}

- (UIColor*)mapView:(MGLMapView*)mapView strokeColorForShapeAnnotation:(MGLShape*)annotation
{
    if ([annotation isEqual:poly_Line]) {
        return [UIColor redColor];
    } else {
        return [UIColor yellowColor];
    }
}

#pragma mark - Location Manager Services

- (void)startStandardUpdates
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
    }

    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }

    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;

    _locationManager.pausesLocationUpdatesAutomatically = NO;

    if ([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }

    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations
{
    if (!isLocationAllowed) {
        isLocationAllowed = YES;

        if (self.sessionQueue == nil) {
            [self configureVCForCamera];
            [self startCameraSession];
        } else {
            [self configureVCForCamera];
        }
    }

    CLLocation* location = [locations lastObject];

    if (userLocationMarker == nil) {
        userLocationMarker = [[MGLPointAnnotation alloc] init];
        userLocationMarker.title = @"User Location";
        [_mapBoxView addAnnotation:userLocationMarker];
    }

    userLocationMarker.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);

    if (isPaused) {
        [self focusMapToShowAllMarkersWithAnimate:(_currentPreference != ViewingPreferenceRouteNorthUp)];

        if (!isAddedWayPointForPolyline) {
            CLLocationCoordinate2D coord[1];
            coord[0] = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            NSRange range = NSMakeRange(0, 1);
            [poly_Line replaceCoordinatesInRange:range withCoordinates:coord];
        } else {
            isAddedWayPointForPolyline = NO;
            CLLocationCoordinate2D coord[1];
            coord[0] = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            [poly_Line insertCoordinates:coord count:1 atIndex:0];
        }

        tempCurrentLocation = location;

        CLLocation* lastLocation;

        if (arrAllTempLocations.count > 0) {
            Locations* objLastWayPoint = [arrAllTempLocations firstObject];
            lastLocation = [[CLLocation alloc] initWithLatitude:objLastWayPoint.latitude longitude:objLastWayPoint.longitude];
        } else {
            lastLocation = currentLocation;
        }

        if ([lastLocation distanceFromLocation:location] < 3) {
            return;
        }

        if (arrAllTempLocations.count > 1) {
            Locations* objLastWayPoint = [arrAllTempLocations firstObject];

            Locations* objLast2WayPoint = arrAllTempLocations[1];

            CGFloat prevAngle = [self angleFromCoordinate:objLast2WayPoint.latitude
                                                     lon1:objLast2WayPoint.longitude
                                                     lat2:objLastWayPoint.latitude
                                                     lon2:objLastWayPoint.longitude];

            CGFloat curAngle = [self angleFromCoordinate:objLastWayPoint.latitude
                                                    lon1:objLastWayPoint.longitude
                                                    lat2:location.coordinate.latitude
                                                    lon2:location.coordinate.longitude];

            if (fabs((prevAngle - curAngle)) < 1) {
                return;
            }
        } else if (arrAllTempLocations.count == 1) {
            Locations* objLast2WayPoint = arrAllTempLocations[0];

            CGFloat prevAngle = [self angleFromCoordinate:objLast2WayPoint.latitude
                                                     lon1:objLast2WayPoint.longitude
                                                     lat2:tempCurrentLocation.coordinate.latitude
                                                     lon2:tempCurrentLocation.coordinate.longitude];

            CGFloat curAngle = [self angleFromCoordinate:tempCurrentLocation.coordinate.latitude
                                                    lon1:tempCurrentLocation.coordinate.longitude
                                                    lat2:location.coordinate.latitude
                                                    lon2:location.coordinate.longitude];

            if (fabs((prevAngle - curAngle)) < 1) {
                return;
            }
        } else {
            CGFloat prevAngle = [self angleFromCoordinate:tempCurrentLocation.coordinate.latitude
                                                     lon1:tempCurrentLocation.coordinate.longitude
                                                     lat2:currentLocation.coordinate.latitude
                                                     lon2:currentLocation.coordinate.longitude];

            CGFloat curAngle = [self angleFromCoordinate:currentLocation.coordinate.latitude
                                                    lon1:currentLocation.coordinate.longitude
                                                    lat2:tempCurrentLocation.coordinate.latitude
                                                    lon2:tempCurrentLocation.coordinate.longitude];

            if (fabs((prevAngle - curAngle)) < 1) {
                return;
            }
        }

        if (isTempWayPointAdded) {
            if ([currentLocation distanceFromLocation:tempCurrentLocation] < WAYPOINT_DISTANCE) {
                return;
            } else {
                isTempWayPointAdded = NO;
                isWayPointAdded = NO;
            }
        }

        counter++;
        Waypoints* objWayPoint = [self generateWayPointId:counter
                                                 location:tempCurrentLocation
                                          withDescription:@""
                                               isWayPoint:NO
                                           withImageArray:@[]
                                           withAudioArray:@[]
                                                 isPaused:YES];

        NSMutableDictionary* dicAdd =
            [self getSaveWayPointDictionaryForOperation:@"add"
                                                   path:[NSString stringWithFormat:@"/waypoints/%ld", (long)counter - 1]
                                                  value:[objWayPoint dictionaryRepresentation]];

        [arrTempRemainingTracks addObject:dicAdd];

        isAddedWayPointForPolyline = YES;

        return;
    } else {
        if (arrTempRemainingTracks.count > 0) {
            [arrRemainingTracks addObjectsFromArray:arrTempRemainingTracks];
            NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:
                                                  NSMakeRange(0, [arrAllTempLocations count])];
            [arrAllLocations insertObjects:arrAllTempLocations atIndexes:indexes];
            arrTempRemainingTracks = [[NSMutableArray alloc] init];
            arrAllTempLocations = [[NSMutableArray alloc] init];
        }
    }

    currentLocation = location;

    [self setLocationDistance];
    [self focusMapToShowAllMarkersWithAnimate:(_currentPreference != ViewingPreferenceRouteNorthUp)];

    if (poly_Line) {
        if (!isAddedWayPointForPolyline) {
            CLLocationCoordinate2D coord[1];
            coord[0] = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
            NSRange range = NSMakeRange(0, 1);
            [poly_Line replaceCoordinatesInRange:range withCoordinates:coord];
        } else {
            isAddedWayPointForPolyline = NO;
            CLLocationCoordinate2D coord[1];
            coord[0] = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
            [poly_Line insertCoordinates:coord count:1 atIndex:0];
        }
    }

    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    NSArray* arrResults = [self convertToDegreeThroughLat:currentLocation.coordinate.latitude andLong:currentLocation.coordinate.longitude];

    if (arrResults.count == 2) {
        cell.lblLatitude.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %@", arrResults[0]]];
        cell.lblLongitude.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %@", arrResults[1]]];
    }

    if (_isFirstTime && arrMapBoxMarkers.count == 0 && !isPaused) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            if (self->arrMapBoxMarkers.count == 0) {
                self->isPaused = YES;
                self->isTempWayPointAdded = YES;

                MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                marker1.coordinate = CLLocationCoordinate2DMake(self->currentLocation.coordinate.latitude, self->currentLocation.coordinate.longitude);
                marker1.title = @"Test Name";
                [self.mapBoxView addAnnotation:marker1];
                [self->arrMapBoxMarkers addObject:marker1];
                [self managePolyline];
                self->isAddedWayPointForPolyline = YES;

                if (self->isAutoPhotoEnabled && self->imgCaptured == nil && self.isSessionRunning) {
                    [self capturePhoto];
                } else if (!self->isAutoPhotoEnabled) {
                    [self playAudio:@"beep1_02" fileType:@"mp3"];
                }

                self.btnAdd.enabled = NO;
                self.btnRecording.enabled = YES;
                self.btnText.enabled = YES;
                self.btnCamera.enabled = YES;

                [self focusMapToShowAllMarkersWithAnimate:YES];

                LocationCell* cell = [self.tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                cell.lblDistanceUnit.hidden = YES;
                cell.btnEdit.hidden = NO;
                [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
                [self.tblLocations endUpdates];
                [self.tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });

        return;
    }

    if (_isFirstTime && arrMapBoxMarkers.count == 0) {
        return;
    }

    if (!isStart) {
        return;
    }

    Locations* objLastWayPoint = [arrAllLocations firstObject];
    CLLocation* lastLocation = [[CLLocation alloc] initWithLatitude:objLastWayPoint.latitude longitude:objLastWayPoint.longitude];
    if ([lastLocation distanceFromLocation:location] < 3) {
        return;
    }

    if (arrAllLocations.count > 1) {
        Locations* objLast2WayPoint = arrAllLocations[1];

        CGFloat prevAngle = [self angleFromCoordinate:objLast2WayPoint.latitude
                                                 lon1:objLast2WayPoint.longitude
                                                 lat2:objLastWayPoint.latitude
                                                 lon2:objLastWayPoint.longitude];

        CGFloat curAngle = [self angleFromCoordinate:objLastWayPoint.latitude
                                                lon1:objLastWayPoint.longitude
                                                lat2:location.coordinate.latitude
                                                lon2:location.coordinate.longitude];

        if (fabs((prevAngle - curAngle)) < 1) {
            return;
        }
    }

    if (isCapturing) {
        return;
    }

    if (isWayPointAdded) {
        if ([lastLocation distanceFromLocation:location] < WAYPOINT_DISTANCE) {
            return;
        } else {
            //            NSLog(@"DONE");
            isWayPointAdded = NO;
        }
    }

    counter++;
    Waypoints* objWayPoint = [self generateWayPointId:counter
                                             location:currentLocation
                                      withDescription:@""
                                           isWayPoint:NO
                                       withImageArray:@[]
                                       withAudioArray:@[]
                                             isPaused:NO];

    NSMutableDictionary* dicAdd =
        [self getSaveWayPointDictionaryForOperation:@"add"
                                               path:[NSString stringWithFormat:@"/waypoints/%ld", (long)counter - 1]
                                              value:[objWayPoint dictionaryRepresentation]];

    [arrRemainingTracks addObject:dicAdd];
    isAddedWayPointForPolyline = YES;
}

- (void)updateCapHeadingForLocation:(CLLocation*)location
{
    CGPoint centerPoint = CGPointMake((_tblLocations.frame.size.width / 2), /*55*/ 70);

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.isWayPoint;
    }];

    NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
    arrWayPoints = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

    if (arrWayPoints.count > 0) {
        Locations* objWayPoints = arrWayPoints[0];

        double curAngle = [self angleFromCoordinate:objWayPoints.latitude
                                               lon1:objWayPoints.longitude
                                               lat2:location.coordinate.latitude
                                               lon2:location.coordinate.longitude];

        double preAngle;

        NSInteger curIndex = 0;

        Locations* objLocation1;

        if (curIndex + 1 == arrAllLocations.count) {
            preAngle = curAngle;
        } else {
            objLocation1 = arrAllLocations[curIndex + 1];

            preAngle = [self angleFromCoordinate:objLocation1.latitude
                                            lon1:objLocation1.longitude
                                            lat2:objWayPoints.latitude
                                            lon2:objWayPoints.longitude];
        }

        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];

        if (preAngle > curAngle) {
            // left // minus
            float A = 360 - (ROUND_TO_NEAREST(preAngle) - ROUND_TO_NEAREST(curAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

            [cell drawDirectionPathIn:cell.contentView startPoint:centerPoint endPoint:CGPointMake(x, y)];

            float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

            float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        } else {
            // right // positive
            float A = (ROUND_TO_NEAREST(curAngle) - ROUND_TO_NEAREST(preAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

            [cell drawDirectionPathIn:cell.contentView startPoint:centerPoint endPoint:CGPointMake(x, y)];

            float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

            float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        }

        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %d° ", ROUND_TO_NEAREST(curAngle)]];
    }
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(nonnull CLHeading*)newHeading
{
    bearingDirection = newHeading.trueHeading;

    if (_currentPreference == ViewingPreferenceCurrentLocationTrackUp) {
        [self updateIconHeading];
    }
}

- (void)updateCurrentLocationCell
{
    CGPoint centerPoint = CGPointMake((_tblLocations.frame.size.width / 2), /*55*/ 70);

    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewSectionCurrentState]];

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.isWayPoint;
    }];

    NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
    arrWayPoints = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

    if (arrWayPoints.count > 0) {
        LocationCell* old_Cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewSectionWayPoints]];

        if ([old_Cell.lblAngle.text isEqualToString:@"  ---° "]) {
            double preAngle = 0;
            double curAngle = bearingDirection;

            if (preAngle > curAngle) {
                // left // minus
                float A = 360 - (ROUND_TO_NEAREST(preAngle) - ROUND_TO_NEAREST(curAngle)) - 90;
                float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
                float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

                [cell drawDirectionPathIn:cell.contentView
                               startPoint:centerPoint
                                 endPoint:CGPointMake(x, y)];

                float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
                float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

                float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
                float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

                [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
            } else {
                // right // positive
                float A = (ROUND_TO_NEAREST(curAngle) - ROUND_TO_NEAREST(preAngle)) - 90;
                float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
                float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

                [cell drawDirectionPathIn:cell.contentView
                               startPoint:centerPoint
                                 endPoint:CGPointMake(x, y)];

                float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
                float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

                float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
                float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

                [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
            }
        } else {
            NSRange r1 = [old_Cell.lblAngle.text rangeOfString:@"  "];
            NSRange r2 = [old_Cell.lblAngle.text rangeOfString:@"° "];
            NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
            NSString* sub = [old_Cell.lblAngle.text substringWithRange:rSub];

            double preAngle = [sub doubleValue];
            double curAngle = bearingDirection;

            if (preAngle > curAngle) {
                // left // minus
                float A = 360 - (ROUND_TO_NEAREST(preAngle) - ROUND_TO_NEAREST(curAngle)) - 90;
                float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
                float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

                [cell drawDirectionPathIn:cell.contentView
                               startPoint:centerPoint
                                 endPoint:CGPointMake(x, y)];

                float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
                float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

                float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
                float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

                [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
            } else {
                // right // positive
                float A = (ROUND_TO_NEAREST(curAngle) - ROUND_TO_NEAREST(preAngle)) - 90;
                float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
                float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

                [cell drawDirectionPathIn:cell.contentView
                               startPoint:centerPoint
                                 endPoint:CGPointMake(x, y)];

                float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
                float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

                float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
                float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

                [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
            }
        }
    } else {
        float A = (ROUND_TO_NEAREST(0) - ROUND_TO_NEAREST(0)) - 90;
        float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
        float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

        [cell drawDirectionPathIn:cell.contentView
                       startPoint:centerPoint
                         endPoint:CGPointMake(x, y)];

        float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
        float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

        float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
        float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

        [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
    }

    cell.lblAngle.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %d° ", ROUND_TO_NEAREST(bearingDirection)]];
}

- (void)updateIconHeading
{
    float oldRad = -_locationManager.heading.trueHeading * M_PI / 180.0f;
    float newRad = -bearingDirection * M_PI / 180.0f;
    CABasicAnimation* theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:oldRad];
    theAnimation.toValue = [NSNumber numberWithFloat:newRad];
    theAnimation.duration = 0.3f;
    [_btnViewPreference.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    _btnViewPreference.transform = CGAffineTransformMakeRotation(newRad);
}

- (void)saveRoadBookForLocation:(CLLocation*)location
                forWayPointType:(WayPointType)wpType
                      withValue:(NSUInteger)value
                  withImageData:(NSData*)imageData
                  withAudioData:(NSData*)audData
                  isWSFirstTime:(BOOL)isWSFirstTime
                       withDesc:(NSString*)strDes
{
    @autoreleasepool {
        isCapturing = NO;

        UIImage* image = nil;

        if (imageData != nil) {
            image = [Function compressImage:[UIImage imageWithData:imageData]];
            imageData = UIImagePNGRepresentation(image);
        }

        Waypoints* objWayPoint = [self generateWayPointId:value
                                                 location:location
                                          withDescription:strDes
                                               isWayPoint:YES
                                           withImageArray:image == nil ? @[] : @[ image ]
                                           withAudioArray:audData == nil ? @[] : @[ audData ]
                                                 isPaused:NO];

        NSString* strImageData = nil;
        NSString* strAudData = nil;

        if (imageData != nil) {
            strImageData = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }

        if (audData != nil) {
            strAudData = [audData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }

        [self generateWSDataWithLocation:location
                               forObject:objWayPoint
                           withImageData:strImageData
                             withAudData:strAudData
                         forWayPointType:wpType
                          isForFirstTime:isWSFirstTime];
    }
}

- (void)generateWSDataWithLocation:(CLLocation*)location
                         forObject:(Waypoints*)objWayPoint
                     withImageData:(NSString*)strImageData
                       withAudData:(NSString*)strAudData
                   forWayPointType:(WayPointType)wpType
                    isForFirstTime:(BOOL)isWSFirstTime
{
    if (isWSFirstTime) {
        RouteDetails* objRouteDetails = [[RouteDetails alloc] init];
        objRouteDetails = [self generateBasicRoute];
        objRouteDetails.name = _strRouteName;
        objRouteDetails.summary.startlocation.coord.lat = location.coordinate.latitude;
        objRouteDetails.summary.startlocation.coord.lon = location.coordinate.longitude;
        objRouteDetails.summary.endlocation.coord.lat = location.coordinate.latitude;
        objRouteDetails.summary.endlocation.coord.lon = location.coordinate.longitude;
        objRouteDetails.settings.units = [objConfig.unit lowercaseString];
        objRouteDetails.waypoints = @[ objWayPoint ];

        NSMutableDictionary* dicRouteDetails = [[objRouteDetails dictionaryRepresentation] mutableCopy];
        [dicRouteDetails setValue:_strFolderId ? _strFolderId : [NSNull null] forKey:@"folder_id"];
        [dicRouteDetails removeObjectForKey:@"id"];

        [self callWSToSavePointWithRouteId:nil withObject:dicRouteDetails withImageData:strImageData withAudData:strAudData forWayPointType:wpType];
    } else {
        NSMutableDictionary* dicAdd =
            [self getSaveWayPointDictionaryForOperation:@"add"
                                                   path:[NSString stringWithFormat:@"/waypoints/%ld", (long)counter - 1]
                                                  value:[objWayPoint dictionaryRepresentation]];

        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
            return objLocation.isWayPoint;
        }];

        NSUInteger totalWayPoints = [[arrAllLocations filteredArrayUsingPredicate:predicate] count];
        NSMutableDictionary* dicTotalWayPoints =
            [self getSaveWayPointDictionaryForOperation:@"replace"
                                                   path:@"/summary/totalwaypoints"
                                                  value:[NSNumber numberWithUnsignedInteger:totalWayPoints]];

        double distance = 0.0;

        for (NSInteger i = arrAllLocations.count - 1; i > 1; i--) {
            Locations* objLocation1 = arrAllLocations[i];
            Locations* objLocation2 = arrAllLocations[i - 1];

            CLLocation* objLoc1 = [[CLLocation alloc] initWithLatitude:objLocation1.latitude longitude:objLocation1.longitude];
            CLLocation* objLoc2 = [[CLLocation alloc] initWithLatitude:objLocation2.latitude longitude:objLocation2.longitude];

            distance += [objLoc1 distanceFromLocation:objLoc2];
        }

        if (arrAllLocations.count > 1) {
            Locations* objPrevWayPoint = arrAllLocations[1];
            CLLocation* prevLocation = [[CLLocation alloc] initWithLatitude:objPrevWayPoint.latitude longitude:objPrevWayPoint.longitude];
            distance += [prevLocation distanceFromLocation:location];
        }

        NSMutableDictionary* dicTotalRange =
            [self getSaveWayPointDictionaryForOperation:@"replace"
                                                   path:@"/summary/totaldistance"
                                                  value:[NSNumber numberWithDouble:distance]];

        NSMutableDictionary* dicLat =
            [self getSaveWayPointDictionaryForOperation:@"replace"
                                                   path:@"/summary/endlocation/coord/lat"
                                                  value:[NSNumber numberWithDouble:location.coordinate.latitude]];

        NSMutableDictionary* dicLon =
            [self getSaveWayPointDictionaryForOperation:@"replace"
                                                   path:@"/summary/endlocation/coord/lon"
                                                  value:[NSNumber numberWithDouble:location.coordinate.longitude]];

        [arrRemainingTracks addObjectsFromArray:@[ dicAdd, dicTotalWayPoints, dicTotalRange, dicLat, dicLon ]];

        [self callWSToSavePointWithRouteId:_strRouteIdentifier withObject:arrRemainingTracks withImageData:strImageData withAudData:strAudData forWayPointType:wpType];
    }
}

- (void)callWSToSavePointWithRouteId:(NSString*)strRouteId
                          withObject:(nonnull id)object
                       withImageData:(NSString*)con_ImgData
                         withAudData:(NSString*)con_AudData
                     forWayPointType:(WayPointType)wpType
{
    NSString* strJsonData = [RallyNavigatorConstants generateJsonStringFromObject:object];

    if (strRouteId != nil) {
        arrRemainingTracks = [[NSMutableArray alloc] init];
    }

    ServiceType serType = ServiceTypePUT;

    if (strRouteId == nil) {
        serType = ServiceTypeJSON;

        NSArray* arrSyncData = [[[[CDSyncData query] where:[NSPredicate predicateWithFormat:@"isEdit = 0 AND isActive = 0"]]
            order:[NSSortDescriptor sortDescriptorWithKey:@"routeIdentifier" ascending:YES]] all];

        if (arrSyncData.count > 0) {
            CDSyncData* objSyncData = [arrSyncData firstObject];

            if ([objSyncData.routeIdentifier doubleValue] > 0) {
                strRouteId = @"-1";
            } else {
                strRouteId = [NSString stringWithFormat:@"%ld", (long)([objSyncData.routeIdentifier doubleValue] - 1)];
            }
        } else {
            strRouteId = @"-1";
        }

        _strRouteIdentifier = strRouteId;
    }

    if (con_ImgData == nil) {
        con_ImgData = @"";
    }

    if (con_AudData == nil) {
        con_AudData = @"";
    }

    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];

    [dicParam setValue:strJsonData forKey:@"jsonData"];
    [dicParam setValue:[NSNumber numberWithInteger:0] forKey:@"isEdit"];
    [dicParam setValue:[NSNumber numberWithInteger:wpType] forKey:@"jsonDataType"];
    [dicParam setValue:[NSNumber numberWithInteger:serType] forKey:@"serviceType"];
    [dicParam setValue:[NSNumber numberWithInteger:0] forKey:@"isActive"];
    [dicParam setValue:[self getCurrentUTCTime] forKey:@"updatedAt"];
    [dicParam setValue:_strRouteName forKey:@"name"];
    [dicParam setValue:[NSNumber numberWithBool:isAutoPhotoEnabled] forKey:@"isAutoPhoto"];

    if (_currentDistanceUnitsType == DistanceUnitsTypeKilometers) {
        [dicParam setValue:@"Kilometers" forKey:@"distanceUnit"];
    } else {
        [dicParam setValue:@"Miles" forKey:@"distanceUnit"];
    }

    [dicParam setValue:con_ImgData forKey:@"imageData"];
    [dicParam setValue:con_AudData forKey:@"voiceData"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [dicParam setValue:[NSNumber numberWithInteger:[self.strRouteIdentifier doubleValue]] forKey:@"routeIdentifier"];
        [CoreDataAdaptor SaveDataInCoreDB:dicParam forEntity:NSStringFromClass([CDSyncData class])];

        self->isCapturing = NO;
        self->isPaused = NO;
        self->isTempWayPointAdded = NO;

        if (AppContext.isWebServiceIsCalling) {
            NSInteger totalWP = AppContext.totalWayPoints;
            totalWP = totalWP + 1;
            AppContext.totalWayPoints = totalWP;
        } else if ([ReachabilityManager isReachable] && !AppContext.isWebServiceIsCalling) {
            NSArray* arrCDUser = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:@"isActive = 0"]] all];

            AppContext.isWebServiceIsCalling = YES;
            AppContext.totalWayPoints = arrCDUser.count;
            AppContext.syncedWayPoints = 0;
            [AppContext checkForSyncData];
        }

        if (self->isBack) {
            [AlertManager showWithImage:@"ic_success"
                                 labels:@[
                                     [AlertManager labelWithText:@"Roadbook saved"
                                                           color:UIColor.whiteColor
                                                            size:1],
                                     [AlertManager labelWithText:@"Roadbook available in My Roadbooks folder on desktop computer for final editing, PDF print production and Sharing to Mobile app"
                                                           color:UIColor.lightGrayColor
                                                            size:0],
                                     [AlertManager labelWithText:@"www.rallynavigator.com"
                                                           color:UIColor.whiteColor
                                                            size:-1]
                                 ]
                             textFields:@[]
                                buttons:@[
                                    [AlertManager buttonWithTitle:@"OK"
                                                           action:^(NSArray<NSString*>* _Nonnull values) {
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                           }
                                                        isDefault:YES
                                                     needValidate:NO]
                                ]];
        }
    });
}

- (NSString*)getCurrentUTCTime
{
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString* strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}

- (Waypoints*)generateWayPointId:(NSUInteger)identifier
                        location:(CLLocation*)location
                 withDescription:(NSString*)desc
                      isWayPoint:(BOOL)isWayPoint
                  withImageArray:(NSArray*)arrPhoto
                  withAudioArray:(NSArray*)arrAudio
                        isPaused:(BOOL)isForPaused
{
    Waypoints* objWayPoint = [[Waypoints alloc] init];
    objWayPoint.alt = [NSNull null];
    objWayPoint.cellPhoneStage = -2;
    objWayPoint.ele = [NSNull null];
    objWayPoint.freelines = @[];
    objWayPoint.wayPointDescription = desc;

    Backgroundimage* objBackImg = [[Backgroundimage alloc] init];
    objBackImg.backgroundimageIdentifier = -1;
    objBackImg.url = @"";
    objWayPoint.backgroundimage = objBackImg;

    GravelLine* objGraveLine = [[GravelLine alloc] init];
    objGraveLine.bottom = NO;
    objGraveLine.top = NO;
    objWayPoint.gravelLine = objGraveLine;

    objWayPoint.icons = @[];
    objWayPoint.lat = location.coordinate.latitude;
    objWayPoint.lon = location.coordinate.longitude;
    objWayPoint.roads = @[];
    objWayPoint.show = isWayPoint;
    objWayPoint.showStickMarkOnTulip = YES;
    objWayPoint.streetSignIcons = @[];

    Td* objTd = [[Td alloc] init];
    objTd.tixX = [NSNull null];
    objTd.ticY = [NSNull null];
    objWayPoint.td = objTd;

    objWayPoint.trayIcons = @[];

    VoiceNote* objVoiceNote = [[VoiceNote alloc] init];
    objVoiceNote.voiceNoteIdentifier = -1;
    objVoiceNote.url = @"";
    objWayPoint.voiceNote = objVoiceNote;

    objWayPoint.waypointid = counter;

    Locations* objLocation = [[Locations alloc] init];
    objLocation.locationId = counter;
    objLocation.latitude = location.coordinate.latitude;
    objLocation.longitude = location.coordinate.longitude;
    objLocation.text = desc;

    if (isWayPoint) {
        objLocation.photos = arrPhoto;
        objLocation.audios = arrAudio;
    }

    objLocation.isWayPoint = isWayPoint;
    [isForPaused ? arrAllTempLocations : arrAllLocations insertObject:objLocation atIndex:0];

    if (isForPaused) {
        return objWayPoint;
    }

    [self setUpLocationId];
    [self setLocationDistance];

    if (isWayPoint) {
        [_tblLocations insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationTop];
        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
        [cell.btnEdit setHidden:YES];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tblLocations beginUpdates];
            [self.tblLocations reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
            [self.tblLocations endUpdates];
        });
    } else {
        if (arrAllLocations.count > 0) {
            [self positionShapeLayerForCell:[_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]
                               andIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        }
        [_tblLocations beginUpdates];
        [_tblLocations reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
        [_tblLocations endUpdates];
    }

    return objWayPoint;
}

- (NSMutableDictionary*)getSaveWayPointDictionaryForOperation:(NSString*)strOperation path:(NSString*)strPath value:(id)value
{
    NSMutableDictionary* dicWayPointOperation = [[NSMutableDictionary alloc] init];

    [dicWayPointOperation setValue:strOperation forKey:@"op"];
    [dicWayPointOperation setValue:strPath forKey:@"path"];
    [dicWayPointOperation setValue:value forKey:@"value"];

    return dicWayPointOperation;
}

#pragma mark - Button Click Events

- (IBAction)btnToggelMapClicked:(id)sender
{
    switch (_currentViewType) {
    case ViewTypeListView: {
        _mapBoxView.hidden = false;
        _btnViewPreference.hidden = false;
        _btnMapType.hidden = false; //[DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView];
        [_tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        _tblLocations.scrollEnabled = NO;
        _currentViewType = ViewTypeMapView;
    } break;

    case ViewTypeMapView: {
        _currentViewType = ViewTypeListView;
        _mapBoxView.hidden = true;
        _btnViewPreference.hidden = true;
        _btnMapType.hidden = true;
        _tblLocations.scrollEnabled = YES;
    } break;

    case ViewTypePreview: {
        _currentViewType = ViewTypeListView;
        _mapBoxView.hidden = true;
        _btnViewPreference.hidden = true;
        _btnMapType.hidden = true;
        _tblLocations.scrollEnabled = YES;
    } break;

    default:
        break;
    }
}

- (IBAction)btnTogglePreferrenceClicked:(id)sender
{
    [self.view endEditing:YES];

    switch (_currentPreference) {
    case ViewingPreferenceCurrentLocationNorthUp: {
        _currentPreference = ViewingPreferenceCurrentLocationTrackUp;
        [self focusMapToShowAllMarkersWithAnimate:NO];
        [self updateIconHeading];
        [_btnViewPreference setImage:Set_Local_Image(@"north_current_location") forState:UIControlStateNormal];
        _mapBoxView.scrollEnabled = NO;
        _mapBoxView.rotateEnabled = NO;
    } break;

    case ViewingPreferenceCurrentLocationTrackUp: {
        curZoomLevel = _mapBoxView.zoomLevel;
        _currentPreference = ViewingPreferenceRouteNorthUp;
        [self focusMapToShowAllMarkersWithAnimate:YES];
        [_btnViewPreference.layer removeAllAnimations];
        _btnViewPreference.transform = CGAffineTransformIdentity;
        [_btnViewPreference setImage:Set_Local_Image(@"north_route") forState:UIControlStateNormal];
        [_mapBoxView resetNorth];
        _mapBoxView.scrollEnabled = YES;
        _mapBoxView.rotateEnabled = YES;
    } break;

    case ViewingPreferenceRouteNorthUp: {
        mCamera = _mapBoxView.camera;
        _currentPreference = ViewingPreferenceCurrentLocationNorthUp;
        [self focusMapToShowAllMarkersWithAnimate:YES];
        [_mapBoxView setZoomLevel:curZoomLevel animated:NO];
        [_btnViewPreference.layer removeAllAnimations];
        _btnViewPreference.transform = CGAffineTransformIdentity;
        [_btnViewPreference setImage:Set_Local_Image(@"north_current_location") forState:UIControlStateNormal];
        [_mapBoxView resetNorth];
        _mapBoxView.scrollEnabled = NO;
        _mapBoxView.rotateEnabled = NO;
    } break;

    default:
        break;
    }
}

- (IBAction)btnMapStyleChanged:(id)sender
{
    if (_myMapBoxType == [MGLStyle satelliteStreetsStyleURL]) {
        _myMapBoxType = [MGLStyle streetsStyleURL];
        _mapBoxView.styleURL = _myMapBoxType;
        [_btnMapType setTitle:@"M" forState:UIControlStateNormal];
    } else {
        _myMapBoxType = [MGLStyle satelliteStreetsStyleURL];
        _mapBoxView.styleURL = _myMapBoxType;
        [_btnMapType setTitle:@"S" forState:UIControlStateNormal];
    }
}

- (IBAction)btnMapFullScreenClicked:(id)sender
{
    [self.view endEditing:YES];
}

- (void)btnStopAndSaveClicked
{
    if (arrRemainingTracks.count > 0) {
        isBack = YES;
        [self handleAddWP:nil];
    } else {
        [AlertManager showWithImage:@"ic_success"
                             labels:@[
                                 [AlertManager labelWithText:@"Roadbook saved"
                                                       color:UIColor.whiteColor
                                                        size:1],
                                 [AlertManager labelWithText:@"Roadbook available in My Roadbooks folder on desktop computer for final editing, PDF print production and Sharing to Mobile app"
                                                       color:UIColor.lightGrayColor
                                                        size:0],
                                 [AlertManager labelWithText:@"www.rallynavigator.com"
                                                       color:UIColor.whiteColor
                                                        size:-1]
                             ]
                         textFields:@[]
                            buttons:@[
                                [AlertManager buttonWithTitle:@"OK"
                                                       action:^(NSArray<NSString*>* _Nonnull values) {
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }
                                                    isDefault:YES
                                                 needValidate:NO]
                            ]];
    }
}

- (IBAction)btnDrawerAction:(UIButton*)sender
{
    [self.view endEditing:YES];

    SettingsVC* vc = loadViewController(StoryBoard_Settings, kIDSettingsVC);
    vc.currentOverlay = o_polylineMapBox ? OverlayStatusHide : OverlayStatusShow;
    vc.isRecording = isStart;
    vc.delegate = self;

    NavController* nav = [[NavController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnAddWayPointClicked:(id)sender
{
    if (isEditEnabled) {
        return;
    }

    [self.view endEditing:YES];

    if (!isPaused) {
        isPaused = YES;
        isTempWayPointAdded = YES;

        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
        marker1.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        marker1.title = @"Test Name";
        [_mapBoxView addAnnotation:marker1];
        [arrMapBoxMarkers addObject:marker1];
        isAddedWayPointForPolyline = YES;
    }

    [self handleAddWP:nil];
    isAddWayPointClick = YES;
    [_tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)btnAddWPWithTextClicked:(id)sender
{
    if (isEditEnabled) {
        return;
    }

    [_tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    if ([cell.txtView isFirstResponder]) {
        [cell.txtView resignFirstResponder];
        return;
    }

    if (!isPaused) {
        isPaused = YES;
        isTempWayPointAdded = YES;

        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
        marker1.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        marker1.title = @"Test Name";
        [_mapBoxView addAnnotation:marker1];
        [arrMapBoxMarkers addObject:marker1];
        isAddedWayPointForPolyline = YES;
    }

    if (isAutoPhotoEnabled && imgCaptured == nil) {
        [self capturePhoto];
    } else {
        [self playAudio:@"Text" fileType:@"aiff"];
    }

    if ([cell.txtView isFirstResponder]) {
        return;
    }

    [cell.txtView becomeFirstResponder];
    [_btnAdd setEnabled:FALSE];
}

- (void)setUpTextField:(UITextField*)textField
{
    textField.placeholder = @"Enter your way-point description here";
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.tintColor = RGB(85, 85, 85);
}

- (IBAction)btnAddWPWithImageClicked:(id)sender
{
    if (isEditEnabled) {
        return;
    }

    [self.view endEditing:YES];

    if (!isPaused) {
        isPaused = YES;
        isTempWayPointAdded = YES;

        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
        marker1.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        marker1.title = @"Test Name";
        [_mapBoxView addAnnotation:marker1];
        [arrMapBoxMarkers addObject:marker1];
        isAddedWayPointForPolyline = YES;
    }

    [self capturePhoto];

    [_tblLocations beginUpdates];
    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [cell.lblDistanceUnit setHidden:YES];
    [cell.btnEdit setHidden:NO];
    [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
    [_tblLocations endUpdates];
    [_tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_btnAdd setEnabled:FALSE];
}

- (IBAction)btnRecordingClicked:(id)sender
{
    [self.view endEditing:YES];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self playAudio:@"TextWithRecord" fileType:@"wav"];

        UIButton* btn = (UIButton*)sender;
        self->btnFlashing = btn;
        [btn.imageView setAlpha:1.0];
        LocationCell* cell = [self.tblLocations cellForRowAtIndexPath:self->selectedIndexPath];

        [cell.lblDistanceUnit setHidden:YES];
        [cell.btnEdit setHidden:NO];

        if (self->isRecordingStarted) {
            self->isCancelled = YES;
            self->isManual = YES;
            [btn setImage:[UIImage imageNamed:@"smallMicrophone"] forState:UIControlStateNormal];
            [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        } else {
            self->isCancelled = NO;
            self->isManual = NO;
            [self playAudio:@"Voice" fileType:@"mp3"];
            [btn setImage:[UIImage imageNamed:@"smallGrayMicrophone"] forState:UIControlStateNormal];
            [self flashOn:btn isEditable:@"YES" button:btn];
            [self ConfigureAudioRecord:btn.tag];
            [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        }

        self->isRecordingStarted = !self->isRecordingStarted;
    });
}

- (IBAction)btnRecordClicked:(id)sender
{
    if (isEditEnabled) {
        return;
    }

    if (!isPaused) {
        isPaused = YES;
        isTempWayPointAdded = YES;

        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
        marker1.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        marker1.title = @"Test Name";
        [_mapBoxView addAnnotation:marker1];
        [arrMapBoxMarkers addObject:marker1];
        isAddedWayPointForPolyline = YES;
    }

    [_btnRecording.imageView setAlpha:1.0];
    [_tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [cell.lblDistanceUnit setHidden:YES];
    [cell.btnEdit setHidden:NO];

    if (isRecordingStarted) {
        isCancelled = YES;
        isManual = YES;
        [_btnRecording.imageView setAlpha:1.0];
        [_btnRecording setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        [self stopRecording];
    } else {
        isCancelled = NO;
        isManual = NO;

        if (isAutoPhotoEnabled && imgCaptured == nil) {
            [self capturePhoto];
        }

        [_tblLocations scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        [self playAudio:@"Voice" fileType:@"mp3"];
        [_btnRecording setImage:[UIImage imageNamed:@"grayVoice"] forState:UIControlStateNormal];
        [self flashOn:_btnRecording isEditable:@"NO" button:_btnRecording];
        [self ConfigureAudioRecord:_btnRecording.tag];
        [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        [_btnAdd setEnabled:FALSE];
    }

    isRecordingStarted = !isRecordingStarted;
}

- (void)flashOff:(UIView*)v isEditable:(NSString*)strIsEditable button:(UIButton*)btnFlash
{
    [UIView animateWithDuration:0.6
        delay:0
        options:UIViewAnimationOptionAllowUserInteraction
        animations:^{
            if ([strIsEditable isEqualToString:@"YES"]) {
                [btnFlash setImage:[UIImage imageNamed:@"smallGrayMicrophone"] forState:UIControlStateNormal];
                [btnFlash.imageView setAlpha:1.0];
            } else {
                [btnFlash setImage:[UIImage imageNamed:@"grayVoice"] forState:UIControlStateNormal];
                [btnFlash.imageView setAlpha:1.0];
            }
        }
        completion:^(BOOL finished) {
            if (!self->isCancelled && self->isRecordingStarted) {
                [self flashOn:v isEditable:strIsEditable button:btnFlash];
            }
        }];
}

- (void)flashOn:(UIView*)v isEditable:(NSString*)strIsEditable button:(UIButton*)btnFlash
{
    [UIView animateWithDuration:0.7
        delay:0
        options:UIViewAnimationOptionAllowUserInteraction
        animations:^{
            if ([strIsEditable isEqualToString:@"YES"]) {
                [btnFlash setImage:[UIImage imageNamed:@"smallMicrophone"] forState:UIControlStateNormal];
                [btnFlash.imageView setAlpha:0.5];
            } else {
                [btnFlash setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
                [btnFlash.imageView setAlpha:0.5];
            }
        }
        completion:^(BOOL finished) {
            if (!self->isCancelled && self->isRecordingStarted) {
                [self flashOff:v isEditable:strIsEditable button:btnFlash];
                [btnFlash.imageView setAlpha:1.0];
            }
        }];
}

- (IBAction)btnPreviewImageClicked:(id)sender
{
    [self.view endEditing:YES];

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.locationId == ((UIButton*)sender).tag;
    }];

    NSMutableArray* arrSearchResults = [[NSMutableArray alloc] init];
    arrSearchResults = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

    if (arrSearchResults.count > 0) {
        Locations* objLocation = [arrSearchResults firstObject];

        ImagePreviewVC* vc = loadViewController(StoryBoard_Main, kIDImagePreviewVC);
        vc.objLocation = objLocation;
        NavController* nav = [[NavController alloc] initWithRootViewController:vc];

        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            nav.navigationBar.barStyle = UIBarStyleBlack;
            nav.navigationBar.translucent = NO;
            nav.navigationBar.tintColor = UIColor.lightGrayColor;
            [nav.navigationBar setTitleTextAttributes:
                                   @{ NSForegroundColorAttributeName : UIColor.lightGrayColor }];
        } else {
            nav.navigationBar.barStyle = UIBarStyleDefault;
            nav.navigationBar.translucent = YES;
            nav.navigationBar.tintColor = UIColor.blackColor;
            [nav.navigationBar setTitleTextAttributes:
                                   @{ NSForegroundColorAttributeName : UIColor.blackColor }];
        }

        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (IBAction)btnDoneClicked:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)btnCapRecorderClicked:(id)sender
{
    [self.view endEditing:YES];

    if ([AppContext.audioPlayer isPlaying]) {
        [AppContext.audioPlayer stop];
        AppContext.audioPlayer = nil;
        return;
    }

    [AppContext.audioPlayer stop];
    AppContext.audioPlayer = nil;

    NSError* error = nil;
    AppContext.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    AppContext.audioPlayer.delegate = self;
    [AppContext.audioPlayer play];
}

- (IBAction)btnRecorderClicked:(id)sender
{
    [self.view endEditing:YES];

    if ([AppContext.audioPlayer isPlaying]) {
        [AppContext.audioPlayer stop];
        AppContext.audioPlayer = nil;
        return;
    }

    [AppContext.audioPlayer stop];
    AppContext.audioPlayer = nil;

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.locationId == ((UIButton*)sender).tag;
    }];

    NSMutableArray* arrSearchResults = [[NSMutableArray alloc] init];
    arrSearchResults = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

    if (arrSearchResults.count > 0) {
        Locations* objLocation = [arrSearchResults firstObject];

        NSData* data;

        if (objLocation.audios.count > 0) {
            data = objLocation.audios[0];
        } else {
            NSString* strMediaLink = objLocation.audioUrl;
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strMediaLink]];
        }

        NSError* error = nil;
        AppContext.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        AppContext.audioPlayer.delegate = self;
        [AppContext.audioPlayer play];
    }
}

- (IBAction)btnCaptureImage:(id)sender
{
    [self.view endEditing:YES];

    [self capturePhoto];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TableViewSectionCurrentState || section == TableViewSectionFooter) {
        return 1;
    }

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.isWayPoint;
    }];

    NSMutableArray* arrSearchResults = [[NSMutableArray alloc] init];
    arrSearchResults = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];
    return arrSearchResults.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == TableViewSectionFooter) {
        return CGRectGetHeight(tableView.frame) - 145.0f;
    }

    return 145.0f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.view endEditing:YES];
}

- (void)manageCell:(LocationCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case TableViewSectionCurrentState: {
        cell.btnAddPhoto.hidden = YES;
        cell.lblDivider.hidden = YES;
        cell.btnAddText.hidden = YES;

        cell.btnEdit.hidden = NO;
        cell.shapeLayer.hidden = NO;
        cell.dirShapeLayer.hidden = NO;
        cell.triShapeLayer.hidden = NO;

        cell.txtView.editable = !isEditEnabled;
        cell.txtView.userInteractionEnabled = !isEditEnabled;

        [cell.btnAddPhoto setImage:[UIImage imageNamed:@"smallCamera"] forState:UIControlStateNormal];

        if (_isFirstTime && arrMapBoxMarkers.count == 1) {
            [cell.lblDistanceUnit setHidden:YES];
            [cell.btnEdit setHidden:NO];
            [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        } else if (audioData == nil && cell.imgWayPoint.image == nil && cell.txtView.text.length == 0) {
            [cell.lblDistanceUnit setHidden:NO];
            [cell.btnEdit setHidden:YES];

            if ([objConfig.unit isEqualToString:@"Kilometers"]) {
                cell.lblDistanceUnit.text = @"KM";
            } else {
                cell.lblDistanceUnit.text = [objConfig.unit uppercaseString];
            }
        } else {
            if (isAddWayPointClick) {
                isAddWayPointClick = !isAddWayPointClick;
                if ([objConfig.unit isEqualToString:@"Kilometers"]) {
                    cell.lblDistanceUnit.text = @"KM";
                } else {
                    cell.lblDistanceUnit.text = [objConfig.unit uppercaseString];
                }
                [cell.lblDistanceUnit setHidden:NO];
                [cell.btnEdit setHidden:YES];
            } else {
                [cell.lblDistanceUnit setHidden:YES];
                [cell.btnEdit setHidden:NO];
                [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
            }
        }

        UIColor* color;

        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            color = UIColor.lightGrayColor;
            [cell.lblDistanceUnit setBackgroundColor:UIColor.blackColor];
        } else {
            color = UIColor.blackColor;
            [cell.lblDistanceUnit setBackgroundColor:[UIColor whiteColor]];
        }
        [cell.lblDistanceUnit setTextColor:color];

        cell.vwLeft.layer.borderColor = [UIColor redColor].CGColor;
        cell.vwRight.layer.borderColor = [UIColor redColor].CGColor;
        cell.vwNavigator.layer.borderColor = [UIColor redColor].CGColor;
    } break;

    case TableViewSectionWayPoints: {
        if (selectedIndexPath == indexPath) {
            [cell.btnEdit setHidden:NO];
            [cell.lblDistanceUnit setHidden:YES];

            if (isEditEnabled) {
                cell.btnAddPhoto.hidden = NO;
                cell.lblDivider.hidden = NO;
                cell.btnAudioWidthConstant.constant = cell.btnAudioWidthConstant.constant - 1;
                cell.btnAudioWidthConstant.constant = cell.btnAddPhotoWidthConstant.constant - 2;
                [self.view updateConstraintsIfNeeded];

                cell.btnAddText.hidden = NO;

                cell.shapeLayer.hidden = YES;
                cell.dirShapeLayer.hidden = YES;
                cell.triShapeLayer.hidden = YES;

                cell.txtView.editable = YES;
                cell.txtView.userInteractionEnabled = YES;

                if (imgEditCaptured == nil) {
                    [cell.btnAddPhoto setImage:[UIImage imageNamed:@"smallCamera"] forState:UIControlStateNormal];
                } else {
                    [cell.btnAddPhoto setTitle:@"" forState:UIControlStateNormal];
                    [cell.btnAddPhoto setImage:imgEditCaptured forState:UIControlStateNormal];
                }

                [cell.btnEdit setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];

            } else {
                cell.btnAddPhoto.hidden = YES;
                cell.lblDivider.hidden = YES;
                cell.btnAddText.hidden = YES;

                cell.shapeLayer.hidden = NO;
                cell.dirShapeLayer.hidden = NO;
                cell.triShapeLayer.hidden = NO;

                cell.txtView.editable = NO;
                cell.txtView.userInteractionEnabled = NO;

                [cell.btnAddPhoto setImage:[UIImage imageNamed:@"smallCamera"] forState:UIControlStateNormal];

                [cell.btnEdit setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
            }
        } else {
            cell.btnAddPhoto.hidden = YES;
            cell.lblDivider.hidden = YES;
            cell.btnAddText.hidden = YES;

            cell.shapeLayer.hidden = NO;
            cell.dirShapeLayer.hidden = NO;
            cell.triShapeLayer.hidden = NO;

            cell.txtView.editable = NO;
            cell.txtView.userInteractionEnabled = NO;

            [cell.btnAddPhoto setImage:[UIImage imageNamed:@"smallCamera"] forState:UIControlStateNormal];

            if (indexPath.row == 0 && isViewLoadFirstTime == YES) {
                [cell.lblDistanceUnit setHidden:YES];
                [cell.btnEdit setHidden:NO];
                selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:TableViewSectionWayPoints];
            } else {
                [cell.lblDistanceUnit setHidden:YES];
                [cell.btnEdit setHidden:YES];
            }

            [cell.btnEdit setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
        }

        UIColor* color;

        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
            color = UIColor.lightGrayColor;
            [cell.lblDistanceUnit setBackgroundColor:UIColor.blackColor];
        } else {
            color = UIColor.blackColor;
            [cell.lblDistanceUnit setBackgroundColor:[UIColor whiteColor]];
        }

        cell.vwLeft.layer.borderColor = color.CGColor;
        cell.vwRight.layer.borderColor = color.CGColor;
        cell.vwNavigator.layer.borderColor = color.CGColor;
        [cell.lblDistanceUnit setTextColor:color];
    } break;

    default:
        break;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    LocationCell* cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];

    if (!cell) {
        cell = [self registerCell:cell inTableView:tableView forClassName:NSStringFromClass([LocationCell class]) identifier:@"locationCell"];
    }

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.isWayPoint;
    }];

    NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
    arrWayPoints = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

    cell.vwLeft.layer.borderWidth = 2.0f;
    cell.vwRight.layer.borderWidth = 2.0f;
    cell.vwNavigator.layer.borderWidth = 2.0f;

    switch (indexPath.section) {
    case TableViewSectionCurrentState: {
        NSArray* arrResults = [self convertToDegreeThroughLat:currentLocation.coordinate.latitude andLong:currentLocation.coordinate.longitude];

        if (arrResults.count == 2) {
            cell.lblLatitude.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %@", arrResults[0]]];
            cell.lblLongitude.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %@", arrResults[1]]];
        }

        double val = 0;

        if ([objConfig.unit isEqualToString:@"Kilometers"]) {
            val = 1.0f;
        } else {
            val = 0.62f;
        }

        cell.lblDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:totalDistance * val] doubleValue]];
        cell.lblPerDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:preDistance * val] doubleValue]];

        cell.btnPreviewImage.hidden = YES;
        cell.imgWayPoint.image = imgCaptured;

        if (audioData != nil) {
            cell.btnStartRecording.hidden = NO;
        } else {
            cell.btnStartRecording.hidden = YES;
        }

        cell.lblRowCount.text = [NSString stringWithFormat:@"%ld", (unsigned long)arrWayPoints.count + 1];

        cell.txtView.text = strWayPointDescription;
        cell.txtView.tag = -1;

        cell.btnEdit.tag = -1;

        if (indexPath.row == 0) {
            [cell.btnStartRecording addTarget:self action:@selector(btnCapRecorderClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    } break;

    case TableViewSectionWayPoints: {
        Locations* objWayPoint = arrWayPoints[indexPath.row];

        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.contentView layoutSubviews];
        });

        NSArray* arrResults = [self convertToDegreeThroughLat:objWayPoint.latitude andLong:objWayPoint.longitude];

        if (arrResults.count == 2) {
            cell.lblLatitude.attributedText = [self moveDegreeSymbolUp:arrResults[0]];
            cell.lblLongitude.attributedText = [self moveDegreeSymbolUp:arrResults[1]];
        }

        // Calculate total distance and per distance for route
        if (indexPath.row == arrWayPoints.count - 1) {
            cell.lblDistance.text = @"0.00";
            cell.lblPerDistance.text = @"0.00";
        } else {
            double distance = 0.0;
            double tempDistance = 0.0;

            for (NSInteger i = arrAllLocations.count - 1; i > 0; i--) {
                Locations* objLocation1 = arrAllLocations[i];
                Locations* objLocation2 = arrAllLocations[i - 1];

                CLLocation* objLoc1 = [[CLLocation alloc] initWithLatitude:objLocation1.latitude longitude:objLocation1.longitude];
                CLLocation* objLoc2 = [[CLLocation alloc] initWithLatitude:objLocation2.latitude longitude:objLocation2.longitude];

                distance += [objLoc1 distanceFromLocation:objLoc2];
                tempDistance += [objLoc1 distanceFromLocation:objLoc2];

                if ([objLocation2 isEqual:objWayPoint]) {
                    break;
                } else if (objLocation2.isWayPoint) {
                    tempDistance = 0.0;
                }
            }

            double val = 0;

            if ([objConfig.unit isEqualToString:@"Kilometers"]) {
                val = 1.0f;
            } else {
                val = 0.62f;
            }

            cell.lblPerDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:tempDistance * val] doubleValue]];
            cell.lblDistance.text = [NSString stringWithFormat:@"%.02f", [[self calculateDistanceFor:distance * val] doubleValue]];
        }

        if (objWayPoint.photos.count > 0) {
            cell.btnPreviewImage.hidden = NO;
            cell.imgWayPoint.image = objWayPoint.photos[0];
        } else {

            cell.btnPreviewImage.hidden = objWayPoint.imageUrl.length == 0;
            [cell.imgWayPoint sd_setImageWithURL:[NSURL URLWithString:objWayPoint.imageUrl]
                                placeholderImage:Set_Local_Image(@"DEFAULT_PROFILE_IMAGE")
                                       completed:^(UIImage* _Nullable image, NSError* _Nullable error, SDImageCacheType cacheType, NSURL* _Nullable imageURL) {
                                           if (error == nil) {
                                               cell.imgWayPoint.image = image;
                                           }
                                       }];
        }

        if (objWayPoint.audios.count > 0) {
            cell.btnStartRecording.hidden = NO;
        } else {
            cell.btnStartRecording.hidden = objWayPoint.audioUrl.length == 0;
        }

        // Displays row number
        cell.lblRowCount.text = [NSString stringWithFormat:@"%ld", (unsigned long)arrWayPoints.count - indexPath.row];
        cell.txtView.tag = objWayPoint.locationId;
        cell.txtView.text = objWayPoint.text;
        cell.btnPreviewImage.tag = objWayPoint.locationId;
        cell.btnStartRecording.tag = objWayPoint.locationId;
        [cell.btnPreviewImage addTarget:self action:@selector(btnPreviewImageClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnEdit.tag = objWayPoint.locationId;
        [cell.btnStartRecording addTarget:self action:@selector(btnRecorderClicked:) forControlEvents:UIControlEventTouchUpInside];
    } break;

    default: {
        cell.hidden = YES;
        return cell;
    } break;
    }

    [self manageCell:cell forIndexPath:indexPath];

    [cell.btnEdit addTarget:self action:@selector(handleAddWP:) forControlEvents:UIControlEventTouchUpInside];

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        cell.lblDistance.textColor = UIColor.lightGrayColor;
        cell.lblRowCount.textColor = UIColor.blackColor;
        cell.lblPerDistance.textColor = UIColor.lightGrayColor;
        cell.lblAngle.textColor = UIColor.lightGrayColor;
        cell.lblLatitude.textColor = UIColor.lightGrayColor;
        cell.lblLongitude.textColor = UIColor.lightGrayColor;
        cell.txtView.layer.shadowColor = BLACK_COLOR.CGColor;
        cell.txtView.textColor = [UIColor whiteColor];
    } else {
        cell.lblDistance.textColor = UIColor.blackColor;
        cell.lblRowCount.textColor = [UIColor whiteColor];
        cell.lblPerDistance.textColor = UIColor.blackColor;
        cell.lblAngle.textColor = UIColor.blackColor;
        cell.lblLatitude.textColor = UIColor.blackColor;
        cell.lblLongitude.textColor = UIColor.blackColor;
        cell.txtView.layer.shadowColor = WHITE_COLOR.CGColor;
        cell.txtView.textColor = UIColor.blackColor;
    }

    // Button to save way-point
    cell.btnCamera.hidden = YES;

    [self positionShapeLayerForCell:cell andIndexPath:indexPath];

    UIToolbar* keyboardToolBar = [[UIToolbar alloc] init];
    [keyboardToolBar sizeToFit];
    UIBarButtonItem* flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneClicked:)];
    keyboardToolBar.items = @[ flexBarButton, doneBarButton ];
    cell.txtView.inputAccessoryView = keyboardToolBar;

    cell.txtView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    cell.txtView.layer.shadowOpacity = 1.0f;
    cell.txtView.layer.shadowRadius = 3.0f;
    cell.txtView.layer.shouldRasterize = YES;

    [cell.btnAddPhoto bringSubviewToFront:cell.contentView];

    [cell.btnAddPhoto addTarget:self action:@selector(btnCaptureImage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnAddText addTarget:self action:@selector(btnRecordingClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (iPadDevice) {
        cell.lblRowCount.font = [UIFont boldSystemFontOfSize:22.0f];
        cell.lblPerDistance.font = [UIFont systemFontOfSize:26.0f];
        cell.lblDistance.font = [UIFont boldSystemFontOfSize:28.0f];
    }

    cell.transform = CGAffineTransformMakeRotation(M_PI);

    return cell;
}

- (void)positionShapeLayerForCell:(LocationCell*)cell andIndexPath:(NSIndexPath*)indexPath
{
    CGPoint centerPoint = CGPointMake((_tblLocations.frame.size.width / 2), /*55*/ 70);

    [cell drawPathIn:cell.contentView
          startPoint:centerPoint
            endPoint:CGPointMake(centerPoint.x, centerPoint.y + /*35*/ 45)];

    if (indexPath.section == TableViewSectionCurrentState) {
        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:@" ---° "];

        float A = (ROUND_TO_NEAREST(0) - ROUND_TO_NEAREST(0)) - 90;
        float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
        float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

        [cell drawDirectionPathIn:cell.contentView
                       startPoint:centerPoint
                         endPoint:CGPointMake(x, y)];

        float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
        float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

        float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
        float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

        [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];

        //        [self updateCurrentLocationCell];
        return;
    } else if (indexPath.section == TableViewSectionFooter) {
        return;
    }

    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
        return objLocation.isWayPoint;
    }];

    NSMutableArray* arrWayPoints = [[NSMutableArray alloc] init];
    arrWayPoints = [[arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

    Locations* objWayPoints = arrWayPoints[indexPath.row];

    double curAngle = 0.0;
    double preAngle = 0.0;

    NSInteger curIndex = [arrAllLocations indexOfObject:objWayPoints];

    if (curIndex != 0) {
        Locations* objLocation2 = arrAllLocations[curIndex - 1];

        curAngle = [self angleFromCoordinate:objWayPoints.latitude
                                        lon1:objWayPoints.longitude
                                        lat2:objLocation2.latitude
                                        lon2:objLocation2.longitude];

        Locations* objLocation1;

        if (curIndex + 1 == arrAllLocations.count) {
            preAngle = curAngle;
        } else {
            objLocation1 = arrAllLocations[curIndex + 1];

            preAngle = [self angleFromCoordinate:objLocation1.latitude
                                            lon1:objLocation1.longitude
                                            lat2:objWayPoints.latitude
                                            lon2:objWayPoints.longitude];
        }

        if (preAngle > curAngle) {
            // left // minus
            float A = 360 - (ROUND_TO_NEAREST(preAngle) - ROUND_TO_NEAREST(curAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

            [cell drawDirectionPathIn:cell.contentView
                           startPoint:centerPoint
                             endPoint:CGPointMake(x, y)];

            float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

            float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        } else {
            // right // positive
            float A = (ROUND_TO_NEAREST(curAngle) - ROUND_TO_NEAREST(preAngle)) - 90;
            float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
            float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

            [cell drawDirectionPathIn:cell.contentView
                           startPoint:centerPoint
                             endPoint:CGPointMake(x, y)];

            float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
            float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

            float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
            float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

            [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
        }

        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:[NSString stringWithFormat:@" %d° ", ROUND_TO_NEAREST(curAngle)]];
    } else {
        cell.lblAngle.attributedText = [self moveDegreeSymbolUp:@" ---° "];

        float A = (ROUND_TO_NEAREST(0) - ROUND_TO_NEAREST(0)) - 90;
        float x = 35 * cos(DEGREES_TO_RADIANS(A)) + centerPoint.x;
        float y = 35 * sin(DEGREES_TO_RADIANS(A)) + centerPoint.y;

        [cell drawDirectionPathIn:cell.contentView
                       startPoint:centerPoint
                         endPoint:CGPointMake(x, y)];

        float sX = 15 * cos(DEGREES_TO_RADIANS((A + 155))) + x;
        float sY = 15 * sin(DEGREES_TO_RADIANS((A + 155))) + y;

        float eX = 15 * cos(DEGREES_TO_RADIANS((A - 155))) + x;
        float eY = 15 * sin(DEGREES_TO_RADIANS((A - 155))) + y;

        [cell drawTriPathIn:cell.contentView startPoint:CGPointMake(x, y) leftPoint:CGPointMake(sX, sY) rightPoint:CGPointMake(eX, eY)];
    }

    [self manageCell:cell forIndexPath:indexPath];
}

- (IBAction)handleAddWP:(id)sender
{
    [self.view endEditing:YES];

    if (isRecordingStarted) {
        [_btnRecording sendActionsForControlEvents:UIControlEventTouchUpInside];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sender != nil) {
                LocationCell* cell = (LocationCell*)[self getCellForClassName:NSStringFromClass([LocationCell class]) withSender:sender];

                if ([cell.btnEdit.imageView.image isEqual:[UIImage imageNamed:@"lock"]]) {
                    [cell.lblDistanceUnit setHidden:NO];
                    [cell.btnEdit setHidden:YES];
                    if ([self->objConfig.unit isEqualToString:@"Kilometers"]) {
                        cell.lblDistanceUnit.text = @"KM";
                    } else {
                        cell.lblDistanceUnit.text = [self->objConfig.unit uppercaseString];
                    }
                    [cell.lblDistanceUnit setBackgroundColor:[UIColor whiteColor]];
                    [self.btnAdd setEnabled:TRUE];
                } else {
                    [cell.btnEdit setBackgroundColor:UIColor.blackColor];
                    [cell.lblDistanceUnit setHidden:NO];
                    [cell.btnEdit setHidden:YES];
                    [self.btnAdd setEnabled:FALSE];
                }

                if (self->isEditEnabled) {
                    NSIndexPath* idPath = [self.tblLocations indexPathForCell:cell];

                    if (idPath.section == TableViewSectionCurrentState) {
                        return;
                    }
                }

                if (((UIButton*)sender).tag != -1) {
                    self->isEditEnabled = !self->isEditEnabled;

                    if (self->isEditEnabled) {
                        [self.tblLocations setScrollEnabled:NO];
                        self->strEditWayPointDescription = cell.txtView.text;
                        [self manageCell:cell forIndexPath:[self.tblLocations indexPathForCell:cell]];
                    } else {
                        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(Locations* objLocation, NSDictionary<NSString*, id>* _Nullable bindings) {
                            return objLocation.locationId == ((UIButton*)sender).tag;
                        }];

                        NSMutableArray* arrSearchResults = [[NSMutableArray alloc] init];
                        arrSearchResults = [[self->arrAllLocations filteredArrayUsingPredicate:predicate] mutableCopy];

                        if (arrSearchResults.count > 0) {
                            NSUInteger index = [self->arrAllLocations indexOfObject:[arrSearchResults firstObject]];
                            Locations* objLocation = [arrSearchResults firstObject];
                            objLocation.text = self->strEditWayPointDescription;
                            if (self->imgEditCaptured != nil) {
                                objLocation.photos = @[ self->imgEditCaptured ];
                            }

                            if (self->audioEditData != nil) {
                                objLocation.audios = @[ self->audioEditData ];
                            }

                            [self->arrAllLocations replaceObjectAtIndex:index withObject:objLocation];

                            NSIndexPath* indexPath = [self.tblLocations indexPathForCell:cell];
                            [self.tblLocations reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                        }

                        [self playAudio:@"beep1_02" fileType:@"mp3"];
                        NSString* strWayPointId = [NSString stringWithFormat:@"%d", (int)((UIButton*)sender).tag];
                        [self saveDataForUpdatingWayPoint:strWayPointId];
                        [self.tblLocations setScrollEnabled:YES];
                        self->audioEditData = nil;
                        self->imgEditCaptured = nil;
                        self->strEditWayPointDescription = @"";
                        [self manageCell:cell forIndexPath:[self.tblLocations indexPathForCell:cell]];
                    }

                    return;
                }
            }

            self->isCapturing = YES;

            NSMutableArray* arrIndexes = [[NSMutableArray alloc] init];

            for (NSInteger i = 0; i < self->arrAllLocations.count; i++) {
                Locations* objLocation = [self->arrAllLocations objectAtIndex:i];
                CLLocation* location = [[CLLocation alloc] initWithLatitude:objLocation.latitude longitude:objLocation.longitude];

                if (objLocation.isWayPoint) {
                    break;
                }

                if ([location distanceFromLocation:self->currentLocation] < /*objConfig.accuracy.minDistanceTrackpoint*/ 50) {
                    [arrIndexes addObject:objLocation];
                } else {
                    break;
                }
            }

            [self->arrAllLocations removeObjectsInArray:arrIndexes];

            self->counter = self->arrAllLocations.count;

            arrIndexes = [[NSMutableArray alloc] init];

            for (NSInteger i = self->arrRemainingTracks.count - 1; i >= 0; i--) {
                NSDictionary* dic = [self->arrRemainingTracks objectAtIndex:i];
                NSDictionary* dicValue = [dic valueForKey:@"value"];
                Waypoints* objWayPoint = [[Waypoints alloc] initWithDictionary:dicValue];
                CLLocation* location1 = [[CLLocation alloc] initWithLatitude:objWayPoint.lat longitude:objWayPoint.lon];

                if ([location1 distanceFromLocation:self->currentLocation] < /*objConfig.accuracy.minDistanceTrackpoint*/ 50) {
                    [arrIndexes addObject:dic];
                } else {
                    break;
                }
            }

            [self->arrRemainingTracks removeObjectsInArray:arrIndexes];

            if (self->isAutoPhotoEnabled && self->imgCaptured == nil) {
                [self.session startRunning];
                [self capturePhoto];
                [self handleAutoPhoto];
                return;
            }

            [self uploadData];
        });
    });
}

- (void)saveDataForUpdatingWayPoint:(NSString*)strWPId
{
    NSString* strImageData = nil;
    NSString* strAudData = nil;

    if (imgEditCaptured != nil) {
        NSData* data = UIImagePNGRepresentation(imgEditCaptured);
        strImageData = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }

    if (audioEditData != nil) {
        strAudData = [audioEditData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }

    NSMutableDictionary* dicParam = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setValue:strWPId forKey:@"wayPointId"];
    if (strEditWayPointDescription == nil) {
        strEditWayPointDescription = @"";
    }
    [dic setValue:strEditWayPointDescription forKey:@"wayPointDesc"];

    [dicParam setValue:[NSNumber numberWithInteger:[_strRouteIdentifier doubleValue]] forKey:@"routeIdentifier"];
    [dicParam setValue:[RallyNavigatorConstants generateJsonStringFromObject:dic] forKey:@"jsonData"];
    [dicParam setValue:[NSNumber numberWithInteger:0] forKey:@"jsonDataType"];
    [dicParam setValue:[NSNumber numberWithInteger:1] forKey:@"isEdit"];
    [dicParam setValue:[NSNumber numberWithInteger:ServiceTypeJSON] forKey:@"serviceType"];
    [dicParam setValue:[NSNumber numberWithInteger:0] forKey:@"isActive"];
    [dicParam setValue:[self getCurrentUTCTime] forKey:@"updatedAt"];
    [dicParam setValue:_strRouteName forKey:@"name"];

    [dicParam setValue:[NSNumber numberWithBool:isAutoPhotoEnabled] forKey:@"isAutoPhoto"];

    if (_currentDistanceUnitsType == DistanceUnitsTypeKilometers) {
        [dicParam setValue:@"Kilometers" forKey:@"distanceUnit"];
    } else {
        [dicParam setValue:@"Miles" forKey:@"distanceUnit"];
    }

    [dicParam setValue:strImageData forKey:@"imageData"];
    [dicParam setValue:strAudData forKey:@"voiceData"];

    [CoreDataAdaptor SaveDataInCoreDB:dicParam forEntity:NSStringFromClass([CDSyncData class])];

    if (AppContext.isWebServiceIsCalling) {
        NSInteger totalWP = AppContext.totalWayPoints;
        totalWP = totalWP + 1;
        AppContext.totalWayPoints = totalWP;
    } else if ([ReachabilityManager isReachable] && !AppContext.isWebServiceIsCalling) {
        //        AppContext.isWebServiceIsCalling = YES;
        NSArray* arrCDUser = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:@"isActive = 0"]] all];

        AppContext.isWebServiceIsCalling = YES;
        AppContext.totalWayPoints = arrCDUser.count;
        AppContext.syncedWayPoints = 0;

        //        NSLog(@"Web Service 1");
        [AppContext checkForSyncData];
    }
}

- (void)uploadData
{
    @autoreleasepool {
        [self playAudio:@"beep1_02" fileType:@"mp3"];
        isCapturing = NO;
        isWayPointAdded = YES;

        counter++;
        Waypoints* objWayPoint = [self generateWayPointId:counter
                                                 location:currentLocation
                                          withDescription:strWayPointDescription
                                               isWayPoint:YES
                                           withImageArray:imgCaptured == nil ? @[] : @[ imgCaptured ]
                                           withAudioArray:audioData == nil ? @[] : @[ audioData ]
                                                 isPaused:NO];
        NSData* data = nil;

        if (imgCaptured != nil) {
            data = UIImagePNGRepresentation(imgCaptured);
        }

        NSString* strImageData = nil;
        NSString* strAudData = nil;

        if (data != nil) {
            strImageData = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }

        if (audioData != nil) {
            strAudData = [audioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }

        [self generateWSDataWithLocation:currentLocation
                               forObject:objWayPoint
                           withImageData:strImageData
                             withAudData:strAudData
                         forWayPointType:WayPointTypeNormal
                          isForFirstTime:_isFirstTime];

        imgCaptured = nil;
        audioData = nil;
        strWayPointDescription = @"";
        _isFirstTime = NO;
        isStart = YES;
    }
}

- (void)handleAutoPhoto
{
    if (imgCaptured == nil) {
        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [cell.btnEdit setHidden:YES];
        [cell.lblDistanceUnit setHidden:NO];
        [self performSelector:@selector(handleAutoPhoto) withObject:nil afterDelay:0.01];
    } else {
        [self uploadData];
    }
}

#pragma mark - Audio Recorder Delegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag
{
    isAnimate = NO;
    isRecording = NO;

    if (!isEditEnabled) {
        [_btnRecording.imageView setAlpha:1.0];
        [_btnRecording setImage:[UIImage imageNamed:@"img_save_voice"] forState:UIControlStateNormal];
    }

    [self stopRecording];

    NSError* error = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:strMediaPath toPath:strMainMediaPath error:&error];
    NSData* mediaData = [NSData dataWithContentsOfFile:strMediaPath];
    [self didRecordAudio:mediaData isManual:isManual];
}

- (void)didRecordAudio:(NSData*)data isManual:(BOOL)isManuallyStopped
{
    if (isEditEnabled) {
        audioEditData = data;
        isRecordingStarted = NO;
        [btnFlashing.imageView setAlpha:1.0];
        [btnFlashing setImage:[UIImage imageNamed:@"smallMicrophone"] forState:UIControlStateNormal];
    } else {
        audioData = data;
        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewSectionCurrentState]];
        [cell.btnStartRecording setHidden:NO];

        if (!isManuallyStopped) {
            isRecordingStarted = NO;
            [self handleAddWP:nil];
            [_btnAdd setEnabled:TRUE];
        }

        isRecordingStarted = NO;
        [_btnRecording.imageView setAlpha:1.0];
        [_btnRecording setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        NSError* err;
        [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    }
}

- (void)clickOnCloseRecordPopUp
{
    isRecordingStarted = NO;
}

#pragma mark - Process For Image

- (void)startCameraSession
{
    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
        case AVCamSetupResultSuccess: {
            [self addObservers];
            [self.session startRunning];
            self.sessionRunning = self.session.isRunning;

            if (self.isFirstTime && self->arrMapBoxMarkers.count == 1 && self->isAutoPhotoEnabled && self->imgCaptured == nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self capturePhoto];
                });
            }
        } break;

        case AVCamSetupResultCameraNotAuthorized: {
            [AlertManager confirm:@"AVCam doesn't have permission to use the camera, please change privacy settings"
                            title:@"AVCam"
                         negative:@"SETTINGS"
                         positive:@"OK"
                       onNegative:^{
                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                       }
                       onPositive:NULL];
        } break;

        case AVCamSetupResultSessionConfigurationFailed: {
            [AlertManager alert:@"Unable to capture media" title:@"AVCam" imageName:@"ic_error" onConfirm:NULL];
        } break;
        }
    });
}

- (void)configureVCForCamera
{
    self.session = [[AVCaptureSession alloc] init];

    NSArray<AVCaptureDeviceType>* deviceTypes = @[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera ];

    self.videoDeviceDiscoverySession =
        [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes
                                                               mediaType:AVMediaTypeVideo
                                                                position:AVCaptureDevicePositionUnspecified];

    self.previewView.session = self.session;
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.setupResult = AVCamSetupResultSuccess;

    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
    case AVAuthorizationStatusAuthorized: {
    } break;

    case AVAuthorizationStatusNotDetermined: {
        dispatch_suspend(self.sessionQueue);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (!granted) {
                                         self.setupResult = AVCamSetupResultCameraNotAuthorized;
                                     }
                                     dispatch_resume(self.sessionQueue);
                                 }];
    } break;

    default: {
        self.setupResult = AVCamSetupResultCameraNotAuthorized;
    } break;
    }

    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.view endEditing:YES];

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.previewView.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

- (void)capturePhoto
{
    if (_sessionQueue == NULL) {
        return;
    }

    @autoreleasepool {
        AVCaptureVideoOrientation videoPreviewLayerVideoOrientation = self.previewView.videoPreviewLayer.connection.videoOrientation;

        dispatch_async(_sessionQueue, ^{

            AVCaptureConnection* photoOutputConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
            photoOutputConnection.videoOrientation = videoPreviewLayerVideoOrientation;

            AVCapturePhotoSettings* photoSettings = [AVCapturePhotoSettings photoSettings];

            if (self.videoDeviceInput.device.isFlashAvailable) {
                photoSettings.flashMode = AVCaptureFlashModeOff;
            }

            photoSettings.highResolutionPhotoEnabled = NO;

            if (@available(iOS 11.0, *)) {
                photoSettings.depthDataDeliveryEnabled = NO;
            }

            AVCamPhotoCaptureDelegate* photoCaptureDelegate =
                [[AVCamPhotoCaptureDelegate alloc] initWithRequestedPhotoSettings:photoSettings
                    willCapturePhotoAnimation:^{
                    }
                    livePhotoCaptureHandler:^(BOOL capturing) {
                        dispatch_async(self.sessionQueue, ^{
                            if (capturing) {
                                self.inProgressLivePhotoCapturesCount++;
                            } else {
                                self.inProgressLivePhotoCapturesCount--;
                            }
                        });
                    }
                    completionHandler:^(AVCamPhotoCaptureDelegate* photoCaptureDelegate) {
                        dispatch_async(self.sessionQueue, ^{
                            self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = nil;
                            self.inProgressPhotoCaptureDelegates = [[NSMutableDictionary alloc] init];
                        });
                    }];
            photoCaptureDelegate.vc = self;
            self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = photoCaptureDelegate;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:photoCaptureDelegate];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.photoOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettings] delegate:photoCaptureDelegate];
                });
            }
        });
    }
}

- (void)didCapturedImage:(NSData*)imageData
{
    if (isEditEnabled) {
        imgEditCaptured = [Function compressImage:[UIImage imageWithData:imageData]];
        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:selectedIndexPath];
        [cell.btnAddPhoto setImage:imgEditCaptured forState:UIControlStateNormal];
        [cell.btnAddPhoto setTitle:@"" forState:UIControlStateNormal];
    } else {
        imgCaptured = [Function compressImage:[UIImage imageWithData:imageData]];
        LocationCell* cell = [_tblLocations cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.imgWayPoint.image = imgCaptured;
    }
}

- (void)configureSession
{
    if (self.setupResult != AVCamSetupResultSuccess) {
        return;
    }

    NSError* error = nil;
    [self.session beginConfiguration];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;

    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];

    if (!videoDevice) {
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];

        if (!videoDevice) {
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }

    AVCaptureDeviceInput* videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];

    if (!videoDeviceInput) {
        NSLog(@"Could not create video device input: %@", error);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }

    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        self.videoDeviceInput = videoDeviceInput;

        dispatch_async(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }

            self.previewView.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
        });
    } else {
        NSLog(@"Could not add video device input to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }

    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];

    if (!audioDeviceInput) {
        NSLog(@"Could not create audio device input: %@", error);
    }

    if ([self.session canAddInput:audioDeviceInput]) {
        [self.session addInput:audioDeviceInput];
    } else {
        NSLog(@"Could not add audio device input to the session");
    }

    AVCapturePhotoOutput* photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.session canAddOutput:photoOutput]) {
        [self.session addOutput:photoOutput];
        self.photoOutput = photoOutput;

        self.photoOutput.highResolutionCaptureEnabled = NO;
        self.photoOutput.livePhotoCaptureEnabled = NO;

        if (@available(iOS 11.0, *)) {
            self.photoOutput.depthDataDeliveryEnabled = NO;
        }

        self.livePhotoMode = AVCamLivePhotoModeOff;
        if (@available(iOS 11.0, *)) {
            self.depthDataDeliveryMode = AVCamDepthDataDeliveryModeOff;
        }

        self.inProgressPhotoCaptureDelegates = [NSMutableDictionary dictionary];
        self.inProgressLivePhotoCapturesCount = 0;
    } else {
        NSLog(@"Could not add photo output to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }

    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    [self.session commitConfiguration];
}

- (BOOL)shouldAutorotate
{
    return !self.movieFileOutput.isRecording;
}

- (void)addObservers
{
    @try {
        [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
    } @catch (NSException* exception) {
        NSLog(@"%@", [exception description]);
    } @finally {
    }

    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    isRegisteredAsCaptureObserver = YES;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (context == SessionRunningContext) {

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)subjectAreaDidChange:(NSNotification*)notification
{
    CGPoint devicePoint = CGPointMake(0.5, 0.5);
    [self focusWithMode:AVCaptureFocusModeLocked
                  exposeWithMode:AVCaptureExposureModeLocked
                   atDevicePoint:devicePoint
        monitorSubjectAreaChange:NO];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
              exposeWithMode:(AVCaptureExposureMode)exposureMode
               atDevicePoint:(CGPoint)point
    monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice* device = self.videoDeviceInput.device;
        NSError* error = nil;
        if ([device lockForConfiguration:&error]) {
            if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode]) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }

            if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }

            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        } else {
            NSLog(@"Could not lock device for configuration: %@", error);
        }
    });
}

- (void)sessionRuntimeError:(NSNotification*)notification
{
    NSError* error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog(@"Capture session runtime error: %@", error);

    if (error.code == AVErrorMediaServicesWereReset) {
        dispatch_async(self.sessionQueue, ^{
            if (self.isSessionRunning) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
        });
    }
}

- (void)sessionWasInterrupted:(NSNotification*)notification
{
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog(@"Capture session was interrupted with reason %ld", (long)reason);
}

- (void)sessionInterruptionEnded:(NSNotification*)notification
{
    NSLog(@"Capture session interruption ended");
}

#pragma mark - SettingVC delegate

- (void)newRecording
{
    [self.view endEditing:YES];

    if (arrRemainingTracks.count > 0) {
        [AlertManager showWithImage:NULL
                             labels:@[
                                 [AlertManager labelWithText:@"Save Changes"
                                                       color:UIColor.whiteColor
                                                        size:1],
                                 [AlertManager labelWithText:@"Do you want to save changes for this route?"
                                                       color:UIColor.lightGrayColor
                                                        size:0]
                             ]
                         textFields:@[]
                            buttons:@[
                                [AlertManager buttonWithTitle:@"SAVE"
                                                       action:^(NSArray<NSString*>* _Nonnull values) {
                                                           [self btnStopAndSaveClicked];
                                                       }
                                                    isDefault:YES
                                                 needValidate:NO],
                                [AlertManager buttonWithTitle:@"DON'T SAVE"
                                                       action:^(NSArray<NSString*>* _Nonnull values) {
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }
                                                    isDefault:NO
                                                 needValidate:NO],
                                [AlertManager buttonWithTitle:@"CANCEL"
                                                       action:NULL
                                                    isDefault:NO
                                                 needValidate:NO]
                            ]];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveRoadbook
{
    [self btnStopAndSaveClicked];
}

- (void)overlayTrack
{
    RoadBooksVC* vc = loadViewController(StoryBoard_Main, kIDRoadBooksVC);
    vc.isOverlayTrack = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearOverlay
{
    overlaySender = nil;

    [_mapBoxView removeAnnotation:o_polylineMapBox];
    [_mapBoxView removeAnnotations:arrMapBoxMarkers1];

    o_polylineMapBox = nil;
}

- (void)clickedOnLogout
{
    [AlertManager confirm:@"Are you sure you want to log out?"
                    title:@"Confirm Logout"
                 negative:@"CANCEL"
                 positive:@"YES"
               onNegative:NULL
               onPositive:^{
                   [[GIDSignIn sharedInstance] signOut];

                   [DefaultsValues setBooleanValueToUserDefaults:NO ForKey:kLogIn];
                   [self.navigationController popToRootViewControllerAnimated:YES];
               }];
}

#pragma mark - Pick Roadbook Delegate Methods

- (void)didPickRoadbookWithId:(NSString*)strRoadbookId
{
    if (_currentViewType == ViewTypeListView) {
        [self btnToggelMapClicked:nil];
    }

    BOOL isConnectionAvailable = [[WebServiceConnector alloc] checkNetConnection];

    overlayName = [self manageForRouteId:[NSString stringWithFormat:@"routeIdentifier='%@'", strRoadbookId]];

    if (isConnectionAvailable && ([strRoadbookId doubleValue] > 0)) {
        [[WebServiceConnector alloc] init:[[URLGetRouteDetails stringByAppendingString:@"/"] stringByAppendingString:strRoadbookId]
                           withParameters:nil
                               withObject:self
                             withSelector:@selector(handlePickedRouteDetailsResponse:)
                           forServiceType:ServiceTypeGET
                           showDisplayMsg:@""
                               showLoader:YES];
    }
}

- (IBAction)handlePickedRouteDetailsResponse:(id)sender
{
    overlaySender = sender;

    NSArray* arrResponse = [self validateResponse:sender
                                       forKeyName:RouteKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0) {
        Route* objRoute = [arrResponse firstObject];
        NSString* strRoadBookId = [NSString stringWithFormat:@"routeIdentifier='%f'", objRoute.routeIdentifier];
        [self manageForRouteId:strRoadBookId];
    } else {
        [self showErrorInObject:self forDict:[sender responseDict]];
    }
}

- (NSString*)manageForRouteId:(NSString*)strRouteId
{
    NSString* strRoadBookId = strRouteId;
    NSArray* arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];
    NSArray* arrNonSyncData = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND isActive = 0 AND isEdit = 0", strRoadBookId]]] all];
    NSMutableArray* arrLocalNonSyncData = [self processForLocalLocationsForArray:arrNonSyncData];

    NSMutableArray* arrAllLocations1 = [[NSMutableArray alloc] init];

    [_mapBoxView removeAnnotations:arrMapBoxMarkers1];

    arrMapBoxMarkers1 = [[NSMutableArray alloc] init];

    NSString* routeName;

    if (arrSyncedData.count > 0) {
        CDRoute* objRoute = [arrSyncedData firstObject];
        routeName = objRoute.name;
        NSDictionary* jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objRoute.data];
        RouteDetails* objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];
        objRouteDetails.waypoints = [[objRouteDetails.waypoints reverseObjectEnumerator] allObjects];

        for (Waypoints* objWP in objRouteDetails.waypoints) {
            Locations* objLocation = [[Locations alloc] init];
            objLocation.locationId = arrAllLocations.count;
            objLocation.latitude = objWP.lat;
            objLocation.longitude = objWP.lon;
            objLocation.text = objWP.wayPointDescription;
            objLocation.isWayPoint = objWP.show;
            objLocation.imageUrl = objWP.backgroundimage.url;
            objLocation.audioUrl = objWP.voiceNote.url;
            [arrAllLocations1 addObject:objLocation];
            if (objLocation.isWayPoint) {
                MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                marker1.coordinate = CLLocationCoordinate2DMake(objLocation.latitude, objLocation.longitude);
                marker1.title = @"Test Name1";
                [_mapBoxView addAnnotation:marker1];
                [arrMapBoxMarkers1 addObject:marker1];
            }
        }
    } else if (arrNonSyncData.count > 0) {
        CDSyncData* data = arrNonSyncData[0];
        routeName = data.name;
    }

    NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [arrLocalNonSyncData count])];
    [arrAllLocations1 insertObjects:[[arrLocalNonSyncData reverseObjectEnumerator] allObjects] atIndexes:indexes];

    NSMutableArray* arrGeoLocations = [[NSMutableArray alloc] init];

    for (Locations* objLocation in arrAllLocations1) {
        [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objLocation.longitude], [NSNumber numberWithDouble:objLocation.latitude], nil]];
    }

    if (arrGeoLocations.count > 0) {
        NSMutableDictionary* dicGeometry = [[NSMutableDictionary alloc] init];
        [dicGeometry setValue:@"LineString" forKey:@"type"];
        [dicGeometry setObject:arrGeoLocations forKey:@"coordinates"];

        NSMutableDictionary* dicName = [[NSMutableDictionary alloc] init];
        [dicName setValue:@"Test Name" forKey:@"name"];

        NSMutableDictionary* dicData = [[NSMutableDictionary alloc] init];
        [dicData setValue:@"Feature" forKey:@"type"];
        [dicData setObject:dicName forKey:@"properties"];
        [dicData setObject:dicGeometry forKey:@"geometry"];

        NSArray* arrFeatures = [NSArray arrayWithObjects:dicData, nil];

        NSMutableDictionary* dicGeoJson = [[NSMutableDictionary alloc] init];
        [dicGeoJson setValue:@"FeatureCollection" forKey:@"type"];
        [dicGeoJson setValue:arrFeatures forKey:@"features"];

        NSError* error;
        NSData* strJsonData = [NSJSONSerialization dataWithJSONObject:dicGeoJson options:NSJSONWritingPrettyPrinted error:&error];

        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(backgroundQueue, ^(void) {
            MGLShapeCollectionFeature* shapeCollectionFeature = (MGLShapeCollectionFeature*)[MGLShape shapeWithData:strJsonData encoding:NSUTF8StringEncoding error:NULL];

            MGLPolylineFeature* temp = self->o_polylineMapBox;
            self->o_polylineMapBox = (MGLPolylineFeature*)shapeCollectionFeature.shapes.firstObject;

            self->o_polylineMapBox.title = self->polylineMapBox.attributes[@"Test Name1"]; // "Crema to Council Crest"

            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [weakSelf.mapBoxView addAnnotation:self->o_polylineMapBox];
                [weakSelf.mapBoxView removeAnnotation:temp];
            });
        });
    }

    mCamera = nil;
    _currentPreference = ViewingPreferenceCurrentLocationTrackUp;
    [self btnTogglePreferrenceClicked:nil];

    return routeName;
}

@end
