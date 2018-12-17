/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Photo capture delegate.
*/


#import "AVCamPhotoCaptureDelegate.h"
#import "Locations.h"

@import Photos;

@interface AVCamPhotoCaptureDelegate ()

@property (nonatomic, readwrite) AVCapturePhotoSettings *requestedPhotoSettings;
@property (nonatomic) void (^willCapturePhotoAnimation)(void);
@property (nonatomic) void (^livePhotoCaptureHandler)(BOOL capturing);
@property (nonatomic) void (^completionHandler)(AVCamPhotoCaptureDelegate *photoCaptureDelegate);

@property (nonatomic) NSData *photoData;
@property (nonatomic) NSURL *livePhotoCompanionMovieURL;

@end

@implementation AVCamPhotoCaptureDelegate

- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings willCapturePhotoAnimation:(void (^)(void))willCapturePhotoAnimation livePhotoCaptureHandler:(void (^)(BOOL))livePhotoCaptureHandler completionHandler:(void (^)(AVCamPhotoCaptureDelegate *))completionHandler
{
	self = [super init];
	if (self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.requestedPhotoSettings = requestedPhotoSettings;
            self.willCapturePhotoAnimation = willCapturePhotoAnimation;
            self.livePhotoCaptureHandler = livePhotoCaptureHandler;
            self.completionHandler = completionHandler;
        });
	}
	return self;
}

- (void)didFinish
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.livePhotoCompanionMovieURL.path])
    {
		NSError *error = nil;
        
		[[NSFileManager defaultManager] removeItemAtPath:self.livePhotoCompanionMovieURL.path error:&error];
		
		if (error)
        {
			NSLog(@"Could not remove file at url: %@", self.livePhotoCompanionMovieURL.path);
		}
	}
	
	self.completionHandler(self);
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
	if ((resolvedSettings.livePhotoMovieDimensions.width > 0) && (resolvedSettings.livePhotoMovieDimensions.height > 0))
    {
		self.livePhotoCaptureHandler(YES);
	}
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
	self.willCapturePhotoAnimation();
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Error capturing photo: %@", error);
        return;
    }
    
    if (@available(iOS 11.0, *))
    {
        self.photoData = [photo fileDataRepresentation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_vc didCapturedImage:self.photoData];
            _photoData = nil;
        });
    }
}

#pragma clang diagnostic pop

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL *)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
	self.livePhotoCaptureHandler(NO);
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    if (!error)
    {
        self.photoData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];

        dispatch_async(dispatch_get_main_queue(), ^{
            [_vc didCapturedImage:self.photoData];
            _photoData = nil;
        });
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput
didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL *)outputFileURL
             duration:(CMTime)duration
     photoDisplayTime:(CMTime)photoDisplayTime
     resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                error:(NSError *)error
{
	if (error != nil)
    {
		NSLog(@"Error processing live photo companion movie: %@", error);
		return;
	}
	
	self.livePhotoCompanionMovieURL = outputFileURL;
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput
didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                error:(NSError *)error
{
    [self didFinish];
}

@end
