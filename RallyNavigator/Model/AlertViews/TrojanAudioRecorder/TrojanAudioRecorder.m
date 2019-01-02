//
//  TrojanAudioRecorder.m
//  CoachApp
//
//  Created by C205 on 11/07/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "TrojanAudioRecorder.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
//#define MEDIA_PATH [NSString stringWithFormat:@"%@/temp.m4a", DOCUMENTS_FOLDER]

@interface TrojanAudioRecorder () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    BOOL isRecording, isAnimate, isManual, isCancelled, isStopped;
    NSString *strMainMediaPath;
    NSString *strMediaPath;
}
@end

@implementation TrojanAudioRecorder

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _vwContainer.layer.cornerRadius = CGRectGetWidth(_vwContainer.frame) / 2;
    _vwContainer.clipsToBounds = YES;
    
    strMainMediaPath = [NSString stringWithFormat:@"%@/%ld.m4a", DOCUMENTS_FOLDER, (long)_locationId];
    strMediaPath = [NSString stringWithFormat:@"%@/%ld_temp.m4a", DOCUMENTS_FOLDER, (long)_locationId];
    
//    NSString *filePath = strMainMediaPath;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    _isMediaPicked = [fileManager fileExistsAtPath:filePath];
    
    if ([self isFileExists])
    {
        [self removeFile];
    }

    if ([self isMainFileExists])
    {
        [self removeMainFile];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self btnRecordClicked:nil];
    });
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _btnCancel.layer.borderColor = RGBA(27, 27, 36, 0.1).CGColor;
    _btnCancel.layer.borderWidth = 1.0f;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isAnimate = NO;
    
    [self stopRecording];
    [AppContext.audioPlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Audio Recorder Handling Methods

- (void)startRecording
{
    if ([self isFileExists])
    {
        [self removeFile];
    }

    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error)
    {
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&error];
    
    error = nil;
    
    if (error)
    {
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Create a new dated file
    _recorderFilePath = strMediaPath;
    
    error = nil;
    
    NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    if (!_recorder)
    {
        NSLog(@"recorder: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        
        [AlertManager alert:[error localizedDescription] title:@"Warning" imageName:@"ic_error" onConfirm:NULL];
        return;
    }
    
    //prepare to record
    [_recorder setDelegate:self];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder recordForDuration:(NSTimeInterval) 10];
}

- (BOOL)isFileExists
{
    NSString *filePath = strMediaPath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (BOOL)isMainFileExists
{
    NSString *filePath = strMainMediaPath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (void)removeFile
{
    NSError *error = nil;
    
    NSURL *url = [NSURL fileURLWithPath:strMediaPath];
    
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&error];
    
    if(!audioData)
        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    error = nil;
    
    [fileManager removeItemAtPath:[url path] error:&error];
    
    if (error)
        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

- (void)removeMainFile
{
    NSError *error = nil;
    
    NSURL *url = [NSURL fileURLWithPath:strMainMediaPath];
    
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&error];
    
    if(!audioData)
        NSLog(@"audio data: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    error = nil;
    
    [fileManager removeItemAtPath:[url path] error:&error];
    
    if (error)
        NSLog(@"File Manager: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
}

- (void)stopRecording
{
    [_recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [_btnRecord setTitle:@"Start" forState:UIControlStateNormal];
    
    isRecording = NO;
    isAnimate = isRecording;

    [self stopRecording];
    
    if (isCancelled)
    {
        return;
    }
    
    if (!isManual)
    {
        [self btnOkClicked:nil];
    }
}

#pragma mark - Button Click Events

- (IBAction)btnRecordClicked:(id)sender
{
    [self.view endEditing:YES];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            [self.btnRecord setTitle:self->isRecording ? @"Start" : @"Stop" forState:UIControlStateNormal];
            
            self->isRecording = !self->isRecording;
            self->isAnimate = self->isRecording;
            
            if (self->isRecording)
            {
                [self animateRecordButton];
                [self startRecording];
            }
            else
            {
                self->isManual = YES;
                [self stopRecording];
                [self btnOkClicked:nil];
            }
        }
        else
        {
            return;
        }
    }];
}


- (void)animateRecordButton
{
    NSLog(@"%f", _recorder.currentTime);
    
    if (!isAnimate)
    {
        _vwContainer.transform = CGAffineTransformIdentity;
        return;
    }
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction animations:^{
                            self.vwContainer.transform = CGAffineTransformMakeScale(1.2, 1.2);
                        } completion:^(BOOL finished) {
                            if (!self->isAnimate)
                            {
                                self.vwContainer.transform = CGAffineTransformIdentity;
                                return;
                            }
                            [UIView animateWithDuration:0.3f
                                                  delay:0
                                                options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                                    self.vwContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                } completion:^(BOOL finished) {
                                                    if (!self->isAnimate)
                                                    {
                                                        self.vwContainer.transform = CGAffineTransformIdentity;
                                                        return;
                                                    }
                                                    [self animateRecordButton];
                                                }];
                        }];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

//- (IBAction)btnResetClicked:(id)sender
//{
//    [self.view endEditing:YES];
//
//    isAnimate = NO;
//
//    [AppContext.audioPlayer stop];
//
//    if ([self isFileExists])
//    {
//        [self removeFile];
//    }
//}
//
- (IBAction)btnOkClicked:(id)sender
{
    [self.view endEditing:YES];

    if (isRecording)
    {
        [AlertManager alert:@"" title:@"Please stop recorder" imageName:@"ic_error" onConfirm:NULL];
        return;
    }

    if ([self isFileExists])
    {
        if ([_delegate respondsToSelector:@selector(didRecordAudio:isManual:)])
        {
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager copyItemAtPath:strMediaPath toPath:strMainMediaPath error:&error];
            NSData *mediaData = [NSData dataWithContentsOfFile:strMediaPath];
            [_delegate didRecordAudio:mediaData isManual:isManual];
        }
    }
}

- (IBAction)btnCancelClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if ([_delegate respondsToSelector:@selector(clickOnCloseRecordPopUp)])
    {
        isCancelled = YES;
        [_delegate clickOnCloseRecordPopUp];
    }
}

@end
