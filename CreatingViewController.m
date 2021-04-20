//
//  CreatingViewController.m
//  Creativity
//
//  Created by Andrew Newman on 6/30/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "CreatingViewController.h"
#import "Singleton.h"
#import "WebsiteCreationListBuilder.h"
#import "Utils.h"

#define TAG_CONFIRMED 1

@interface CreatingViewController ()

@end

@implementation CreatingViewController


#pragma mark - View lifecycle.
-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"creating view controller - view will appear.");
    
    tableData = 0;
	tableData = [[NSMutableArray alloc] init]; //initialize the array
    
    websiteCreationTitles = [[NSMutableArray alloc] init];
    
    // Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
	
	char *errorMsg;
    
    //NSString *dropSQL = @"DROP TABLE creations;";
    //if(sqlite3_exec(database, [dropSQL UTF8String],NULL,NULL,&errorMsg) != SQLITE_OK){
   //     sqlite3_close(database);
     //   NSAssert1(0,@"Error dropping table: %s", errorMsg);
   // }
    
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS creations (row integer primary key, poemTitle varchar(25), poemText text, dateDouble double, dateString varchar(25));";
    
	if(sqlite3_exec(database, [createSQL UTF8String],NULL,NULL,&errorMsg) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert1(0,@"Error creating table: %s", errorMsg);
    }
    
    //Registering a notification when keyboard will show.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
}

#pragma mark - methods for the keyboard scrolling effect.
-(void) keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardEndFrame;
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        keyboardSize = keyboardEndFrame.size.height;
    }
    else {
        keyboardSize = keyboardEndFrame.size.width;
    }
    
    NSLog(@"inside keyboard will show size: %i", keyboardSize);
    
    float screensize = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"screensize: %f", screensize);
    
    if ((int)screensize <= 568) {
        if([poemText isFirstResponder]){
            scrollAmount = 45;
        }
    }
    
    if(scrollAmount > 0) {
        moveViewUp = YES;
        [self scrollTheView:YES];
    }
    else {
        moveViewUp = NO;
    }
}

- (void) scrollTheView: (BOOL) movedUp {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect rect = self.view.frame;
    
    if(movedUp){
        rect.origin.y -= scrollAmount;
    }
    else {
        if (scrollAmount > 0) {
            //if there was an existing scroll amount, then move keyboard back whole way.
            rect.origin.y += scrollAmount;
        }
    }
    
    self.view.frame = rect;
    [UIView commitAnimations];
}


