/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Photo capture delegate.
*/

@import AVFoundation;

#import "LocationsVC.h"

@interface AVCamPhotoCaptureDelegate : NSObject<AVCapturePhotoCaptureDelegate>

@property (strong, nonatomic) LocationsVC *vc;

@property (assign, nonatomic) BOOL isWSFirstTime;

@property (strong, nonatomic) NSData *audData;
@property (assign, nonatomic) NSUInteger value;
@property (strong, nonatomic) NSString *strDisc;
@property (strong, nonatomic) CLLocation *location;
@property (assign, nonatomic) WayPointType wayPointType;

@property (nonatomic, readonly) AVCapturePhotoSettings *requestedPhotoSettings;

- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings willCapturePhotoAnimation:(void (^)(void))willCapturePhotoAnimation livePhotoCaptureHandler:(void (^)( BOOL capturing ))livePhotoCaptureHandler completionHandler:(void (^)( AVCamPhotoCaptureDelegate *photoCaptureDelegate ))completionHandler;

@end
