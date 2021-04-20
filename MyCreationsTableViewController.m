//
//  MyCreationsTableViewController.m
//  Creativity
//
//  Created by Andrew Newman on 7/5/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import "MyCreationsTableViewController.h"
#import "Singleton.h"

@interface MyCreationsTableViewController ()

@end

@implementation MyCreationsTableViewController

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
	
	tableData = 0;
	tableData = [[NSMutableArray alloc] init]; //initialize the array
    
	// Open database
	if(sqlite3_open([[[Singleton sharedSingleton] dataFilePath] UTF8String], &database) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database");
	}
	
	char *errorMsg;
    
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS creations (row integer primary key, poemTitle varchar(25), poemText text, dateDouble double, dateString varchar(25));";
    
	if(sqlite3_exec(database, [createSQL UTF8String],NULL,NULL,&errorMsg) != SQLITE_OK){
		sqlite3_close(database);
		NSAssert1(0,@"Error creating table: %s", errorMsg);
    }
    
    query = @"SELECT poemTitle FROM creations ORDER BY dateDouble DESC;";
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, nil) == SQLITE_OK){
        while(sqlite3_step(statement) == SQLITE_ROW){
            [tableData addObject:[NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)]];
        }
        sqlite3_finalize(statement);
    }
    
    NSLog(@"list of poem titles from MyCreations View Controller: %@", tableData);
    
	[self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tableData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
	//Set up the cell
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int row = (int)[indexPath row];
	row = row+1;
	int count = (int)[tableData count];
    
    NSLog(@"row in didSelectRowAtIndexPath: %i", row);
	
	for (int i=1; i<count+1; i++) {
		if(row == i)
		{
            nameChosen = [tableData objectAtIndex:indexPath.row];
            
            NSLog(@"name chosen: %@",nameChosen);
            
            // I have to get a correct row number from the database for this poem title.
            query = [[NSString alloc] initWithFormat: @"SELECT row FROM creations where poemTitle = '%@' limit 1",nameChosen];
            
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
		}
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
