//
//  Common.m
//  SQLExample
//
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.

#define DATE_Formatter   @"yyyy-MM-dd HH:mm:ss"
#define TIME_ZONE @"UTC"
#define font_brandon_regular @"BrandonGrotesque-Regular"

#import "Function.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Function

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#pragma mark - dictionary functions
#pragma mark -
+(NSString *) getStringFromObject:(NSString *) key fromDictionary:(NSDictionary *) values
{
    if (![[values objectForKey:key] isKindOfClass:[NSNull class]])
        return  [values objectForKey:key];
    else
        return @"";
}
+(NSString *) getStringForKey:(NSString *) key fromDictionary:(NSDictionary *) values
{
    if (![[values objectForKey:key] isKindOfClass:[NSNull class]])
        return  [values objectForKey:key];
    else
        return @"";
}

+(int) getIntegerForKey:(NSString *) key fromDictionary:(NSDictionary *) values
{
    if (![[values objectForKey:key] isKindOfClass:[NSNull class]])
        //        return  [[values objectForKey:key]integerValue]; //CHANGES OF WARNING
        return  [[values objectForKey:key]intValue];
    else
        return 0;
}

+(double) getDoubleForKey:(NSString *) key fromDictionary:(NSDictionary *) values
{
    if (![[values objectForKey:key] isKindOfClass:[NSNull class]])
        return  [[values objectForKey:key]doubleValue];
    else
        return 0;
}
#pragma mark - string functions
#pragma mark -


+ (NSString*)encodedStringtoSend:(NSString*)mystr
{
    return [[mystr dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    }
    return base64String;
}

+ (NSString*)decode64ToString:(NSString*)fromString
{
    if (fromString == nil)
    {
        return @"";
    }
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fromString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

+ (NSString*)parseEncodedStringtoDisplay:(NSString*)mystr
{
    @try
    {
        if (!mystr)
        {
            return @"";
        }
        
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:mystr options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        if (!decodedString || decodedString.length == 0) {
            return mystr;
        }
        return decodedString;
    }
    @catch (NSException *exception)
    {
        //        [SVProgressHUD showErrorWithStatus:exception.description maskType:SVProgressHUDMaskTypeGradient];
    }
}

+ (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet forString:(NSString *)string
{
    NSUInteger location = 0;
    NSUInteger length = [string length];
    unichar charBuffer[length];
    [string getCharacters:charBuffer];
    
    for (location = 0; location < length; location++)
    {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    
    return [string substringWithRange:NSMakeRange(location, length - location)];
}

+ (NSString *)trimmedString:(NSString *)string
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:charSet];
    return trimmedString;
}

+ (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet forString:(NSString *)string
{
    NSUInteger location = 0;
    NSUInteger length = [string length];
    unichar charBuffer[length];
    [string getCharacters:charBuffer];
    
    for (length=0; length > 0; length--)
    {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    
    return [string substringWithRange:NSMakeRange(location, length - location)];
}

+ (BOOL ) stringIsEmpty:(NSString *) aString
{
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;
}

+(NSString*)generateRandomString:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    //    CurrentTimeStamp
    return string;
}

#pragma mark - date functions
#pragma mark -

+(NSDateFormatter *)getDateFormatForApp
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:DATE_Formatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:TIME_ZONE]];
    return formatter;
}

+(NSDate *)getDateFromString: (NSString *)strDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    //    [dateFormatter setDateFormat:@"dd-MM-yyyy"];//yyyy-MM-dd //MMM d, yyyy
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:strDate];
    return dateFromString;
}
#pragma mark timezone and Date Functions
+(NSDate *) convertStringToServerDate:(NSString *)strDate fromTimeZone : (NSTimeZone *) fromTZ toTimeZone : (NSTimeZone *) toTZ
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter * dateFormats= [[NSDateFormatter alloc] init];
    [dateFormats setTimeZone:fromTZ];
    [dateFormats setLocale:[NSLocale systemLocale]];
    [dateFormats setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormats dateFromString:strDate];
    return date;
}
+(NSString *)returnCurrentDate
{
    NSDate *todayDate = [NSDate date];
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * strDate = [formatter1 stringFromDate:todayDate];
    
    NSString *timeZone = @"UTC";
    NSDate *dateToSend = [self convertStringToServerDate:strDate fromTimeZone:[NSTimeZone localTimeZone] toTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZone]];
    NSString *dateToStore = [formatter stringFromDate:dateToSend];
    return dateToStore;
}


#pragma mark - View controller methods
//When get stuck with issues like popover as main view or tabbars as main view or having many subviews then refer this link here: http://stackoverflow.com/questions/6131205/iphone-how-to-find-topmost-view-controller

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    return topController;
}
#pragma mark - QR Code generation
+(UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat) scale{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage;
}


