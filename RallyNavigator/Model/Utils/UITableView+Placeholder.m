//
//  UITableView+Placeholder.m
//  checklist
//
//  Created by pp on 06/02/14.
//  Copyright (c) 2014 PlayPal Group Private Limited. All rights reserved.
//

#import "UITableView+Placeholder.h"

@implementation UITableView (Placeholder)

static const int kPlaceholderRightPadding = 10;
static const int kPlaceholderLeftPadding = 10;
static const int kPlaceholderTopPadding = 10;
static const int kPlaceholderBottomPadding = 10;

- (void)reloadDataWithPlaceholderString:(NSString *)placeholderString
{
    [self setBackgroundView:nil];
    if ([self numberOfSections] == 0 || ([self numberOfRowsInSection:0] == 0 || [self numberOfRowsInSection:0] == NSNotFound))
    {
        if (placeholderString.length > 0)
        {
            UILabel *lblEmpty = [self getLabel];
            [lblEmpty setText:placeholderString];
            [self setBackgroundView:lblEmpty];
        }
    }
    else{
         [self setBackgroundView:nil];
    }
    [self reloadData];

}

- (void)reloadDataWithPlaceholderString:(NSString *)placeholderString lookupsection:(NSInteger)section
{
    [self setBackgroundView:nil];
    if ([self numberOfSections] == 0 && ([self numberOfRowsInSection:section] == 0 || [self numberOfRowsInSection:section] == NSNotFound))
    {
        if (placeholderString.length > 0)
        {
            UILabel *lblEmpty = [self getLabel];
            [lblEmpty setText:placeholderString];
            lblEmpty.textColor  = [UIColor lightGrayColor];
            [self setBackgroundView:lblEmpty];
        }
    }
    else{
         [self setBackgroundView:nil];
    }
    [self reloadData];
    
}

- (void)reloadDataWithPlaceholderString:(NSString *)placeholderString withUIColor:(UIColor *)placeholderColor
{
    [self setBackgroundView:nil];
   
    if ([self numberOfSections] == 0 || ([self numberOfRowsInSection:0] == 0 || [self numberOfRowsInSection:0] == NSNotFound))
    {
        if (placeholderString.length > 0)
        {
            UILabel *lblEmpty = [self getLabel];
            [lblEmpty setText:placeholderString];
            lblEmpty.textColor = placeholderColor;
            [self setBackgroundView:lblEmpty];
        }
    }
    else{
        [self setBackgroundView:nil];
    }
    [self reloadData];
}

- (UILabel *)getLabel
{
    UILabel *lblEmpty = [[UILabel alloc]initWithFrame:CGRectMake(kPlaceholderLeftPadding, kPlaceholderTopPadding, CGRectGetWidth(self.frame)-kPlaceholderRightPadding-kPlaceholderLeftPadding, CGRectGetHeight(self.frame)-kPlaceholderBottomPadding) ];
    lblEmpty.numberOfLines = 3;
    lblEmpty.textAlignment = NSTextAlignmentCenter;
    [lblEmpty setLineBreakMode:NSLineBreakByWordWrapping];
    [lblEmpty setFont:THEME_FONT_Bold(14.0)];
    [lblEmpty sizeThatFits:lblEmpty.frame.size];
    return lblEmpty;
}

- (UILabel *)getLabelForFontAwesome
{
    UILabel *lblEmpty = [[UILabel alloc]initWithFrame:CGRectMake(kPlaceholderLeftPadding, kPlaceholderTopPadding, CGRectGetWidth(self.frame)-kPlaceholderRightPadding-kPlaceholderLeftPadding, CGRectGetHeight(self.frame)-kPlaceholderBottomPadding) ];
    lblEmpty.numberOfLines = 1;
    lblEmpty.textAlignment = NSTextAlignmentCenter;
    [lblEmpty setLineBreakMode:NSLineBreakByWordWrapping];
//    [lblEmpty setFont:FONT_AWESOME(15.0)];
    [lblEmpty sizeThatFits:lblEmpty.frame.size];
    return lblEmpty;
}

- (NSMutableAttributedString *)customAttributedPlaceholderString:(NSString *)mainString withSubstring:(NSString *)substring {
    
    NSRange range = [mainString rangeOfString:substring];
    
    NSDictionary *textAttributes = @{ NSFontAttributeName: THEME_FONT(14.0) };
    
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:mainString];
    [myString setAttributes:textAttributes range:range];
    
    return myString;
}

- (UILabel *)getLabelForFontAwesomeForRequestParam
{
    UILabel *lblEmpty = [[UILabel alloc]initWithFrame:CGRectMake(kPlaceholderLeftPadding, kPlaceholderTopPadding, CGRectGetWidth(self.frame)-kPlaceholderRightPadding-kPlaceholderLeftPadding, CGRectGetHeight(self.frame)-kPlaceholderBottomPadding) ];
    lblEmpty.numberOfLines = 2;
    lblEmpty.textAlignment = NSTextAlignmentCenter;
    [lblEmpty setLineBreakMode:NSLineBreakByWordWrapping];
    [lblEmpty setFont:THEME_FONT(14.0)];
    [lblEmpty sizeThatFits:lblEmpty.frame.size];
    return lblEmpty;
}

