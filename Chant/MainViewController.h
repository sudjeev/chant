//
//  MainViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 7/30/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField* commentBox;
@property (strong, nonatomic) IBOutlet UIButton* comment;
@property (strong, nonatomic) NSMutableArray *tableData;

- (IBAction)onComment:(id)sender;
@end
