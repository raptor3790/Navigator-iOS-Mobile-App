//
//  DownloadMapVC.m
//  RallyNavigator
//
//  Created by C205 on 14/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "DownloadMapVC.h"
#import "ZoomLevelVC.h"
#import "LocationsVC.h"
#import "PickRoadBookVC.h"

#import "Route.h"
#import "Waypoints.h"
#import "CDSyncData.h"
#import "Locations.h"

@interface DownloadMapVC () <MGLMapViewDelegate, ZoomLevelVCDelegate> {
    BOOL isLoaded, isSetUp, isLocated, isPoped;

    NSMutableArray* arrMapMarkers;
    NSMutableArray* arrAllMapMarkers;
    NSMutableArray* arrGeoLocations;

    MGLOfflinePack* d_Pack;
    MGLCoordinateBounds cordBounds;
}

@property (nonatomic) MGLMapView* mapView;

@end

@implementation DownloadMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _strMapName;

    [self setUpLayout];
    [self setUpMap];

    if (_currentPack) {
        _btnStyle.hidden = YES;
        _lblDownloadProgress.hidden = NO;
        _downloadProgressView.hidden = NO;

        if (_currentPack.state == MGLOfflinePackStateComplete) {
            [_downloadProgressView setProgress:1];
        } else {
            MGLOfflinePackProgress progress = _currentPack.progress;
            uint64_t completedResources = progress.countOfResourcesCompleted;
            uint64_t expectedResources = progress.countOfResourcesExpected;

            float progressPercentage = (float)completedResources / expectedResources;
            [_downloadProgressView setProgress:progressPercentage];
            _lblDownloadProgress.text = [NSString stringWithFormat:@"%.2f%%", progressPercentage * 100];
        }
    } else {
        _maxZoomLevel = 14;

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

        _btnDownload = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"download") style:UIBarButtonItemStyleDone target:self action:@selector(btnDownloadClicked:)];
        _btnDownload.enabled = NO;

        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
        _downloadProgressView.transform = transform;

        if (_overlaySender) {
            UIBarButtonItem* btnCancel = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"cancel_icon") style:UIBarButtonItemStylePlain target:self action:@selector(btnDismissClicked:)];

            self.navigationItem.rightBarButtonItems = @[ btnCancel, _btnDownload ];

            [self handleRouteDetailsResponse:_overlaySender];
        } else {
            self.navigationItem.rightBarButtonItems = @[ _btnDownload ];
        }
    }

    [self.view sendSubviewToBack:_mapView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setUpObservers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([self isMovingFromParentViewController]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Manage Layout

- (void)setUpLayout
{
    _btnStyle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _btnStyle.layer.borderWidth = 2.0f;
    _btnStyle.layer.cornerRadius = CGRectGetHeight(_btnStyle.frame) / 2.0f;
    _btnStyle.clipsToBounds = YES;
}

#pragma mark - Set Up Map

- (void)setUpMap
{
    _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];

    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.compassView.hidden = YES;
    _mapView.attributionButton.hidden = YES;
    _mapView.rotateEnabled = NO;
    [_mapView setMinimumZoomLevel:4];
    [_mapView setMaximumZoomLevel:14];

    if (_currentPack) {
        _mapView.userInteractionEnabled = NO;
        MGLTilePyramidOfflineRegion* region = (MGLTilePyramidOfflineRegion*)_currentPack.region;
        _mapView.styleURL = region.styleURL;
        [self setStyle];
        [_mapView setVisibleCoordinateBounds:region.bounds edgePadding:UIEdgeInsetsMake(CGRectGetHeight(_lblOverlay1.frame), CGRectGetHeight(_lblOverlay1.frame), CGRectGetHeight(_lblOverlay4.frame), CGRectGetHeight(_lblOverlay1.frame)) animated:NO];
        _mapView.zoomLevel = region.minimumZoomLevel;
    } else {
        [self manageStyle];
    }

    [self.view addSubview:_mapView];
}

- (void)setStyle
{
    if ([_mapView.styleURL isEqual:[MGLStyle streetsStyleURL]]) {
        _curMapStyle = CurrentMapStyleStreets;
    } else if ([_mapView.styleURL isEqual:[MGLStyle satelliteStreetsStyleURL]]) {
        _curMapStyle = CurrentMapStyleSatellite;
    }
}

- (void)manageStyle
{
    switch (_curMapStyle) {
    case CurrentMapStyleStreets: {
        _mapView.styleURL = [MGLStyle streetsStyleURL];
    } break;

    case CurrentMapStyleSatellite: {
        _mapView.styleURL = [MGLStyle satelliteStreetsStyleURL];
    } break;

    default:
        break;
    }
}

#pragma mark - Set Up Observers

- (void)setUpObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlinePackProgressDidChange:)
                                                 name:MGLOfflinePackProgressChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlinePackDidReceiveError:)
                                                 name:MGLOfflinePackErrorNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlinePackDidReceiveMaximumAllowedMapboxTiles:)
                                                 name:MGLOfflinePackMaximumMapboxTilesReachedNotification
                                               object:nil];
}