//- (NSMutableAttributedString *)customAttributedPlaceholderStringForRequestParam:(NSString *)mainString withSubstring:(NSString *)substring {
//    
//    NSRange range = [mainString rangeOfString:substring];
//    
//    NSDictionary *textAttributes = @{ NSFontAttributeName: FONT_AWESOME(15.0) };
//    
//    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:mainString];
//    [myString setAttributes:textAttributes range:range];
//    
//    return myString;
//}


- (void)reloadDataWithPlaceholderImage:(UIImage *)placeholderImage
{
    [self setBackgroundView:nil];
    
    if ([self numberOfSections] == 0 || ([self numberOfRowsInSection:0] == 0 || [self numberOfRowsInSection:0] == NSNotFound))
    {
        if (placeholderImage != nil)
        {
            UIImageView *img = [[UIImageView alloc] initWithFrame:self.frame];
            [img setImage:placeholderImage];
            [img setBackgroundColor:[UIColor clearColor]];
            img.contentMode = UIViewContentModeScaleAspectFit;
            [self setBackgroundView:img];
        }
    }
    else{
        [self setBackgroundView:nil];
    }
    [self reloadData];
}

- (void)reloadDataAnimateWithWave:(WaveAnimation)animation;
{
    [self setContentOffset:self.contentOffset animated:NO];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [UIView transitionWithView:self
                      duration:.1
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^(void) {
                        [self setHidden:YES];
                        [self reloadData];
                    } completion:^(BOOL finished) {
                        if(finished){
                            [self setHidden:NO];
                            [self visibleRowsBeginAnimation:animation];
                        }
                    }
     ];
}

- (void)visibleRowsBeginAnimation:(WaveAnimation)animation
{
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        UITableViewCell *cell = [self cellForRowAtIndexPath:path];
        cell.frame = [self rectForRowAtIndexPath:path];
        cell.hidden = YES;
        [cell.layer removeAllAnimations];
        NSArray *array = @[path,[NSNumber numberWithInt:animation]];
        [self performSelector:@selector(animationStart:) withObject:array afterDelay:.08*i];
    }
}

- (void)animationStart:(NSArray *)array
{
    NSIndexPath *path = [array objectAtIndex:0];
    float i = [((NSNumber*)[array objectAtIndex:1]) floatValue] ;
    UITableViewCell *cell = [self cellForRowAtIndexPath:path];
    CGPoint originPoint = cell.center;
    CGPoint beginPoint = CGPointMake(cell.frame.size.width*i, originPoint.y);
    CGPoint endBounce1Point = CGPointMake(originPoint.x-i*2*kBOUNCE_DISTANCE, originPoint.y);
    CGPoint endBounce2Point  = CGPointMake(originPoint.x+i*kBOUNCE_DISTANCE, originPoint.y);
    cell.hidden = NO ;
    
    CAKeyframeAnimation *move = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    move.keyTimes=@[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.]];
    move.values=@[[NSValue valueWithCGPoint:beginPoint],[NSValue valueWithCGPoint:endBounce1Point],[NSValue valueWithCGPoint:endBounce2Point],[NSValue valueWithCGPoint:originPoint]];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CABasicAnimation *opaAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opaAnimation.fromValue = @(0.f);
    opaAnimation.toValue = @(1.f);
    opaAnimation.autoreverses = NO;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[move,opaAnimation];
    group.duration = kWAVE_DURATION;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [cell.layer addAnimation:group forKey:nil];
}

- (void)reloadCellwithAnimation:(UITableViewCell *)cell
{
    CGPoint originPoint = cell.center;
    CGPoint beginPoint = CGPointMake(cell.frame.size.width*1, originPoint.y);
    CGPoint endBounce1Point = CGPointMake(originPoint.x*2*kBOUNCE_DISTANCE, originPoint.y);
    CGPoint endBounce2Point  = CGPointMake(originPoint.x*kBOUNCE_DISTANCE, originPoint.y);
    cell.hidden = NO ;
    
    CAKeyframeAnimation *move = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    move.keyTimes=@[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.]];
    move.values=@[[NSValue valueWithCGPoint:beginPoint],[NSValue valueWithCGPoint:endBounce1Point],[NSValue valueWithCGPoint:endBounce2Point],[NSValue valueWithCGPoint:originPoint]];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CABasicAnimation *opaAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opaAnimation.fromValue = @(0.f);
    opaAnimation.toValue = @(1.f);
    opaAnimation.autoreverses = NO;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[move,opaAnimation];
    group.duration = kWAVE_DURATION;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [cell.layer addAnimation:group forKey:nil];
}

@end
