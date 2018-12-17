//
//  ImagePreviewVC.h
//  RallyNavigator
//
//  Created by C205 on 27/12/17.
//  Copyright © 2017 C205. All rights reserved.
//

#import "BaseVC.h"
#import "Locations.h"

@interface ImagePreviewVC : BaseVC

@property (strong, nonatomic) Locations *objLocation;
@property (weak, nonatomic) IBOutlet UIImageView *imgPreview;

@end
