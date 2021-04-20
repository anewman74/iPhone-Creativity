//
//  PersonalDetailsViewController.m
//  Creativity
//
//  Created by Andrew Newman on 7/22/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "PersonalDetailsViewController.h"
#import "WebsiteCreationListBuilder.h"
#import "Utils.h"

#define USERNAME  @""
#define EMAIL   @""
#define PASSWORD @""

@interface PersonalDetailsViewController ()

@end

@implementation PersonalDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle.
-(void)viewWillAppear:(BOOL)animated {
    
    username.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    email.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
    password.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    
}

- (IBAction)signUpAction:(id)sender {
    
    [username resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    
    if([self validateEmail:email.text]) {
        signingUp = true;
        
        // First validate the data  .... email and username can only have ...... characters.
        
        // Try to save the details to server. With loading icon.
        
        // If not, then just show an alert message to user.
        
        // If success, then save the details into NSUserDefaults ... then alert
        
        // Then go back to home page after cool is clicked.... and you'll see this creation on the home page.
        
        NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                          (CFStringRef)username.text,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                          kCFStringEncodingUTF8));
        
        NSString *encodedEmail = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                       (CFStringRef)email.text,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                       kCFStringEncodingUTF8));
        
        NSString *encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                          (CFStringRef)password.text,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                          kCFStringEncodingUTF8));
        
        // Show alert if there is no username, email or password
        if ( [username.text isEqualToString:@""]  || [email.text isEqualToString:@""] || [password.text isEqualToString:@""] ) {
            //Alert view message.
            message = [[NSString alloc] initWithFormat:
                       @"Username, email and password are required.\n\nPlease fill in the empty fields."];
            
            alert = [[UIAlertView alloc] initWithTitle:nil
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        } else {
            // Already logged in
            if( [[NSUserDefaults standardUserDefaults]objectForKey:@"username"] && ![[[NSUserDefaults standardUserDefaults]objectForKey:@"username"] isEqualToString:@""]){
                
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are already logged in.  If your details have changed,  log out first and then log in again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                [Utils startActivityIndicator:@"Signing up..."];
                
                NSString *phoneDevice = [[UIDevice currentDevice] model];
                
                post = [NSString stringWithFormat:@"username=%@&email=%@&password=%@&phoneDevice=%@",encodedUsername, encodedEmail, encodedPassword,phoneDevice];
                NSLog(@"post content: %@", post);
                req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://www.creativityinspire.com:8080/creations/signupCreatorFromPhone"]];
                NSLog(@"req: %@", req);
                
                dataParamters = [post dataUsingEncoding:NSUTF8StringEncoding]; // don't encode twice ...?
                [req setHTTPMethod:@"POST"];
                [req setHTTPBody:dataParamters];
                [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataParamters length]] forHTTPHeaderField:@"Content-Length"];
                [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [self performSelectorOnMainThread:@selector(startRequest:) withObject:req waitUntilDone:YES];
            }
        }
    }
    else {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"The email is not valid.  Please type it again."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)logInAction:(id)sender {
    
    [username resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    
    if([self validateEmail:email.text]) {
        signingUp = false;
        
        // First validate the data  .... email and username can only have ...... characters.
        
        // Try to save the details to server. With loading icon.
        
        // If not, then just show an alert message to user.
        
        // If success, then save the details into NSUserDefaults ... then alert
        
        // Then go back to home page after cool is clicked.... and you'll see this creation on the home page.
        
        NSString *encodedEmail = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                       (CFStringRef)email.text,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                       kCFStringEncodingUTF8));
        
        NSString *encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                          (CFStringRef)password.text,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@" !*'();:@&=+$,/?%#[]{}-_|\\<>.,",
                                                                                                          kCFStringEncodingUTF8));
        
        // Show alert if there is no email or password
        if ( [email.text isEqualToString:@""] || [password.text isEqualToString:@""] ) {
            //Alert view message.
            message = [[NSString alloc] initWithFormat:
                       @"Email or password are required.\n\nPlease fill in the empty fields."];
            
            alert = [[UIAlertView alloc] initWithTitle:nil
                                               message:message
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        } else {
            // If username is already stored on phone, don't log in.
            NSLog(@"username: %@", [[NSUserDefaults standardUserDefaults]objectForKey:@"username"]);
            if( [[NSUserDefaults standardUserDefaults]objectForKey:@"username"] && ![[[NSUserDefaults standardUserDefaults]objectForKey:@"username"] isEqualToString:@""]){
                
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are already logged in.  If your details have changed, log out first and then log in again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                [Utils startActivityIndicator:@"Logging in..."];
                
                NSString *phoneDevice = [[UIDevice currentDevice] model];
                
                post = [NSString stringWithFormat:@"email=%@&password=%@&phoneDevice=%@", encodedEmail, encodedPassword,phoneDevice];
                NSLog(@"post content: %@", post);
                req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://www.creativityinspire.com:8080/creations/loginCreatorFromPhone"]];
                NSLog(@"req: %@", req);
                
                dataParamters = [post dataUsingEncoding:NSUTF8StringEncoding]; // don't encode twice ...?
                [req setHTTPMethod:@"POST"];
                [req setHTTPBody:dataParamters];
                [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataParamters length]] forHTTPHeaderField:@"Content-Length"];
                [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [self performSelectorOnMainThread:@selector(startRequest:) withObject:req waitUntilDone:YES];
            }
        }
    }
    else {
        //Alert view message.
        message = [[NSString alloc] initWithFormat:
                   @"The email is not valid.  Please type it again."];
        
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
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
        alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) processResponse:(NSData*) data {
    
    if (data) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"response string: %@", responseString);
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        NSLog(@"parsed object from server: %@", parsedObject);
        
        NSString *response = [parsedObject valueForKey:@"response"];
        NSLog(@"response - which is the phoneid: %@", response);
        
        NSString *returnedUsername = [parsedObject valueForKey:@"username"];
        NSLog(@"returnedUsername: %@", returnedUsername);
        
        NSString *error = [parsedObject valueForKey:@"error"];
        NSLog(@"error: %@", error);
        
        if (response) {
            [Utils hideHUD:nil];
            
            // Save to NSUserDefaults
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:returnedUsername forKey:@"username"];
            [defaults setObject:email.text forKey:@"email"];
            [defaults setObject:password.text forKey:@"password"];
            [defaults setObject:response forKey:@"phoneId"];
            [defaults synchronize];
            
            if(signingUp) {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"You signed up sucessfully. You can start creating." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                username.text = returnedUsername;
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"You logged in sucessfully. You can start creating." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        } else if (error) {
            [Utils hideHUD:nil];
            alert = [[UIAlertView alloc] initWithTitle:nil message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            //// need to put this back on thread too. ....... ?
            [Utils hideHUD:nil];
            alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please try again now or later in the day." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSString *user = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    NSLog(@"username: %@", user);
    if ( !user || [user isEqualToString:@""]) {
        return true;
    }
    return false;
}

-(BOOL) validateEmail:(NSString*) emailString
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    NSLog(@"%lu", (unsigned long)regExMatches);
    if (regExMatches == 0) {
        return NO;
    }
    else
        return YES;
}

- (IBAction)logOutAction:(id)sender {

    [username resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    
    // Save to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"username"];
    [defaults setObject:@"" forKey:@"email"];
    [defaults setObject:@"" forKey:@"password"];
    [defaults setObject:@"" forKey:@"phoneId"];
    [defaults synchronize];
    
    username.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    email.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
    password.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
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
