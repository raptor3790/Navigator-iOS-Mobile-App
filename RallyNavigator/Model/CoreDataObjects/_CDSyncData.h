// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDSyncData.h instead.

#import <CoreData/CoreData.h>

extern const struct CDSyncDataAttributes {
	 __unsafe_unretained NSString *distanceUnit;
	 __unsafe_unretained NSString *imageData;
	 __unsafe_unretained NSString *isActive;
	 __unsafe_unretained NSString *isAutoPhoto;
	 __unsafe_unretained NSString *isEdit;
	 __unsafe_unretained NSString *jsonData;
	 __unsafe_unretained NSString *jsonDataType;
	 __unsafe_unretained NSString *name;
	 __unsafe_unretained NSString *routeIdentifier;
	 __unsafe_unretained NSString *serviceType;
	 __unsafe_unretained NSString *updatedAt;
	 __unsafe_unretained NSString *voiceData;
} CDSyncDataAttributes;

@interface CDSyncDataID : NSManagedObjectID {}
@end

@interface _CDSyncData : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDSyncDataID* objectID;

@property (nonatomic, retain) NSString* distanceUnit;

//- (BOOL)validateDistanceUnit:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* imageData;

//- (BOOL)validateImageData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* isActive;

@property (atomic) int64_t isActiveValue;
- (int64_t)isActiveValue;
- (void)setIsActiveValue:(int64_t)value_;

//- (BOOL)validateIsActive:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* isAutoPhoto;

@property (atomic) int64_t isAutoPhotoValue;
- (int64_t)isAutoPhotoValue;
- (void)setIsAutoPhotoValue:(int64_t)value_;

//- (BOOL)validateIsAutoPhoto:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* isEdit;

@property (atomic) int64_t isEditValue;
- (int64_t)isEditValue;
- (void)setIsEditValue:(int64_t)value_;

//- (BOOL)validateIsEdit:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* jsonData;

//- (BOOL)validateJsonData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* jsonDataType;

@property (atomic) int64_t jsonDataTypeValue;
- (int64_t)jsonDataTypeValue;
- (void)setJsonDataTypeValue:(int64_t)value_;

//- (BOOL)validateJsonDataType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* routeIdentifier;

@property (atomic) int64_t routeIdentifierValue;
- (int64_t)routeIdentifierValue;
- (void)setRouteIdentifierValue:(int64_t)value_;

//- (BOOL)validateRouteIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* serviceType;

@property (atomic) int64_t serviceTypeValue;
- (int64_t)serviceTypeValue;
- (void)setServiceTypeValue:(int64_t)value_;

//- (BOOL)validateServiceType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* voiceData;

//- (BOOL)validateVoiceData:(id*)value_ error:(NSError**)error_;

@end

@interface _CDSyncData (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveDistanceUnit;
- (void)setPrimitiveDistanceUnit:(NSString*)value;

- (NSString*)primitiveImageData;
- (void)setPrimitiveImageData:(NSString*)value;

- (NSNumber*)primitiveIsActive;
- (void)setPrimitiveIsActive:(NSNumber*)value;

- (int64_t)primitiveIsActiveValue;
- (void)setPrimitiveIsActiveValue:(int64_t)value_;

- (NSNumber*)primitiveIsAutoPhoto;
- (void)setPrimitiveIsAutoPhoto:(NSNumber*)value;

- (int64_t)primitiveIsAutoPhotoValue;
- (void)setPrimitiveIsAutoPhotoValue:(int64_t)value_;

- (NSNumber*)primitiveIsEdit;
- (void)setPrimitiveIsEdit:(NSNumber*)value;

- (int64_t)primitiveIsEditValue;
- (void)setPrimitiveIsEditValue:(int64_t)value_;

- (NSString*)primitiveJsonData;
- (void)setPrimitiveJsonData:(NSString*)value;

- (NSNumber*)primitiveJsonDataType;
- (void)setPrimitiveJsonDataType:(NSNumber*)value;

- (int64_t)primitiveJsonDataTypeValue;
- (void)setPrimitiveJsonDataTypeValue:(int64_t)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveRouteIdentifier;
- (void)setPrimitiveRouteIdentifier:(NSNumber*)value;

- (int64_t)primitiveRouteIdentifierValue;
- (void)setPrimitiveRouteIdentifierValue:(int64_t)value_;

- (NSNumber*)primitiveServiceType;
- (void)setPrimitiveServiceType:(NSNumber*)value;

- (int64_t)primitiveServiceTypeValue;
- (void)setPrimitiveServiceTypeValue:(int64_t)value_;

- (NSString*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSString*)value;

- (NSString*)primitiveVoiceData;
- (void)setPrimitiveVoiceData:(NSString*)value;

@end
