//
//  ImagePreviewVC.m
//  RallyNavigator
//
//  Created by C205 on 27/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "ImagePreviewVC.h"

@interface ImagePreviewVC ()

@end

@implementation ImagePreviewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Preview";
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        self.view.backgroundColor = [UIColor blackColor];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
//    UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDismissClicked:)];
    UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithImage:Set_Local_Image(@"cancel_icon") style:UIBarButtonItemStylePlain target:self action:@selector(btnDismissClicked:)];
    self.navigationItem.rightBarButtonItem = btnDismiss;
    
    if (_objLocation.photos.count > 0)
    {
        _imgPreview.image = _objLocation.photos[0];
    }
    else
    {
        [_imgPreview sd_setImageWithURL:[NSURL URLWithString:_objLocation.imageUrl]
                            placeholderImage:Set_Local_Image(@"DEFAULT_PROFILE_IMAGE")
                                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                       if (error == nil) {
                                           _imgPreview.image = image;
                                       }
                                   }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton Click Events

- (IBAction)btnDismissClicked:(id)sender
{
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