#pragma mark - Save To Phone function.
- (IBAction)saveToPhone:(id)sender {
    
    NSLog(@"inside save to phone function");
    
    [poemText resignFirstResponder];
    [poemTitle resignFirstResponder];
    
    // Show alert if there is no title or no poem
    if ( [poemTitle.text isEqualToString:@""]  || [poemText.text isEqualToString:@"Content ..."] ) {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"The title or creation is empty.\n\n Please add text."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else {
        dateNow = [[NSDate alloc] init];
        NSLog(@"now: %@", dateNow);
        dblNow = [dateNow timeIntervalSince1970];
        NSLog(@"dblNow: %f", dblNow);
        NSString *strDblPicker = [NSString stringWithFormat:@"%f",dblNow];
        NSLog(@"srNow: %@", strDblPicker);
        
        // Formatter
        formatter1 = [[NSDateFormatter alloc] init];
        [formatter1 setDateFormat:@"MM/dd/YYYY"];
        
        // String now
        strNow = [formatter1 stringFromDate:dateNow];
        NSLog(@"time selected in details method: %@", strNow);
        
        query = @"SELECT poemTitle FROM creations;";
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                [tableData addObject:[NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)]];
            }
            sqlite3_finalize(statement);
        }
        NSLog(@"list of poem titles, table data: %@", tableData);
        NSLog(@"poemTitle text: %@", poemTitle.text);
        
        // Check if poemTitle has already been saved in local database.
        if([tableData containsObject:poemTitle.text]) {
            //Alert view message.
            message = [[NSString alloc] initWithFormat:
                       @"This poem title has already been saved on this phone.\n\n Please use a different title."];
            
            alert = [[UIAlertView alloc] initWithTitle:nil
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
        else {
            char *insert = "INSERT INTO creations (poemTitle, poemText,dateDouble,dateString) VALUES(?,?,?,?);";
            NSLog(@"insert: %s", insert);
            sqlite3_stmt *stmt;
            if(sqlite3_prepare_v2(database, insert, -1, &stmt, nil) == SQLITE_OK){
                sqlite3_bind_text(stmt, 1, [poemTitle.text UTF8String], -1, NULL);
                sqlite3_bind_text(stmt, 2, [poemText.text UTF8String], -1, NULL);
                sqlite3_bind_double(stmt,3, [dateNow timeIntervalSince1970]);
                sqlite3_bind_text(stmt, 4, [strNow UTF8String], -1, NULL);
                NSLog(@"in sql insert stmt");
            }
            if(sqlite3_step(stmt) != SQLITE_DONE) {
                NSLog(@"statement failed");
                sqlite3_finalize(stmt);
            }
            
            
            
//            // is the timestamp the same as this dateNow value???
//            2014-08-04 22:18:58.081 Creativity[1509:2e0b] Server response : {
//                error = "Not Found";
//                message = "";
//                path = "/updateCreation";
//                status = 404;
//                timestamp = 1407215938079;
//            }
            
            
            
            // I have to get a correct row number from the database where goal is this name
            query = [[NSString alloc] initWithFormat: @"SELECT row FROM creations ORDER BY row DESC LIMIT 1;"];
            
            sqlite3_stmt *stateme;
            if(sqlite3_prepare_v2(database, [query UTF8String],-1, &stateme, nil) == SQLITE_OK){
                while(sqlite3_step(stateme) == SQLITE_ROW){
                    rowNumber = sqlite3_column_int(stateme, 0);
                    NSLog(@"row number in creations table: %i", rowNumber);
                    
                    [[Singleton sharedSingleton] setnewrownumber:rowNumber];
                }
                sqlite3_finalize(stateme);
            }
            sqlite3_close(database);
            [self.navigationController popViewControllerAnimated:true];
            
            // Save title, username, isPrivate and date on server.
            NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
            NSString *phoneId = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneId"];
            
            // See if we have username in nsuerdefaults - if so ... then save.  If don't, show an alert and send them to account page.  Firstly make a website creation object that can be used to populate the creating view controller once the details have been saved.
            
            // Send title and username to server to update backup table.
            request = [self createUrlRequest:username phoneId:phoneId poem:@"" url:@"http://www.creativityinspire.com:8080/creations/saveCreationFromPhone"];
            NSLog(@"request: %@", request);
            
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                NSLog(@"success from server when saving title and username only");
            }];
        }
    }
}

#pragma mark - Save To Website function.
- (IBAction)saveToWebsite:(id)sender {
    
    NSLog(@"inside save to website function");
    bool titleAlreadyUsed = false;
    
    [poemText resignFirstResponder];
    [poemTitle resignFirstResponder];
    
    NSMutableArray *creationsFromDefaults = [[NSMutableArray alloc] init];    
    creationsFromDefaults = [[NSUserDefaults standardUserDefaults]objectForKey:@"websiteCreationTitles"];
    
    NSLog(@"website creation titles: %@", creationsFromDefaults);
    for (int i=0; i<[creationsFromDefaults count]; i++) {
        NSLog(@"title: %@",creationsFromDefaults[i]);
        if ([creationsFromDefaults[i] isEqualToString:poemTitle.text]) {
            titleAlreadyUsed = true;
        }
        [websiteCreationTitles addObject:creationsFromDefaults[i]];
    }
    
    // Show alert if there is no title or no poem
    if ( [poemTitle.text isEqualToString:@""]  || [poemText.text isEqualToString:@""] ) {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"The title or creation is empty.\n\n Please add text."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else if (titleAlreadyUsed) {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"The title has already been used on another of your creations.\n\n Please save with a different title."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else{
        NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
        NSString *phoneId = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneId"];
        
        if (![username isEqualToString:@""]) {
            [Utils startActivityIndicator:@"Saving Creation..."];
            request = [self createUrlRequest:username phoneId:phoneId poem:poemText.text url:@"http://www.creativityinspire.com:8080/creations/saveCreationFromPhone"];
            NSLog(@"request: %@", request);
            [self performSelectorOnMainThread:@selector(startRequest:) withObject:request waitUntilDone:YES];
        }
        else {
            //Alert view message.
            message = [[NSString alloc] initWithFormat:
                       @"Please log in or sign up by clicking the Account icon below."];
            
            alert = [[UIAlertView alloc] initWithTitle:nil
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (NSMutableURLRequest *) createUrlRequest:(NSString*)username phoneId:(NSString*)phoneId poem:(NSString *)poem url: (NSString *)url {
    NSMutableURLRequest *req;
    username = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)username,
                                                                                     NULL,
                                                                                     (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                     kCFStringEncodingUTF8));
    
    NSString *encodedTitle = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                   (CFStringRef)poemTitle.text,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                   kCFStringEncodingUTF8));
    
    NSString *encodedPoem = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                  (CFStringRef)poem,
                                                                                                  NULL,
                                                                                                  (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                  kCFStringEncodingUTF8));
    
    phoneId = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                    (CFStringRef)phoneId,
                                                                                    NULL,
                                                                                    (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                    kCFStringEncodingUTF8));
    
    
    post = [NSString stringWithFormat:@"title=%@&poem=%@&username=%@&phoneId=%@",encodedTitle, encodedPoem, username, phoneId];
    NSLog(@"post content: %@", post);
    
    req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
    NSLog(@"req: %@", req);
    dataParamters = [post dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:dataParamters];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataParamters length]] forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    return req;
}