#pragma mark - html utilities
+(NSAttributedString *)extractHTMLtags:(NSString *)htmlstr
{
    htmlstr = [NSString stringWithFormat:@"<span style=\"font-family: Arial; font-size: 12\">%@</span>", htmlstr];
    
    NSError *err;
    NSAttributedString *str ;
    
    NSRange range;
    //NSData *data = [htmlstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [htmlstr dataUsingEncoding:NSUnicodeStringEncoding];
    
    str = [[NSAttributedString alloc]initWithString:htmlstr];
    
    //while((range = [htmlstr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    while((range = [htmlstr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        str =[[NSAttributedString alloc] initWithData:data options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes: nil error:&err];
        return str;
    }
    
    if(err)
    {
        NSLog(@"Unable to parse HTML tags!...");
    }
    
    return str;
    
}

+(NSMutableAttributedString *)stringConvertToHtml:(NSString *)stringHtmlText
{
    stringHtmlText = [stringHtmlText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    stringHtmlText = [stringHtmlText stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;"];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithData: [stringHtmlText dataUsingEncoding:NSUnicodeStringEncoding]
                                                   options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding] }
                                                   documentAttributes:nil
                                                   error: nil
                                                   ];
    
    
    //NSString *string = (NSString *)attributedString;
    
    //attributedString = [self extractHTMLtagsNew:string];
    //attributedString = [[self extractHTMLtagsNew:[attributedString mutableCopy]] mutableCopy];
    [attributedString addAttribute:NSFontAttributeName value:THEME_FONT(16) range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

+(NSMutableAttributedString *)extractHTMLtagsNew:(NSString *)htmlstr
{
    htmlstr = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: 16\">%@</span>",font_brandon_regular, htmlstr];
    htmlstr = [htmlstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSError *err;
    NSMutableAttributedString *str ;
    
    NSRange range;
    str = [[NSMutableAttributedString alloc]initWithString:htmlstr];
    while((range = [htmlstr rangeOfString:@"<[^>]+>|&nbsp;" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        
        str = [[NSMutableAttributedString alloc]initWithData:[htmlstr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        
        NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSRange range = [str.string rangeOfCharacterFromSet:charSet];
        
        // Trim trailing whitespace and newlines.
        range = [str.string rangeOfCharacterFromSet:charSet
                                            options:NSBackwardsSearch];
        while (range.length != 0 && NSMaxRange(range) == str.length)
        {
            [str replaceCharactersInRange:range withString:@""];
            range = [str.string rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
        }
        
        return str;
    }
    if(err)
    {
        NSLog(@"Unable to parse HTML tags!...");
    }
    
    return str;
}


#pragma mark - image utilities
/***  Base 64 for UIImage ***/
+ (NSString *)encodeImageToBase64String:(UIImage *)image {
    return [UIImageJPEGRepresentation(image, 0.0f) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark - Animation Functions
#pragma mark image resize
+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
    //    int kMaxResolution = 640;
    int kMaxResolution = 960;
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
    
}

+ (UIImage *)fixOrientationForImage:(UIImage*)neededImage {
    
    // No-op if the orientation is already correct
    if (neededImage.imageOrientation == UIImageOrientationUp) return neededImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (neededImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.width, neededImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, neededImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (neededImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, neededImage.size.width, neededImage.size.height,
                                             CGImageGetBitsPerComponent(neededImage.CGImage), 0,
                                             CGImageGetColorSpace(neededImage.CGImage),
                                             CGImageGetBitmapInfo(neededImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (neededImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,neededImage.size.height,neededImage.size.width), neededImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,neededImage.size.width,neededImage.size.height), neededImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)compressImage:(UIImage *)image
{
    image = [self scaleAndRotateImage:image];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    if ((imageData.length/1024) >= 10)
    {
        CGFloat compression = 1.0f;
        CGFloat maxCompression = 0.0f;
        int maxFileSize = 1024 * 10;
        
        while ([imageData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.05;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
    }
    image = [UIImage imageWithData:imageData];
    return image;
}


#pragma mark Label Text Animation
+ (void)animateLabelShowText:(NSString*)newText characterDelay:(NSTimeInterval)delay forLabel : (UILabel *) lbl
{
    [lbl setText:@""];
    
    for (int i=0; i<newText.length; i++)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [lbl setText:[NSString stringWithFormat:@"%@%C", lbl.text, [newText characterAtIndex:i]]];
                           [lbl setTextColor:[UIColor greenColor]];
                       });
    }
}

#pragma mark Shake effect animation

+ (void) shakeAnimForCustomTextfield : (UITextField *) txt
{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        NSInteger repeatCount = 8;
        NSTimeInterval duration = 1.0 / (NSTimeInterval)repeatCount;
        
        for (NSInteger i = 0; i < repeatCount; i++) {
            [UIView addKeyframeWithRelativeStartTime:i * duration relativeDuration:duration animations:^{
                CGFloat dx = 5.0;
                if (i == repeatCount - 1) {
                    txt.transform = CGAffineTransformIdentity;
                } else if (i % 2) {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -dx, 0.0);
                } else {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, +dx, 0.0);
                }
            }];
        }
    } completion:^(BOOL finished)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                        {
                        });
     }];
}

+ (void) shakeAnimForTextField : (UITextField *) txt
{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        NSInteger repeatCount = 8;
        NSTimeInterval duration = 1.0 / (NSTimeInterval)repeatCount;
        
        for (NSInteger i = 0; i < repeatCount; i++) {
            [UIView addKeyframeWithRelativeStartTime:i * duration relativeDuration:duration animations:^{
                CGFloat dx = 5.0;
                if (i == repeatCount - 1) {
                    txt.transform = CGAffineTransformIdentity;
                } else if (i % 2) {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -dx, 0.0);
                } else {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, +dx, 0.0);
                }
            }];
        }
    } completion:^(BOOL finished)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                        {
                        });
     }];
    
}


