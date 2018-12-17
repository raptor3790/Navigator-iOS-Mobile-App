//
//  CoreDataWrapper.m
//  NIPLiOSFramework
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import "CoreDataAdaptor.h"
#import "CoreDataHelper.h"

NSFetchedResultsController *fetchedResultController;

@implementation CoreDataAdaptor

#pragma mark - Helper Methods

+ (void)SaveDataInCoreDB:(NSDictionary *)dict forEntity:(NSString *)entityname
{
    [[[NSClassFromString(entityname) create] insert:dict] save];
}

+ (void)deleteAllDataInCoreDB:(NSString *)entityname
{
    [NSClassFromString(entityname) clear:nil];
    [CoreDataHelper save];
}

+ (void)deleteDataInCoreDB:(NSString *)entityname withCondition:(NSString *)condition
{
    [NSClassFromString(entityname) clear:[NSPredicate predicateWithFormat:condition]];
    [CoreDataHelper save];
}

+ (NSArray *)fetchAllRecordForEntityName:(NSString *)strEntityname
{
    NSArray *records = [[NSClassFromString(strEntityname) query] order:[NSSortDescriptor sortDescriptorWithKey:@"" ascending:NO]].all;
    return records;
}

+ (NSArray *)fetchAllRecordsForEntity:(NSString *)strEntityname withCondition:(NSString *)condition
{
    NSArray *applicants = [[NSClassFromString(strEntityname) query] where:condition].all;
    return applicants;
}

+ (NSArray *)fetchDataFromLocalDB:(NSString *)condition
                   sortDescriptor:(NSSortDescriptor*)sortDescriptor
                        forEntity:(NSString *)entityname
{
    if (condition != nil)
    {
        NSArray *arrData = [[[NSClassFromString(entityname) query] where:condition] order:sortDescriptor].all;
        return arrData;
    }
    else{
        NSArray *arrData = [[NSClassFromString(entityname) query] order:sortDescriptor].all;
        return arrData;
    }
    return nil;
}

+ (id)fetchData1FromLocalDB:(NSString *)condition
                   sortDescriptor:(NSSortDescriptor*)sortDescriptor
                        forEntity:(NSString *)entityname
{
    if (condition != nil)
    {
        NSArray *arrData = [[[NSClassFromString(entityname) query] where:condition] order:sortDescriptor].first;
        return arrData;
    }
    else{
        NSArray *arrData = [[NSClassFromString(entityname) query] order:sortDescriptor].first;
        return arrData;
    }
    return nil;
}


+ (NSInteger)getCountOfSyncData:(NSString *)condition
                 sortDescriptor:(NSSortDescriptor*)sortDescriptor
                      forEntity:(NSString *)entityname
{
    NSError *error = nil;
    //return [CoreDataHelper countObjectsOfEntity:NSClassFromString(entityname) withPredicate:condition error:&error];
    
    return [CoreDataHelper countObjectsOfEntity:NSClassFromString(entityname) where:condition error:&error];
}

