//
//  ClientViewController.h
//  Creativity
//
//  Created by Andrew Newman on 5/20/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "WebsiteCreation.h"
#define kFilename	@"creating.sqlite3"

@interface HomeViewController : UIViewController<UITextViewDelegate> {
    sqlite3 *database;
    NSString *query;
    NSString *poemTextStr;
    IBOutlet UITextView *poemText;
    int rownumber;
    NSArray* websiteCreations;
    NSMutableArray *websiteCreationTitles;
    WebsiteCreation *websiteCreation;
    NSString *message;
    UIAlertView *alert;
    NSMutableURLRequest *req;
    NSString *post;
    NSData *dataParamters;
}
- (IBAction)getWebsiteCreations:(id)sender;
- (IBAction)viewWebsite:(id)sender;

@end