+ (void) shakeAnimForLabel : (UILabel *) lbl
{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        NSInteger repeatCount = 8;
        NSTimeInterval duration = 1.0 / (NSTimeInterval)repeatCount;
        
        for (NSInteger i = 0; i < repeatCount; i++) {
            [UIView addKeyframeWithRelativeStartTime:i * duration relativeDuration:duration animations:^{
                CGFloat dx = 5.0;
                if (i == repeatCount - 1) {
                    lbl.transform = CGAffineTransformIdentity;
                } else if (i % 2) {
                    lbl.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -dx, 0.0);
                } else {
                    lbl.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, +dx, 0.0);
                }
            }];
        }
    } completion:^(BOOL finished)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                        {
                        });
     }];
}

+ (void) shakeAnimForButton : (UIButton *) txt
{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        NSInteger repeatCount = 8;
        NSTimeInterval duration = 1.0 / (NSTimeInterval)repeatCount;
        
        for (NSInteger i = 0; i < repeatCount; i++) {
            [UIView addKeyframeWithRelativeStartTime:i * duration relativeDuration:duration animations:^{
                CGFloat dx = 5.0;
                if (i == repeatCount - 1) {
                    txt.transform = CGAffineTransformIdentity;
                } else if (i % 2) {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -dx, 0.0);
                } else {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, +dx, 0.0);
                }
            }];
        }
    } completion:^(BOOL finished)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
         });
     }];
}

+ (void) shakeAnimForTextView : (UITextView *) txt
{
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        NSInteger repeatCount = 8;
        NSTimeInterval duration = 1.0 / (NSTimeInterval)repeatCount;
        
        for (NSInteger i = 0; i < repeatCount; i++) {
            [UIView addKeyframeWithRelativeStartTime:i * duration relativeDuration:duration animations:^{
                CGFloat dx = 5.0;
                if (i == repeatCount - 1) {
                    txt.transform = CGAffineTransformIdentity;
                } else if (i % 2) {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -dx, 0.0);
                } else {
                    txt.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, +dx, 0.0);
                }
            }];
        }
    } completion:^(BOOL finished)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
         });
     }];
}

+ (void)textFieldPlaceHolderColor : (UITextField *) textField
{
    [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
}


#pragma mark convert string date format
+(NSString *)stringDateToFormat:(NSString *)stringDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [dateFormatter dateFromString:stringDate];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringConverted = [dateFormatter stringFromDate:date];
    
    return stringConverted;
}


#pragma mark Predicates
+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *subpredicates = [NSMutableArray array];
    for (NSString* key in dict) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"%K = %@", key, [dict objectForKey:key]]];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

#pragma Validation Function
+ (BOOL)validEmail:(NSString *)email
{
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL_REG_EXP];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}

+ (BOOL)validName:(NSString *)name
{
    BOOL isValid = (name.length>= kNameLenght && name.length<= kNameMaxLenght);
    return isValid;
}


+ (BOOL)validPassword:(NSString *)password
{
    BOOL isValid = (password.length>= kPasswordLenght);
    return isValid;
}

+(void)makeDeviceVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - Short Numbers
+(NSString*) suffixNumber:(NSNumber*)number
{
    if (!number)
        return @"";
    
    long long num = [number longLongValue];
    
    int s = ( (num < 0) ? -1 : (num > 0) ? 1 : 0 );
    NSString* sign = (s == -1 ? @"-" : @"" );
    
    num = llabs(num);
    
    if (num < 1000)
        return [NSString stringWithFormat:@"%@%lld",sign,num];
    
    int exp = (int) (log10l(num) / 3.f); //log10l(1000));
    
    NSArray* units = @[@"K",@"M",@"G",@"T",@"P",@"E"];
    
    return [NSString stringWithFormat:@"%@%.1f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
}

@end
