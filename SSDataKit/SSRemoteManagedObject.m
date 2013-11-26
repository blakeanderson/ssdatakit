//
//  SSRemoteManagedObject.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2013 Sam Soffes. All rights reserved.
//

#import "SSRemoteManagedObject.h"

@implementation SSRemoteManagedObject

@dynamic remoteID;
@dynamic createdAt;
@dynamic updatedAt;

#pragma mark -

+ (id)objectWithRemoteID:(NSString *)remoteID {
	return [self objectWithRemoteID:remoteID context:nil];
}


+ (id)objectWithRemoteID:(NSString *)remoteID context:(NSManagedObjectContext *)context {
	
	// If there isn't a suitable remoteID, we won't find the object. Return nil.
	if (!remoteID ||
		![remoteID respondsToSelector:@selector(integerValue)] ||
		[remoteID integerValue] == 0) {
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}
	
	// Look up the object
	SSRemoteManagedObject *object = [self existingObjectWithRemoteID:remoteID context:context];
	
	// If the object doesn't exist, create it
	if (!object) {
		object = [[self alloc] initWithContext:context];
		object.remoteID = remoteID;
	}
	
	// Return the fetched or new object
	return object;
}


+ (id)existingObjectWithRemoteID:(NSString *)remoteID {
	return [self existingObjectWithRemoteID:remoteID context:nil];
}


+ (id)existingObjectWithRemoteID:(NSString *)remoteID context:(NSManagedObjectContext *)context {
	
	// If there isn't a suitable remoteID, we won't find the object. Return nil.
	if (!remoteID ||
		![remoteID respondsToSelector:@selector(integerValue)] ||
		[remoteID integerValue] == 0) {
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID = %@", remoteID];
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// Return the object
	return [results lastObject];
}

+ (id)objectWithAttribute:(NSString *)attributeName value:(id)value {
	return [self objectWithAttribute:attributeName value:value context:nil];
}

+ (id)objectWithAttribute:(NSString *)attributeName value:(id)value context:(NSManagedObjectContext *)context {
	
	// If there isn't a suitable attribute name, we won't find the object. Return nil.
	if (!attributeName ||
		[attributeName length] == 0) {
		return nil;
	}
	
	// If there isn't a suitable value, we won't find the object. Return nil.
	if (!value){
		return nil;
	}
	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}
	
	// Look up the object
	SSRemoteManagedObject *object = [self existingObjectWithAttribute:attributeName value:value context:context];
	
	// If the object doesn't exist, create it
	if (!object) {
		object = [[self alloc] initWithContext:context];
		[object setValue:value forKey:attributeName];
	}
	
	// Return the fetched or new object
	return object;
}

+ (id)existingObjectWithAttribute:(NSString *)attributeName value:(id)value {
	return [self existingObjectWithAttribute:attributeName value:value context:nil];
}

