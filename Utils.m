//
//  Utils.m
//  Creativity
//
//  Created by Andrew Newman on 7/20/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "Utils.h"
#import "MBProgressHUD.h"

@implementation Utils

+(void) networkUnavailable:(id) sender{
    
    UIAlertView* networkAlert = [[UIAlertView alloc] init];
    [networkAlert setDelegate:self];
    [networkAlert setTitle:@"Network Unavailable!"];
    [networkAlert setMessage:@"Make sure you have internet connection."];
    [networkAlert addButtonWithTitle:@"Ok"];
    [networkAlert show];
    
}

+(void) startActivityIndicator:(NSString*) message{
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = message;
    
}

+(void) hideHUD:(id) sender{
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
    
}

+(void) showErrorDialog: (NSString*) message {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"close-button.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = message;
}

+(NSDictionary*) serverResponseFromJSON:(NSData*) objectNotation error:(NSError**) error{
    
    NSError *localError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    NSLog(@"parsed object from server: %@", response);
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    return response;
}

@end
