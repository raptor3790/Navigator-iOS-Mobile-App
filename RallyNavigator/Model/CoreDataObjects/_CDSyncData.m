// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDSyncData.m instead.

#import "_CDSyncData.h"

const struct CDSyncDataAttributes CDSyncDataAttributes = {
	.distanceUnit = @"distanceUnit",
	.imageData = @"imageData",
	.isActive = @"isActive",
	.isAutoPhoto = @"isAutoPhoto",
	.isEdit = @"isEdit",
	.jsonData = @"jsonData",
	.jsonDataType = @"jsonDataType",
	.name = @"name",
	.routeIdentifier = @"routeIdentifier",
	.serviceType = @"serviceType",
	.updatedAt = @"updatedAt",
	.voiceData = @"voiceData",
};

@implementation CDSyncDataID
@end

@implementation _CDSyncData

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDSyncData" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDSyncData";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDSyncData" inManagedObjectContext:moc_];
}

- (CDSyncDataID*)objectID {
	return (CDSyncDataID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isActiveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isActive"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isAutoPhotoValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isAutoPhoto"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isEditValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEdit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"jsonDataTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"jsonDataType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"routeIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"routeIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"serviceTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"serviceType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic distanceUnit;

@dynamic imageData;

@dynamic isActive;

- (int64_t)isActiveValue {
	NSNumber *result = [self isActive];
	return [result longLongValue];
}

- (void)setIsActiveValue:(int64_t)value_ {
	[self setIsActive:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIsActiveValue {
	NSNumber *result = [self primitiveIsActive];
	return [result longLongValue];
}

- (void)setPrimitiveIsActiveValue:(int64_t)value_ {
	[self setPrimitiveIsActive:[NSNumber numberWithLongLong:value_]];
}

@dynamic isAutoPhoto;

- (int64_t)isAutoPhotoValue {
	NSNumber *result = [self isAutoPhoto];
	return [result longLongValue];
}

- (void)setIsAutoPhotoValue:(int64_t)value_ {
	[self setIsAutoPhoto:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIsAutoPhotoValue {
	NSNumber *result = [self primitiveIsAutoPhoto];
	return [result longLongValue];
}

- (void)setPrimitiveIsAutoPhotoValue:(int64_t)value_ {
	[self setPrimitiveIsAutoPhoto:[NSNumber numberWithLongLong:value_]];
}

@dynamic isEdit;

- (int64_t)isEditValue {
	NSNumber *result = [self isEdit];
	return [result longLongValue];
}

- (void)setIsEditValue:(int64_t)value_ {
	[self setIsEdit:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIsEditValue {
	NSNumber *result = [self primitiveIsEdit];
	return [result longLongValue];
}

- (void)setPrimitiveIsEditValue:(int64_t)value_ {
	[self setPrimitiveIsEdit:[NSNumber numberWithLongLong:value_]];
}

@dynamic jsonData;

@dynamic jsonDataType;

- (int64_t)jsonDataTypeValue {
	NSNumber *result = [self jsonDataType];
	return [result longLongValue];
}

- (void)setJsonDataTypeValue:(int64_t)value_ {
	[self setJsonDataType:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveJsonDataTypeValue {
	NSNumber *result = [self primitiveJsonDataType];
	return [result longLongValue];
}

- (void)setPrimitiveJsonDataTypeValue:(int64_t)value_ {
	[self setPrimitiveJsonDataType:[NSNumber numberWithLongLong:value_]];
}

@dynamic name;

@dynamic routeIdentifier;

- (int64_t)routeIdentifierValue {
	NSNumber *result = [self routeIdentifier];
	return [result longLongValue];
}

- (void)setRouteIdentifierValue:(int64_t)value_ {
	[self setRouteIdentifier:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRouteIdentifierValue {
	NSNumber *result = [self primitiveRouteIdentifier];
	return [result longLongValue];
}

- (void)setPrimitiveRouteIdentifierValue:(int64_t)value_ {
	[self setPrimitiveRouteIdentifier:[NSNumber numberWithLongLong:value_]];
}

@dynamic serviceType;

- (int64_t)serviceTypeValue {
	NSNumber *result = [self serviceType];
	return [result longLongValue];
}

- (void)setServiceTypeValue:(int64_t)value_ {
	[self setServiceType:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveServiceTypeValue {
	NSNumber *result = [self primitiveServiceType];
	return [result longLongValue];
}

- (void)setPrimitiveServiceTypeValue:(int64_t)value_ {
	[self setPrimitiveServiceType:[NSNumber numberWithLongLong:value_]];
}

@dynamic updatedAt;

@dynamic voiceData;

@end