+ (id)existingObjectWithAttribute:(NSString *)attributeName value:(id)value context:(NSManagedObjectContext *)context {
	
	// If there isn't a suitable attribute name, we won't find the object. Return nil.
	if (!attributeName ||
		[attributeName length] == 0) {
		return nil;
	}
	
	// If there isn't a suitable value, we won't find the object. Return nil.
	if (!value){
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%@ = %@", attributeName, value];
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// Return the object
	return [results lastObject];
}

+ (NSArray*)existingObjects {
	return [self existingObjectsWithContext:nil];
}

+ (NSArray*)existingObjectsWithContext:(NSManagedObjectContext *)context  {
	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	return results;
}

+ (void)removeExistingObjects {
	NSArray *items = [self existingObjects];
	
	NSError *error;
	for (NSManagedObject *managedObject in items) {
		[[SSManagedObject mainQueueContext] deleteObject:managedObject];
		NSLog(@"%@ object deleted", [self entityName]);
	}
	if (![[SSManagedObject mainQueueContext] save:&error]) {
		NSLog(@"Error deleting - error");
	}
}


+ (id)objectWithDictionary:(NSDictionary *)dictionary {
	return [self objectWithDictionary:dictionary context:nil];
}


+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	
	// Make sure we have a dictionary
	if (![dictionary isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
	// Extract the remoteID from the dictionary
	NSString *remoteID = [[self class] unpackRemoteIDFromDictionary:dictionary];
	
	// Find object by remoteID
	SSRemoteManagedObject *object = [[self class] objectWithRemoteID:remoteID context:context];
	
	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}
	
	// Return the new or updated object
	return object;
}


+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary {
	return [self existingObjectWithDictionary:dictionary context:nil];
}


+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	
	// Make sure we have a dictionary
	if (![dictionary isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
	// Extract the remoteID from the dictionary
	NSString *remoteID = [[self class] unpackRemoteIDFromDictionary:dictionary];
	
	// Find object by remoteID
	SSRemoteManagedObject *object = [[self class] existingObjectWithRemoteID:remoteID context:context];
	
	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}
	
	// Return the new or updated object
	return object;
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
	if (!self.isRemote) {
		self.remoteID = [[self class] unpackRemoteIDFromDictionary:dictionary];
	}
	
	if ([self respondsToSelector:@selector(setCreatedAt:)]) {
		self.createdAt = [[self class] parseDate:dictionary[@"created_at"]];
	}
	
	if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
		self.updatedAt = [[self class] parseDate:dictionary[@"updated_at"]];
	}
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	if (![self respondsToSelector:@selector(updatedAt)] || !self.updatedAt) {
		return YES;
	}
	
	NSDate *newDate = [[self class] parseDate:dictionary[@"updated_at"]];
	if (newDate && [self.updatedAt compare:newDate] == NSOrderedAscending) {
		return YES;
	}
	
	return NO;
}

+ (NSString *)unpackRemoteIDFromDictionary:(NSDictionary *)dictionary {
	return [dictionary objectForKey:@"_id"];
}

- (BOOL)isRemote {
	return self.remoteID.integerValue > 0;
}

+ (NSDate *)parseDate:(id)dateStringOrDateNumber {
	// Return nil if nil is given
	if (!dateStringOrDateNumber || dateStringOrDateNumber == [NSNull null]) {
		return nil;
	}
	
	// Parse number
	if ([dateStringOrDateNumber isKindOfClass:[NSNumber class]]) {
		return [NSDate dateWithTimeIntervalSince1970:[dateStringOrDateNumber doubleValue]];
	}
	
	// Parse string
	else if ([dateStringOrDateNumber isKindOfClass:[NSString class]]) {
		// ISO8601 Parser borrowed from SSToolkit. http://sstoolk.it
		NSString *iso8601 = dateStringOrDateNumber;
		if (!iso8601) {
			return nil;
		}
		
		const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
		char newStr[25];
		
		struct tm tm;
		size_t len = strlen(str);
		if (len == 0) {
			return nil;
		}
		
		// UTC
		if (len == 20 && str[len - 1] == 'Z') {
			strncpy(newStr, str, len - 1);
			strncpy(newStr + len - 1, "+0000", 5);
		}
		
		//Milliseconds parsing
		else if (len == 24 && str[len - 1] == 'Z') {
			strncpy(newStr, str, len - 1);
			strncpy(newStr, str, len - 5);
			strncpy(newStr + len - 5, "+0000", 5);
		}
		
		// Timezone
		else if (len == 25 && str[22] == ':') {
			strncpy(newStr, str, 22);
			strncpy(newStr + 22, str + 23, 2);
		}
		
		// Poorly formatted timezone
		else {
			strncpy(newStr, str, len > 24 ? 24 : len);
		}
		
		// Add null terminator
		newStr[sizeof(newStr) - 1] = 0;
		
		if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
			return nil;
		}
		
		time_t t;
		t = mktime(&tm);
		
		return [NSDate dateWithTimeIntervalSince1970:t];
	}
	
	NSAssert1(NO, @"[SSRemoteManagedObject] Failed to parse date: %@", dateStringOrDateNumber);
	return nil;
}


+ (NSArray *)defaultSortDescriptors {
	return [NSArray arrayWithObjects:
			[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO],
			[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:NO],
			nil];
}

@end