#pragma mark - Web Service Handler

- (void)handleRouteDetailsResponse:(id)sender
{
    NSDictionary* dic = sender;

    [_mapView addAnnotations:[dic valueForKey:@"markers"]];

    [_mapView showAnnotations:[dic valueForKey:@"markers"] edgePadding:UIEdgeInsetsMake(CGRectGetHeight(_lblOverlay1.frame) + 30, CGRectGetWidth(_lblOverlay2.frame) + 30, CGRectGetHeight(_lblOverlay4.frame) + 30, CGRectGetWidth(_lblOverlay3.frame) + 30) animated:NO];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [weakSelf.mapView addAnnotation:[dic valueForKey:@"polyline"]];
    });

    /*return;
    
    NSArray *arrResponse = [self validateResponse:sender
                                       forKeyName:RouteKey
                                        forObject:self
                                        showError:YES];
    if (arrResponse.count > 0)
    {
        arrGeoLocations = [[NSMutableArray alloc] init];

        Route *objRoute = [arrResponse firstObject];

        NSString *strRoadBookId = [NSString stringWithFormat:@"routeIdentifier='%f'", objRoute.routeIdentifier];
        NSArray *arrSyncedData = [[[CDRoute query] where:[NSPredicate predicateWithFormat:strRoadBookId]] all];
        NSArray *arrNonSyncData = [[[CDSyncData query] where:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND isActive = 0 AND isEdit = 0", strRoadBookId]]] all];

        NSMutableArray *arrAllLocations1 = [[NSMutableArray alloc] init];

        [_mapView removeAnnotations:arrMapMarkers];

        arrMapMarkers = [[NSMutableArray alloc] init];
        arrAllMapMarkers = [[NSMutableArray alloc] init];

        if (arrSyncedData.count > 0)
        {
            CDRoute *objRoute = [arrSyncedData firstObject];
            NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objRoute.data];
            RouteDetails *objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];
            objRouteDetails.waypoints = [[objRouteDetails.waypoints reverseObjectEnumerator] allObjects];

            for (Waypoints *objWP in objRouteDetails.waypoints)
            {
                [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objWP.lon], [NSNumber numberWithDouble:objWP.lat], nil]];

                MGLPointAnnotation *marker1 = [[MGLPointAnnotation alloc] init];
                marker1.coordinate = CLLocationCoordinate2DMake(objWP.lat, objWP.lon);
                marker1.title = @"Test Name1";
                [arrAllMapMarkers addObject:marker1];

                if (objWP.show)
                {
                    [_mapView addAnnotation:marker1];
                    [arrMapMarkers addObject:marker1];
                }
            }
        }

        NSMutableArray *arrLocalNonSyncData = [self processForLocalLocationsForArray:arrNonSyncData];

        [_mapView showAnnotations:arrAllMapMarkers edgePadding:UIEdgeInsetsMake(CGRectGetHeight(_lblOverlay1.frame) + 30, CGRectGetWidth(_lblOverlay2.frame) + 30, CGRectGetHeight(_lblOverlay4.frame) + 30, CGRectGetWidth(_lblOverlay3.frame) + 30) animated:NO];

        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [arrLocalNonSyncData count])];
        [arrAllLocations1 insertObjects:[[arrLocalNonSyncData reverseObjectEnumerator] allObjects] atIndexes:indexes];

        if (arrGeoLocations.count > 0)
        {
            NSMutableDictionary *dicGeometry = [[NSMutableDictionary alloc] init];
            [dicGeometry setValue:@"LineString" forKey:@"type"];
            [dicGeometry setObject:arrGeoLocations forKey:@"coordinates"];

            NSMutableDictionary *dicName = [[NSMutableDictionary alloc] init];
            [dicName setValue:@"Test Name" forKey:@"name"];

            NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
            [dicData setValue:@"Feature" forKey:@"type"];
            [dicData setObject:dicName forKey:@"properties"];
            [dicData setObject:dicGeometry forKey:@"geometry"];

            NSArray *arrFeatures = [NSArray arrayWithObjects:dicData, nil];

            NSMutableDictionary *dicGeoJson = [[NSMutableDictionary alloc] init];
            [dicGeoJson setValue:@"FeatureCollection" forKey:@"type"];
            [dicGeoJson setValue:arrFeatures forKey:@"features"];

            NSError *error;
            NSData *strJsonData = [NSJSONSerialization dataWithJSONObject:dicGeoJson options:NSJSONWritingPrettyPrinted error:&error];

            dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(backgroundQueue, ^(void) {
                MGLShapeCollectionFeature *shapeCollectionFeature = (MGLShapeCollectionFeature *)[MGLShape shapeWithData:strJsonData encoding:NSUTF8StringEncoding error:NULL];

                MGLPolylineFeature *o_polylineMapBox = (MGLPolylineFeature *)shapeCollectionFeature.shapes.firstObject;

                o_polylineMapBox.title = o_polylineMapBox.attributes[@"Test Name1"]; // "Crema to Council Crest"

                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [weakSelf.mapView addAnnotation:o_polylineMapBox];
                });
            });
        }
    }*/
}

