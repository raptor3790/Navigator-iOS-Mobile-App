//
//  NSObject+TDArchivable.m
//  Roomorama
//
//  Created by DAO XUAN DUNG on 20/11/12.
//
//

#import "NSObject+Archivable.h"
#import "ObjMapper.h"


@implementation NSObject (Archivable)

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    NSDictionary* propertyDict = [ObjMapper propertiesForClass:[self class]];
    
    for (NSString* key in propertyDict) {
        id value = [self valueForKey:key];
        [encoder encodeObject:value forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if([self init]) {
        //decode properties, other class vars
        NSDictionary* propertyDict = [ObjMapper propertiesForClass:[self class]];
        
        for (NSString* key in propertyDict) {
            id value = [decoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

@end
