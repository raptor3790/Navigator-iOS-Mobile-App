//
//  AddMapNameVC.h
//  RallyNavigator
//
//  Created by C205 on 26/06/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "BaseVC.h"

@protocol AddMapNameVCDelegate <NSObject>

@optional

- (void)didSelectMapName:(NSString *)strMapName;

@end

@interface AddMapNameVC : BaseVC

@property (strong, nonatomic) id<AddMapNameVCDelegate> delegate;

@property (strong, nonatomic) NSString *strMapName;

@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UITextField *txtMapName;

@end