- (NSMutableArray*)processForLocalLocationsForArray:(NSArray*)arrLocalLocations
{
    NSMutableArray* arrLData = [[NSMutableArray alloc] init];

    for (int i = 0; i < arrLocalLocations.count; i++) {
        // TO DO: MAKE CHANGES
        CDSyncData* objSync = [arrLocalLocations objectAtIndex:i];

        id object = [[RallyNavigatorConstants convertJsonStringToObject:objSync.jsonData] mutableCopy];

        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary* arrOperations = object;
            RouteDetails* obj = [[RouteDetails alloc] initWithDictionary:arrOperations];
            Waypoints* objRoute = obj.waypoints[0];

            [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objRoute.lon], [NSNumber numberWithDouble:objRoute.lat], nil]];

            MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
            marker1.coordinate = CLLocationCoordinate2DMake(objRoute.lat, objRoute.lon);
            marker1.title = @"Test Name";
            [arrAllMapMarkers addObject:marker1];

            if (objRoute.show) {
                [_mapView addAnnotation:marker1];
                [arrMapMarkers addObject:marker1];
            }
        } else {
            NSMutableArray* arrOperations = [object mutableCopy];
            for (NSDictionary* dic in arrOperations) {
                if ([dic objectForKey:@"op"]) {
                    if ([[dic valueForKey:@"op"] isEqualToString:@"add"]) {
                        Waypoints* objRoute = [[Waypoints alloc] initWithDictionary:[dic valueForKey:@"value"]];
                        [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objRoute.lon], [NSNumber numberWithDouble:objRoute.lat], nil]];

                        MGLPointAnnotation* marker1 = [[MGLPointAnnotation alloc] init];
                        marker1.coordinate = CLLocationCoordinate2DMake(objRoute.lat, objRoute.lon);
                        marker1.title = @"Test Name";
                        [arrAllMapMarkers addObject:marker1];

                        if (objRoute.show) {
                            [_mapView addAnnotation:marker1];
                            [arrMapMarkers addObject:marker1];
                        }
                    }
                }
            }
        }
    }

    return arrLData;
}

