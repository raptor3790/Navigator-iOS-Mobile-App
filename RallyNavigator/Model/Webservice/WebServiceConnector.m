//
//  WebConnector.m
//  SQLExample
//
//  Created by Prerna on 5/15/15.
//  Copyright (c) 2015 Narola. All rights reserved.
//

#import "WebServiceConnector.h"
#import "WebServiceResponse.h"
#import "WebServiceDataAdaptor.h"
#import "ReachabilityManager.h"

#define DEFAULT_TIMEOUT 3000.0f

@implementation WebServiceConnector
@synthesize responseArray, responseError, responseDict, responseCode, URLRequest;

- (BOOL)checkNetConnection
{
    return [ReachabilityManager isReachable];
}

- (void)init:(NSString*)WebService
    withParameters:(NSDictionary*)ParamsDictionary
        withObject:(id)object
      withSelector:(SEL)selector
    forServiceType:(ServiceType)serviceType /* serviceType: {GET, POST, JSON} */
    showDisplayMsg:(NSString*)message
        showLoader:(BOOL)showLoader
{
    WebServiceResponse* server = [WebServiceResponse sharedMediaServer];
    dispatch_async(dispatch_get_main_queue(), ^{
        ShowNetworkIndicator(YES);
    });
    //        NSLog(@"%@", ParamsDictionary);
    responseCode = 100;
    responseError = [[NSString alloc] init];
    responseArray = [[NSArray alloc] init];

    switch (serviceType) {
    case ServiceTypeGET: {
        URLRequest = [self getMutableRequestFromGetWS:WebService withParams:ParamsDictionary];
    } break;

    case ServiceTypePOST: {
        if ([WebService isEqualToString:URLUploadImage]) {
            URLRequest = [self getMutableRequestForCreateFeedsWS:WebService withObjects:ParamsDictionary];
        } else {
            URLRequest = [self getMutableRequestForPostWS:WebService withObjects:ParamsDictionary isJsonBody:NO isPut:NO];
        }
    } break;

    case ServiceTypeJSON: {
        URLRequest = [self getMutableRequestForPostWS:WebService withObjects:ParamsDictionary isJsonBody:YES isPut:NO];
    } break;

    case ServiceTypePUT: {
        URLRequest = [self getMutableRequestForPostWS:WebService withObjects:ParamsDictionary isJsonBody:YES isPut:YES];
    } break;

    case ServiceTypeDELETE: {
        URLRequest = [self getMutableRequestFromDeleteWS:WebService withParams:ParamsDictionary];
    } break;

    default:
        break;
    }

    //    if (![self checkNetConnection])
    //    {
    //        responseCode = 104;
    //        self.responseError = @"The network connection was lost.";
    //        [SVProgressHUD showInfoWithStatus:@"The network connection was lost."];
    //        [object performSelectorOnMainThread:selector withObject:self waitUntilDone:false];
    //        return;
    //    }

    if (showLoader) {
        [SVProgressHUD show];
    }

    [server initWithWebRequests:URLRequest
                        inBlock:^(NSError* error, id objects, NSString* responseString) {

                            if (error) {
                                self.responseCode = 101;
                                self.responseError = error.localizedDescription;
                            } else {
                                if ([responseString isEqualToString:@"Fail"]) {
                                    self.responseCode = 102;
                                    self.responseError = @"Response Issue From Server";
                                } else if ([responseString isEqualToString:@"Not Available"]) {
                                    self.responseCode = 103;
                                    self.responseError = @"No Data Available";
                                    ShowNetworkIndicator(NO);
                                } else if ([[objects valueForKey:@"status"] isEqualToString:@"failed"]) {
                                    self.responseCode = 104;
                                    self.responseDict = (NSDictionary*)objects;
                                    self.responseError = [objects valueForKey:@"message"];
                                    ShowNetworkIndicator(NO);
                                } else {
                                    self.responseCode = 100;
                                    self.responseDict = (NSDictionary*)objects;
                                    self.responseArray = [[WebServiceDataAdaptor alloc] autoParse:self.responseDict forServiceName:WebService];
                                    ShowNetworkIndicator(NO);
                                }
                            }

                            if (showLoader) {
                                [SVProgressHUD dismissWithCompletion:^{
                                    if ([object respondsToSelector:selector]) {
                                        [object performSelectorOnMainThread:selector withObject:self waitUntilDone:false];
                                    }
                                }];
                            } else {
                                if ([object respondsToSelector:selector]) {
                                    [object performSelectorOnMainThread:selector withObject:self waitUntilDone:false];
                                }
                            }
                        }];
}

