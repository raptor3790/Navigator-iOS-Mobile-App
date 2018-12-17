// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDFolders.h instead.

#import <CoreData/CoreData.h>

extern const struct CDFoldersAttributes {
	 __unsafe_unretained NSString *folderName;
	 __unsafe_unretained NSString *folderType;
	 __unsafe_unretained NSString *foldersIdentifier;
	 __unsafe_unretained NSString *parentId;
	 __unsafe_unretained NSString *routesCounts;
	 __unsafe_unretained NSString *subfoldersCount;
} CDFoldersAttributes;

@interface CDFoldersID : NSManagedObjectID {}
@end

@interface _CDFolders : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDFoldersID* objectID;

@property (nonatomic, retain) NSString* folderName;

//- (BOOL)validateFolderName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* folderType;

//- (BOOL)validateFolderType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* foldersIdentifier;

@property (atomic) double foldersIdentifierValue;
- (double)foldersIdentifierValue;
- (void)setFoldersIdentifierValue:(double)value_;

//- (BOOL)validateFoldersIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* parentId;

@property (atomic) double parentIdValue;
- (double)parentIdValue;
- (void)setParentIdValue:(double)value_;

//- (BOOL)validateParentId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* routesCounts;

@property (atomic) double routesCountsValue;
- (double)routesCountsValue;
- (void)setRoutesCountsValue:(double)value_;

//- (BOOL)validateRoutesCounts:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* subfoldersCount;

@property (atomic) double subfoldersCountValue;
- (double)subfoldersCountValue;
- (void)setSubfoldersCountValue:(double)value_;

//- (BOOL)validateSubfoldersCount:(id*)value_ error:(NSError**)error_;

@end

@interface _CDFolders (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFolderName;
- (void)setPrimitiveFolderName:(NSString*)value;

- (NSString*)primitiveFolderType;
- (void)setPrimitiveFolderType:(NSString*)value;

- (NSNumber*)primitiveFoldersIdentifier;
- (void)setPrimitiveFoldersIdentifier:(NSNumber*)value;

- (double)primitiveFoldersIdentifierValue;
- (void)setPrimitiveFoldersIdentifierValue:(double)value_;

- (NSNumber*)primitiveParentId;
- (void)setPrimitiveParentId:(NSNumber*)value;

- (double)primitiveParentIdValue;
- (void)setPrimitiveParentIdValue:(double)value_;

- (NSNumber*)primitiveRoutesCounts;
- (void)setPrimitiveRoutesCounts:(NSNumber*)value;

- (double)primitiveRoutesCountsValue;
- (void)setPrimitiveRoutesCountsValue:(double)value_;

- (NSNumber*)primitiveSubfoldersCount;
- (void)setPrimitiveSubfoldersCount:(NSNumber*)value;

- (double)primitiveSubfoldersCountValue;
- (void)setPrimitiveSubfoldersCountValue:(double)value_;

@end
