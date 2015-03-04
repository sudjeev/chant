//
//  ReplyCommentCell.h
//  Chant
//
//  Created by Sudjeev Singh on 10/24/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ReplyData.h"

@interface ReplyCommentCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView* view;
@property (strong, nonatomic) ReplyData* data;
@property (strong, nonatomic) IBOutlet UITextView* comment;
@property (strong, nonatomic) IBOutlet UILabel* username;
@property (strong, nonatomic) IBOutlet UILabel* upvotes;
@property (strong, nonatomic) IBOutlet UIImageView* flair;
-(void) updateViewWithItem:(ReplyData*) data;
@end