#pragma mark - generate URL Methods
///*** this method can be used when there is cake php webservice ***/
//-(NSString *) getNetURLFromService:(NSString *) WebService withParams: (NSArray *) ParamsArray
//{
//    NSString *Query = WebService;
//    if(ParamsArray == nil)
//        return nil;
//
//    for(int i = 0;i<[ParamsArray count];i++)
//    {
//        NSString *appendString = [NSString stringWithFormat:@"/%@",[ParamsArray objectAtIndex:i]];
//        Query = [Query stringByAppendingString:appendString];
//    }
//    return Query;
//}

/*** this method can be used when parameters are to be sent as query string ***/
- (NSMutableURLRequest*)getMutableRequestFromGetWS:(NSString*)WebService withParams:(NSDictionary*)ParamsDictionary
{
    NSString* Query;
    if (ParamsDictionary == nil) {
        Query = WebService;
    } else {
        int i = 0;
        Query = WebService;
        for (id key in ParamsDictionary) {
            NSString* appendString = @"";
            if (i != ParamsDictionary.count - 1)
                appendString = [appendString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [ParamsDictionary objectForKey:key]]];
            else
                appendString = [appendString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [ParamsDictionary objectForKey:key]]];
            Query = [Query stringByAppendingString:appendString];
            i++;
        }
    }
    Query = [Query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSMutableURLRequest* request = [NSMutableURLRequest
         requestWithURL:[NSURL URLWithString:Query]
            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
        timeoutInterval:DEFAULT_TIMEOUT];
    if ([DefaultsValues isKeyAvailbaleInDefault:kUserObject]) {
        User* objUser = GET_USER_OBJ;
        if ((objUser != NULL) && (objUser.authenticationToken != NULL) && (objUser.email != NULL)) {
            NSDictionary* headers = @{ @"token" : objUser.authenticationToken,
                @"email" : objUser.email };
            [request setAllHTTPHeaderFields:headers];
        }
    }

    return request;
}

- (NSMutableURLRequest*)getMutableRequestFromDeleteWS:(NSString*)WebService withParams:(NSDictionary*)ParamsDictionary
{
    NSString* Query;
    if (ParamsDictionary == nil) {
        Query = WebService;
    } else {
        int i = 0;
        Query = WebService;
        for (id key in ParamsDictionary) {
            NSString* appendString = @"";
            if (i != ParamsDictionary.count - 1)
                appendString = [appendString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [ParamsDictionary objectForKey:key]]];
            else
                appendString = [appendString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [ParamsDictionary objectForKey:key]]];
            Query = [Query stringByAppendingString:appendString];
            i++;
        }
    }
    Query = [Query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSMutableURLRequest* request = [NSMutableURLRequest
         requestWithURL:[NSURL URLWithString:Query]
            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
        timeoutInterval:DEFAULT_TIMEOUT];
    if ([DefaultsValues isKeyAvailbaleInDefault:kUserObject]) {
        User* objUser = GET_USER_OBJ;
        if ((objUser != NULL) && (objUser.authenticationToken != NULL) && (objUser.email != NULL)) {
            NSDictionary* headers = @{ @"token" : objUser.authenticationToken,
                @"email" : objUser.email };
            [request setAllHTTPHeaderFields:headers];
        }
    }
    [request setHTTPMethod:@"DELETE"];

    return request;
}

