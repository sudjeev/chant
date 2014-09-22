//
//  CommentTableViewCell.h
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CommentData.h"

@interface CommentTableViewCell : UITableViewCell
@property (nonatomic, strong) CommentData* commentData;
@property (nonatomic, strong) IBOutlet UILabel* text;
@property (nonatomic, strong) IBOutlet UILabel* username;
@property (nonatomic, strong) IBOutlet UILabel* upvotes;
-(void) updateViewWithItem: (NSString*) comment;
- (IBAction)onUpvote:(id)sender;

@end
