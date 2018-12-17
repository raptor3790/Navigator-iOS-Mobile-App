//
//  WebConnector.h
//  SQLExample
//
//  Created by Prerna on 5/15/15.
//  Copyright (c) 2015 Narola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef enum
{
    ServiceTypeGET = 0,
    ServiceTypePOST,
    ServiceTypeJSON,
    ServiceTypePUT,
    ServiceTypeDELETE
}ServiceType;

@interface WebServiceConnector : NSObject
{
    NSArray *responseArray;
    NSDictionary *responseDict;
    NSString *responseError;
    NSMutableURLRequest *URLRequest;
    NSInteger responseCode;

}
@property (nonatomic,assign) NSInteger intCallWS;

@property (nonatomic,retain) NSDictionary *responseDict;
@property (nonatomic,retain)    NSArray *responseArray;
@property (nonatomic,retain)    NSString *responseError;
@property (nonatomic,retain) NSMutableURLRequest *URLRequest;
@property (nonatomic) NSInteger responseCode;

- (void)init:(NSString *)WebService
withParameters:(NSDictionary *) ParamsDictionary
  withObject:(id)object
withSelector:(SEL)selector
forServiceType:(ServiceType)serviceType
showDisplayMsg:(NSString *)message
  showLoader:(BOOL)showLoader;

- (BOOL)checkNetConnection;

//-(NSString *) getNetURLFromService:(NSString *) WebService withParams: (NSArray *) ParamsArray;

-(NSMutableURLRequest *) getMutableRequestFromGetWS:(NSString *)WebService withParams: (NSDictionary *) ParamsDictionary;

- (NSMutableURLRequest *)getMutableRequestForPostWS:(NSString *)url withObjects:(NSDictionary *)dict isJsonBody:(bool)JSONBody isPut:(BOOL)isPut;

@end
