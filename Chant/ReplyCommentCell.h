//
//  ReplyCommentCell.h
//  Chant
//
//  Created by Sudjeev Singh on 10/24/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentData.h"

@interface ReplyCommentCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView* view;
@property (strong, nonatomic) CommentData* data;
@property (strong, nonatomic) IBOutlet UITextView* comment;
@property (strong, nonatomic) IBOutlet UILabel* username;
-(void) updateViewWithItem:(CommentData*) data;
@end
