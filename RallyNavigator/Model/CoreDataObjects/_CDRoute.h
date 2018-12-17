// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoute.h instead.

#import <CoreData/CoreData.h>

extern const struct CDRouteAttributes {
	 __unsafe_unretained NSString *currentStyle;
	 __unsafe_unretained NSString *data;
	 __unsafe_unretained NSString *deletedAt;
	 __unsafe_unretained NSString *endAddress;
	 __unsafe_unretained NSString *endLatitude;
	 __unsafe_unretained NSString *endLongitude;
	 __unsafe_unretained NSString *fuelRange;
	 __unsafe_unretained NSString *length;
	 __unsafe_unretained NSString *lock;
	 __unsafe_unretained NSString *name;
	 __unsafe_unretained NSString *routeDescription;
	 __unsafe_unretained NSString *routeIdentifier;
	 __unsafe_unretained NSString *sharingLevel;
	 __unsafe_unretained NSString *startAddress;
	 __unsafe_unretained NSString *startLatitude;
	 __unsafe_unretained NSString *startLongitude;
	 __unsafe_unretained NSString *token;
	 __unsafe_unretained NSString *units;
	 __unsafe_unretained NSString *updatedAt;
	 __unsafe_unretained NSString *userId;
	 __unsafe_unretained NSString *waypointCount;
} CDRouteAttributes;

@interface CDRouteID : NSManagedObjectID {}
@end

@interface _CDRoute : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDRouteID* objectID;

@property (nonatomic, retain) NSString* currentStyle;

//- (BOOL)validateCurrentStyle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* deletedAt;

//- (BOOL)validateDeletedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* endAddress;

//- (BOOL)validateEndAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* endLatitude;

@property (atomic) double endLatitudeValue;
- (double)endLatitudeValue;
- (void)setEndLatitudeValue:(double)value_;

//- (BOOL)validateEndLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* endLongitude;

@property (atomic) double endLongitudeValue;
- (double)endLongitudeValue;
- (void)setEndLongitudeValue:(double)value_;

//- (BOOL)validateEndLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* fuelRange;

@property (atomic) double fuelRangeValue;
- (double)fuelRangeValue;
- (void)setFuelRangeValue:(double)value_;

//- (BOOL)validateFuelRange:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* length;

@property (atomic) double lengthValue;
- (double)lengthValue;
- (void)setLengthValue:(double)value_;

//- (BOOL)validateLength:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* lock;

//- (BOOL)validateLock:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* routeDescription;

//- (BOOL)validateRouteDescription:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* routeIdentifier;

@property (atomic) double routeIdentifierValue;
- (double)routeIdentifierValue;
- (void)setRouteIdentifierValue:(double)value_;

//- (BOOL)validateRouteIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* sharingLevel;

@property (atomic) double sharingLevelValue;
- (double)sharingLevelValue;
- (void)setSharingLevelValue:(double)value_;

//- (BOOL)validateSharingLevel:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* startAddress;

//- (BOOL)validateStartAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* startLatitude;

@property (atomic) double startLatitudeValue;
- (double)startLatitudeValue;
- (void)setStartLatitudeValue:(double)value_;

//- (BOOL)validateStartLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* startLongitude;

@property (atomic) double startLongitudeValue;
- (double)startLongitudeValue;
- (void)setStartLongitudeValue:(double)value_;

//- (BOOL)validateStartLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* token;

//- (BOOL)validateToken:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* units;

//- (BOOL)validateUnits:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* userId;

@property (atomic) double userIdValue;
- (double)userIdValue;
- (void)setUserIdValue:(double)value_;

//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* waypointCount;

@property (atomic) double waypointCountValue;
- (double)waypointCountValue;
- (void)setWaypointCountValue:(double)value_;

//- (BOOL)validateWaypointCount:(id*)value_ error:(NSError**)error_;

@end

@interface _CDRoute (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCurrentStyle;
- (void)setPrimitiveCurrentStyle:(NSString*)value;

- (NSString*)primitiveData;
- (void)setPrimitiveData:(NSString*)value;

- (NSString*)primitiveDeletedAt;
- (void)setPrimitiveDeletedAt:(NSString*)value;

- (NSString*)primitiveEndAddress;
- (void)setPrimitiveEndAddress:(NSString*)value;

- (NSNumber*)primitiveEndLatitude;
- (void)setPrimitiveEndLatitude:(NSNumber*)value;

- (double)primitiveEndLatitudeValue;
- (void)setPrimitiveEndLatitudeValue:(double)value_;

- (NSNumber*)primitiveEndLongitude;
- (void)setPrimitiveEndLongitude:(NSNumber*)value;

- (double)primitiveEndLongitudeValue;
- (void)setPrimitiveEndLongitudeValue:(double)value_;

- (NSNumber*)primitiveFuelRange;
- (void)setPrimitiveFuelRange:(NSNumber*)value;

- (double)primitiveFuelRangeValue;
- (void)setPrimitiveFuelRangeValue:(double)value_;

- (NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(NSNumber*)value;

- (double)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(double)value_;

- (NSString*)primitiveLock;
- (void)setPrimitiveLock:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveRouteDescription;
- (void)setPrimitiveRouteDescription:(NSString*)value;

- (NSNumber*)primitiveRouteIdentifier;
- (void)setPrimitiveRouteIdentifier:(NSNumber*)value;

- (double)primitiveRouteIdentifierValue;
- (void)setPrimitiveRouteIdentifierValue:(double)value_;

- (NSNumber*)primitiveSharingLevel;
- (void)setPrimitiveSharingLevel:(NSNumber*)value;

- (double)primitiveSharingLevelValue;
- (void)setPrimitiveSharingLevelValue:(double)value_;

- (NSString*)primitiveStartAddress;
- (void)setPrimitiveStartAddress:(NSString*)value;

- (NSNumber*)primitiveStartLatitude;
- (void)setPrimitiveStartLatitude:(NSNumber*)value;

- (double)primitiveStartLatitudeValue;
- (void)setPrimitiveStartLatitudeValue:(double)value_;

- (NSNumber*)primitiveStartLongitude;
- (void)setPrimitiveStartLongitude:(NSNumber*)value;

- (double)primitiveStartLongitudeValue;
- (void)setPrimitiveStartLongitudeValue:(double)value_;

- (NSString*)primitiveToken;
- (void)setPrimitiveToken:(NSString*)value;

- (NSString*)primitiveUnits;
- (void)setPrimitiveUnits:(NSString*)value;

- (NSString*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSString*)value;

- (NSNumber*)primitiveUserId;
- (void)setPrimitiveUserId:(NSNumber*)value;

- (double)primitiveUserIdValue;
- (void)setPrimitiveUserIdValue:(double)value_;

- (NSNumber*)primitiveWaypointCount;
- (void)setPrimitiveWaypointCount:(NSNumber*)value;

- (double)primitiveWaypointCountValue;
- (void)setPrimitiveWaypointCountValue:(double)value_;

@end
