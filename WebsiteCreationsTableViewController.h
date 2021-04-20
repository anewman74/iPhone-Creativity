//
//  WebsiteCreations.h
//  Creativity
//
//  Created by Andrew Newman on 7/20/14.
//  Copyright (c) 2014 Andrew Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebsiteCreation.h"

@interface WebsiteCreationsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableCreations;
    NSArray* websiteCreationsArray;
    WebsiteCreation *websiteCreation;
}
@property (nonatomic, strong) NSArray* websiteCreationsArray;

@end
