//
//  ReplyViewController.h
//  Chant
//
//  Created by Sudjeev Singh on 11/11/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentData.h"

@interface ReplyViewController : UIViewController
- (void) updateViewWithCommentData: (CommentData*) comment;
@property (nonatomic, weak) IBOutlet UIView* replyView;
@property (nonatomic, weak) IBOutlet UIView* commentView;
@end
