//
//  CreationViewController.h
//  Creativity
//
//  Created by Andrew Newman on 7/5/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"creating.sqlite3"

@interface CreationViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    sqlite3 *database;
    IBOutlet UITextField *poemTitle;
    IBOutlet UITextView *poemText;
    NSString *poemTitleStr;
    NSString *poemTextStr;
    NSDateFormatter *formatter1;
    NSDate *dateNow;
    NSString *strNow;
    double dblNow;
    NSString *query;
    NSMutableArray *tableData;
    NSString *nameChosen;
    int rownumber;
    NSString *message;
    UIAlertView *alert;
    NSMutableURLRequest *request;
    NSString *post;
    NSData *dataParamters;
    NSMutableArray* websiteCreationTitles;
    
    BOOL moveViewUp;
    CGFloat scrollAmount;
    int keyboardSize;
}
- (IBAction)saveToWebsite:(id)sender;
- (IBAction)updateCreation:(id)sender;
- (IBAction)deleteCreation:(id)sender;
- (NSMutableURLRequest *) createUrlRequest:(NSString*)username phoneId:(NSString*)phoneId poem:(NSString *)poem url: (NSString *)url;

@end