/*
#pragma mark - Language CoreData methods

+ (NSArray *) fetchAllLanguage:(NSString *) condition {

    NSArray *applicants = [[CoreDataLanguages query] where:condition].all;
    return applicants;
}

+(BOOL)isVoiceAvailable:(NSString*)languageCode
{
    CoreDataLanguages *applicants = [CoreDataAdaptor fetchLanguageDetailsWhere:[NSString stringWithFormat:@"language == '%@' AND iso681languagecode.length > 0", languageCode]];
    return !(applicants == nil);
}

+(BOOL)isVoiceType:(NSString*)condition male:(BOOL)isMale
{
    CoreDataLanguages *applicants = [CoreDataAdaptor fetchLanguageDetailsWhere:condition];
    return [(isMale ? applicants.maleVoice : applicants.femaleVoice) boolValue] ;
}

+ (CoreDataLanguages *) fetchLanguageDetailsWhere:(NSString *) condition {

    return [[[CoreDataLanguages query] where:condition] first];
}

+(NSInteger)getLanguageCount
{
    NSArray *arrRecords = [CoreDataLanguages query].all;
    return [arrRecords count];
}


#pragma mark - Translation CoreData methods
+ (NSArray *) fetchAllTranslation:(NSString *)condition {
    
    NSArray *applicants = [[[CoreDataTraslation query] where:condition] order:[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES]].all;
    return applicants;
}

+ (CoreDataTraslation *)saveNewTranslation:(NSDictionary *)dictionary{
    
    NSArray *transDetail = [[CoreDataTraslation query] where:[NSPredicate predicateWithFormat:@"translationId = %@",[dictionary objectForKey:@"translationId"]]].all;
    
    CoreDataTraslation *newtransDetail = [transDetail firstObject];
    
    if(newtransDetail == nil) {
        newtransDetail = [NSEntityDescription insertNewObjectForEntityForName:ClassCoreDataTraslation inManagedObjectContext:[[CoreDataHelper instance] managedObjectContext]];
    }
    
    newtransDetail.translationId = NULL_TO_NIL([dictionary objectForKey:@"translationId"]);
    newtransDetail.translatetionType = NULL_TO_NIL([dictionary objectForKey:@"translatetionType"]);
    newtransDetail.translatedText = NULL_TO_NIL([dictionary objectForKey:@"translatedText"]);
    newtransDetail.targetedLanguage = NULL_TO_NIL([dictionary objectForKey:@"targetedLanguage"]);
    newtransDetail.targetedLanguageCode = NULL_TO_NIL([dictionary objectForKey:@"targetedLanguageCode"]);
    newtransDetail.sourceText = NULL_TO_NIL([dictionary objectForKey:@"sourceText"]);
    newtransDetail.sourceLanguage = NULL_TO_NIL([dictionary objectForKey:@"sourceLanguage"]);
    newtransDetail.sourceLanguageCode = NULL_TO_NIL([dictionary objectForKey:@"sourceLanguageCode"]);
    newtransDetail.createdDate = [NSDate date];
    
    [CoreDataHelper save];
    return newtransDetail;
}

+(void)deleteTraslationwithCondition:(NSString *)condition
{
    [CoreDataTraslation clear:[NSPredicate predicateWithFormat:condition]];
}


*/

//+ (NSArray *) fetchAllOffersWhere:(NSString *) condition {
//
//    NSArray *offers = [[[CoreDataOffers query] where:condition] order:[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]].all;
//    return offers;
//}
//
//+ (NSArray *) fetchAllCategoriesWhere:(NSString *) condition {
//    
//    NSArray *categories = [[CoreDataCategories query] where:condition].all;
//    return categories;
//}
//
//+ (NSArray *) fetchAllPolicy:(NSString *) condition
//{
//    NSArray *policies = [[CoreDataAppPolicy query] where:nil].all;
//    return policies;
//}
//
//+ (BOOL) updateStatusOfAnOffer:(NSString *) status withCondition:(NSString *) condition {
//    
//    CoreDataOffers *objOffer = [[CoreDataOffers query] where:condition].first;
//    
//    if (objOffer) {
//        objOffer.offerStatus = status;
//        
//        [CoreDataHelper save];
//        
//        return YES;
//    }
//    return NO;
//}
//
//+ (BOOL) updateStatusOfAnOfferAsApplicant:(NSString *) status withCondition:(NSString *) condition {
//    
//    CoreDataOffers *objOffer = [[CoreDataOffers query] where:condition].first;
//    
//    if (objOffer) {
//        objOffer.status = status;
//        
//        [CoreDataHelper save];
//        
//        return YES;
//    }
//    return NO;
//}
//
//+ (BOOL) updateStatusOfApplicant:(NSString *) status withCondition:(NSString *) condition {
//    
//    CoreDataApplicants *objOffer = [[CoreDataApplicants query] where:condition].first;
//    
//    if (objOffer) {
//        objOffer.status = status;
//        
//        [CoreDataHelper save];
//        
//        return YES;
//    }
//    return NO;
//}
//
//+ (NSArray *) fetchAllApplicantsWhere:(NSString *) condition {
//    
//    NSArray *applicants = [[CoreDataApplicants query] where:condition].all;
//    return applicants;
//}
//
//+ (CoreDataOffers *) fetchOfferWhere:(NSString *) condition {
//    return [[[CoreDataOffers query] where:condition] first];
//}
//
//// =========== Offers CoreData methods Ends
//
//
//#pragma mark - Users CoreData methods
//
//+ (NSArray *) fetchAllUsersWhere:(NSString *) condition {
//    
//    NSArray *users = [[CoreDataUsers query] where:condition].all;
//    
////    order:[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]
//    return users;
//}
//
//+ (CoreDataUsers *) fetchUserDetailsWhere:(NSString *) condition {
//    
//    return [[[CoreDataUsers query] where:condition] first];
//}

