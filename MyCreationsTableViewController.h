//
//  MyCreationsTableViewController.h
//  Creativity
//
//  Created by Andrew Newman on 7/5/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#define kFilename	@"creating.sqlite3"

@interface MyCreationsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableCreations;
    sqlite3 *database;
    NSString *query;
    NSMutableArray *tableData;
    NSString *nameChosen;
    int rowNumber;
}

@end
