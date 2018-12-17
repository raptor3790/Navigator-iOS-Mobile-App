// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoute.m instead.

#import "_CDRoute.h"

const struct CDRouteAttributes CDRouteAttributes = {
	.currentStyle = @"currentStyle",
	.data = @"data",
	.deletedAt = @"deletedAt",
	.endAddress = @"endAddress",
	.endLatitude = @"endLatitude",
	.endLongitude = @"endLongitude",
	.fuelRange = @"fuelRange",
	.length = @"length",
	.lock = @"lock",
	.name = @"name",
	.routeDescription = @"routeDescription",
	.routeIdentifier = @"routeIdentifier",
	.sharingLevel = @"sharingLevel",
	.startAddress = @"startAddress",
	.startLatitude = @"startLatitude",
	.startLongitude = @"startLongitude",
	.token = @"token",
	.units = @"units",
	.updatedAt = @"updatedAt",
	.userId = @"userId",
	.waypointCount = @"waypointCount",
};

@implementation CDRouteID
@end

@implementation _CDRoute

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDRoute" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDRoute";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDRoute" inManagedObjectContext:moc_];
}

- (CDRouteID*)objectID {
	return (CDRouteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"endLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"endLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fuelRangeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fuelRange"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lengthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"length"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"routeIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"routeIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sharingLevelValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sharingLevel"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"waypointCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"waypointCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic currentStyle;

@dynamic data;

@dynamic deletedAt;

@dynamic endAddress;

@dynamic endLatitude;

- (double)endLatitudeValue {
	NSNumber *result = [self endLatitude];
	return [result doubleValue];
}

- (void)setEndLatitudeValue:(double)value_ {
	[self setEndLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveEndLatitudeValue {
	NSNumber *result = [self primitiveEndLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveEndLatitudeValue:(double)value_ {
	[self setPrimitiveEndLatitude:[NSNumber numberWithDouble:value_]];
}

@dynamic endLongitude;

- (double)endLongitudeValue {
	NSNumber *result = [self endLongitude];
	return [result doubleValue];
}

- (void)setEndLongitudeValue:(double)value_ {
	[self setEndLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveEndLongitudeValue {
	NSNumber *result = [self primitiveEndLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveEndLongitudeValue:(double)value_ {
	[self setPrimitiveEndLongitude:[NSNumber numberWithDouble:value_]];
}

@dynamic fuelRange;

- (double)fuelRangeValue {
	NSNumber *result = [self fuelRange];
	return [result doubleValue];
}

- (void)setFuelRangeValue:(double)value_ {
	[self setFuelRange:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveFuelRangeValue {
	NSNumber *result = [self primitiveFuelRange];
	return [result doubleValue];
}

- (void)setPrimitiveFuelRangeValue:(double)value_ {
	[self setPrimitiveFuelRange:[NSNumber numberWithDouble:value_]];
}

@dynamic length;

- (double)lengthValue {
	NSNumber *result = [self length];
	return [result doubleValue];
}

- (void)setLengthValue:(double)value_ {
	[self setLength:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLengthValue {
	NSNumber *result = [self primitiveLength];
	return [result doubleValue];
}

- (void)setPrimitiveLengthValue:(double)value_ {
	[self setPrimitiveLength:[NSNumber numberWithDouble:value_]];
}

@dynamic lock;

@dynamic name;

@dynamic routeDescription;

@dynamic routeIdentifier;

- (double)routeIdentifierValue {
	NSNumber *result = [self routeIdentifier];
	return [result doubleValue];
}

- (void)setRouteIdentifierValue:(double)value_ {
	[self setRouteIdentifier:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveRouteIdentifierValue {
	NSNumber *result = [self primitiveRouteIdentifier];
	return [result doubleValue];
}

- (void)setPrimitiveRouteIdentifierValue:(double)value_ {
	[self setPrimitiveRouteIdentifier:[NSNumber numberWithDouble:value_]];
}

@dynamic sharingLevel;

- (double)sharingLevelValue {
	NSNumber *result = [self sharingLevel];
	return [result doubleValue];
}

- (void)setSharingLevelValue:(double)value_ {
	[self setSharingLevel:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveSharingLevelValue {
	NSNumber *result = [self primitiveSharingLevel];
	return [result doubleValue];
}

- (void)setPrimitiveSharingLevelValue:(double)value_ {
	[self setPrimitiveSharingLevel:[NSNumber numberWithDouble:value_]];
}

@dynamic startAddress;

@dynamic startLatitude;

- (double)startLatitudeValue {
	NSNumber *result = [self startLatitude];
	return [result doubleValue];
}

- (void)setStartLatitudeValue:(double)value_ {
	[self setStartLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveStartLatitudeValue {
	NSNumber *result = [self primitiveStartLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveStartLatitudeValue:(double)value_ {
	[self setPrimitiveStartLatitude:[NSNumber numberWithDouble:value_]];
}

@dynamic startLongitude;

- (double)startLongitudeValue {
	NSNumber *result = [self startLongitude];
	return [result doubleValue];
}

- (void)setStartLongitudeValue:(double)value_ {
	[self setStartLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveStartLongitudeValue {
	NSNumber *result = [self primitiveStartLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveStartLongitudeValue:(double)value_ {
	[self setPrimitiveStartLongitude:[NSNumber numberWithDouble:value_]];
}

@dynamic token;

@dynamic units;

@dynamic updatedAt;

@dynamic userId;

- (double)userIdValue {
	NSNumber *result = [self userId];
	return [result doubleValue];
}

- (void)setUserIdValue:(double)value_ {
	[self setUserId:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveUserIdValue {
	NSNumber *result = [self primitiveUserId];
	return [result doubleValue];
}

- (void)setPrimitiveUserIdValue:(double)value_ {
	[self setPrimitiveUserId:[NSNumber numberWithDouble:value_]];
}

@dynamic waypointCount;

- (double)waypointCountValue {
	NSNumber *result = [self waypointCount];
	return [result doubleValue];
}

- (void)setWaypointCountValue:(double)value_ {
	[self setWaypointCount:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWaypointCountValue {
	NSNumber *result = [self primitiveWaypointCount];
	return [result doubleValue];
}

- (void)setPrimitiveWaypointCountValue:(double)value_ {
	[self setPrimitiveWaypointCount:[NSNumber numberWithDouble:value_]];
}

@end

