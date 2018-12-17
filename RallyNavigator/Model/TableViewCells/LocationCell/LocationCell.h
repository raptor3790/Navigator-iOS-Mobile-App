//
//  LocationCell.h
//  RallyNavigator
//
//  Created by C205 on 19/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblLatitude;
@property (weak, nonatomic) IBOutlet UILabel *lblLongitude;
@property (weak, nonatomic) IBOutlet UIView *vwNavigator;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblAngle;
@property (weak, nonatomic) IBOutlet UILabel *lblRowCount;
@property (weak, nonatomic) IBOutlet UIView *vwLeft;
@property (weak, nonatomic) IBOutlet UIView *vwRight;
@property (weak, nonatomic) IBOutlet UIView *vwAngleContainer;
@property (weak, nonatomic) IBOutlet UIView *vwLocationContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblPerDistance;
@property (weak, nonatomic) IBOutlet UIView *vwPerDistance;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnAddText;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblDivider;
@property (weak, nonatomic) IBOutlet UIImageView *imgWayPoint;
@property (weak, nonatomic) IBOutlet UIButton *btnPreviewImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnStartRecording;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIView *vwCountContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnAudioWidthConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnAddPhotoWidthConstant;
@property (strong, nonatomic) IBOutlet UILabel *lblDistanceUnit;

@property CAShapeLayer *shapeLayer;
@property CAShapeLayer *dirShapeLayer;
@property CAShapeLayer *triShapeLayer;

- (void)drawPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (void)drawDirectionPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (void)drawTriPathIn:(UIView *)view startPoint:(CGPoint)startPoint leftPoint:(CGPoint)leftPoint rightPoint:(CGPoint)rightPoint;

@end
