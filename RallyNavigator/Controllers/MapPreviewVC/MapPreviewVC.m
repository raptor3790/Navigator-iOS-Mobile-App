//
//  MapPreviewVC.m
//  RallyNavigator
//
//  Created by C205 on 27/03/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "MapPreviewVC.h"
#import "Route.h"
#import "Waypoints.h"
#import "CDSyncData.h"
#import "Locations.h"

@interface MapPreviewVC () <MGLMapViewDelegate>
{
    NSMutableArray *arrMapMarkers;
    NSMutableArray *arrGeoLocations;
}

@property (nonatomic) MGLMapView *mapView;

@end

@implementation MapPreviewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Overlay Track";
    
    _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.compassView.hidden = YES;
    _mapView.attributionButton.hidden = YES;
    _mapView.rotateEnabled = NO;
    _mapView.styleURL = [MGLStyle satelliteStreetsStyleURL];
    [self.view addSubview:_mapView];
    
    [[WebServiceConnector alloc] init:[[URLGetRouteDetails stringByAppendingString:@"/"] stringByAppendingString:_strRoadbookId]
                       withParameters:nil
                           withObject:self
                         withSelector:@selector(handleRouteDetailsResponse1:)
                       forServiceType:ServiceTypeGET
                       showDisplayMsg:@""
                           showLoader:NO];
}

- (IBAction)handleRouteDetailsResponse1:(id)sender
{
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
        
        if (arrSyncedData.count > 0)
        {
            CDRoute *objRoute = [arrSyncedData firstObject];
            NSDictionary *jsonDict = [RallyNavigatorConstants convertJsonStringToObject:objRoute.data];
            RouteDetails *objRouteDetails = [[RouteDetails alloc] initWithDictionary:jsonDict];
            objRouteDetails.waypoints = [[objRouteDetails.waypoints reverseObjectEnumerator] allObjects];
            
            for (Waypoints *objWP in objRouteDetails.waypoints)
            {
                [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objWP.lon], [NSNumber numberWithDouble:objWP.lat], nil]];

                if (objWP.show)
                {
                    MGLPointAnnotation *marker1 = [[MGLPointAnnotation alloc] init];
                    marker1.coordinate = CLLocationCoordinate2DMake(objWP.lat, objWP.lon);
                    marker1.title = @"Test Name1";
                    [_mapView addAnnotation:marker1];
                    [arrMapMarkers addObject:marker1];
                }
            }
        }
        
        
        NSMutableArray *arrLocalNonSyncData = [self processForLocalLocationsForArray:arrNonSyncData];
        [_mapView showAnnotations:arrMapMarkers animated:NO];

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
                
                // Optionally set the title of the polyline, which can be used for:
                //  - Callout view
                //  - Object identification
                // In this case, set it to the name included in the GeoJSON
                o_polylineMapBox.title = o_polylineMapBox.attributes[@"Test Name1"]; // "Crema to Council Crest"
                
                // Add the polyline to the map, back on the main thread
                // Use weak reference to self to prevent retain cycle
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [weakSelf.mapView addAnnotation:o_polylineMapBox];
                });
            });
        }
    }
}

- (NSMutableArray *)processForLocalLocationsForArray:(NSArray *)arrLocalLocations
{
    NSMutableArray *arrLData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrLocalLocations.count; i++)
    {
        // TO DO: MAKE CHANGES
        CDSyncData *objSync = [arrLocalLocations objectAtIndex:i];
        
        id object = [[RallyNavigatorConstants convertJsonStringToObject:objSync.jsonData] mutableCopy];
        
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *arrOperations = object;
            RouteDetails *obj = [[RouteDetails alloc] initWithDictionary:arrOperations];
            Waypoints *objRoute = obj.waypoints[0];
            
            [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objRoute.lon], [NSNumber numberWithDouble:objRoute.lat], nil]];

            if (objRoute.show)
            {
                MGLPointAnnotation *marker1 = [[MGLPointAnnotation alloc] init];
                marker1.coordinate = CLLocationCoordinate2DMake(objRoute.lat, objRoute.lon);
                marker1.title = @"Test Name";
                [_mapView addAnnotation:marker1];
                [arrMapMarkers addObject:marker1];
            }
        }
        else
        {
            NSMutableArray *arrOperations = [object mutableCopy];
            for (NSDictionary*dic in arrOperations)
            {
                if ([dic objectForKey:@"op"])
                {
                    if ([[dic valueForKey:@"op"] isEqualToString:@"add"])
                    {
                        Waypoints *objRoute = [[Waypoints alloc] initWithDictionary:[dic valueForKey:@"value"]];
                        [arrGeoLocations addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:objRoute.lon], [NSNumber numberWithDouble:objRoute.lat], nil]];
                        if (objRoute.show)
                        {
                            MGLPointAnnotation *marker1 = [[MGLPointAnnotation alloc] init];
                            marker1.coordinate = CLLocationCoordinate2DMake(objRoute.lat, objRoute.lon);
                            marker1.title = @"Test Name";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation {
    
    NSLog(@"%@", annotation.title);
    
    MGLAnnotationImage *annotationImage;
    
    if ([annotation.title isEqualToString:@"Test Name"])
    {
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"pisa"];
        
        // If the ‘pisa’ annotation image hasn‘t been set yet, initialize it here.
        if (!annotationImage) {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            UIImage *image = [UIImage imageNamed:@"imgWay_Point"];
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"pisa"];
        }
    }
    else
    {
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"pisa1"];
        
        // If the ‘pisa’ annotation image hasn‘t been set yet, initialize it here.
        if (!annotationImage) {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            UIImage *image = [UIImage imageNamed:@"imgHexa_Point"];
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"pisa1"];
        }
    }
    
    return annotationImage;
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation
{
    return NO;
}

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation
{
    // Set the alpha for all shape annotations to 1 (full opacity)
    return 1.0f;
}

- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(MGLPolyline *)annotation
{
    // Set the line width for polyline annotations
    return 3.0f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    // Set the stroke color for shape annotations
    // ... but give our polyline a unique color by checking for its `title` property
    if ([annotation.title isEqualToString:@"Test Name"])
    {
        return [UIColor redColor];
    }
    else
    {
        return [UIColor yellowColor];
    }
}

@end
