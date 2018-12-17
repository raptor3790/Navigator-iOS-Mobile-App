#import "NSString+Extensions.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Extensions)

+ (NSString*)stringToSha1:(NSString*)str {
  const char *s = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];

    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, (CC_LONG)keyData.length, digest);
	
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [out description];
	
	NSCharacterSet *doNotWants = [NSCharacterSet characterSetWithCharactersInString:@"<> "];
	hash = [[hash componentsSeparatedByCharactersInSet:doNotWants] componentsJoinedByString:@""];
	
    return hash;
}

- (NSNumber*)stringToNSNumber {
	NSNumberFormatter* tmpFormatter = [[NSNumberFormatter alloc] init];
	[tmpFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber* theNumber = [tmpFormatter numberFromString:self];
	return theNumber;
}

- (BOOL)isEmpty {
    if ([self length] <= 0 || self == (id)[NSNull null] || self == nil) {
        return YES;
    } 
    return NO;
}

- (BOOL)stringContainsSubString:(NSString *)subString {
    NSRange aRange = [self rangeOfString:subString];
    if (aRange.location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (NSString*)stringByReplacingStringsFromDictionary:(NSDictionary*)dict {
    NSMutableString* string = [self mutableCopy];
    for (NSString* target in dict) {
        [string replaceOccurrencesOfString:target withString:[dict objectForKey:target] options:0 range:NSMakeRange(0, [string length])];
    }
    return string;
}
// Checking if String is Empty
-(BOOL)isBlank
{
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""]) ? YES : NO;
}
//Checking if String is empty or nil
-(BOOL)isValid
{
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""] || self == nil || [self isEqualToString:@"(null)"]) ? NO :YES;
}

- (BOOL)isValidName
{
//    NSString *alphaRegex = @"[A-Za-z]+";
//    NSPredicate *alphaTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", alphaRegex];

    BOOL isValid = (self.length >= kNameLenght && self.length <= kNameMaxLenght /*&& [alphaTest evaluateWithObject:self]*/);
    return isValid;
}

- (BOOL)isValidEventName
{
    BOOL isValid = (self.length >= kNameLenght && self.length <= 50);
    return isValid;
}

// remove white spaces from String
-(NSString *)removerAllWhiteSpacesFromString{
    NSString *trimmedString =  [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return trimmedString;
}

- (NSString *)removeWhiteSpacesFromString
{
	NSString *trimmedString = [self stringByTrimmingCharactersInSet:
							   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return trimmedString;
}

// Counts number of Words in String
- (NSUInteger)countNumberOfWords
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
    NSUInteger count = 0;
    while ([scanner scanUpToCharactersFromSet: whiteSpace  intoString: nil]) {
        count++;
    }
	
    return count;
}

// If string contains substring
- (BOOL)containsString:(NSString *)subString
{
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}

// If my string starts with given string
- (BOOL)isBeginsWith:(NSString *)string
{
    return ([self hasPrefix:string]) ? YES : NO;
}

// If my string ends with given string
- (BOOL)isEndssWith:(NSString *)string
{
    return ([self hasSuffix:string]) ? YES : NO;
}



// Replace particular characters in my string with new character
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar
{
    return  [self stringByReplacingOccurrencesOfString:olderChar withString:newerChar];
}

// Get Substring from particular location to given lenght
- (NSString*)getSubstringFrom:(NSInteger)begin to:(NSInteger)end
{
	NSRange r;
	r.location = begin;
	r.length = end - begin;
	return [self substringWithRange:r];
}

// Add substring to main String
- (NSString *)addString:(NSString *)string
{
    if(!string || string.length == 0)
        return self;
    
    return [self stringByAppendingString:string];
}

// Remove particular sub string from main string
-(NSString *)removeSubString:(NSString *)subString
{
    if ([self containsString:subString])
    {
        NSRange range = [self rangeOfString:subString];
        return  [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}


// If my string contains ony letters
- (BOOL)containsOnlyLetters
{
    NSCharacterSet *letterCharacterset = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:letterCharacterset].location == NSNotFound);
}

// If my string contains only numbers
- (BOOL)containsOnlyNumbers
{
    NSCharacterSet *numbersCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbersCharacterSet].location == NSNotFound);
}

// If my string contains letters and numbers
- (BOOL)containsOnlyNumbersAndLetters
{
    NSCharacterSet *numAndLetterCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:numAndLetterCharSet].location == NSNotFound);
}

// If my string is available in particular array
- (BOOL)isInThisarray:(NSArray*)array
{
    for(NSString *string in array) {
        if([self isEqualToString:string]) {
            return YES;
        }
    }
    return NO;
}

// Get String from array
+ (NSString *)getStringFromArray:(NSArray *)array
{
    return [array componentsJoinedByString:@" "];
}

// Convert Array from my String
- (NSArray *)getArray
{
    return [self componentsSeparatedByString:@" "];
}

// Get My Application Version number
+ (NSString *)getMyApplicationVersion
{
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSString *version = [info objectForKey:@"CFBundleVersion"];
	return version;
}

// Get My Application name
+ (NSString *)getMyApplicationName
{
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSString *name = [info objectForKey:@"CFBundleDisplayName"];
	return name;
}


// Convert string to NSData
- (NSData *)convertToData
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

// Get String from NSData
+ (NSString *)getStringFromData:(NSData *)data
{
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
    
}

// Is Valid Email

- (BOOL)isValidEmail
{
    NSString *regex1 = @"\\A[a-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,5}\\z";
    NSString *regex2 = @"^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*";
    NSPredicate *test1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [test1 evaluateWithObject:[self lowercaseString]] && [test2 evaluateWithObject:[self lowercaseString]];

//    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}";
//    NSPredicate *emailTestPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    return [emailTestPredicate evaluateWithObject:self];
}

// Is Valid Phone

- (BOOL)isValidPhoneNumber
{
    
    NSString *regex = @"^[0-9]{10}$";
    //NSString *regex = @"[235689][0-9]{6}([0-9]{3})?";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

// Is Valid URL

- (BOOL)isValidUrl
{
    NSString *regex =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

- (BOOL)isValidPassword
{
    BOOL isValid = (self.length >= kPasswordLenght) && (self.length <= kPasswordMaxLenght);
    return isValid;
}

- (NSString *)FirstLetterCapital
{
    NSString *firstCapChar = [[self substringToIndex:1] capitalizedString];
    NSString *cappedString = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    return cappedString;
}

@end
