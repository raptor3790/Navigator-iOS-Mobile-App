//
//  WebHelper.h
//  SQLExample
//
//  Created by iMac on 17/03/14.
//  Copyright (c) 2014 Narola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Routes.h"
#import "Route.h"
#import "Roadbooks.h"
#import "Folders.h"

@interface WebServiceDataAdaptor : NSObject
{

}
@property(nonatomic,retain) NSArray *arrParsedData;


-(NSArray *) autoParse:(NSDictionary *) allValues
        forServiceName:(NSString *)requestURL;

-(NSArray *) processJSONData: (NSDictionary *)dict
                    forClass:(NSString *)classname
                   forEntity:(NSString *)entityname
                 withJSONKey:(NSString *)json_Key;

-(NSDictionary *)processObjectForCoreData:(id)obj;

@end