#pragma mark - Download Map

- (void)startOfflinePackDownload
{
    NSLog(@"%f", self.mapView.zoomLevel);

    _downloadProgressView.hidden = NO;
    _lblDownloadProgress.hidden = NO;

    id<MGLOfflineRegion> region = [[MGLTilePyramidOfflineRegion alloc] initWithStyleURL:self.mapView.styleURL
                                                                                 bounds:cordBounds
                                                                          fromZoomLevel:self.mapView.zoomLevel
                                                                            toZoomLevel:self.mapView.zoomLevel > _maxZoomLevel ? self.mapView.zoomLevel : _maxZoomLevel];

    NSDictionary* userInfo = @{ @"name" : _strMapName };
    NSData* context = [NSKeyedArchiver archivedDataWithRootObject:userInfo];

    [[MGLOfflineStorage sharedOfflineStorage] addPackForRegion:region
                                                   withContext:context
                                             completionHandler:^(MGLOfflinePack* pack, NSError* error) {
                                                 if (error != nil) {
                                                     NSLog(@"Error: %@", error.localizedFailureReason);
                                                 } else {
                                                     self.mapView.userInteractionEnabled = NO;
                                                     self->d_Pack = pack;
                                                     [pack resume];
                                                 }
                                             }];
}

#pragma mark - Button Click Events

- (IBAction)btnDownloadClicked:(id)sender
{
    [self.view endEditing:YES];

    [AlertManager confirm:@"Are you sure you want to download this map?"
                    title:@"Download Map\n(WiFi Recommended)"
                 negative:@"CANCEL"
                 positive:@"YES"
               onNegative:NULL
               onPositive:^{
                   self.btnDownload.enabled = NO;
                   self.btnStyle.hidden = YES;

                   CLLocationCoordinate2D cord1 = [self.mapView convertPoint:CGPointMake(CGRectGetWidth(self.lblOverlay2.frame), CGRectGetMaxY(self.lblOverlay2.frame)) toCoordinateFromView:self.view];
                   CLLocationCoordinate2D cord2 = [self.mapView convertPoint:CGPointMake(CGRectGetMinX(self.lblOverlay3.frame), CGRectGetMaxY(self.lblOverlay1.frame)) toCoordinateFromView:self.view];

                   self->cordBounds = MGLCoordinateBoundsMake(cord1, cord2);

                   [self startOfflinePackDownload];
               }];
}

- (IBAction)btnSettingsClicked:(id)sender
{
    [self.view endEditing:YES];

    ZoomLevelVC* vc = loadViewController(StoryBoard_Settings, kIDZoomLevelVC);
    vc.delegate = self;
    vc.curZoomLevel = _mapView.zoomLevel;
    _maxZoomLevel = self.mapView.zoomLevel > _maxZoomLevel ? self.mapView.zoomLevel : _maxZoomLevel;
    vc.maxZoomLevel = _maxZoomLevel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnStyleClicked:(id)sender
{
    [self.view endEditing:YES];

    switch (_curMapStyle) {
    case CurrentMapStyleStreets: {
        _mapView.styleURL = [MGLStyle satelliteStreetsStyleURL];
        _curMapStyle = CurrentMapStyleSatellite;
        [_btnStyle setTitle:@"S" forState:UIControlStateNormal];
        //            [_btnStyle setImage:Set_Local_Image(@"mountain_view") forState:UIControlStateNormal];
    } break;

    case CurrentMapStyleSatellite: {
        _mapView.styleURL = [MGLStyle streetsStyleURL];
        _curMapStyle = CurrentMapStyleStreets;
        [_btnStyle setTitle:@"M" forState:UIControlStateNormal];
        //            [_btnStyle setImage:Set_Local_Image(@"satellite_view") forState:UIControlStateNormal];
    } break;

    default:
        break;
    }
}

- (IBAction)btnDismissClicked:(id)sender
{
    [self.view endEditing:YES];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES
                                 completion:^{

                                     //            if ([_delegate respondsToSelector:@selector(didPickRoadbookWithId:)])
                                     //            {
                                     //                [((LocationsVC *)_delegate) didPickRoadbookWithId:_strRoadbookId];
                                     //            }
                                 }];
    });
}

