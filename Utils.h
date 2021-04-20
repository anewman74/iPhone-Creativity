//
//  Utils.h
//  Creativity
//
//  Created by Andrew Newman on 7/20/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Utils : NSObject

+(NSDictionary*) serverResponseFromJSON:(NSData*) objectNotation error:(NSError**) error;
+(void) networkUnavailable:(id) sender;
+(void) startActivityIndicator:(NSString*) message;
+(void) hideHUD:(id) sender;
@end