//+ (void) deleteAllCategoryTypesforUser:(NSString *) condition {
//    [CoreDataCategories clear:[NSPredicate predicateWithFormat:condition]];
//    [CoreDataHelper save];
//}


// =========== Offers CoreData methods Ends


//+(void)deleteDataInCoreDB:(NSString *)entityname withCondition:(NSString *)condition
//{
//    [Restaurant clear:[NSPredicate predicateWithFormat:condition]];
//}
//+(void)deleteAllDataInCoreDB:(NSString *)entityname
//{
//    [Restaurant clear:nil];
//}
//
//+ (NSArray *) fetchRestaurantWhere:(NSString *)condition
//{
//    NSArray *food = [[Restaurant query]where:condition].all;
//    return food;
//}
//
//+ (NSArray *) fetchAllRestaurant
//{
//    NSArray *food = [Restaurant query].all;
//    return food;
//}

//+ (void)updateRecords:(NSString *) condition
//{
//    //NSPredicate *condition1 = [NSPredicate predicateWithFormat:@"fooddescription contains[c] 'Bhel puri'"];
//    NSArray *food = [[Restaurant query]where:condition].all;
//    for(int i = 0; i< [food count];i++)
//    {
//        Restaurant * restaurant = [food objectAtIndex:i];
//        [restaurant.title stringByReplacingOccurrencesOfString:@"Bhel puri" withString:@"BhelPuri"];
//        restaurant.landmark = @"Near Iscon mall";
//        [CoreDataHelper save];
//    }
//}
//
//-(NSInteger)getRecordCount: (NSString *)entityname
//{
//    NSArray *arrRecords = [Restaurant query].all;
//    return [arrRecords count];
//}

/*********** Reference methods   *************/
+ (void)SaveRestaurantInCoreDB:(NSDictionary *)dict
{
    //
    //    [[[FamousFood create]
    //        insert:@{@"call":[NSNumber numberWithInteger:8128998654],
    //                 @"foodId":[NSNumber numberWithInteger:10],
    //                 @"foodname":@"Pavbhaji",
    //                 @"images":@"",
    //                 @"landmark":@"Temple",
    //                 @"location":@"Adajan",
    //                 @"ratings":[NSNumber numberWithInteger:5],
    //                 @"title":@"Mahesh Pavbhaji"}]
    //        save];
    //
    //    [[[FamousFood create] insert:dict]save];
    
}
+(NSArray *)getAllRestaurantFromCoreDB
{
    //    [FamousFood create];
    //    fetchedResultController = [[[[FamousFood query]order:@""]sectionNameKeyPath:@""]fetchedResultsController];
    //    NSLog(@"%@",fetchedResultController.fetchedObjects);
    return fetchedResultController.fetchedObjects;
}
+ (void)MapNSObjectToNSManagedObject:(NSString *)objClass forEntityName:(NSManagedObject *)entityname withDataSource:(NSMutableArray *)array
{
    //    if([array count] >0)
    //    {
    //
    //    }
    //    else
    //    {
    //        unsigned count;
    //        objc_property_t *properties = class_copyPropertyList([objClass class], &count);
    //        NSMutableDictionary *attributes = (NSMutableDictionary *)[[entityname entity] attributesByName];
    //        NSMutableDictionary *elements = [NSMutableDictionary dictionary];
    //        [elements setObject:[NSValue valueWithPointer:&RestaurantAttributes]
    //                       forKey:@"Keys"];
    //
    //        for (int i = 0; i < count; i++)
    //        {
    //            NSString *objectkey = [NSString stringWithUTF8String:property_getName(properties[i])];
    //            NSString *objectValue = [NSString stringWithUTF8String:property_copyAttributeValue(*properties, property_getName(properties[i]))];
    //            for (objectkey in [attributes allKeys])
    //            {
    //                //property_getName(properties[i]) = [attributes objectForKey:<#(nonnull id)#>]
    //                [attributes setValue:objectValue forKey:objectkey];
    //                NSLog(@"%@",attributes);
    //            }
    //        }
    //    }
}



+(NSInteger)getRecordCount: (NSString *)entityname
{
    return 0;
}


+ (NSArray *)distinctValueFromEntity:(Class)entityClass
                       withPredicate:(NSPredicate *)predicate
                       attributeName:(NSString*)attributeName
                               error:(NSError **)error
{
    return [CoreDataHelper distinctValueFromEntity:entityClass withPredicate:predicate attributeName:attributeName error:error];
}

@end
