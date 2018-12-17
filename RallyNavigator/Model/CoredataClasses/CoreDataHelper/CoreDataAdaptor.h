//
//  CoreDataWrapper.h
//  NIPLiOSFramework
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDRoutes.h"
#import "CDRoute.h"
#import "CDFolders.h"
//#import "CoreDataTraslation.h"
//#import "CoreDataLanguages.h"


@interface CoreDataAdaptor : NSObject

+ (void)SaveDataInCoreDB:(NSDictionary *)dict forEntity:(NSString *)entityname;
+ (void)deleteAllDataInCoreDB:(NSString *)entityname;
+ (void)deleteDataInCoreDB:(NSString *)entityname withCondition:(NSString *)condition;
+ (NSArray *)fetchAllRecordForEntityName:(NSString *)strEntityname;
+ (NSArray *)fetchAllRecordsForEntity:(NSString *)strEntityname withCondition:(NSString *)condition;

+ (NSArray *)fetchDataFromLocalDB:(NSString *)condition
                   sortDescriptor:(NSSortDescriptor*)sortDescriptor
                        forEntity:(NSString *)entityname;

+ (id)fetchData1FromLocalDB:(NSString *)condition
             sortDescriptor:(NSSortDescriptor*)sortDescriptor
                  forEntity:(NSString *)entityname;

+ (NSInteger)getCountOfSyncData:(NSString *)condition
                   sortDescriptor:(NSSortDescriptor*)sortDescriptor
                        forEntity:(NSString *)entityname;

+ (NSArray *)distinctValueFromEntity:(Class)entityClass
                       withPredicate:(NSPredicate *)predicate
                       attributeName:(NSString*)attributeName
                               error:(NSError **)error;


/*#pragma mark - Language CoreData methods
+ (NSArray *) fetchAllLanguage:(NSString *) condition;
+ (CoreDataLanguages *) fetchLanguageDetailsWhere:(NSString *) condition;
+(NSInteger)getLanguageCount;
+(BOOL)isVoiceAvailable:(NSString*)languageCode;
+(BOOL)isVoiceType:(NSString*)condition male:(BOOL)isMale;


#pragma mark - Translation CoreData methods
+ (NSArray *) fetchAllTranslation:(NSString *)condition;
+ (CoreDataTraslation *)saveNewTranslation:(NSDictionary *)dictionary;
+(void)deleteTraslationwithCondition:(NSString *)condition;

+(NSInteger)getRecordCount: (NSString *)entityname;*/

@end
