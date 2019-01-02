//
//  ZoomLevelVC.m
//  RallyNavigator
//
//  Created by C205 on 19/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "ZoomLevelVC.h"

@interface ZoomLevelVC ()

@end

@implementation ZoomLevelVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Manage Zoom";
    
    _lblCurZoom.text = [NSString stringWithFormat:@"%.2f", _curZoomLevel];
    
    _curZoomProgessView.value = _curZoomLevel;
    
    _maxZoomProgressView.minimumValue = _curZoomLevel;
    _maxZoomProgressView.maximumValue = 18.0f;
    
    if (_curZoomLevel > _maxZoomLevel)
    {
        _maxZoomProgressView.value = _maxZoomProgressView.minimumValue;
    }
    else
    {
        _maxZoomProgressView.value = _maxZoomLevel;
    }
    
    _lblMaxZoom.text = [NSString stringWithFormat:@"%.2f", ceilf(_maxZoomProgressView.value)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)maxSliderValueChanged:(UISlider *)sender
{
    _lblMaxZoom.text = [NSString stringWithFormat:@"%.2f", ceilf(_maxZoomProgressView.value)];
}

@end
