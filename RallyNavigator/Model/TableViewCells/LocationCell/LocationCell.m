//
//  LocationCell.m
//  RallyNavigator
//
//  Created by C205 on 19/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIColor *color;
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        color = [UIColor lightGrayColor];
    }
    else
    {
        color = [UIColor blackColor];
    }
    
    _vwCountContainer.backgroundColor = color;
//    _lblRowCount.center = _vwCountContainer.center;
    
//    _vwLeft.layer.borderWidth = 2.0f;
//    _vwLeft.layer.borderColor = color.CGColor;
//    
//    _vwRight.layer.borderWidth = 2.0f;
//    _vwRight.layer.borderColor = color.CGColor;
//
//    _vwNavigator.layer.borderWidth = 2.0f;
//    _vwNavigator.layer.borderColor = color.CGColor;

    _vwAngleContainer.layer.borderWidth = 3.0f;
    _vwAngleContainer.layer.borderColor = color.CGColor;

    _vwLocationContainer.layer.borderWidth = 3.0f;
    _vwLocationContainer.layer.borderColor = color.CGColor;
    
    _vwPerDistance.layer.borderWidth = 3.0f;
    _vwPerDistance.layer.borderColor = color.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)drawPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [_shapeLayer removeFromSuperlayer];
    
    _shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
//    CAShapeLayer *thinShapeLayer = [CAShapeLayer layer];
//    UIBezierPath *thinPath = [UIBezierPath bezierPath];
//    [thinPath moveToPoint:startPoint];
//    [thinPath addLineToPoint:CGPointMake(endPoint.x + 15, endPoint.y - 30)];
    
    _shapeLayer.path = path.CGPath;
//    thinShapeLayer.path = thinPath.CGPath;
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//         thinShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
//         thinShapeLayer.strokeColor = [UIColor blackColor].CGColor;
    }
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineWidth = 4;
//    thinShapeLayer.fillColor = [UIColor clearColor].CGColor;
//    thinShapeLayer.lineWidth = 1;
    [view.layer addSublayer:_shapeLayer];
//    [view.layer addSublayer:thinShapeLayer];
}

- (void)drawDirectionPathIn:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [_dirShapeLayer removeFromSuperlayer];
    
    _dirShapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    _dirShapeLayer.path = path.CGPath;
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _dirShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    }
    else
    {
        _dirShapeLayer.strokeColor = [UIColor blackColor].CGColor;
    }
    _dirShapeLayer.fillColor = [UIColor clearColor].CGColor;
    _dirShapeLayer.lineWidth = 4;
    [view.layer addSublayer:_dirShapeLayer];
}

- (void)drawTriPathIn:(UIView *)view startPoint:(CGPoint)startPoint leftPoint:(CGPoint)leftPoint rightPoint:(CGPoint)rightPoint
{
    [_triShapeLayer removeFromSuperlayer];
    
    _triShapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:leftPoint];
    [path addLineToPoint:rightPoint];
    [path closePath];
    _triShapeLayer.path = path.CGPath;
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _triShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _triShapeLayer.fillColor = [UIColor lightGrayColor].CGColor;

    }
    else
    {
        _triShapeLayer.strokeColor = [UIColor blackColor].CGColor;
        _triShapeLayer.fillColor = [UIColor blackColor].CGColor;

    }
    _triShapeLayer.lineWidth = 4;
    _triShapeLayer.zPosition = 2;
    [view.layer insertSublayer:_triShapeLayer atIndex:0];
}

@end
