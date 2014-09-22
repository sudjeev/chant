//
//  CommentTableViewCell.m
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

-(void) updateViewWithItem: (CommentData*) comment
{
    if([comment isEqual:nil])
    {
        NSLog(@"dis bitch is empty");
        return;
    }
    
    self.commentData = comment;
    self.text.text = comment.text;
    self.upvotes.text = [comment.upvotes stringValue];
    self.username.text = comment.username;
}

-(IBAction)onUpvote:(id)sender
{
    //also need to change the image of the button so it looks upvoted
    //or change the color of the cell
    //we dont need to worry about the case of not have objectID for your own comment because you can upvote your own comment
    
    if([self.commentData.username isEqualToString:[PFUser currentUser].username] || self.commentData.upvoted)
    {
        //cant upvote your own comment
        return;
    }
    
    self.commentData.upvotes = [[NSNumber alloc] initWithInt:[self.commentData.upvotes intValue] + 1];
    self.upvotes.text =  [self.commentData.upvotes stringValue];
    
    PFQuery* query = [PFQuery queryWithClassName:@"Comments"];
    [query getObjectInBackgroundWithId:self.commentData.objectId block:^(PFObject *thisComment, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        if(!error)
        {
            [thisComment incrementKey:@"Upvotes"];
            [thisComment saveInBackground];
        }
        else
        {
            NSLog(@"%@",[error userInfo][@"error"]);
        }
    }];
    
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
