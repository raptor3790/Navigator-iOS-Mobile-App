//
//  Common.h
//  SQLExample
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.


#import <Foundation/Foundation.h>

@interface Function : NSObject
{

}
void runOnMainQueueWithoutDeadlocking(void (^block)(void));


#pragma mark - dictionary functions
+(NSString *) getStringFromObject:(NSString *) key fromDictionary:(NSDictionary *) values;
+(NSString *) getStringForKey:(NSString *) key fromDictionary:(NSDictionary *) values;

+(int) getIntegerForKey:(NSString *) key fromDictionary:(NSDictionary *) values;
+(double) getDoubleForKey:(NSString *) key fromDictionary:(NSDictionary *) values;

#pragma mark - string functions
+ (NSString*)encodedStringtoSend:(NSString*)mystr;
+ (NSString*)encodeStringTo64:(NSString*)fromString;
+ (NSString*)decode64ToString:(NSString*)fromString;
+ (NSString*)parseEncodedStringtoDisplay:(NSString*)mystr;
+ (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet forString:(NSString *)string;
+ (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet forString:(NSString *)string;
+ (BOOL ) stringIsEmpty:(NSString *) aString;
+(NSString*)generateRandomString:(int)num;
+ (NSString *)trimmedString:(NSString *)string;

#pragma mark - dateFormats
+(NSDateFormatter *)getDateFormatForApp;
+(NSDate *)getDateFromString: (NSString *)strDate;


#pragma mark - View controller methods

+ (UIViewController*) topMostController;

#pragma mark - QR Code generation
+(UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat) scale;

#pragma mark - timezone
+(NSDate *) convertStringToServerDate:(NSString *)strDate fromTimeZone : (NSTimeZone *) fromTZ toTimeZone : (NSTimeZone *) toTZ;
+(NSString *)returnCurrentDate;

#pragma mark - html utilities
+(NSAttributedString *)extractHTMLtags:(NSString *)htmlstr;

#pragma mark - image utilities
+ (NSString *)encodeImageToBase64String:(UIImage *)image;

#pragma mark - html text convert
+(NSMutableAttributedString *)stringConvertToHtml:(NSString *)stringHtmlText;

#pragma mark - Animation
#pragma mark  image resize
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
+ (UIImage *)fixOrientationForImage:(UIImage*)neededImage;
+ (UIImage *)compressImage:(UIImage *)image;

#pragma mark Label Text Animation
+ (void)animateLabelShowText:(NSString*)newText characterDelay:(NSTimeInterval)delay forLabel : (UILabel *) lbl ;

#pragma mark Shake effect animation
+ (void) shakeAnimForCustomTextfield : (UITextField *)txt;
+ (void) shakeAnimForTextField : (UITextField *) txt;
+ (void) shakeAnimForLabel : (UILabel *)lbl ;
+ (void) shakeAnimForButton : (UIButton *)txt;
+ (void) shakeAnimForTextView : (UITextView *) txt;



+ (void)textFieldPlaceHolderColor : (UITextField *) textField;
+(NSString *)stringDateToFormat:(NSString *)stringDate;
+(NSMutableAttributedString *)extractHTMLtagsNew:(NSString *)htmlstr;


+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict;


+ (BOOL)validEmail:(NSString *)email;
+ (BOOL)validName:(NSString *)name;
+ (BOOL)validPassword:(NSString *)password;

+(void)makeDeviceVibrate;

#pragma mark - Short Numbers
+(NSString*) suffixNumber:(NSNumber*)number;

@end