-(void) startRequest: (NSMutableURLRequest*) request2 {
    [NSURLConnection sendAsynchronousRequest:request2 queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self performSelectorOnMainThread:@selector(processError:) withObject:error waitUntilDone:YES];
        } else {
            NSLog(@"data from server: %@", data);
            [self performSelectorOnMainThread:@selector(processResponse:) withObject:data waitUntilDone:YES];
        }
    }];
}

-(void) processError:(NSError*) error {
    //call error handling method
    NSLog(@"Error returned: %@", error);
    NSLog(@"Error code: %ld", (long)error.code);
    
    //Error returned: Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline."
    //Error Domain=NSURLErrorDomain Code=-1005 "The network connection was lost."
    if (error.code == -1009 || error.code == -1005) {
        NSLog(@"Error returned - internet off");
        [Utils hideHUD:nil];
        alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"The Internet connection appears to be offline." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Error returned - there is internet");
        [Utils hideHUD:nil];
        alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please try again now or later in the day." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) processResponse:(NSData*) data {
    
    NSError *error = nil;
    
    NSDictionary*  serverResponse = [Utils serverResponseFromJSON:data error:&error];
    
    NSLog(@"Server response : %@", serverResponse);
    NSLog(@"server response count: %i",(int)[serverResponse count] );
    
    if ([serverResponse count] > 0) {
        
        NSString *response = [serverResponse valueForKey:@"response"];
        NSLog(@"response: %@", response);
        
        if ([response isEqualToString:@"Server Transaction Success"]) {
            [self performSelectorOnMainThread:@selector(showResults:) withObject:nil waitUntilDone:YES];
        }
        else if([response isEqualToString:@"Your personal details are not recognized. Please login to the App and try again."]) {
            //// need to put this back on thread too. ....... ?
            [Utils hideHUD:nil];
            alert = [[UIAlertView alloc] initWithTitle:nil message:response delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(![response isEqualToString:@"(null)"]) {
            //// need to put this back on thread too. ....... ?
            [Utils hideHUD:nil];
            alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:response delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            [Utils hideHUD:nil];
            alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please try again now or later in the day." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        [Utils hideHUD:nil];
        alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please try again now or later in the day." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) showResults:(id) sender{
    [Utils hideHUD:nil];
    
    //Update websiteCreationTitles so we don't add another creation in this iphone session with the same title.
    NSString *title = poemTitle.text;
    [websiteCreationTitles addObject: title];
    
    // Save to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:websiteCreationTitles forKey:@"websiteCreationTitles"];
    [defaults synchronize];

    alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your creation was successfully saved on our website." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = TAG_CONFIRMED;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_CONFIRMED) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark UITextViewDelegate  && UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textfield
{
    NSLog(@"inside text field did begin editing");
    
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"inside text view did begin editing");
    
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)saveAction:(id)sender
{
    // finish typing text/dismiss the keyboard by removing it as the first responder
    [poemTitle resignFirstResponder];
    [poemText resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;   // this will remove the "save" button
    
    if(scrollAmount > 0) {
        scrollAmount = -scrollAmount;
        moveViewUp = NO;
        [self scrollTheView:YES];
    }
    else {
        moveViewUp = NO;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
