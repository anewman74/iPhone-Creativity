//
//  WebsiteCreationViewController.m
//  Creativity
//
//  Created by Andrew Newman on 7/27/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "WebsiteCreationViewController.h"
#import "Singleton.h"
#import "Utils.h"

#define TAG_DELETE 1
#define TAG_CONFIRMED 2

@interface WebsiteCreationViewController ()

@end

@implementation WebsiteCreationViewController
@synthesize websiteCreationsArray;

#pragma mark - View lifecycle.
-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"WebsiteCreationViewController - view will appear website creations array: %@", websiteCreationsArray);
    
    rowNumber = (int)[[Singleton sharedSingleton] getnewrownumber];
    NSLog(@"row number: %i", rowNumber);
    
    existingWebsiteCreation = [[WebsiteCreation alloc] init];
    existingWebsiteCreation = [websiteCreationsArray objectAtIndex:rowNumber];
    NSLog(@"website title chosen: %@", existingWebsiteCreation.title);
    
    poemTitle.text = existingWebsiteCreation.title;
    poemText.text = existingWebsiteCreation.poem;
    deletingCreation = false;
    
    tableData = 0;
	tableData = [[NSMutableArray alloc] init]; //initialize the array
    
	// Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}

    query = @"SELECT poemTitle FROM creations ORDER BY dateDouble DESC;";
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
        while(sqlite3_step(statement) == SQLITE_ROW){
            [tableData addObject:[NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)]];
        }
        sqlite3_finalize(statement);
    }
    
    NSLog(@"list of poem titles saved on phone: %@", tableData);
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)saveToPhone:(id)sender {
    NSLog(@"inside save to phone function");
    
    [poemText resignFirstResponder];
    [poemTitle resignFirstResponder];
    
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
            
            [self.navigationController popToRootViewControllerAnimated:true];
            
            // Save title, username, isPrivate and date on server.
            NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
            NSString *phoneId = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneId"];
            
            // Send title and username to server to update backup table.
            request = [self createUrlRequest:username phoneId:phoneId poem:@"" url:@"http://www.creativityinspire.com:8080/creations/saveCreationFromPhone"];
            NSLog(@"request: %@", request);
            
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                NSLog(@"success from server when saving title and username only");
            }];

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


- (IBAction)updateCreationOnWebsite:(id)sender {
    
    [poemText resignFirstResponder];
    [poemTitle resignFirstResponder];
    
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
    else {
        NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
        NSString *phoneId = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneId"];
        
        // See if we have username in nsuerdefaults - if so ... then save.  If don't, show an alert and send them to account page.  Firstly make awebsite creation object that can be used to populate the creating view controller once the details have been saved.
        
        // Check if poemTitle is already in websiteCreationList
        isAlreadySavedOnWebsite = false;
        
        if ([existingWebsiteCreation.title isEqualToString:poemTitle.text]) {
            isAlreadySavedOnWebsite = true;
        }
        
        if(isAlreadySavedOnWebsite) {
            [Utils startActivityIndicator:@"Updating Creation..."];
            request = [self createUrlRequest:username phoneId:phoneId poem:poemText.text url:@"http://www.creativityinspire.com:8080/creations/updateCreationFromPhone"];
        }
        else {
            [Utils startActivityIndicator:@"Saving Creation..."];
            request = [self createUrlRequest:username phoneId:phoneId poem:poemText.text url:@"http://www.creativityinspire.com:8080/creations/saveCreationFromPhone"];
        }
        NSLog(@"request: %@", request);
        deletingCreation = false;
        
        dataParamters = [post dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:dataParamters];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataParamters length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self performSelectorOnMainThread:@selector(startRequest:) withObject:request waitUntilDone:YES];
    }
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
    
    // Make new method which just processes the saved creation response.   sucess or failure.  Put it in utils.
    
    
    /// Also check the code for creationsListFromJSON - it looks like there may be an error if there is only one creation returned from the server.
    
    
    NSDictionary*  serverResponse = [Utils serverResponseFromJSON:data error:&error];
    
    NSLog(@"Server response : %@", serverResponse);
    NSLog(@"server response count: %i",(int)[serverResponse count] );
    
    if ([serverResponse count] >0) {
        
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
    
    //Update websiteCreationsArray so we don't add another creation in this iphone session with the same title.
    newWebsiteCreation = [[WebsiteCreation alloc] init];
    newWebsiteCreation.title = poemTitle.text;
    newWebsiteCreation.poem = poemText.text;
    NSLog(@"existing website creation: %@",existingWebsiteCreation);
    NSLog(@"new website creation: %@",newWebsiteCreation);
    NSLog(@"new website creation title: %@",newWebsiteCreation.title);
    NSLog(@"new website creation poem: %@",newWebsiteCreation.poem);
    NSLog(@"deletingCreation: %d",deletingCreation);
    NSLog(@"isAlreadySavedOnWebsite: %d",isAlreadySavedOnWebsite);
    
    if (deletingCreation) {
        [websiteCreationsArray removeObject:existingWebsiteCreation];
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your creation was successfully deleted from our website." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = TAG_CONFIRMED;
        [alert show];
    }
    else if(isAlreadySavedOnWebsite) {
        [websiteCreationsArray removeObject:existingWebsiteCreation];
        [websiteCreationsArray addObject:newWebsiteCreation];
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your creation was successfully updated on our website." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = TAG_CONFIRMED;
        [alert show];
    }
    else {
        [websiteCreationsArray addObject:newWebsiteCreation];
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your creation was successfully saved on our website." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = TAG_CONFIRMED;
        [alert show];
    }
    NSLog(@"website creations array: %@",websiteCreationsArray);
}


- (IBAction)deleteCreation:(id)sender {
    
    [poemText resignFirstResponder];
    [poemTitle resignFirstResponder];
    
    //Alert view message.
    message = [[NSString alloc] initWithFormat:
               @"Are you sure you would like to delete this creation?"];
    
    alert = [[UIAlertView alloc] initWithTitle:nil
                                       message:message
                                      delegate:self
                             cancelButtonTitle:@"Yes"
                             otherButtonTitles:nil];
    alert.tag = TAG_DELETE;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_DELETE) {
        if (buttonIndex == 0) {
            NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
            NSString *phoneId =[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneId"];
            //    NSString *phoneId = @"trertwetrwR";
            
            // See if we have username in nsuerdefaults - if so ... then save.  If don't, show an alert and send them to account page.  Firstly make awebsite creation object that can be used to populate the creating view controller once the details have been saved.
            
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
            
            phoneId = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                            (CFStringRef)phoneId,
                                                                                            NULL,
                                                                                            (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                            kCFStringEncodingUTF8));
            
            [Utils startActivityIndicator:@"Deleting Creation..."];
            deletingCreation = true;
            
            post = [NSString stringWithFormat:@"title=%@&username=%@&phoneId=%@&isPrivate=false",encodedTitle, username, phoneId];
            NSLog(@"post content: %@", post);
            
            request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://www.creativityinspire.com:8080/creations/deleteCreationFromPhone"]];
            dataParamters = [post dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:dataParamters];
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataParamters length]] forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [self performSelectorOnMainThread:@selector(startRequest:) withObject:request waitUntilDone:YES];
        }
    } else if(alertView.tag == TAG_CONFIRMED) {
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
    //
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
