//
//  Singleton.h
//  Creativity
//
//  Created by Andrew Newman on 6/30/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kFilename	@"creating.sqlite3"

@interface Singleton : NSObject {
    NSUInteger newrownumber;
}

+ (Singleton*) sharedSingleton;
-(NSString *)dataFilePath;
- (NSUInteger) getnewrownumber;
- (void) setnewrownumber:(NSUInteger)value;

@end
