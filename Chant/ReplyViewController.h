//
//  ReplyViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 11/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CommentData.h"
#import "ReplyData.h"
#import "ReplyCommentCell.h"
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"


@interface ReplyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
- (void) updateViewWithCommentData: (CommentData*) comment;
@property (nonatomic, weak) IBOutlet UIView* replyView;
@property (nonatomic, weak) IBOutlet UIView* commentView;
@property (nonatomic, weak) IBOutlet UIImageView* userFlair;
@property (nonatomic, weak) IBOutlet UILabel* username;
@property (nonatomic, weak) IBOutlet UITextView* comment;
@property (nonatomic, weak) IBOutlet UILabel* upvotes;
@property (nonatomic, weak) IBOutlet UITextField* replyBox;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* replies;
@property (strong, nonatomic) NSDictionary* dictionary;
@property (strong, nonatomic) CommentData* myCommentData;

- (IBAction)upvote:(id)sender;


- (IBAction)onReply:(id) sender;


@end
