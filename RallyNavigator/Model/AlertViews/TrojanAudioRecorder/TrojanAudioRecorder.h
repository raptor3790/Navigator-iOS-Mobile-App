//
//  TrojanAudioRecorder.h
//  CoachApp
//
//  Created by C205 on 11/07/17.
//  Copyright © 2017 C205. All rights reserved.
//
@import AVFoundation;

#import <UIKit/UIKit.h>

@protocol TrojanAudioRecorderDelegate <NSObject>

@optional

- (void)didRecordAudio:(NSData *)data isManual:(BOOL)isManuallyStopped;
- (void)clickOnCloseRecordPopUp;

@end

@interface TrojanAudioRecorder : UIViewController

@property (strong, nonatomic) id<TrojanAudioRecorderDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *vwHeader;
//@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
//@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
//@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
//@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (assign, nonatomic) BOOL isMediaPicked;

// Audio Recorder
@property (assign, nonatomic) double locationId;
@property (weak, nonatomic) NSString *recorderFilePath;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@end
