//
//  WebsiteCreationViewController.h
//  Creativity
//
//  Created by Andrew Newman on 7/27/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "WebsiteCreation.h"
#define kFilename	@"creating.sqlite3"

@interface WebsiteCreationViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    sqlite3 *database;
    IBOutlet UITextField *poemTitle;
    IBOutlet UITextView *poemText;
    NSMutableArray* websiteCreationsArray;
    WebsiteCreation *newWebsiteCreation;
    WebsiteCreation *existingWebsiteCreation;
    NSDateFormatter *formatter1;
    NSDate *dateNow;
    NSString *strNow;
    double dblNow;
    NSString *query;
    NSMutableArray *tableData;
    NSString *nameChosen;
    int rowNumber;
    NSString *message;
    UIAlertView *alert;
    NSString *urlAsString;
    bool isAlreadySavedOnWebsite;
    bool deletingCreation;
    NSMutableURLRequest *request;
    NSString *post;
    NSData *dataParamters;
    
    BOOL moveViewUp;
    CGFloat scrollAmount;
    int keyboardSize;
}
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSArray* websiteCreationsArray;

- (IBAction)updateCreationOnWebsite:(id)sender;
- (IBAction)saveToPhone:(id)sender;
- (IBAction)deleteCreation:(id)sender;
- (NSMutableURLRequest *) createUrlRequest:(NSString*)username phoneId:(NSString*)phoneId poem:(NSString *)poem url: (NSString *)url;
-(void) startRequest: (NSMutableURLRequest*) request2;


@end
