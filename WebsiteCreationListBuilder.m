//
//  WebsiteCreationListBuilder.m
//  Creativity
//
//  Created by Andrew Newman on 7/26/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "WebsiteCreationListBuilder.h"
#import "WebsiteCreation.h"

@implementation WebsiteCreationListBuilder

+(NSArray*) creationsListFromJSON:(NSData*) objectNotation error:(NSError**) error{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    NSLog(@"parsed object from server: %@", parsedObject);
    
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    NSMutableArray *websiteCreationList = [[NSMutableArray alloc] init];
    
    int numParsedObjects = (int)[parsedObject count];
    NSLog(@"parsed object count: %d" , numParsedObjects);
    
    ////// need to test all scenarios
    // if there is only one poem, count = 3 for title and poem
    if (numParsedObjects > 0) {
        for (NSDictionary *itemDic in parsedObject) {
            WebsiteCreation *websiteCreation = [[WebsiteCreation alloc] init];
            
            for (NSString *key in itemDic) {
                
                if ([websiteCreation respondsToSelector:NSSelectorFromString(key)]) {
                    [websiteCreation setValue:[itemDic valueForKey:key] forKey:key];
                }
            }
            [websiteCreationList addObject:websiteCreation];
        }
    }
    return websiteCreationList;
}
@end