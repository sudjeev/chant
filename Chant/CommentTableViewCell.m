//
//  CommentTableViewCell.m
//  Chant
//
//  Created by Sudjeev Singh on 8/20/14.
//  Copyright (c) 2014 SudjeevSingh. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Flairs.h"

@implementation CommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

-(void) updateViewWithItem: (CommentData*) comment
{
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    if([comment isEqual:nil])
    {
        NSLog(@"dis bitch is empty");
        return;
    }
    
    
    self.commentData = comment;
    self.text.text = comment.text;
    self.upvotes.text = [comment.upvotes stringValue];
    self.username.text = comment.username;
    
    
    PFQuery* query = [PFQuery queryWithClassName:@"userData"];
    [query whereKey:@"username" equalTo:self.commentData.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error)
     {
         if(!error)
         {
             for (PFObject* object in objects)
             {
                 if (object[@"Team"] != nil) {
                     //self.logo.image = [self.dictionary objectForKey:object[@"Team"]];
                     self.logo.image = [[Flairs allFlairs].dict objectForKey:object[@"Team"]];
                 }
                 else
                 {
                     self.logo.image = [UIImage imageNamed:@"jordan.jpg"];
                 }
             }
         }
         else
         {
             NSLog(@"error looking up user in userData");
         }
     }];
}

-(IBAction)onUpvote:(id)sender
{
    //also need to change the image of the button so it looks upvoted
    //or change the color of the cell
    //we dont need to worry about the case of not have objectID for your own comment because you can upvote your own comment
   
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //generate a key unique to this comment to use for NSUserDefaults
    NSString* key = [NSString stringWithFormat:@"%@%@", self.commentData.gameId, self.commentData.objectId];
    NSLog(@"entered this bithc");
    NSLog(@"fuck this %@",key);
    

    if([self.commentData.username isEqualToString:[PFUser currentUser].username] || [defaults objectForKey:key] != nil)
    {
        //cant upvote your own comment
        NSLog(@"already upvoted this");
        return;
    }
    
    //if it doesnt already exist in our defaults then we can add it and upvote the comment
    NSLog(@"first time upvoting");
    [defaults setBool:YES forKey:key];
    
    NSLog(@"got past saving in defaults");
    
    self.commentData.upvotes = [[NSNumber alloc] initWithInt:[self.commentData.upvotes intValue] + 1];
    self.upvotes.text =  [self.commentData.upvotes stringValue];

    
    PFQuery* query = [PFQuery queryWithClassName:self.commentData.gameId];
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
    
    PFQuery* upvoteUser = [PFQuery queryWithClassName:@"userData"];
    [upvoteUser whereKey:@"username" equalTo:self.commentData.username];
    [upvoteUser findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
    {
        if(!error)
        {
            for (PFObject* object in objects)
            {
                [object incrementKey:@"totalUpvotes"];
                [object saveInBackground];
            }
        }
        else
        {
            NSLog(@"%@",[error userInfo][@"error"]);
        }
    }];

}

- (IBAction)onReply:(id)sender
{
    NSString *notification = @"ReplyNotification";
    NSString *key = @"CommentValue";
    NSDictionary *info = [NSDictionary dictionaryWithObject:self.commentData forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil userInfo:info];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
