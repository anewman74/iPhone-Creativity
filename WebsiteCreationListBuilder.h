//
//  WebsiteCreationListBuilder.h
//  Creativity
//
//  Created by Andrew Newman on 7/26/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebsiteCreationListBuilder : NSObject

+(NSArray*) creationsListFromJSON:(NSData*) objectNotation error:(NSError**) error;

@end
