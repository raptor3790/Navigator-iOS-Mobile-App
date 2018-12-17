//
//  WebServiceParser
//
//  Created by Parth on 8/20/12.
//  Copyright (c) NarolaInfotech. All rights reserved.
//

/*
 * Queued server to manage concurrency and priority of NSURLRequests.
 */

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "WebServiceDataAdaptor.h"

typedef void (^ResponseBlock)     (NSError *error, id objects, NSString *responseString);
typedef void (^ImageReadResponseBlock)     (NSError *error, id objects, NSString *responseString, NSData *data);

@interface WebServiceResponse : NSObject
{
    Reachability *reachability;
}

@property (strong) NSOperationQueue *operationQueue;
@property (strong) NSOperationQueue *scanoperationQueue;

+ (id)sharedMediaServer;

- (void)initWithWebRequests:(NSMutableURLRequest *)URLRequest inBlock:(ResponseBlock)resBlock;
- (void)initWithWebImageReadeRequests:(NSMutableURLRequest *)URLRequest inBlock:(ImageReadResponseBlock)resBlock;

@end
