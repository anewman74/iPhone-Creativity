//
//  Singleton.m
//  Creativity
//
//  Created by Andrew Newman on 6/30/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

static Singleton* _sharedSingleton = nil;

+ (Singleton*)sharedSingleton {
	
	@synchronized([Singleton class]) {
		if(!_sharedSingleton)
			_sharedSingleton = [[self alloc] init];
		
		return _sharedSingleton;
	}
	return nil;
}


+ (id) alloc {
	@synchronized ([Singleton class]) {
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a Singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
	
	return nil;
}

-(id) init {
	
	self = [super init];
	
	if (self != nil) {
	}
	return self;
}

- (NSString *)dataFilePath {
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (NSUInteger) getnewrownumber {
	return newrownumber;
}
- (void) setnewrownumber:(NSUInteger)value {
	newrownumber = value;
}

@end
