//
//  PersonalDetailsViewController.h
//  Creativity
//
//  Created by Andrew Newman on 7/22/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalDetailsViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UITextField *username;
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    NSString *message;
    UIAlertView *alert;
    NSString *urlAsString;
    NSMutableURLRequest *req;
    NSString *post;
    NSData *dataParamters;
    bool signingUp;
}
- (IBAction)signUpAction:(id)sender;
- (IBAction)logInAction:(id)sender;
- (IBAction)logOutAction:(id)sender;

@end