- (NSMutableURLRequest*)getMutableRequestForPostWS:(NSString*)url withObjects:(NSDictionary*)dict isJsonBody:(bool)JSONBody isPut:(BOOL)isPut
{
    NSString* urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSMutableURLRequest* request = [NSMutableURLRequest
         requestWithURL:[NSURL URLWithString:urlString]
            cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:DEFAULT_TIMEOUT];
    NSData* objData;
    User* objUser = GET_USER_OBJ;

    if (JSONBody) {
        //TraceWS(url,dict,@"JSON")
        objData = [self dictionaryToJSONData:dict];

        NSDictionary* headers;

        if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kLogIn]) {
            if ((objUser != NULL) && (objUser.authenticationToken != NULL) && (objUser.email != NULL)) {
                headers = @{ @"Content-Type" : @"application/json",
                    @"token" : objUser.authenticationToken,
                    @"email" : objUser.email };
            }
        } else {
            headers = @{ @"Content-Type" : @"application/json" };
        }

        [request setAllHTTPHeaderFields:headers];
    } else {
        //TraceWS(url,dict,@"POST")
        objData = [self dictionaryToPostData:dict];
        if ([DefaultsValues isKeyAvailbaleInDefault:kUserObject]) {
            User* objUser = GET_USER_OBJ;
            if ((objUser != NULL) && (objUser.authenticationToken != NULL) && (objUser.email != NULL)) {
                NSDictionary* headers = @{ @"token" : objUser.authenticationToken,
                    @"email" : objUser.email };
                [request setAllHTTPHeaderFields:headers];
            }
        } else {
            [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
    }
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[objData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:isPut ? @"PUT" : @"POST"];
    [request setHTTPBody:objData];
    return request;
}

- (NSMutableURLRequest*)getMutableRequestForCreateFeedsWS:(NSString*)url withObjects:(NSDictionary*)dict
{

    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString* BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";

    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file[]";

    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:url];

    // create request
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:DEFAULT_TIMEOUT];
    [request setHTTPMethod:@"POST"];

    // set Content-Type in HTTP header
    NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    // post body
    NSMutableData* body = [NSMutableData data];

    // add params (all params are strings)

    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];

    for (id key in dict) {
        if (![key isEqualToString:@"file"]) {
            [_params setObject:[NSString stringWithFormat:@"%@", [dict valueForKey:key]] forKey:key];
        }
    }

    for (NSString* param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dict objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSMutableArray* arrMedia = [dict objectForKey:@"file"];
    //    [arrMedia enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    for (int i = 0; i < arrMedia.count; i++) {
        id obj = [arrMedia objectAtIndex:i];

        if ([obj isKindOfClass:[UIImage class]]) {
            //media is image
            UIImage* img = (UIImage*)obj;
            NSData* imageData = UIImageJPEGRepresentation(img, 1.0);
            //set unique name for image with time stamp for temporary purpose, as on server randomly name are getting generated as well.
            //            NSString *timeStamp =[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
            NSString* strImageName = @"Hello.jpeg";
            NSString* str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant, strImageName];

            if (imageData) {

                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        } else {
            //media is video
        }
    };

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];

    // set URL
    [request setURL:requestURL];

    return request;
}

//- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
//{
//    float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
//    float total = [[NSNumber numberWithInteger:totalBytesExpectedToWrite] floatValue];
//    NSLog(@"per  =%f", progress / total);
//    progressView.progress =
//}

#pragma mark - helper methods
- (NSData*)dictionaryToJSONData:(NSDictionary*)dict
{
    NSError* jsonError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithDictionary:dict] options:0 error:&jsonError];
    if (jsonError != nil) {
        return nil;
    }
    return jsonData;
}

- (NSData*)dictionaryToPostData:(NSDictionary*)ParamsDictionary
{
    int i = 0;
    NSString* postDataString = @"";
    for (id key in ParamsDictionary) {
        if (i != ParamsDictionary.count - 1)
            postDataString = [postDataString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [ParamsDictionary objectForKey:key]]];
        else
            postDataString = [postDataString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [ParamsDictionary objectForKey:key]]];
        i++;
    }
    return [postDataString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
