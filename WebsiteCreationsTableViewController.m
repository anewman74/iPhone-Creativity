//
//  WebsiteCreations.m
//  Creativity
//
//  Created by Andrew Newman on 7/20/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "WebsiteCreationsTableViewController.h"
#import "WebsiteCreationViewController.h"
#import "WebsiteCreation.h"
#import "Singleton.h"
#import "Utils.h"

@interface WebsiteCreationsTableViewController ()

@end

@implementation WebsiteCreationsTableViewController
@synthesize websiteCreationsArray;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle.
-(void)viewDidAppear:(BOOL)animated {
    
    
    websiteCreation = [[WebsiteCreation alloc] init];
    
    NSLog(@"WebsiteCreationsTableViewController - view will appear website creations array: %@", websiteCreationsArray);
    for (int i=0; i<[websiteCreationsArray count]; i++) {
        websiteCreation = websiteCreationsArray[i];
        NSLog(@"%@",websiteCreation.title);
    }
    [self.tableView reloadData];}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of rows in the section.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [websiteCreationsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    websiteCreation = [websiteCreationsArray objectAtIndex:indexPath.row];
    NSLog(@"Creation title: %@", websiteCreation.title);

    //Set up the cell
    cell.textLabel.text = websiteCreation.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int row = (int)[indexPath row];
    
    NSLog(@"row in didSelectRowAtIndexPath: %i", row);
    [[Singleton sharedSingleton] setnewrownumber:row];
    
    websiteCreation = [websiteCreationsArray objectAtIndex:[indexPath row]];
    NSLog(@"website title chosen: %@", websiteCreation.title);
    
    
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"websiteCreationList"]) {
        // Get destination view controller and don't forget
        // to cast it to the right class
        WebsiteCreationViewController *websiteCreationViewController = [segue destinationViewController];
        // Pass data
        websiteCreationViewController.websiteCreationsArray = websiteCreationsArray;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
