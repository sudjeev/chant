//
//  ReplyViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 10/24/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplyCommentCell.h"
#import "CommentData.h"

@interface ReplyViewController : UITableViewController
@property (nonatomic, strong) CommentData* data;

-(void) updateViewWithItem:(CommentData*) data;
@end
