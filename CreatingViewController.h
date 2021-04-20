//
//  CreatingViewController.h
//  Creativity
//
//  Created by Andrew Newman on 6/30/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"creating.sqlite3"

@interface CreatingViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    sqlite3 *database;
    IBOutlet UITextView *poemText;
    IBOutlet UITextField *poemTitle;
    NSDateFormatter *formatter1;
    NSDate *dateNow;
    NSString *strNow;
    double dblNow;
    NSMutableArray *tableData;
    NSString *query;
    int rowNumber;
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
- (IBAction)saveToPhone:(id)sender;
- (IBAction)saveToWebsite:(id)sender;
- (NSMutableURLRequest *) createUrlRequest:(NSString*)username phoneId:(NSString*)phoneId poem:(NSString *)poem url: (NSString *)url;

@end
