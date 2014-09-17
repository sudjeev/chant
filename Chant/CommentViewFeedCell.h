//
//  CommentViewFeedCell.h
//  Chant
//
//  Created by Sudjeev Singh on 9/15/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CommentTableViewCell.h"
#import "GameData.h"

@interface CommentViewFeedCell : UICollectionViewCell<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView* feed;
@property (nonatomic, strong) IBOutlet UITextField* commentBox;
@property (nonatomic, strong) GameData* data;
@property (nonatomic, strong) NSMutableArray* tableData;

- (void)setupWithGameData:(GameData*) data;

-(IBAction)onComment:(id)sender;

@end