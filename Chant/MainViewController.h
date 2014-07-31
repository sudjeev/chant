//
//  MainViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 7/30/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView* tView;
@property (strong, nonatomic) IBOutlet UITextView* commentBox;

@end
