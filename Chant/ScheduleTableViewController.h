//
//  ScheduleTableViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 9/3/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@end
