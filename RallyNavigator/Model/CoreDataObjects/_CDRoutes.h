// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoutes.h instead.

#import <CoreData/CoreData.h>

extern const struct CDRoutesAttributes {
	 __unsafe_unretained NSString *editable;
	 __unsafe_unretained NSString *folderId;
	 __unsafe_unretained NSString *folderIdentifier;
	 __unsafe_unretained NSString *length;
	 __unsafe_unretained NSString *name;
	 __unsafe_unretained NSString *routesIdentifier;
	 __unsafe_unretained NSString *units;
	 __unsafe_unretained NSString *updatedAt;
	 __unsafe_unretained NSString *waypointCount;
} CDRoutesAttributes;

@interface CDRoutesID : NSManagedObjectID {}
@end

@interface _CDRoutes : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDRoutesID* objectID;

@property (nonatomic, retain) NSNumber* editable;

@property (atomic) int64_t editableValue;
- (int64_t)editableValue;
- (void)setEditableValue:(int64_t)value_;

//- (BOOL)validateEditable:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* folderId;

@property (atomic) double folderIdValue;
- (double)folderIdValue;
- (void)setFolderIdValue:(double)value_;

//- (BOOL)validateFolderId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* folderIdentifier;

@property (atomic) double folderIdentifierValue;
- (double)folderIdentifierValue;
- (void)setFolderIdentifierValue:(double)value_;

//- (BOOL)validateFolderIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* length;

@property (atomic) double lengthValue;
- (double)lengthValue;
- (void)setLengthValue:(double)value_;

//- (BOOL)validateLength:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* routesIdentifier;

@property (atomic) double routesIdentifierValue;
- (double)routesIdentifierValue;
- (void)setRoutesIdentifierValue:(double)value_;

//- (BOOL)validateRoutesIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* units;

//- (BOOL)validateUnits:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* waypointCount;

@property (atomic) double waypointCountValue;
- (double)waypointCountValue;
- (void)setWaypointCountValue:(double)value_;

//- (BOOL)validateWaypointCount:(id*)value_ error:(NSError**)error_;

@end

@interface _CDRoutes (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveEditable;
- (void)setPrimitiveEditable:(NSNumber*)value;

- (int64_t)primitiveEditableValue;
- (void)setPrimitiveEditableValue:(int64_t)value_;

- (NSNumber*)primitiveFolderId;
- (void)setPrimitiveFolderId:(NSNumber*)value;

- (double)primitiveFolderIdValue;
- (void)setPrimitiveFolderIdValue:(double)value_;

- (NSNumber*)primitiveFolderIdentifier;
- (void)setPrimitiveFolderIdentifier:(NSNumber*)value;

- (double)primitiveFolderIdentifierValue;
- (void)setPrimitiveFolderIdentifierValue:(double)value_;

- (NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(NSNumber*)value;

- (double)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(double)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveRoutesIdentifier;
- (void)setPrimitiveRoutesIdentifier:(NSNumber*)value;

- (double)primitiveRoutesIdentifierValue;
- (void)setPrimitiveRoutesIdentifierValue:(double)value_;

- (NSString*)primitiveUnits;
- (void)setPrimitiveUnits:(NSString*)value;

- (NSString*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSString*)value;

- (NSNumber*)primitiveWaypointCount;
- (void)setPrimitiveWaypointCount:(NSNumber*)value;

- (double)primitiveWaypointCountValue;
- (void)setPrimitiveWaypointCountValue:(double)value_;

@end
