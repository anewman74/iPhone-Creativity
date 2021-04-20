//
//  ClientViewController.m
//  Creativity
//
//  Created by Andrew Newman on 5/20/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "HomeViewController.h"
#import "Singleton.h"
#import "WebsiteCreationListBuilder.h"
#import "WebsiteCreationsTableViewController.h"
#import "Utils.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - View lifecycle.
-(void)viewWillAppear:(BOOL)animated {
    
    websiteCreationTitles = [[NSMutableArray alloc] init];
    
    poemTextStr = [NSString stringWithFormat:@"The icon image is a Supernova explosion.\n\nIt is caused when the mass of a star flows into its core. Eventually, the core is so heavy that it can't withstand its own gravitational force. The core collapses, which results in the giant explosion of a Supernova.\n\nMaybe, this can inspire you to delve inside yourself to let your own creative force shine out and inspire others.\n\n\n\n[This text area will show your lastest creation saved on to your phone.]"];
    poemText.text = poemTextStr;
    
	// Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
	
	char *errorMsg;
    
//    NSString *dropSQL = @"DROP TABLE creations;";
//    
//	if(sqlite3_exec(database, [dropSQL UTF8String],NULL,NULL,&errorMsg) != SQLITE_OK){
//		sqlite3_close(database);
//		NSAssert1(0,@"Error dropping table: %s", errorMsg);
//    }
    
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS creations (row integer primary key, poemTitle varchar(25), poemText text, dateDouble double, dateString varchar(25));";
    
	if(sqlite3_exec(database, [createSQL UTF8String],NULL,NULL,&errorMsg) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert1(0,@"Error creating table: %s", errorMsg);
    }
	query = [[NSString alloc] initWithFormat: @"SELECT poemText FROM creations ORDER BY dateDouble DESC LIMIT 1;"];
    NSLog(@"query - %@", query);
    
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
		while(sqlite3_step(statement) == SQLITE_ROW){
            
            char *poemChar = (char *)sqlite3_column_text(statement, 0);
            poemTextStr = [[NSString alloc] initWithFormat:@"%s",poemChar];
            NSLog(@"poem text is  %@", poemTextStr);
            
            // Take out backslashes from single quotes or double quotes.
            if (![poemTextStr isEqualToString:@"(null)"]) {
                poemText.text = poemTextStr;
            }
        }
	}
}

- (IBAction)getWebsiteCreations:(id)sender {
    NSLog(@"inside get Website Creations");
    
    NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    
    // TODO - if username = "",  then tell them to sign in.  Same as creating view controller and mycreationsviewcontroller.
    
    //  There seems to be an ERROR if there are two or less creations.
    
    
    username = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)username,
                                                                                     NULL,
                                                                                     (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                     kCFStringEncodingUTF8));
    
    if (![username isEqualToString:@""]) {
        [Utils startActivityIndicator:@"Loading Creations..."];
        
        post = [NSString stringWithFormat:@"username=%@", username];
        NSLog(@"post content: %@", post);
        
        req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://www.creativityinspire.com:8080/creations/myCreations"]];
        dataParamters = [post dataUsingEncoding:NSUTF8StringEncoding]; // don't encode twice ...?
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:dataParamters];
        [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataParamters length]] forHTTPHeaderField:@"Content-Length"];
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self performSelectorOnMainThread:@selector(startRequest:) withObject:req waitUntilDone:YES];
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

-(void) startRequest: (NSMutableURLRequest*) request {
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSLog(@"Response: %@", response);
        
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
    
    websiteCreations = [WebsiteCreationListBuilder creationsListFromJSON:data error:&error];
    
    if ([websiteCreations count] > 0) {
        [self performSelectorOnMainThread:@selector(showResults:) withObject:nil waitUntilDone:YES];
        
        for (int i=0; i<[websiteCreations count]; i++) {
            websiteCreation = websiteCreations[i];
            NSLog(@"%@",websiteCreation.title);
            [websiteCreationTitles addObject:websiteCreation.title];
        }
        
        // Save to NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:websiteCreationTitles forKey:@"websiteCreationTitles"];
        [defaults synchronize];
    }
    else {
        [Utils hideHUD:nil];
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"No creations were returned from the server. Have you saved any creations on our website?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) showResults:(id) sender{
    [Utils hideHUD:nil];
    
    [self performSegueWithIdentifier: @"websiteCreationList"
                              sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"websiteCreationList"]) {
        // Get destination view controller and don't forget
        // to cast it to the right class
        WebsiteCreationsTableViewController *websiteCreationsTableViewController = [segue destinationViewController];
        // Pass data
        websiteCreationsTableViewController.websiteCreationsArray = websiteCreations;
    }
}

- (IBAction)viewWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.creativityinspire.com"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
