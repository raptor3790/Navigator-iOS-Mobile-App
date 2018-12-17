// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoutes.m instead.

#import "_CDRoutes.h"

const struct CDRoutesAttributes CDRoutesAttributes = {
	.editable = @"editable",
	.folderId = @"folderId",
	.folderIdentifier = @"folderIdentifier",
	.length = @"length",
	.name = @"name",
	.routesIdentifier = @"routesIdentifier",
	.units = @"units",
	.updatedAt = @"updatedAt",
	.waypointCount = @"waypointCount",
};

@implementation CDRoutesID
@end

@implementation _CDRoutes

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDRoutes" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDRoutes";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDRoutes" inManagedObjectContext:moc_];
}

- (CDRoutesID*)objectID {
	return (CDRoutesID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"editableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"editable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"folderIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"folderId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"folderIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"folderIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lengthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"length"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"routesIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"routesIdentifier"];
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

@dynamic editable;

- (int64_t)editableValue {
	NSNumber *result = [self editable];
	return [result longLongValue];
}

- (void)setEditableValue:(int64_t)value_ {
	[self setEditable:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveEditableValue {
	NSNumber *result = [self primitiveEditable];
	return [result longLongValue];
}

- (void)setPrimitiveEditableValue:(int64_t)value_ {
	[self setPrimitiveEditable:[NSNumber numberWithLongLong:value_]];
}

@dynamic folderId;

- (double)folderIdValue {
	NSNumber *result = [self folderId];
	return [result doubleValue];
}

- (void)setFolderIdValue:(double)value_ {
	[self setFolderId:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveFolderIdValue {
	NSNumber *result = [self primitiveFolderId];
	return [result doubleValue];
}

- (void)setPrimitiveFolderIdValue:(double)value_ {
	[self setPrimitiveFolderId:[NSNumber numberWithDouble:value_]];
}

@dynamic folderIdentifier;

- (double)folderIdentifierValue {
	NSNumber *result = [self folderIdentifier];
	return [result doubleValue];
}

- (void)setFolderIdentifierValue:(double)value_ {
	[self setFolderIdentifier:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveFolderIdentifierValue {
	NSNumber *result = [self primitiveFolderIdentifier];
	return [result doubleValue];
}

- (void)setPrimitiveFolderIdentifierValue:(double)value_ {
	[self setPrimitiveFolderIdentifier:[NSNumber numberWithDouble:value_]];
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

@dynamic name;

@dynamic routesIdentifier;

- (double)routesIdentifierValue {
	NSNumber *result = [self routesIdentifier];
	return [result doubleValue];
}

- (void)setRoutesIdentifierValue:(double)value_ {
	[self setRoutesIdentifier:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveRoutesIdentifierValue {
	NSNumber *result = [self primitiveRoutesIdentifier];
	return [result doubleValue];
}

- (void)setPrimitiveRoutesIdentifierValue:(double)value_ {
	[self setPrimitiveRoutesIdentifier:[NSNumber numberWithDouble:value_]];
}

@dynamic units;

@dynamic updatedAt;

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