#pragma mark - MapView Delegate Methods

- (void)mapViewDidFinishLoadingMap:(MGLMapView*)mapView
{
    isLoaded = YES;
    _btnDownload.enabled = _currentPack == nil;
}

- (void)mapView:(MGLMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (isLoaded && (_currentPack == nil) && (d_Pack == nil)) {
        //        _btnDownload.enabled = mapView.zoomLevel >= 7;
    }
}

- (void)mapView:(nonnull MGLMapView*)mapView didUpdateUserLocation:(nullable MGLUserLocation*)userLocation
{
    if (!_currentPack && !isLocated && !_overlaySender) {
        isLocated = YES;
        [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate
                            zoomLevel:12
                             animated:NO];
    }
}

- (MGLAnnotationImage*)mapView:(MGLMapView*)mapView imageForAnnotation:(id<MGLAnnotation>)annotation
{
    MGLAnnotationImage* annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"pisa1"];

    if (!annotationImage) {
        UIImage* image = [UIImage imageNamed:@"imgHexa_Point"];
        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height / 2, 0)];
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"pisa1"];
    }

    return annotationImage;
}

- (BOOL)mapView:(MGLMapView*)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation
{
    return NO;
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
    return [UIColor yellowColor];
}

#pragma mark - MGLOfflinePack notification handlers

- (void)offlinePackProgressDidChange:(NSNotification*)notification
{
    MGLOfflinePack* pack = notification.object;

    if (_currentPack) {
        if (_currentPack != pack) {
            return;
        }
    } else if (d_Pack) {
        if (d_Pack != pack) {
            return;
        }
    } else {
        return;
    }

    //    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];

    MGLOfflinePackProgress progress = pack.progress;

    uint64_t completedResources = progress.countOfResourcesCompleted;
    uint64_t expectedResources = progress.countOfResourcesExpected;

    float progressPercentage = (float)completedResources / expectedResources;

    [_downloadProgressView setProgress:progressPercentage animated:YES];

    if (completedResources == expectedResources) {
        _lblDownloadProgress.text = @"100%";

        //        NSString *byteCount = [NSByteCountFormatter stringFromByteCount:progress.countOfBytesCompleted countStyle:NSByteCountFormatterCountStyleMemory];
        //        NSLog(@"Offline pack “%@” completed: %@, %llu resources", userInfo[@"name"], byteCount, completedResources);
        if ([_delegate isKindOfClass:[LocationsVC class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else if ([_delegate respondsToSelector:@selector(didDownloadedMap)] && !isPoped) {
            isPoped = YES;
            [_delegate didDownloadedMap];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        //        NSLog(@"Offline pack “%@” has %llu of %llu resources — %.2f%%.", userInfo[@"name"], completedResources, expectedResources, progressPercentage * 100);
        _lblDownloadProgress.text = [NSString stringWithFormat:@"%.2f%%", progressPercentage * 100];
    }
}

- (void)offlinePackDidReceiveError:(NSNotification*)notification
{
    MGLOfflinePack* pack = notification.object;
    NSDictionary* userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    NSError* error = notification.userInfo[MGLOfflinePackUserInfoKeyError];
    NSLog(@"Offline pack “%@” received error: %@", userInfo[@"name"], error.localizedFailureReason);
}

- (void)offlinePackDidReceiveMaximumAllowedMapboxTiles:(NSNotification*)notification
{
    MGLOfflinePack* pack = notification.object;
    NSDictionary* userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    uint64_t maximumCount = [notification.userInfo[MGLOfflinePackUserInfoKeyMaximumCount] unsignedLongLongValue];
    NSLog(@"Offline pack “%@” reached limit of %llu tiles.", userInfo[@"name"], maximumCount);
}

@end
